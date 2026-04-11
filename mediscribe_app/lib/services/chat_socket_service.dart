import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatSocketService {
  static IO.Socket? _socket;
  static bool _isConnected = false;
  static String? _currentUserId;

  /// Initialize socket connection
  static void initialize(String userId) {
    if (_socket != null && _isConnected) {
      print('[ChatSocket] Already connected');
      return;
    }

    _currentUserId = userId;
    print('[ChatSocket] Initializing socket for user: $userId');

    // Dispose existing socket if any
    if (_socket != null) {
      print('[ChatSocket] Disposing old socket connection');
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
    }

    _socket = IO.io(
      'https://mediscribeapp.onrender.com',
      <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionDelay': 1000,
        'reconnectionAttempts': 5,
        'timeout': 10000,
      },
    );

    _socket!.onConnect((_) {
      print('[ChatSocket] ✅ Connected to server');
      _isConnected = true;
      _socket!.emit('register', userId);
    });

    _socket!.onDisconnect((_) {
      print('[ChatSocket] ❌ Disconnected from server');
      _isConnected = false;
    });

    _socket!.onConnectError((error) {
      print('[ChatSocket] ⚠️ Connection error: $error');
    });

    _socket!.onError((error) {
      print('[ChatSocket] ❌ Error: $error');
    });
    
    _socket!.onReconnect((_) {
      print('[ChatSocket] 🔄 Reconnected to server');
      _isConnected = true;
      _socket!.emit('register', userId);
    });
    
    _socket!.onReconnectError((error) {
      print('[ChatSocket] ⚠️ Reconnect error: $error');
    });
  }

  /// Join a chat room
  static void joinChat(String appointmentId) {
    if (_socket == null) {
      print('[ChatSocket] ❌ Socket not initialized, cannot join chat');
      return;
    }
    
    if (!_isConnected) {
      print('[ChatSocket] ⚠️ Not connected yet, will join when connected');
      // Try to join after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (_isConnected) {
          print('[ChatSocket] Joining chat after reconnection: $appointmentId');
          _socket!.emit('join-chat', {'appointmentId': appointmentId});
        }
      });
      return;
    }

    print('[ChatSocket] Joining chat: $appointmentId');
    _socket!.emit('join-chat', {'appointmentId': appointmentId});
  }

  /// Leave a chat room
  static void leaveChat(String appointmentId) {
    if (_socket == null) return;

    print('[ChatSocket] Leaving chat: $appointmentId');
    _socket!.emit('leave-chat', {'appointmentId': appointmentId});
  }

  /// Send a message
  static void sendMessage({
    required String appointmentId,
    required String text,
    required String senderName,
    required String senderRole,
  }) {
    if (_socket == null) {
      print('[ChatSocket] ❌ Socket not initialized, cannot send message');
      return;
    }
    
    if (!_isConnected) {
      print('[ChatSocket] ⚠️ Not connected, message may not be delivered');
    }

    print('[ChatSocket] Sending message to $appointmentId');
    print('[ChatSocket] Message: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
    
    _socket!.emit('send-message', {
      'appointmentId': appointmentId,
      'text': text,
      'senderName': senderName,
      'senderRole': senderRole,
    });
  }

  /// Listen for incoming messages
  static void onMessageReceived(Function(Map<String, dynamic>) callback) {
    if (_socket == null) {
      print('[ChatSocket] Socket not initialized');
      return;
    }

    _socket!.on('receive-message', (data) {
      print('[ChatSocket] Received message');
      if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  /// Check if connected
  static bool get isConnected => _isConnected;

  /// Disconnect
  static void dispose() {
    if (_socket != null) {
      print('[ChatSocket] Disposing socket connection');
      _socket!.disconnect();
      _socket = null;
      _isConnected = false;
    }
  }
}
