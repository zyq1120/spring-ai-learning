-- pgvector 初始化（docker 首次启动时执行）
-- Spring AI 的 PgVectorStore 在应用启动时会自动建 vector_store 表，
-- 这里只负责打开扩展。
CREATE EXTENSION IF NOT EXISTS vector;
