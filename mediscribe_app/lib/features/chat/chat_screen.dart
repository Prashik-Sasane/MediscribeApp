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
    try {
      print('[Chat] Initializing chat...');
      
      // Get current user name from AppState
      final appState = AppScope.of(context);
      _currentUserName = appState.currentUser?.name ?? 'User';
      print('[Chat] Current user: $_currentUserName');

      // Initialize socket FIRST
      if (appState.currentUser?.email != null) {
        print('[Chat] Initializing socket for: ${appState.currentUser!.email}');
        ChatSocketService.initialize(appState.currentUser!.email);
        ChatSocketService.onConnectionChanged((_) {
          if (mounted) setState(() {});
        });
        ChatSocketService.joinChat(widget.appointmentId);
        ChatSocketService.onMessageReceived(_onNewMessage);
      } else {
        print('[Chat] Warning: No user email available');
      }

      // Load messages (with timeout)
      await _loadMessages();
      
      print('[Chat] Initialization complete');
    } catch (e) {
      print('[Chat] Error during initialization: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _onNewMessage(Map<String, dynamic> message) {
    print('[Chat] New message received via socket: ${message['text']}');
    
    if (mounted) {
      setState(() {
        messages.add(message);
      });
      
      _scrollToBottom();

      // Show notification if message is from other person
      final isFromMe = widget.isDoctor
          ? message['senderRole'] == 'doctor'
          : message['senderRole'] == 'patient';

      if (!isFromMe) {
        NotificationService.addNotification(
          title: widget.isDoctor
              ? 'New Message from Patient'
              : 'New Message from Dr. ${widget.doctorName}',
          message: message['text'] ?? 'New message',
          type: NotificationType.info,
        );
      }
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
      print('[Chat] Appointment ID: ${widget.appointmentId}');


      const baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://mediscribeapp.onrender.com/api',
      );
      
      final response = await http
          .get(
            Uri.parse('$baseUrl/chat/${widget.appointmentId}'),
            headers: {'Authorization': 'Bearer ${widget.token}'},
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('[Chat] API request timeout after 10 seconds');
              throw Exception('Request timeout');
            },
          );

      print('[Chat] API Response status: ${response.statusCode}');
      print('[Chat] API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            if (data != null && data['messages'] != null) {
              messages = List<Map<String, dynamic>>.from(data['messages']);
              print('[Chat] Loaded ${messages.length} messages');
            } else {
              messages = [];
              print('[Chat] No messages found');
            }
            _loading = false;
          });
          _scrollToBottom();
        }
      } else if (response.statusCode == 403) {
        print('[Chat] Forbidden - User not authorized for this chat');
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You do not have access to this chat')),
          );
        }
      } else if (response.statusCode == 404) {
        print('[Chat] Chat not found');
        if (mounted) {
          setState(() => _loading = false);
          messages = [];
        }
      } else {
        print('[Chat] Unexpected status code: ${response.statusCode}');
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load messages (${response.statusCode})')),
          );
        }
      }
    } catch (e) {
      print('[Chat] Error loading messages: $e');
      if (mounted) {
        setState(() => _loading = false);
        
        // Show user-friendly error
        String errorMessage = 'Failed to load messages';
        if (e.toString().contains('timeout')) {
          errorMessage = 'Connection timeout. Please check your internet.';
        } else if (e.toString().contains('SocketException')) {
          errorMessage = 'No internet connection';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadMessages,
            ),
          ),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;

    print('[Chat] Sending message: $text');
    setState(() => _sending = true);

    try {
      const baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://mediscribeapp.onrender.com/api',
      );

      // 1) Persist via REST (so it won't "disappear")
      final resp = await http.post(
        Uri.parse('$baseUrl/chat/${widget.appointmentId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({'text': text}),
      );

      if (resp.statusCode != 201) {
        throw Exception('send failed: ${resp.statusCode} ${resp.body}');
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final msg = Map<String, dynamic>.from(data['message'] as Map);

      // 2) Update UI with the persisted message
      setState(() {
        messages.add(msg);
      });

      _messageController.clear();
      _scrollToBottom();

      // 3) Broadcast via socket for realtime delivery to the other party
      // (server will NOT save again when messageId is provided).
      final appState = AppScope.of(context);
      ChatSocketService.sendMessage(
        appointmentId: widget.appointmentId,
        text: msg['text'] ?? text,
        senderName: msg['senderName'] ?? (_currentUserName ?? 'User'),
        senderRole: msg['senderRole'] ?? (widget.isDoctor ? 'doctor' : 'patient'),
        messageId: msg['id']?.toString(),
        createdAt: msg['createdAt']?.toString(),
        senderId: appState.currentUser?.email,
      );
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
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: ChatSocketService.isConnected ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  ChatSocketService.isConnected ? 'Online' : 'Connecting...',
                  style: TextStyle(
                    color: ChatSocketService.isConnected ? Colors.green : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() => _loading = true);
              _loadMessages();
            },
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
