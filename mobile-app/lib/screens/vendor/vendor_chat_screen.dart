import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class VendorChatScreen extends StatefulWidget {
  const VendorChatScreen({super.key});

  @override
  State<VendorChatScreen> createState() => _VendorChatScreenState();
}

class _VendorChatScreenState extends State<VendorChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ApiService _api = ApiService.instance;

  void _sendCustomQuote() {
    showDialog(
      context: context,
      builder: (context) {
        final quoteAmount = TextEditingController(text: '35000');
        final quoteNotes = TextEditingController(text: 'Includes extra 4 hours drone coverage & 1 additional candid shooter');

        return AlertDialog(
          title: const Text('Send Custom Price Quote', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quoteAmount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Offered Price (INR)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: quoteNotes,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Custom Scope / Add-on terms'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _api.sendChatMessage('📄 CUSTOM QUOTE GENERATED: ₹${quoteAmount.text}\nTerms: ${quoteNotes.text}');
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Custom quote sent to client!')),
                );
              },
              child: const Text('Send Quote'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: Rahul Sharma', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            Text('Booking: SS-2026001 (Nov 4th, Delhi)', style: TextStyle(fontSize: 11, color: AppTheme.primaryCrimson, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.request_quote_rounded, color: AppTheme.primaryCrimson),
            tooltip: 'Generate Custom Quote',
            onPressed: _sendCustomQuote,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Response Templates
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: AppTheme.surfaceBg,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickReply('Yes, drone team confirmed!'),
                  _buildQuickReply('What is the Varmala timing?'),
                  _buildQuickReply('Sending our senior cinematographer.'),
                ],
              ),
            ),
          ),

          // Message Bubbles
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _api.chatMessages.length,
              itemBuilder: (context, index) {
                final msg = _api.chatMessages[index];
                final isVendorSender = !msg.isMe; // For vendor perspective

                return Align(
                  alignment: isVendorSender ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isVendorSender ? AppTheme.slateDark : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isVendorSender ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isVendorSender ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.messageText,
                          style: TextStyle(
                            color: isVendorSender ? Colors.white : AppTheme.slateDark,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            msg.timestamp,
                            style: TextStyle(
                              color: isVendorSender ? Colors.white70 : AppTheme.slateMuted,
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

          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.request_quote_rounded, color: AppTheme.primaryCrimson),
                  tooltip: 'Add Custom Quote',
                  onPressed: _sendCustomQuote,
                ),
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'Reply to client...',
                      filled: true,
                      fillColor: AppTheme.surfaceBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    onPressed: () {
                      final text = _msgController.text.trim();
                      if (text.isEmpty) return;
                      setState(() {
                        _api.sendChatMessage(text);
                        _msgController.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReply(String text) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _api.sendChatMessage(text);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
        ),
      ),
    );
  }
}
