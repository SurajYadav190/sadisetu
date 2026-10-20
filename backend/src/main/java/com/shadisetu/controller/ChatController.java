package com.shadisetu.controller;

import com.shadisetu.entity.User;
import com.shadisetu.payload.ApiResponse;
import com.shadisetu.payload.ChatMessageDto;
import com.shadisetu.service.ChatService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
public class ChatController {

    @Autowired
    private ChatService chatService;

    @GetMapping("/api/chat/history")
    public ResponseEntity<ApiResponse<List<ChatMessageDto>>> getChatHistory(
            @AuthenticationPrincipal User user,
            @RequestParam Long otherUserId) {
        return ResponseEntity.ok(ApiResponse.ok(chatService.getConversation(user.getId(), otherUserId)));
    }

    @GetMapping("/api/chat/booking/{bookingId}")
    public ResponseEntity<ApiResponse<List<ChatMessageDto>>> getBookingChat(@PathVariable Long bookingId) {
        return ResponseEntity.ok(ApiResponse.ok(chatService.getBookingChat(bookingId)));
    }

    @PostMapping("/api/chat/send")
    public ResponseEntity<ApiResponse<ChatMessageDto>> sendChatMessage(
            @AuthenticationPrincipal User user,
            @RequestBody ChatMessageDto dto) {
        return ResponseEntity.ok(ApiResponse.ok(chatService.sendMessage(user.getId(), dto)));
    }

    // STOMP WebSocket endpoint mapping
    @MessageMapping("/chat.sendMessage")
    public void handleWebSocketMessage(@Payload ChatMessageDto dto) {
        chatService.sendMessage(dto.getSenderId(), dto);
    }
}
