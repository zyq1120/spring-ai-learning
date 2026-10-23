package com.example.ai.controller;

import com.example.ai.domain.dto.ChatRequest;
import com.example.ai.domain.vo.ChatResponse;
import com.example.ai.service.AiChatService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * AI 聊天接口。
 *
 * <pre>
 * POST /ai/chat
 * {"message": "你好，请介绍一下你自己"}
 * -&gt; {"reply": "...", "model": "..."}
 * </pre>
 */
@RestController
@RequestMapping("/ai")
public class AiChatController {

    private final AiChatService aiChatService;

    public AiChatController(AiChatService aiChatService) {
        this.aiChatService = aiChatService;
    }

    @PostMapping("/chat")
    public ChatResponse chat(@RequestBody ChatRequest request) {
        String reply = aiChatService.chat(request.message());
        return new ChatResponse(reply, aiChatService.model());
    }
}
