import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:mediscribe_app/core/app_state.dart';
import 'package:mediscribe_app/screens/webrtc_call_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class IncomingCallService {
  static IO.Socket? _socket;
  static BuildContext? _context;
  static bool _isListening = false;
  static AudioPlayer? _ringtonePlayer;
  static bool _isRinging = false;

  static void initialize(BuildContext context) {
    _context = context;
    if (!_isListening) {
      _setupIncomingCallListener();
      _isListening = true;
    }
  }

  static void _setupIncomingCallListener() {
    if (_context == null) return;

    final appState = AppScope.of(_context!);
    final currentUserId = appState.currentUser?.email ?? '';

    if (currentUserId.isEmpty) return;

    // Dispose existing socket if any
    _socket?.dispose();
    
    // Setup socket connection
    _socket = IO.io('https://mediscribeapp.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket!.onConnect((_) {
      print('[IncomingCall] Socket connected');
      // Register user
      _socket!.emit('register', currentUserId);
    });

    // Listen for incoming calls
    _socket!.on('incoming-call', (data) async {
      print('[IncomingCall] Received incoming call from: ${data['callerName']}');
      
      if (_context != null) {
        _playRingtone();
        _showIncomingCallDialog(data);
      }
    });

    _socket!.onDisconnect((_) {
      print('[IncomingCall] Socket disconnected');
    });
  }

  static void _playRingtone() {
    if (_isRinging) return;
    _isRinging = true;
    
    _ringtonePlayer = AudioPlayer();
    _ringtonePlayer!.setReleaseMode(ReleaseMode.loop);
    _ringtonePlayer!.play(AssetSource('sounds/ringtone.mp3'));
    print('[IncomingCall] Playing ringtone...');
  }

  static void _stopRingtone() {
    if (!_isRinging) return;
    _isRinging = false;
    
    _ringtonePlayer?.stop();
    _ringtonePlayer?.dispose();
    _ringtonePlayer = null;
    print('[IncomingCall] Ringtone stopped');
  }

  static void _showIncomingCallDialog(Map<String, dynamic> data) {
    if (_context == null) return;

    showDialog(
      context: _context!,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF2E7DFF),
                child: Icon(Icons.videocam, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'Incoming Video Call',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data['callerName'] ?? 'Unknown',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data['callerRole'] == 'doctor' ? 'Doctor' : 'Patient',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reject button
                ElevatedButton.icon(
                  onPressed: () {
                    _stopRingtone();
                    Navigator.pop(context);
                    _socket?.emit('reject-call', {
                      'to': data['from'],
                    });
                  },
                  icon: const Icon(Icons.call_end, color: Colors.white),
                  label: const Text('Decline'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                // Accept button
                ElevatedButton.icon(
                  onPressed: () {
                    _stopRingtone();
                    Navigator.pop(context);
                    _acceptCall(context, data);
                  },
                  icon: const Icon(Icons.call, color: Colors.white),
                  label: const Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void _acceptCall(BuildContext context, Map<String, dynamic> data) {
    final appState = AppScope.of(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebRTCCallScreen(
          userId: appState.currentUser!.email, 
          targetUserId: data['from'],
          targetName: data['callerName'] ?? 'Unknown',
          // targetImageUrl: '',
          isIncoming: true,
          incomingOffer: data['offer'],
        ),
      ),
    );
  }

  static void dispose() {
    _socket?.disconnect();
    _isListening = false;
  }
}
