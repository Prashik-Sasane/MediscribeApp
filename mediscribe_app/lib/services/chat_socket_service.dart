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

    _socket = IO.io(
      'https://mediscribeapp.onrender.com',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      },
    );

    _socket!.onConnect((_) {
      print('[ChatSocket] Connected to server');
      _isConnected = true;
      _socket!.emit('register', userId);
    });

    _socket!.onDisconnect((_) {
      print('[ChatSocket] Disconnected from server');
      _isConnected = false;
    });

    _socket!.onConnectError((error) {
      print('[ChatSocket] Connection error: $error');
    });

    _socket!.onError((error) {
      print('[ChatSocket] Error: $error');
    });
  }

  /// Join a chat room
  static void joinChat(String appointmentId) {
    if (_socket == null || !_isConnected) {
      print('[ChatSocket] Not connected, cannot join chat');
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
    if (_socket == null || !_isConnected) {
      print('[ChatSocket] Not connected, cannot send message');
      return;
    }

    print('[ChatSocket] Sending message to $appointmentId');
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
