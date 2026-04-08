import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static late IO.Socket socket;

  static void init(String userId) {
    socket = IO.io('http://10.222.254.49:5000', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print("Socket connected");
      socket.emit('register', userId);
    });
  }
}