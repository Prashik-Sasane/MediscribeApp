import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatSocketService {
  static IO.Socket? _socket;
  static bool _isConnected = false;
  static String? _currentUserId;
  static final Set<String> _pendingRooms = <String>{};
  static void Function(bool connected)? _onConnectionChanged;

  // Keep base URL consistent with the rest of the app.
  // Default matches production Render deployment.
  static const String _baseApiUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mediscribeapp.onrender.com/api',
  );

  static String _socketUrlFromApiBase(String apiBase) {
    // Expected: https://host/api  -> https://host
    final trimmed = apiBase.endsWith('/api')
        ? apiBase.substring(0, apiBase.length - 4)
        : apiBase;
    return trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
  }

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
      _socketUrlFromApiBase(_baseApiUrl),
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
      print('[ChatSocket]  Connected to server');
      _isConnected = true;
      _socket!.emit('register', userId);
      _onConnectionChanged?.call(true);

      // Join any rooms requested before we were connected.
      for (final apptId in _pendingRooms) {
        _socket!.emit('join-chat', {'appointmentId': apptId});
      }
    });

    _socket!.onDisconnect((_) {
      print('[ChatSocket] ❌ Disconnected from server');
      _isConnected = false;
      _onConnectionChanged?.call(false);
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
      _onConnectionChanged?.call(true);

      for (final apptId in _pendingRooms) {
        _socket!.emit('join-chat', {'appointmentId': apptId});
      }
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

    _pendingRooms.add(appointmentId);
    if (!_isConnected) {
      print('[ChatSocket] ⚠️ Not connected yet, will join when connected: $appointmentId');
      return;
    }

    print('[ChatSocket] Joining chat: $appointmentId');
    _socket!.emit('join-chat', {'appointmentId': appointmentId});
  }

  /// Leave a chat room
  static void leaveChat(String appointmentId) {
    if (_socket == null) return;

    print('[ChatSocket] Leaving chat: $appointmentId');
    _pendingRooms.remove(appointmentId);
    _socket!.emit('leave-chat', {'appointmentId': appointmentId});
  }

  /// Send a message
  static void sendMessage({
    required String appointmentId,
    required String text,
    required String senderName,
    required String senderRole,
    String? messageId,
    String? createdAt,
    String? senderId,
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
      if (messageId != null) 'messageId': messageId,
      if (createdAt != null) 'createdAt': createdAt,
      if (senderId != null) 'senderId': senderId,
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

  /// Notify UI about connection changes.
  static void onConnectionChanged(void Function(bool connected) callback) {
    _onConnectionChanged = callback;
  }

  /// Disconnect
  static void dispose() {
    if (_socket != null) {
      print('[ChatSocket] Disposing socket connection');
      _socket!.disconnect();
      _socket = null;
      _isConnected = false;
      _pendingRooms.clear();
      _onConnectionChanged?.call(false);
    }
  }
}
