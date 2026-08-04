# Cloud WAN + FortiGate GWLB 多 Region 流量检查

基于 AWS Cloud WAN Service Insertion + GWLB + FortiGate FGSP（Active-Active）实现 Singapore / Tokyo 双 Region East-West 流量强制经过 FortiGate 检测。

---

## 架构概览

```
┌──────────── Singapore (ap-southeast-1) ──────┐      ┌──────────── Tokyo (ap-northeast-1) ───────────┐
│                                               │      │                                               │
│  Spoke A VPC    Spoke B VPC    Security VPC   │      │  Security VPC    Spoke A VPC    Spoke B VPC   │
│  10.2.0.0/16   10.3.0.0/16    10.1.0.0/16    │      │  10.11.0.0/16   10.12.0.0/16   10.13.0.0/16  │
│                                ┌──────────┐   │      │  ┌──────────┐                                │
│                                │ cwan-sub │   │      │  │ cwan-sub │                                │
│                                │ gwlbe-sub│   │      │  │ gwlbe-sub│                                │
│                                │ GWLB     │   │      │  │ GWLB     │                                │
│                                │ FGT×2 AA │   │      │  │ FGT×2 AA │                                │
│                                └──────────┘   │      │  └──────────┘                                │
└──────┬──────────────┬──────────────┬──────────┘      └──────┬──────────────┬──────────────┬──────────┘
       │              │              │                         │              │              │
       │ VPC attach   │ VPC attach   │ VPC attach (NFG)       │ VPC attach   │ VPC attach   │ VPC attach
       │ (production) │ (production) │ (inspectionVpcs)       │(inspectionV) │ (production) │ (production)
       └──────────────┴──────────────┼────────────────────────┼──────────────┴──────────────┘
                                     │                        │
                         AWS Cloud WAN Core Network
                         ┌─────────────────────────────────────┐
                         │  Segment: production (isolated)      │
                         │  NFG: inspectionVpcs                 │
                         │  Policy: send-via single-hop         │
                         └─────────────────────────────────────┘
```

---

## CIDR 规划

| VPC | Singapore | Tokyo |
|-----|-----------|-------|
| Security | 10.1.0.0/16 | 10.11.0.0/16 |
| Spoke A | 10.2.0.0/16 | 10.12.0.0/16 |
| Spoke B | 10.3.0.0/16 | 10.13.0.0/16 |

### Security VPC 子网分配

| 子网 | 用途 | AZ1 | AZ2 |
|------|------|------|------|
| external | FortiGate port1，出站 NAT | .1.0/24 | .2.0/24 |
| internal | FortiGate port2 + GWLB ENI | .3.0/24 | .4.0/24 |
| HA | FortiGate port3，FGSP session-sync | .5.0/24 | .6.0/24 |
| mgmt | FortiGate port4，管理 EIP | .7.0/24 | .8.0/24 |
| cwan | Cloud WAN attachment | .9.0/24 | .10.0/24 |
| gwlbe | GWLB Endpoint | .11.0/24 | .12.0/24 |

---

## FortiGate 设计

| 项目 | 说明 |
|------|------|
| HA 模式 | FGSP（Standalone Cluster）Active-Active |
| 实例类型 | c6i.xlarge |
| FortiOS | 7.6.7 |
| License | BYOL (FortiFlex) |
| port1 | External，独立 EIP，出站 NAT 上网 |
| port2 | Internal，GWLB GENEVE target |
| port3 | HA，session-sync（UDP 703 / TCP 702） |
| port4 | Management，dedicated-to management，独立 EIP |

### GENEVE 配置（自动通过 SSH provisioning）

- gwlb-az1 / gwlb-az2 隧道指向 GWLB ENI IP
- zone: gwlb-geneve（intrazone allow）
- router policy: 对称路由（从哪个口进从哪个口出）
- firewall policy: gwlb-inspection（东西向）+ gwlb-to-internet（南北向 NAT）

---

## Cloud WAN Policy 设计

```
Segment:        production (isolate-attachments: true)
NFG:            inspectionVpcs
segment-actions:
  - send-via: production → * via inspectionVpcs (single-hop)
  - send-to:  production via inspectionVpcs
attachment-policies:
  - tag inspection=true → NFG inspectionVpcs
  - tag domain=production → production segment
```

### single-hop 路由行为

跨区域流量按 Cloud WAN ordered list 选择固定一个 NFG 区域。当前使用 `edge-override` 让 Singapore edge 使用本地 NFG：

| 流量方向 | 经过检查 |
|---------|---------|
| SG Spoke → SG Spoke | SG FortiGate ✅ |
| TKY Spoke → TKY Spoke | TKY FortiGate ✅ |
| SG Spoke → TKY Spoke | TKY FortiGate ✅ |
| TKY Spoke → SG Spoke | TKY FortiGate（ordered list 限制） |

> 详见 [docs/cloud_wan_routing_design.md](docs/cloud_wan_routing_design.md)

---

## 流量路径

### East-West（Spoke 间）

```
Spoke A → Cloud WAN production segment
  → Security VPC cwan-subnet
  → GWLBE (gwlbe-subnet)
  → GWLB (internal-subnet)
  → FortiGate port2 (GENEVE 6081) 检查
  → GWLB → GWLBE
  → cwan-subnet → Cloud WAN
  → 目的 Spoke
```

### North-South（Spoke 上网）

```
Spoke → Cloud WAN → Security VPC → GWLBE → GWLB → FortiGate 检查
  → FortiGate port1 NAT → IGW → Internet
```

---

## 前提条件

- AWS 账号已启用 Cloud WAN
- 每个目标 Region 有 EC2 Key Pair（`lg-vwan`）
- FortiGate AMI 可用（Marketplace 订阅）
- FortiFlex 序列号（BYOL）
- Terraform >= 1.5.0, AWS Provider ~> 5.0
- `sshpass` 已安装（GENEVE provisioning 需要）

---

## 部署

```bash
vim terraform.tfvars    # 编辑密码、keypair、FortiFlex SN
terraform init
terraform apply
```

---

## 部署后验证

### 获取测试实例

```bash
aws ec2 describe-instances --region ap-southeast-1 \
  --filters "Name=tag:Name,Values=*spoke*test*" \
  --query "Reservations[].Instances[].{Id:InstanceId,IP:PrivateIpAddress,Name:Tags[?Key=='Name'].Value|[0]}" \
  --output table
```

### SSM 登录测试

```bash
aws ssm start-session --target <instance-id> --region ap-southeast-1
```

### 连通性测试

```bash
# 上网
ping 8.8.8.8 -c 3
curl ifconfig.me          # 显示 FortiGate port1 EIP

# 同区域 East-West
ping 10.3.1.x -c 3       # SG Spoke-A → SG Spoke-B

# 跨区域 East-West
ping 10.12.1.x -c 3      # SG Spoke-A → TKY Spoke-A
```

### FortiGate 验证

```bash
ssh admin@<mgmt-eip>

# 集群状态
diagnose sys standalone-cluster peer-info

# GENEVE 流量抓包
diagnose sniffer packet gwlb-az1 'icmp' 4 10

# 防火墙策略命中
get firewall policy
```

### Cloud WAN 路由表检查

```bash
CORE_ID="core-network-00ca862b87a76e619"
GN_ID="global-network-06a1d383beb42817a"

aws networkmanager get-network-routes \
  --global-network-id $GN_ID \
  --route-table-identifier "CoreNetworkSegmentEdge={CoreNetworkId=$CORE_ID,SegmentName=production,EdgeLocation=ap-southeast-1}" \
  --region us-west-2 \
  --query "NetworkRoutes[].{Dest:DestinationCidrBlock,Type:Type,Attachment:Destinations[0].ResourceId}" \
  --output table
```

---

## 项目结构

```
cloudwan-sg-tky/
├── providers.tf                 # Provider aliases
├── variables.tf                 # var.regions map + 全局变量
├── terraform.tfvars             # 参数值
├── locals.tf                    # name_prefix, region_keys, remote_spoke_cidrs
├── cloud_wan.tf                 # Global/Core Network + Policy (NFG + send-via)
├── cloud_wan_attachments.tf     # VPC attachments (for_each)
├── cloud_wan_routes.tf          # 0.0.0.0/0 → core network 路由（依赖 attachment）
├── main.tf                      # Module blocks (Singapore + Tokyo)
├── moved.tf                     # attachment 重命名的 state 迁移
├── outputs.tf
├── docs/
│   └── cloud_wan_routing_design.md   # 路由设计说明与限制分析
└── modules/region/
    ├── variables.tf             # region_config 对象 + 部署开关
    ├── data_sources.tf          # AMI, AZ
    ├── sec_vpc.tf               # Security VPC (6 子网 × 2 AZ + 路由表)
    ├── spoke_vpcs.tf            # Spoke VPC + test instances (for_each)
    ├── fortigates.tf            # FortiGate 4-port FGSP instances
    ├── gwlb.tf                  # GWLB + Target Group + GWLBE
    ├── geneve_provisioning.tf   # SSH provisioner 配置 GENEVE
    ├── userdata.tf              # FortiOS bootstrap 模板渲染
    ├── security_groups.tf
    ├── eips.tf                  # 每台 FortiGate 独立 external + mgmt EIP
    ├── iam.tf
    ├── ssm.tf                   # Spoke VPC SSM Endpoints（可选）
    ├── moved.tf                 # 模块内资源重命名的 state 迁移
    ├── vpc_endpoint.tf
    ├── outputs.tf
    └── templates/
        ├── fgt_primary.tpl
        └── fgt_secondary.tpl
```

---

## 部署耗时优化

以下为相对初版的改动，目标是缩短 apply 的关键路径。

| 项 | 改动 | 说明 |
|----|------|------|
| 3 | 去掉 `time_sleep.wait_for_cwan`（每 region 固定 180s） | core network 路由移到 root 的 `cloud_wan_routes.tf`，直接引用 `aws_networkmanager_vpc_attachment`。provider 的 `waitVPCAttachmentAvailable` 已经会阻塞到 attachment AVAILABLE，因此这是精确依赖而非估算等待 |
| 4 | GWLB ENI 查询由 `description = "*ELB gwy/*"` + `depends_on` 改为精确匹配 `"ELB ${aws_lb.gwlb.arn_suffix}"` | 读取 `arn_suffix` 天然形成对 GWLB 的依赖（无需 `depends_on`，否则 read 会被推迟到 apply 阶段、令 GENEVE trigger 在 plan 时未知）；并加 `postcondition`，匹配为空时立刻报错，而不是把空 `remote-ip` 写进 FortiGate |
| 5 | 12 个 SSM Interface Endpoint 改为 `var.enable_ssm_endpoints` 控制，默认 `false` | 每个 endpoint 创建 2–4 分钟。关闭后测试机仍可用 keypair 经 Cloud WAN SSH 访问 |
| 6 | root 模块每 region 由 ~55 行参数缩为 ~10 行 | 模块入参收敛为单个 `region_config` 对象（原 22 个变量）；6 个 attachment 资源收敛为 2 个 `for_each` 资源 |
| 7 | 路由内联、路由表合并、`for_each` 收敛关联 | 默认路由写在 `aws_route_table` 的 `route` block 内，省去独立 `aws_route` 的额外图节点与 API 往返；`sec_internal` / `sec_ha` 两张空路由表合并为 `sec_private`；12 条关联与 spoke 资源改为 `for_each` |

未改动：第 1、2 项（GENEVE provisioner 的 `sleep 600` 与两份重复脚本）。`sleep` 值已提取为
`var.fortigate_boot_wait`（默认仍为 600），可按镜像实际启动时间下调。

`main.tf` 仍是每 region 一个 module block：provider alias 必须静态指定，当前 Terraform
（v1.14）尚不支持 `provider` 的 `for_each`（`for_each` 在 provider block 中是保留字）。

### 迁移已有 state

新目录不含 `terraform.tfstate`。若要接管现有环境，先复制 state，再 apply：

```bash
cp ~/cloudwan-sg-tky/terraform.tfstate ~/cloudwan-sg-tky-opt/
cd ~/cloudwan-sg-tky-opt && terraform init && terraform plan
```

`moved.tf` 已覆盖同类型改名（VPC / 子网 / 实例 / 路由表 / attachment），这些不会重建。
但以下会出现 destroy + create，**请先 review plan 再 apply**：

- `aws_route.spoke_{a,b}_default`、`aws_route.sec_gwlbe_to_cwan` → `aws_route.cwan_default[...]`
- `aws_route.sec_public_default`、`aws_route.sec_cwan_to_gwlbe` → 内联进各自路由表
- `aws_route_table.sec_ha` → 合并进 `sec_private`（HA 子网重新关联）
- SSM endpoints → 默认删除，需保留请设 `enable_ssm_endpoints = true`

路由的 destroy/create 之间有短暂无默认路由的窗口，会中断该子网的转发；生产环境建议先在测试环境走一遍。

---

## 新增 Region

1. `terraform.tfvars` 的 `regions` map 添加新 entry
2. `providers.tf` 添加 provider alias
3. `main.tf` 添加 module block（复制现有块，改 key 与 provider alias）
4. `cloud_wan_attachments.tf` 的 `local.region_modules` 与 `local.region_route_targets` 各加一个 entry

---

## 参考资料

- [AWS: Cloud WAN Service Insertion](https://docs.aws.amazon.com/network-manager/latest/cloudwan/cloudwan-policy-service-insertion.html)
- [AWS Blog: Simplify Global Security Inspection with Cloud WAN Service Insertion](https://aws.amazon.com/blogs/networking-and-content-delivery/simplify-global-security-inspection-with-aws-cloud-wan-service-insertion/)
- [Fortinet: AWS Cloud WAN Service Insertion with FortiGate](https://community.fortinet.com/t5/FortiGate-VM-on-AWS-Discussions/AWS-Cloud-WAN-Service-Insertion-with-FortiGate/td-p/357490)
