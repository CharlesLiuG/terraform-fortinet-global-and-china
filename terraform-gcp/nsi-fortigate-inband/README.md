# GCP NSI In-band + FortiGate v7.6.6 跨可用区部署

## 架构说明

```
┌─────────────────────────────────────────────────────────────────┐
│                        Same GCP Project                          │
│                                                                  │
│  ┌─────────────────────────────┐  ┌───────────────────────────┐ │
│  │     Consumer VPC            │  │     Producer VPC           │ │
│  │     (10.20.0.0/24)          │  │     (10.10.0.0/24)         │ │
│  │                             │  │                            │ │
│  │  ┌───────────────────────┐  │  │  ┌──────────────────────┐ │ │
│  │  │ Workload VMs          │  │  │  │ FortiGate-A (zone-a) │ │ │
│  │  └───────────────────────┘  │  │  └──────────────────────┘ │ │
│  │                             │  │  ┌──────────────────────┐ │ │
│  │  Endpoint Group ──────────────▶│  │ FortiGate-B (zone-b) │ │ │
│  │  + Firewall Policy          │  │  └──────────────────────┘ │ │
│  │  (apply_security_profile)   │  │         ▲                 │ │
│  │                             │  │    ILB (UDP:6081)          │ │
│  │                             │  │    Deployment Group        │ │
│  └─────────────────────────────┘  └───────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 文件结构

| 文件 | 说明 |
|------|------|
| `main.tf` | Provider 配置 |
| `variables.tf` | 变量定义 |
| `network.tf` | Producer VPC + Consumer VPC |
| `fortigate.tf` | FortiGate VM 实例 (跨 AZ) |
| `ilb.tf` | Internal Load Balancer (GENEVE UDP:6081) |
| `nsi.tf` | NSI Intercept Deployment Group / Deployment / Endpoint Group |
| `firewall_policy.tf` | Security Profile + Firewall Policy 规则 |
| `firewall.tf` | VPC 防火墙规则 (健康检查 + GENEVE) |
| `outputs.tf` | 输出 |

## 使用方法

```bash
cp terraform.tfvars.example terraform.tfvars
# 编辑 terraform.tfvars 填入实际值

terraform init
terraform plan
terraform apply
```

## 注意事项

1. **FortiGate 镜像名称**：请通过 `gcloud compute images list --project=fortigcp-project-001 --filter="name~fgt-766"` 确认实际可用的 v7.6.6 镜像名称。

2. **NSI 资源需要 google-beta provider**：Intercept Deployment 等资源目前在 `google-beta` provider 中提供。

3. **Organization ID**：Security Profile 和 Security Profile Group 需要在组织级别创建。如果没有组织，需要调整 `parent` 为项目级别。

4. **FortiGate GENEVE 配置**：部署后需要在 FortiGate 上完成 GENEVE 隧道的详细配置，包括策略路由等。metadata 中的 bootstrap 仅为示例。

5. **健康检查端口**：FortiGate 默认使用 8008 端口作为探测端口，请确认与您的 FortiGate 配置一致。
