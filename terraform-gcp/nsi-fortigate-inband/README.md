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

## License 模式

通过 `license_type` 变量选择许可证模式，支持 PAYG 和 BYOL 共存：

| 模式 | license_type | 说明 |
|------|-------------|------|
| PAYG（按需付费） | `payg` | 使用 on-demand 镜像，无需提供 license，费用含在 GCP 计费中 |
| BYOL（自带许可） | `file` | 使用 BYOL 镜像 + .lic 文件注入 |
| FortiFlex | `fortiflex` | 使用 BYOL 镜像 + VM Token 激活 |

### PAYG 模式（默认）

```hcl
license_type = "payg"
```

无需额外配置，自动使用 on-demand 镜像。

### BYOL - License 文件模式

```hcl
license_type   = "file"
license_file_a = "./licenses/fortigate-a.lic"
license_file_b = "./licenses/fortigate-b.lic"
```

### BYOL - FortiFlex Token 模式

```hcl
license_type      = "fortiflex"
fortiflex_token_a = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
fortiflex_token_b = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
```

> **注意**：切换 license_type 会更换 FortiGate 镜像（PAYG 用 `fgtondemand`，BYOL 用 `fgt`），需要 recreate 实例。

## 使用方法

```bash
cp terraform.tfvars.example terraform.tfvars
# 编辑 terraform.tfvars，选择 license_type 并填入对应参数

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
