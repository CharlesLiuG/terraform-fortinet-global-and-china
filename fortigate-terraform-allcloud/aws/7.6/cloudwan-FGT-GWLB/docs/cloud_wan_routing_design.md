# Cloud WAN 流量检查路由设计说明

## 当前架构：Service Insertion（NFG + send-via single-hop）

### 工作原理

- Security VPC 的 Cloud WAN attachment 被标记为 `inspection=true`，归属于 Network Function Group (NFG) `inspectionVpcs`
- Production segment 设置 `isolate-attachments = true`，Spoke 之间不能直接通信
- `send-via single-hop` 策略强制 production segment 的流量经过 NFG（FortiGate）检查

### 已知限制

**single-hop 在跨区域场景下无法实现"目的端检查"：**

当两个区域都有 NFG 成员时，Cloud WAN 按 **ordered list**（内部区域优先级排序）**固定选择一个区域的 NFG** 处理所有跨区域流量。无法按目的 CIDR 动态选择不同区域的 NFG。

当前状态（使用 edge-override 让 SG 走本地后）：

| 流量方向 | 经过检查 | 说明 |
|---------|---------|------|
| SG Spoke → SG Spoke | SG FortiGate ✅ | 同区域本地检查 |
| TKY Spoke → TKY Spoke | TKY FortiGate ✅ | 同区域本地检查 |
| SG Spoke → TKY Spoke | TKY FortiGate ✅ | 目的端检查（ordered list 选 Tokyo）|
| TKY Spoke → SG Spoke | TKY FortiGate ❌ | 应走 SG，但 ordered list 固定选 Tokyo |

**AWS 文档原文确认：**
> Single hop — Traffic traverses a single intermediate attachment, using the deterministically preferred source or destination Region.
> If the Inspection VPC exists in both Regions, service insertion will deterministically choose which Region to use based on the default Region priority list.

`edge-override` 只能按 edge 粒度整体切换 NFG 选择，不能按"目的 CIDR"来区分。

### 可选模式对比

| 模式 | 效果 | 适用场景 |
|------|------|---------|
| single-hop | 跨区域流量固定走一个 NFG | 单区域检查或接受 ordered list 行为 |
| dual-hop | 两端 NFG 都检查 | 需要双重检查（延迟翻倍） |
| 传统静态路由 | 完全自定义路由下一跳 | 需要精确控制检查位置 |

---

## 替代方案：传统静态路由（不使用 Service Insertion）

如果需要精确控制"东京访问新加坡走新加坡 FortiGate，新加坡访问东京走东京 FortiGate"，需要放弃 service insertion，使用传统静态路由方式。

### 架构变更

| 项目 | Service Insertion 方式 | 传统静态路由方式 |
|------|----------------------|----------------|
| Sec VPC attachment 归属 | NFG（inspectionVpcs） | production segment |
| attachment tag | `inspection = "true"` | `domain = "production"` |
| 路由控制 | 自动 propagated（不可手动改） | 手动静态路由（Console 可编辑） |
| segment-actions | send-via + send-to | 不需要 |
| 新增 Spoke | 自动获得检查路由 | 需要手动加静态路由 |

### Console 配置步骤

#### 前提条件

1. 去掉 Cloud WAN policy 中的 `segment-actions`（send-via、send-to）
2. 去掉 `network-function-groups` 定义
3. 将 Sec VPC attachment 的 tag 从 `inspection=true` 改为 `domain=production`，使其加入 production segment
4. 保持 `isolate-attachments = true`（Spoke 之间仍然隔离，必须经过静态路由指定的中间 VPC）

#### 在 Console 中添加静态路由

1. 打开 **AWS Console → VPC → Network Manager → Core Networks**
2. 选择你的 Core Network
3. 点击 **Routing** tab
4. 选择 Segment: **production**

##### Singapore edge (ap-southeast-1) 路由配置：

| 目的 CIDR | 下一跳 Attachment | 说明 |
|-----------|------------------|------|
| 10.2.0.0/16 | Singapore Sec VPC attachment | SG Spoke-A → SG FortiGate（本地） |
| 10.3.0.0/16 | Singapore Sec VPC attachment | SG Spoke-B → SG FortiGate（本地） |
| 10.12.0.0/16 | Tokyo Sec VPC attachment | → TKY FortiGate（目的端检查） |
| 10.13.0.0/16 | Tokyo Sec VPC attachment | → TKY FortiGate（目的端检查） |

##### Tokyo edge (ap-northeast-1) 路由配置：

| 目的 CIDR | 下一跳 Attachment | 说明 |
|-----------|------------------|------|
| 10.12.0.0/16 | Tokyo Sec VPC attachment | TKY Spoke-A → TKY FortiGate（本地） |
| 10.13.0.0/16 | Tokyo Sec VPC attachment | TKY Spoke-B → TKY FortiGate（本地） |
| 10.2.0.0/16 | Singapore Sec VPC attachment | → SG FortiGate（目的端检查） |
| 10.3.0.0/16 | Singapore Sec VPC attachment | → SG FortiGate（目的端检查） |

#### 流量效果

| 流量方向 | 经过检查 |
|---------|---------|
| SG Spoke → SG Spoke | SG FortiGate ✅ |
| TKY Spoke → TKY Spoke | TKY FortiGate ✅ |
| SG Spoke → TKY Spoke | TKY FortiGate ✅ （目的端） |
| TKY Spoke → SG Spoke | SG FortiGate ✅ （目的端） |

### Terraform 代码变更要点

如果要用 Terraform 实现传统静态路由方案，需要修改：

1. **cloud_wan.tf** — 去掉 `network_function_groups`、`segment_actions`（send-via/send-to）
2. **cloud_wan_attachments.tf** — Sec VPC attachment tag 改为 `domain = "production"`
3. **cloud_wan.tf** — 添加 `segment_actions` 类型为 `create-route`，手动指定静态路由

示例 policy segment-actions：

```hcl
# Singapore edge: 去 TKY spoke 的流量 → TKY Sec VPC
segment_actions {
  action                  = "create-route"
  segment                 = "production"
  destination_cidr_blocks = ["10.12.0.0/16", "10.13.0.0/16"]
  destinations            = [aws_networkmanager_vpc_attachment.tokyo_sec.id]
}

# Tokyo edge: 去 SG spoke 的流量 → SG Sec VPC
segment_actions {
  action                  = "create-route"
  segment                 = "production"
  destination_cidr_blocks = ["10.2.0.0/16", "10.3.0.0/16"]
  destinations            = [aws_networkmanager_vpc_attachment.singapore_sec.id]
}
```

> **注意：** `create-route` 在 policy 中是全局的（所有 edge 都生效）。如果需要 per-edge 不同的路由，只能通过 Console 手动配置，Terraform policy document 不支持 per-edge 静态路由。

---

## 建议

- **Demo 演示**：保持当前 service insertion 方案，接受 TKY→SG 走 Tokyo FGT 的限制。两边 FortiGate 的安全策略配置相同即可保证安全效果一致。
- **需要精确目的端检查**：切换到传统静态路由方案，通过 Console 手动配置 per-edge 路由。
- **未来 AWS 更新**：关注 AWS Cloud WAN 是否会在 single-hop 中增加 per-destination 的 NFG 选择能力。
