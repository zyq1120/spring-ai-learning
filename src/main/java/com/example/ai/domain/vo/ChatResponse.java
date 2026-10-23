package com.example.ai.domain.vo;

/**
 * 聊天响应 VO。
 *
 * @param reply 模型回复内容
 * @param model 实际使用的模型 ID（来自配置 AI_MODEL）
 */
public record ChatResponse(String reply, String model) {
}
