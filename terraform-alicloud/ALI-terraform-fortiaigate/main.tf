# ─────────────────────────────────────────────────────────────────────────────
# 可选: 创建 ACK 集群 + GPU Node Pool (自动创建 VPC/VSwitch)
# ─────────────────────────────────────────────────────────────────────────────
module "ack" {
  count  = var.create_ack ? 1 : 0
  source = "./modules/ack"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_cidr        = var.vpc_cidr
  region          = var.region
  instance_type   = var.gpu_instance_type
  desired_size    = var.gpu_node_pool_desired
}

# ─────────────────────────────────────────────────────────────────────────────
# 自动生成 kubeconfig（集群创建后立即可用，不依赖 deploy_app）
# ─────────────────────────────────────────────────────────────────────────────
resource "null_resource" "kubeconfig" {
  count = var.create_ack ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p ~/.kube
      aliyun cs GET /k8s/${module.ack[0].cluster_id}/user_config --region ${var.region} | jq -r '.config' > ~/.kube/config
      cp ~/.kube/config ${path.module}/.kubeconfig
      echo "kubeconfig generated successfully."
    EOT
  }

  depends_on = [module.ack]
}

# ─────────────────────────────────────────────────────────────────────────────
# 可选: 创建 NAS 文件系统
# ─────────────────────────────────────────────────────────────────────────────
module "nas" {
  count  = var.create_nas ? 1 : 0
  source = "./modules/nas"

  vpc_id     = var.create_ack ? module.ack[0].vpc_id : data.alicloud_vpcs.cluster[0].vpcs[0].id
  vswitch_id = var.create_ack ? module.ack[0].vswitch_ids[0] : data.alicloud_vswitches.cluster[0].vswitches[0].id
}

# 使用已有 ACK 时，获取集群所在 VPC 和 VSwitch
data "alicloud_vpcs" "cluster" {
  count = !var.create_ack ? 1 : 0
  ids   = [data.alicloud_cs_clusters.this[0].clusters[0].vpc_id]
}

data "alicloud_vswitches" "cluster" {
  count  = !var.create_ack ? 1 : 0
  vpc_id = data.alicloud_vpcs.cluster[0].vpcs[0].id
}

# ─────────────────────────────────────────────────────────────────────────────
# 解析 NAS ID（从新建或已有）
# ─────────────────────────────────────────────────────────────────────────────
locals {
  nas_id           = var.create_nas ? module.nas[0].nas_id : var.nas_id
  nas_mount_target = var.create_nas ? module.nas[0].mount_target_domain : var.nas_mount_target
  # ALB 所需的 VSwitch IDs（至少 2 个不同可用区）
  alb_vswitch_ids  = var.create_ack ? module.ack[0].vswitch_ids : [for vs in data.alicloud_vswitches.cluster[0].vswitches : vs.id]
}

# ─────────────────────────────────────────────────────────────────────────────
# GPU 节点自动发现
# ─────────────────────────────────────────────────────────────────────────────
data "alicloud_instances" "gpu_nodes" {
  count = var.deploy_app ? 1 : 0
  tags = {
    "ack.aliyun.com" = local.cluster_id
  }
  status = "Running"
}

# ─────────────────────────────────────────────────────────────────────────────
# License 文件与 GPU 节点绑定
# ─────────────────────────────────────────────────────────────────────────────
locals {
  license_dir   = "${path.module}/charts/files/licenses"
  license_files = sort(tolist(fileset(local.license_dir, "*.lic")))

  _auto_gpu_nodes = var.deploy_app ? sort([
    for inst in try(data.alicloud_instances.gpu_nodes[0].instances, []) : "${inst.region_id}.${inst.private_ip}"
  ]) : []

  gpu_node_names = length(local._auto_gpu_nodes) > 0 ? local._auto_gpu_nodes : (var.gpu_node_name != "" ? [var.gpu_node_name] : [])

  node_license_map = {
    for i, node in local.gpu_node_names :
    node => "files/licenses/${local.license_files[i]}"
    if i < length(local.license_files)
  }

  gpu_node_name = var.gpu_node_name != "" ? var.gpu_node_name : (length(local.gpu_node_names) > 0 ? local.gpu_node_names[0] : "")
}

# ─────────────────────────────────────────────────────────────────────────────
# Namespace
# ─────────────────────────────────────────────────────────────────────────────
resource "kubernetes_namespace" "fortiaigate" {
  count = var.deploy_app ? 1 : 0
  metadata {
    name = var.namespace
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# ACR Credential Helper 配置（确保所有 namespace 免密拉镜像）
# ─────────────────────────────────────────────────────────────────────────────
resource "null_resource" "acr_credential_config" {
  count = var.deploy_app ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      # 安装 alb-ingress-controller（如果不存在）
      aliyun cs POST /clusters/${local.cluster_id}/components/install --header "Content-Type=application/json" --body '[{"name":"alb-ingress-controller"}]' 2>/dev/null || true
      # 安装 acr-credential-helper（如果不存在）
      aliyun cs POST /clusters/${local.cluster_id}/components/install --header "Content-Type=application/json" --body '[{"name":"aliyun-acr-credential-helper"}]' 2>/dev/null || true
      sleep 15
      # 配置 watch 所有 namespace
      kubectl patch configmap acr-configuration -n kube-system --type merge \
        -p '{"data":{"watch-namespace":"all","service-account":"*","acr-registry-info":"[{\"instanceId\":\"cri-trdfajgsnkbtpthu\",\"regionId\":\"cn-wulanchabu\"}]"}}' 2>/dev/null || true
      kubectl rollout restart deployment aliyun-acr-credential-helper -n kube-system 2>/dev/null || true

      # 等待 credential helper 就绪
      echo "Waiting for acr-credential-helper to be ready..."
      kubectl rollout status deployment/aliyun-acr-credential-helper -n kube-system --timeout=120s 2>/dev/null || true

      # 等待 helper 为目标 namespace 注入 imagePullSecret（最多等待 90 秒）
      echo "Waiting for imagePullSecret injection in namespace ${var.namespace}..."
      for i in $(seq 1 18); do
        SECRETS=$(kubectl get sa default -n ${var.namespace} -o jsonpath='{.imagePullSecrets[*].name}' 2>/dev/null)
        if [ -n "$SECRETS" ]; then
          echo "imagePullSecret injected: $SECRETS"
          break
        fi
        echo "  attempt $i/18 - not yet injected, waiting 5s..."
        sleep 5
      done
    EOT
  }

  depends_on = [kubernetes_namespace.fortiaigate]
}

# ─────────────────────────────────────────────────────────────────────────────
# ALB Config — managed by ALB Ingress Controller
# HTTPS listener + certificate 通过 kubectl 配置:
#   kubectl patch albconfig alb --type merge -p '{"spec":{"listeners":[{"port":443,"protocol":"HTTPS","certificates":[{"certificateId":"<cert-id>"}]}]}}'
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# NAS StorageClasses
# ─────────────────────────────────────────────────────────────────────────────
resource "kubernetes_storage_class" "nas_sc" {
  count = (var.deploy_app && var.create_nas_storage_class) ? 1 : 0
  metadata { name = "nas-sc" }
  storage_provisioner    = "nasplugin.csi.alibabacloud.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true
  parameters = {
    volumeAs       = "subpath"
    fileSystemId   = local.nas_id
    server         = local.nas_mount_target
    pathSuffix     = "fortiaigate"
    dirPermissions = "0775"
  }
  mount_options = ["vers=3", "nolock"]
  depends_on    = [kubernetes_namespace.fortiaigate]
}

resource "kubernetes_storage_class" "nas_sc_db" {
  count = (var.deploy_app && var.create_nas_storage_class) ? 1 : 0
  metadata { name = "nas-sc-db" }
  storage_provisioner    = "nasplugin.csi.alibabacloud.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true
  parameters = {
    volumeAs       = "subpath"
    fileSystemId   = local.nas_id
    server         = local.nas_mount_target
    pathSuffix     = "fortiaigate-db"
    dirPermissions = "0775"
  }
  mount_options = ["vers=3", "nolock"]
  depends_on    = [kubernetes_namespace.fortiaigate]
}

# ─────────────────────────────────────────────────────────────────────────────
# NVIDIA Device Plugin (ACK GPU 节点池通常已自带，按需安装)
# ─────────────────────────────────────────────────────────────────────────────
resource "helm_release" "nvidia_device_plugin" {
  count      = var.install_nvidia_device_plugin ? 1 : 0
  name       = "nvidia-device-plugin"
  repository = "https://nvidia.github.io/k8s-device-plugin"
  chart      = "nvidia-device-plugin"
  version    = "0.17.0"
  namespace  = "kube-system"

  depends_on = [module.ack]
}

# ─────────────────────────────────────────────────────────────────────────────
# Helm Release
# ─────────────────────────────────────────────────────────────────────────────
resource "helm_release" "fortiaigate" {
  count     = var.deploy_app ? 1 : 0
  name      = var.helm_release_name
  namespace = var.namespace
  chart     = "${path.module}/charts"

  values = [file("${path.module}/charts/values.yaml")]

  # 动态注入所有 node:license 绑定
  dynamic "set" {
    for_each = local.node_license_map
    content {
      name  = "global.licenses.${replace(set.key, ".", "\\.")}"
      value = set.value
    }
  }

  set {
    name  = "ingress.certificateId"
    value = var.certificate_id
    type  = "string"
  }
  set {
    name  = "ingress.host"
    value = var.ingress_host
  }
  set {
    name  = "ingress.zoneMappings[0].vSwitchId"
    value = local.alb_vswitch_ids[0]
  }
  set {
    name  = "ingress.zoneMappings[1].vSwitchId"
    value = local.alb_vswitch_ids[1]
  }

  wait            = true
  wait_for_jobs   = true
  timeout         = 900
  force_update    = false
  cleanup_on_fail = true

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "Pre-destroy: removing PVC/PV finalizers to prevent hang..."
      kubectl get pvc -n ${self.namespace} -o name 2>/dev/null | xargs -I {} kubectl patch {} -n ${self.namespace} -p '{"metadata":{"finalizers":null}}' --type=merge 2>/dev/null || true
      kubectl get pv -o json 2>/dev/null | \
        jq -r '.items[] | select(.spec.claimRef.namespace=="${self.namespace}") | .metadata.name' | \
        xargs -I {} kubectl patch pv {} -p '{"metadata":{"finalizers":null}}' --type=merge 2>/dev/null || true
      echo "Finalizers removed."
    EOT
  }

  depends_on = [
    module.nas,
    kubernetes_storage_class.nas_sc,
    kubernetes_storage_class.nas_sc_db,
    helm_release.nvidia_device_plugin,
    null_resource.acr_credential_config,
  ]
}
