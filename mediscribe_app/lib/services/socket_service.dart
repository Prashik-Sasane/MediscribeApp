import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static late IO.Socket socket;

  static void init(String userId) {
    socket = IO.io('https://mediscribeapp.onrender.com/', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print("Socket connected");
      socket.emit('register', userId);
    });
  }
}