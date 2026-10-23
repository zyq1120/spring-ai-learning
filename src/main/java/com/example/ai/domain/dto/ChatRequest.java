package com.example.ai.domain.dto;

/**
 * 聊天请求 DTO。
 *
 * @param message        用户输入的问题
 * @param conversationId 会话 ID（第 2 周多轮对话时使用，第 1 周可不传）
 */
public record ChatRequest(String message, String conversationId) {
}
