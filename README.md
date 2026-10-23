# spring-ai-learning

Spring AI 12 周学习项目：从单轮聊天起步，逐步完成多轮对话与持久化、RAG 知识库、
Tool Calling、MCP Server、多步骤 Agent 与工厂权限隔离，最终 Docker 部署验收。

- Java 21 ｜ Spring Boot 4.1.1 ｜ Spring AI 2.0.2 ｜ Maven 3.9+
- 业务背景结合 SAP / MDM / SRM 经验：物料、采购订单、质量规则三组模拟数据（1070 / 1080 两厂）

## 第 1 周完成标准

从 Apifox 发送请求 → Spring Boot 接收 → Spring AI 调用模型 → 响应返回 Apifox。
仓库已备好项目骨架与 `/ai/chat` 接口，你只需完成本机工具安装与 API Key 配置。

## 快速开始

### 1. 本机环境（自行安装）

- [ ] JDK 21（配置 `JAVA_HOME`）
- [ ] IntelliJ IDEA
- [ ] Maven 3.9+
- [ ] Git
- [ ] Apifox 或 Postman
- [ ] Docker Desktop（第 4 周起才真正用到）

自检：

```bash
bash scripts/check-env.sh
java -version && mvn -version && git --version && docker --version
```

### 2. 配置大模型 API Key

复制 `.env.example` 为 `.env` 并填入自己的 Key（或在 IDEA 运行配置里逐项设置环境变量）：

```yaml
AI_PROVIDER: openai            # 服务商标识（记录用）
AI_BASE_URL: https://api.openai.com   # 服务商的 OpenAI 兼容接口地址
AI_API_KEY:  只放本地环境变量，绝不提交到 Git
AI_MODEL:    gpt-4o-mini       # 服务商支持的模型 ID
```

初期选一个兼容 Spring AI 的服务商即可。换服务商只改 `AI_BASE_URL` 与 `AI_MODEL`
（仍为 OpenAI 兼容接口时连 Starter 都不用换）。

### 3. 启动与测试

```bash
mvn spring-boot:run
```

```bash
curl -X POST http://localhost:8080/ai/chat \
  -H 'Content-Type: application/json' \
  -d '{"message":"你好，请介绍一下你自己"}'
# 期望返回：{"reply":"...","model":"gpt-4o-mini"}
```

Apifox 中新建 POST 请求 `http://localhost:8080/ai/chat`，Body 选 JSON 填同样内容即可。

**浏览器前端**：启动后直接打开 `http://localhost:8080/` —— 仓库自带一个极简聊天页
（`src/main/resources/static/index.html`，原生 HTML/JS、零构建），可发消息、显示模型名、
切换新会话，页面内的示例问题对应种子数据与知识库内容。后端接入会话记忆后，
前端会自动带上 conversationId。

不依赖真实 Key 的链路测试（Mock 模型）已包含在仓库里：

```bash
mvn test    # AiChatControllerTest 验证 请求 -> Spring AI -> 响应 整条链路
```

## 项目结构

```text
spring-ai-learning/
├── pom.xml
├── docker-compose.yml          # MySQL / Redis / pgvector（第 4-7 周）
├── db/
│   ├── mysql/                  # 建表 DDL + 三组业务种子数据（容器首次启动自动执行）
│   └── postgres/               # pgvector 扩展初始化
├── scripts/check-env.sh        # 环境自检
├── spring-ai-mcp-server/       # 第 9 周 MCP Server 独立模块（当前占位）
└── src/
    ├── main/java/com/example/ai/
    │   ├── AiApplication.java
    │   ├── controller/         # AiChatController：POST /ai/chat
    │   ├── service/            # AiChatService
    │   ├── config/             # 后续周次放配置类
    │   ├── domain/dto、vo/     # ChatRequest / ChatResponse
    │   └── tool/               # 第 8 周放 @Tool 工具类
    ├── main/resources/
    │   ├── application.yml     # 全部参数走环境变量
    │   ├── static/index.html   # 极简聊天前端（原生 HTML/JS，无构建）
    │   └── knowledge/          # RAG 模拟文档 6 份（第 5-7 周）
    └── test/
```

## 中间件与数据（第 4-7 周）

```bash
docker compose up -d           # MySQL 8 / Redis 7 / PostgreSQL+pgvector 一次拉起
```

- MySQL：`localhost:3306`，库 `spring_ai_learning`，账号 `springai / springai123`（root 为 `springai_root`，仅本地学习用）。首次启动自动执行 `db/mysql/` 下的建表与种子数据。
- Redis：`localhost:6379`，无密码（仅本地）。
- pgvector：`localhost:5432`，库 `spring_ai_knowledge`，账号 `postgres / springai123`，扩展已在初始化脚本中打开；Spring AI 的 PgVectorStore 会自动建 `vector_store` 表。

AI 业务表（`ai_conversation`、`ai_chat_message`、`ai_document`、`ai_tool_call_log`、`ai_model_usage`）是学习项目的建议设计，已随 DDL 一并建好，不是框架强制要求。

## 业务种子数据（第 8 周 Tool Calling 用）

| 表 | 内容 | 规模 |
|---|---|---|
| `demo_material` | 物料主数据（1070 / 1080 两厂，含 1 条已置删除标志的旧型号） | 20 条 |
| `demo_purchase_order` | 采购订单头（五种状态齐全） | 10 张 |
| `demo_purchase_order_line` | 采购订单行（含已交货完成、部分交货、逻辑删除行） | 27 行 |
| `demo_quality_rule` | 质量检验规则（含 1 条已停用的旧标准） | 15 条 |

**Tool Calling 验证问题（第 8 周逐个验收）：**

1. 查询 1080 工厂的全部物料。
2. 查询指定物料的基本信息。
3. 查询某采购订单的全部订单行。
4. 查询某物料对应的质量检验规则。
5. 查询已经完成交货的采购订单行。

## RAG 知识库文档（第 5-7 周用）

`src/main/resources/knowledge/` 下 6 份虚构制度文档，口径与种子数据一致
（工厂 1070/1080、物料组、订单状态、权限模型互相引用，可直接用来验证
RAG 回答是否引用了正确的制度条款）：

1. `01_企业采购管理制度.md`（分级审批、禁止无单收货、超交拒收）
2. `02_物料主数据管理规范.md`（编码规则、删除标志语义）
3. `03_采购订单变更操作说明.md`（数量变更下限、超交比例、关闭流程）
4. `04_质量检验管理制度.md`（按工厂+物料组匹配启用规则）
5. `05_工厂与租户权限说明.md`（用户—工厂授权、AI 工具同样受限）
6. `06_常见问题FAQ.md`

真实公司制度与业务文档未经授权不得接入外部模型，本仓库文档全部为虚构。

## 分周路线

| 周 | 主题 | 仓库准备情况 |
|---|---|---|
| 1 | 环境 + 项目骨架 + 单轮聊天 | ✅ 已备齐（本机工具与 Key 需自备） |
| 2-3 | 多轮对话、会话记忆 | 接口已预留 `conversationId` |
| 4 | MySQL + MyBatis-Plus、聊天记录持久化、Redis | docker-compose 与 DDL 已备 |
| 5-7 | RAG：pgvector + 文档入库 + 检索 + 来源展示 | 文档与 pgvector 已备 |
| 8 | Tool Calling | 三组种子数据 + 验证问题已备 |
| 9 | MCP Server | 独立模块占位（见其 README） |
| 10-11 | Agent + 工厂权限与租户隔离 | 权限口径已写入知识库文档 05 |
| 12 | 验收：日志、Token 统计、Docker 部署、集成测试 | 用量表 `ai_model_usage` 已备 |

## 注意事项

- API Key 只通过环境变量注入，`.env` 已被 `.gitignore` 排除；提交前请再检查一次暂存区。
- 本地学习口令（docker-compose 内）仅用于本机，不要带到任何真实环境。
- 版本组合为本仓库锁定验证的搭配：Spring Boot 4.1.1 + Spring AI 2.0.2 + Java 21，升级时先查 Spring AI 官方兼容表。
