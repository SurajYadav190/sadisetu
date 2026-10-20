package com.shadisetu.service;

import com.shadisetu.entity.Booking;
import com.shadisetu.entity.ChatMessage;
import com.shadisetu.entity.User;
import com.shadisetu.payload.ChatMessageDto;
import com.shadisetu.repository.BookingRepository;
import com.shadisetu.repository.ChatMessageRepository;
import com.shadisetu.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ChatService {

    @Autowired
    private ChatMessageRepository chatMessageRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    public List<ChatMessageDto> getConversation(Long user1, Long user2) {
        return chatMessageRepository.findChatHistory(user1, user2).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public List<ChatMessageDto> getBookingChat(Long bookingId) {
        return chatMessageRepository.findByBookingIdOrderByTimestampAsc(bookingId).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public ChatMessageDto sendMessage(Long senderId, ChatMessageDto dto) {
        User sender = userRepository.findById(senderId)
                .orElseThrow(() -> new RuntimeException("Sender not found"));
        User receiver = userRepository.findById(dto.getReceiverId())
                .orElseThrow(() -> new RuntimeException("Receiver not found"));

        ChatMessage message = new ChatMessage();
        message.setSender(sender);
        message.setReceiver(receiver);
        if (dto.getBookingId() != null) {
            bookingRepository.findById(dto.getBookingId()).ifPresent(message::setBooking);
        }
        message.setMessageText(dto.getMessageText());
        message.setMediaUrl(dto.getMediaUrl());
        message.setMessageType(dto.getMessageType() != null ? dto.getMessageType() : "TEXT");
        message.setTimestamp(LocalDateTime.now());
        message = chatMessageRepository.save(message);

        ChatMessageDto responseDto = toDto(message);

        // Broadcast to WebSocket broker so recipient receives live push
        messagingTemplate.convertAndSend("/topic/messages/" + receiver.getId(), responseDto);

        return responseDto;
    }

    private ChatMessageDto toDto(ChatMessage entity) {
        ChatMessageDto dto = new ChatMessageDto();
        dto.setId(entity.getId());
        dto.setSenderId(entity.getSender().getId());
        dto.setSenderName(entity.getSender().getFullName());
        dto.setReceiverId(entity.getReceiver().getId());
        if (entity.getBooking() != null) {
            dto.setBookingId(entity.getBooking().getId());
        }
        dto.setMessageText(entity.getMessageText());
        dto.setMediaUrl(entity.getMediaUrl());
        dto.setMessageType(entity.getMessageType());
        dto.setTimestamp(entity.getTimestamp());
        return dto;
    }
}
