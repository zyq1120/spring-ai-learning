# spring-ai-mcp-server（第 9 周动工，当前占位）

把第 8 周在主工程里实现的业务查询，以 MCP Server 的形式独立暴露，
让任何 MCP Client（包括主工程的 Spring AI MCP Client）都能发现并调用。

## 计划开放的工具（只读）

| 工具名 | 说明 | 数据来源 |
|---|---|---|
| `getMaterialById` | 按物料编码 + 工厂查物料基本信息 | `demo_material` |
| `getPurchaseOrderById` | 按订单号查订单头 + 全部订单行 | `demo_purchase_order` / `demo_purchase_order_line` |
| `getQualityRulesByMaterial` | 按物料查其物料组在本工厂启用的质量规则 | `demo_quality_rule` |

初期只开放只读查询，**不开放新增、修改、删除**。工具执行前必须做工厂权限校验
（口径见主工程 `knowledge/05_工厂与租户权限说明.md`），并记录工具调用日志。

## 第 9 周开工清单

- [ ] 在本模块添加启动类与三个工具实现（复用主工程第 8 周的查询逻辑）
- [ ] 配置 MCP Server（名称、版本、工具列表暴露）
- [ ] 主工程配置 MCP Client，验证能发现工具列表
- [ ] 验证客户端调用工具并拿到结构化结果
- [ ] 增加参数校验与异常处理（物料不存在、无权限、订单不存在分别给出可理解的错误）
