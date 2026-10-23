import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/wedding_models.dart';
import '../../services/api_service.dart';

class CustomerChatScreen extends StatefulWidget {
  final String? vendorName;
  final BookingModel? booking;

  const CustomerChatScreen({
    super.key,
    this.vendorName,
    this.booking,
  });

  @override
  State<CustomerChatScreen> createState() => _CustomerChatScreenState();
}

class _CustomerChatScreenState extends State<CustomerChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _api = ApiService.instance;
  bool _isVendorTyping = false;

  final List<String> _quickPrompts = [
    'Confirm 4K Drone camera?',
    'What time will the team arrive?',
    'Is payment held in Safe Escrow?',
    'Please share raw photo timeline',
  ];

  @override
  void initState() {
    super.initState();
    // If opening for a specific booking and messages are empty, seed context
    if (widget.booking != null && _api.chatMessages.isEmpty) {
      _api.chatMessages.addAll([
        ChatMessageModel(
          id: 1,
          senderId: 4,
          senderName: widget.vendorName ?? 'Wedding Vendor',
          messageText: 'Namaste! We are honored to be part of your wedding celebrations. Your booking ${widget.booking!.bookingNumber} is logged in our system.',
          timestamp: '10:00 AM',
          isMe: false,
        ),
        ChatMessageModel(
          id: 2,
          senderId: 4,
          senderName: widget.vendorName ?? 'Wedding Vendor',
          messageText: 'All equipment including cameras, drone, and team assignments are being prepared. Let us know if you have specific ritual preferences!',
          timestamp: '10:02 AM',
          isMe: false,
        ),
      ]);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? prefilledText]) {
    final text = prefilledText ?? _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _api.sendChatMessage(text);
      if (prefilledText == null) {
        _msgController.clear();
      }
      _isVendorTyping = true;
    });

    _scrollToBottom();

    // Realistic automated vendor response simulation
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;

      final lower = text.toLowerCase();
      String replyText;
      if (lower.contains('drone')) {
        replyText = 'Yes! Our DGCA-licensed drone pilot and DJI 4K Cine kit are 100% confirmed for your grand entry and Varmala ceremonies.';
      } else if (lower.contains('time') || lower.contains('arrive') || lower.contains('when')) {
        replyText = 'Our full team arrives 1.5 hours prior to the shift to calibrate stage lighting and test wireless feeds at the venue.';
      } else if (lower.contains('pay') || lower.contains('escrow') || lower.contains('money') || lower.contains('price')) {
        replyText = 'Your funds are safely held under Shaadi Setu Escrow Guarantee. Payout is only released after you inspect and approve the deliverables.';
      } else if (lower.contains('raw') || lower.contains('photo') || lower.contains('album') || lower.contains('film')) {
        replyText = 'All raw 1500+ photos will be delivered via private cloud link within 48 hours of the event, followed by edited 4K teasers.';
      } else {
        replyText = 'Thank you for updating us! We have noted this in your event brief and will coordinate directly with the venue team.';
      }

      setState(() {
        _isVendorTyping = false;
        _api.chatMessages.add(
          ChatMessageModel(
            id: _api.chatMessages.length + 1,
            senderId: 4,
            senderName: widget.vendorName ?? 'Vendor Team',
            messageText: replyText,
            timestamp: 'Just now',
            isMe: false,
          ),
        );
      });

      _scrollToBottom();
    });
  }

  String get _vendorDisplayName => widget.vendorName ?? 'LensCraft Studios';

  String get _avatarInitials {
    final name = _vendorDisplayName.trim();
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, (name.length >= 2 ? 2 : 1)).toUpperCase() : 'VN';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.lightGold,
              child: Text(
                _avatarInitials,
                style: const TextStyle(color: AppTheme.primaryCrimson, fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _vendorDisplayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                  ),
                  const Row(
                    children: [
                      CircleAvatar(radius: 3, backgroundColor: AppTheme.successGreen),
                      SizedBox(width: 4),
                      Text(
                        'Online  •  Escrow Verified Vendor',
                        style: TextStyle(fontSize: 11, color: AppTheme.successGreen, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: AppTheme.primaryCrimson),
            tooltip: 'Call via Escrow Masked Dial',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connecting via Shaadi Setu secure privacy number...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Booking Context Header (if opened for a booking)
          if (widget.booking != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFF1F5F9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long_rounded, size: 16, color: AppTheme.primaryCrimson),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Booking ${widget.booking!.bookingNumber} • ₹${widget.booking!.totalAmount.toInt()} Escrow',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Safe Escrow',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF047857)),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              color: AppTheme.lightGold,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, size: 13, color: Color(0xFFB45309)),
                  SizedBox(width: 6),
                  Text(
                    'Direct chat with vendor protected under Shaadi Setu Escrow',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF78350F), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

          // Message Bubbles List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _api.chatMessages.length,
              itemBuilder: (context, index) {
                final msg = _api.chatMessages[index];
                return Align(
                  alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: msg.isMe ? AppTheme.primaryCrimson : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: msg.isMe ? const Radius.circular(16) : Radius.zero,
                        bottomRight: msg.isMe ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.messageText,
                          style: TextStyle(
                            color: msg.isMe ? Colors.white : AppTheme.slateDark,
                            fontSize: 13.5,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            msg.timestamp,
                            style: TextStyle(
                              color: msg.isMe ? Colors.white70 : AppTheme.slateMuted,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Typing indicator
          if (_isVendorTyping)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryCrimson),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_vendorDisplayName is typing...',
                    style: const TextStyle(fontSize: 11.5, color: AppTheme.slateMuted, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

          // Quick Suggestion Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: _quickPrompts.map((prompt) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(prompt),
                    labelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
                    backgroundColor: const Color(0xFFF8FAFC),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    onPressed: () => _sendMessage(prompt),
                  ),
                );
              }).toList(),
            ),
          ),

          // Chat Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file_rounded, color: AppTheme.slateMuted),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Attach venue photo, stage layout, or song list')),
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Type message or requirement...',
                      filled: true,
                      fillColor: AppTheme.surfaceBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.primaryCrimson,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: () => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
