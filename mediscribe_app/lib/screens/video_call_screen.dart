// video_call_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class VideoCallScreen extends StatefulWidget {
  final String userId;
  final String targetUserId;
  final bool isCaller;
  final Map? offer;

  const VideoCallScreen({
    super.key,
    required this.userId,
    required this.targetUserId,
    required this.isCaller,
    this.offer,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late IO.Socket socket;
  late RTCPeerConnection _peerConnection;
  MediaStream? _localStream;

  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    _connectSocket();

    if (widget.isCaller) {
      await _startCall();
    } else if (widget.offer != null) {
      await _acceptCall(widget.offer!);
    }
  }

  // 🔌 SOCKET
  void _connectSocket() {
    socket = IO.io(
      'https://mediscribeapp.onrender.com',
      {
        'transports': ['websocket'],
        'autoConnect': true,
      },
    );

    socket.onConnect((_) {
      print("✅ SOCKET CONNECTED");
      socket.emit("register", widget.userId);
    });

    socket.on("call-accepted", (data) async {
      await _peerConnection.setRemoteDescription(
        RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        ),
      );
    });

    socket.on("ice-candidate", (data) async {
      await _peerConnection.addCandidate(
        RTCIceCandidate(
          data['candidate']['candidate'],
          data['candidate']['sdpMid'],
          data['candidate']['sdpMLineIndex'],
        ),
      );
    });

    socket.on("end-call", (_) {
      _endCall();
    });
  }

  // 🔥 PEER CONNECTION (TURN FIXED)
  Future<void> _createPeerConnection() async {
    Map<String, dynamic> config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {
          'urls': 'turn:openrelay.metered.ca:80',
          'username': 'openrelayproject',
          'credential': 'openrelayproject',
        },
        {
          'urls': 'turn:openrelay.metered.ca:443',
          'username': 'openrelayproject',
          'credential': 'openrelayproject',
        },
      ]
    };

    _peerConnection = await createPeerConnection(config);

    _peerConnection.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams[0];
      }
    };

    _peerConnection.onIceCandidate = (candidate) {
      if (candidate != null) {
        socket.emit("ice-candidate", {
          "to": widget.targetUserId,
          "candidate": candidate.toMap(),
        });
      }
    };
  }

  // 📷 LOCAL STREAM
  Future<void> _initLocalStream() async {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    _localRenderer.srcObject = _localStream;

    for (var track in _localStream!.getTracks()) {
      _peerConnection.addTrack(track, _localStream!);
    }
  }

  // 📞 CALL
  Future<void> _startCall() async {
    await _createPeerConnection();
    await _initLocalStream();

    var offer = await _peerConnection.createOffer();
    await _peerConnection.setLocalDescription(offer);

    socket.emit("call-user", {
      "to": widget.targetUserId,
      "offer": offer.toMap(),
    });
  }

  // 📞 ACCEPT
  Future<void> _acceptCall(Map data) async {
    await _createPeerConnection();
    await _initLocalStream();

    await _peerConnection.setRemoteDescription(
      RTCSessionDescription(data['sdp'], data['type']),
    );

    var answer = await _peerConnection.createAnswer();
    await _peerConnection.setLocalDescription(answer);

    socket.emit("accept-call", {
      "to": widget.targetUserId,
      "answer": answer.toMap(),
    });
  }

  // ❌ END
  void _endCall() {
    _localStream?.dispose();
    _peerConnection.close();

    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: RTCVideoView(_remoteRenderer),
          ),
          Positioned(
            right: 20,
            top: 50,
            width: 120,
            height: 160,
            child: RTCVideoView(_localRenderer, mirror: true),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: () {
                  socket.emit("end-call", {
                    "to": widget.targetUserId,
                  });
                  _endCall();
                },
                child: const Icon(Icons.call_end),
              ),
            ),
          )
        ],
      ),
    );
  }
}