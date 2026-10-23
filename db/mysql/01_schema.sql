-- ============================================================
-- spring_ai_learning 建表脚本（学习项目建议设计，非框架强制）
-- 执行顺序：docker 首次启动时由 /docker-entrypoint-initdb.d 按文件名顺序执行
-- 字符集统一 utf8mb4
-- ============================================================

-- ---------- AI 业务表（第 2-4 周起逐步使用） ----------

-- 会话基本信息
CREATE TABLE IF NOT EXISTS ai_conversation (
    id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    user_id     VARCHAR(64)  NOT NULL COMMENT '用户标识（第 10-11 周权限测试用）',
    title       VARCHAR(255) NULL     COMMENT '会话标题',
    model       VARCHAR(128) NULL     COMMENT '使用的模型 ID',
    create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_conv_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI 会话';

-- 用户和 AI 的聊天记录
CREATE TABLE IF NOT EXISTS ai_chat_message (
    id              BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    conversation_id BIGINT       NOT NULL COMMENT '会话 ID',
    role            VARCHAR(16)  NOT NULL COMMENT '角色：user / assistant / system',
    content         TEXT         NOT NULL COMMENT '消息内容',
    token_count     INT          NULL     COMMENT '本条消息估算 Token 数',
    create_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_msg_conv (conversation_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI 聊天记录';

-- 知识库文档信息（第 5-7 周 RAG 使用）
CREATE TABLE IF NOT EXISTS ai_document (
    id            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    file_name     VARCHAR(255) NOT NULL COMMENT '文档文件名',
    doc_type      VARCHAR(32)  NULL     COMMENT '文档类型：md / txt / pdf',
    chunk_count   INT          NULL     COMMENT '切分后的文本块数量',
    status        VARCHAR(16)  NOT NULL DEFAULT 'PENDING' COMMENT '状态：PENDING / INDEXED / FAILED',
    create_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='知识库文档';

-- 工具调用日志（第 8 周 Tool Calling 起使用，第 10-11 周做审计）
CREATE TABLE IF NOT EXISTS ai_tool_call_log (
    id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    user_id     VARCHAR(64)  NULL     COMMENT '调用用户',
    tool_name   VARCHAR(128) NOT NULL COMMENT '工具名',
    arguments   TEXT         NULL     COMMENT '调用参数（JSON）',
    result      TEXT         NULL     COMMENT '调用结果摘要',
    success     TINYINT      NOT NULL DEFAULT 1 COMMENT '是否成功：1 是 0 否',
    cost_ms     BIGINT       NULL     COMMENT '耗时（毫秒）',
    create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_tool_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='工具调用日志';

-- 模型调用量和 Token 使用记录（第 12 周统计用）
CREATE TABLE IF NOT EXISTS ai_model_usage (
    id                BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    model             VARCHAR(128) NOT NULL COMMENT '模型 ID',
    prompt_tokens     INT          NOT NULL DEFAULT 0 COMMENT '输入 Token',
    completion_tokens INT          NOT NULL DEFAULT 0 COMMENT '输出 Token',
    total_tokens      INT          NOT NULL DEFAULT 0 COMMENT '总 Token',
    create_time       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_usage_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='模型用量';

-- ---------- Tool Calling 模拟业务表（第 8 周使用） ----------

-- 物料主数据
CREATE TABLE IF NOT EXISTS demo_material (
    material_id    VARCHAR(32)  NOT NULL COMMENT '物料编码',
    material_name  VARCHAR(128) NOT NULL COMMENT '物料名称',
    plant_id       VARCHAR(16)  NOT NULL COMMENT '工厂编码：1070 / 1080',
    material_type  VARCHAR(32)  NULL     COMMENT '物料类型：原材料 / 半成品 / 成品 / 辅料',
    material_group VARCHAR(32)  NULL     COMMENT '物料组',
    unit           VARCHAR(16)  NULL     COMMENT '基本单位',
    del_flag       TINYINT      NOT NULL DEFAULT 0 COMMENT '删除标志：1 已删除',
    PRIMARY KEY (material_id, plant_id),
    KEY idx_material_plant (plant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='演示物料主数据';

-- 采购订单（头）
CREATE TABLE IF NOT EXISTS demo_purchase_order (
    po_id       VARCHAR(32) NOT NULL COMMENT '采购订单号',
    supplier_id VARCHAR(32) NOT NULL COMMENT '供应商编码',
    plant_id    VARCHAR(16) NOT NULL COMMENT '工厂编码',
    status      VARCHAR(32) NOT NULL COMMENT '订单状态：已创建 / 已下达 / 部分交货 / 交货完成 / 已关闭',
    create_time DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (po_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='演示采购订单';

-- 采购订单行
CREATE TABLE IF NOT EXISTS demo_purchase_order_line (
    po_id                   VARCHAR(32)   NOT NULL COMMENT '采购订单号',
    line_no                 INT           NOT NULL COMMENT '订单行号',
    material_id             VARCHAR(32)   NOT NULL COMMENT '物料编码',
    quantity                DECIMAL(14, 3) NOT NULL COMMENT '采购数量',
    delivered_quantity      DECIMAL(14, 3) NOT NULL DEFAULT 0 COMMENT '已交货数量',
    delete_flag             TINYINT       NOT NULL DEFAULT 0 COMMENT '删除标记',
    delivery_completed      TINYINT       NOT NULL DEFAULT 0 COMMENT '交货完成标记',
    over_delivery_tolerance DECIMAL(5, 2)  NOT NULL DEFAULT 0 COMMENT '超交比例（%）',
    PRIMARY KEY (po_id, line_no),
    KEY idx_line_material (material_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='演示采购订单行';

-- 质量检验规则
CREATE TABLE IF NOT EXISTS demo_quality_rule (
    rule_id             VARCHAR(32)  NOT NULL COMMENT '规则编码',
    plant_id            VARCHAR(16)  NOT NULL COMMENT '工厂编码',
    material_group      VARCHAR(32)  NOT NULL COMMENT '物料组',
    inspection_item     VARCHAR(128) NOT NULL COMMENT '检验项目',
    inspection_standard VARCHAR(255) NOT NULL COMMENT '检验标准',
    enabled             TINYINT      NOT NULL DEFAULT 1 COMMENT '是否启用',
    PRIMARY KEY (rule_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='演示质量检验规则';
