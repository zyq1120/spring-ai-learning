package com.example.ai.service;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * AI 聊天服务：第 1 周只做单轮问答，后续周次在这里叠加
 * 会话记忆（第 2 周）、RAG Advisor（第 5-7 周）与工具调用（第 8 周）。
 */
@Service
public class AiChatService {

    private final ChatClient chatClient;

    @Value("${spring.ai.openai.chat.options.model}")
    private String model;

    public AiChatService(ChatClient.Builder chatClientBuilder) {
        this.chatClient = chatClientBuilder.build();
    }

    /**
     * 单轮聊天：把用户问题发给模型，返回文本回复。
     */
    public String chat(String message) {
        return chatClient.prompt()
                .user(message)
                .call()
                .content();
    }

    public String model() {
        return model;
    }
}
