import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mediscribe_app/services/notification_service.dart';
import 'package:mediscribe_app/services/chat_socket_service.dart';
import 'package:mediscribe_app/core/app_state.dart';

class ChatScreen extends StatefulWidget {
  final String appointmentId;
  final String doctorName;
  final String token;
  final bool isDoctor;

  const ChatScreen({
    super.key,
    required this.appointmentId,
    required this.doctorName,
    required this.token,
    this.isDoctor = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Get current user name from AppState
    final appState = AppScope.of(context);
    _currentUserName = appState.currentUser?.name ?? 'User';

    // Load initial messages via API
    await _loadMessages();

    // Initialize socket and join chat room
    if (appState.currentUser?.email != null) {
      ChatSocketService.initialize(appState.currentUser!.email);
    }

    ChatSocketService.joinChat(widget.appointmentId);
    ChatSocketService.onMessageReceived(_onNewMessage);
  }

  void _onNewMessage(Map<String, dynamic> message) {
    print('[Chat] New message received via socket: ${message['text']}');
    
    setState(() {
      messages.add(message);
    });
    
    _scrollToBottom();

    // Show notification if message is from other person
    final isFromMe = widget.isDoctor
        ? message['senderRole'] == 'doctor'
        : message['senderRole'] == 'patient';

    if (!isFromMe && mounted) {
      NotificationService.addNotification(
        title: widget.isDoctor
            ? 'New Message from Patient'
            : 'New Message from Dr. ${widget.doctorName}',
        message: message['text'] ?? 'New message',
        type: NotificationType.info,
      );
    }
  }

  @override
  void dispose() {
    ChatSocketService.leaveChat(widget.appointmentId);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      print('[Chat] Loading messages from API...');
      final response = await http.get(
        Uri.parse('https://mediscribeapp.onrender.com/api/chat/${widget.appointmentId}'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data != null && data['messages'] != null) {
            messages = List<Map<String, dynamic>>.from(data['messages']);
            print('[Chat] Loaded ${messages.length} messages');
          } else {
            messages = [];
          }
          _loading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      print('[Chat] Error loading messages: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;

    print('[Chat] Sending message: $text');
    setState(() => _sending = true);

    try {
      // Send via Socket.IO for real-time delivery
      ChatSocketService.sendMessage(
        appointmentId: widget.appointmentId,
        text: text,
        senderName: _currentUserName ?? 'User',
        senderRole: widget.isDoctor ? 'doctor' : 'patient',
      );

      // Optimistic UI update
      setState(() {
        messages.add({
          'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
          'text': text,
          'senderName': _currentUserName ?? 'User',
          'senderRole': widget.isDoctor ? 'doctor' : 'patient',
          'createdAt': DateTime.now().toIso8601String(),
        });
      });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      print('[Chat] Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isDoctor ? 'Patient Chat' : 'Dr. ${widget.doctorName}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Text(
              'Online',
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7DFF)))
                : messages.isEmpty
                    ? const Center(
                        child: Text(
                          'No messages yet\nStart the conversation!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg['senderRole'] == (widget.isDoctor ? 'doctor' : 'patient');
                          return _buildMessageBubble(msg['text'] ?? '', isMe, msg['senderName'] ?? '');
                        },
                      ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF2E7DFF),
                  child: IconButton(
                    icon: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sending ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String senderName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF2E7DFF),
              child: Text(
                senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF2E7DFF) : const Color(0xFF1E293B),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
