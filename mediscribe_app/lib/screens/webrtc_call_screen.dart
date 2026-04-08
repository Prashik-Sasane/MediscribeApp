import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:permission_handler/permission_handler.dart';

class WebRTCCallScreen extends StatefulWidget {
  final String targetUserId;
  final String targetName;
  final bool isIncoming;
  final Map<String, dynamic>? incomingOffer;

  const WebRTCCallScreen({
    super.key,
    required this.targetUserId,
    required this.targetName,
    this.isIncoming = false,
    this.incomingOffer,
  });

  @override
  State<WebRTCCallScreen> createState() => _WebRTCCallScreenState();
}

class _WebRTCCallScreenState extends State<WebRTCCallScreen> {
  late RTCPeerConnection _peerConnection;

  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  late IO.Socket _socket;

  bool _isCallConnected = false;
  bool _isMuted = false;
  bool _isCameraOff = false;

  int _callDuration = 0;
  Timer? _timer;

  List<RTCIceCandidate> _pendingCandidates = [];
  bool _remoteDescSet = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  // ================= INIT =================
  Future<void> _init() async {
    await _requestPermissions();

    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {
          'urls': 'turn:openrelay.metered.ca:80',
          'username': 'openrelayproject',
          'credential': 'openrelayproject',
        }
      ]
    });

    _setupPeerConnection();
    _setupSocket();
    await _getLocalMedia();

    if (widget.isIncoming && widget.incomingOffer != null) {
      await _handleIncoming(widget.incomingOffer!);
    } else {
      await _startCall();
    }
  }

  // ================= PERMISSIONS =================
  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }

  // ================= LOCAL MEDIA =================
  Future<void> _getLocalMedia() async {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {
        'facingMode': 'user',
      }
    });

    _localRenderer.srcObject = _localStream;

    for (var track in _localStream!.getTracks()) {
      _peerConnection.addTrack(track, _localStream!);
    }
  }

  // ================= PEER =================
  void _setupPeerConnection() {
    _peerConnection.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        setState(() {
          _remoteStream = event.streams[0];
          _remoteRenderer.srcObject = _remoteStream;
          _isCallConnected = true;
        });
        _startTimer();
      }
    };

    _peerConnection.onIceCandidate = (c) {
      if (c.candidate != null) {
        _socket.emit('ice-candidate', {
          'to': widget.targetUserId,
          'candidate': c.toMap(),
        });
      }
    };
  }

  // ================= SOCKET =================
  void _setupSocket() {
    _socket = IO.io('http://10.222.254.49:5000', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.onConnect((_) {
      print("Connected to server");
    });

    _socket.on('call-accepted', (data) async {
      await _peerConnection.setRemoteDescription(
        RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        ),
      );

      _remoteDescSet = true;

      for (var c in _pendingCandidates) {
        await _peerConnection.addCandidate(c);
      }
      _pendingCandidates.clear();
    });

    _socket.on('ice-candidate', (data) async {
      final c = RTCIceCandidate(
        data['candidate']['candidate'],
        data['candidate']['sdpMid'],
        data['candidate']['sdpMLineIndex'],
      );

      if (_remoteDescSet) {
        await _peerConnection.addCandidate(c);
      } else {
        _pendingCandidates.add(c);
      }
    });

    _socket.on('end-call', (_) {
      _endLocal();
    });
  }

  // ================= CALL =================
  Future<void> _startCall() async {
    final offer = await _peerConnection.createOffer();
    await _peerConnection.setLocalDescription(offer);

    _socket.emit('call-user', {
      'to': widget.targetUserId,
      'offer': offer.toMap(),
    });
  }

  Future<void> _handleIncoming(Map offer) async {
    await _peerConnection.setRemoteDescription(
      RTCSessionDescription(offer['sdp'], offer['type']),
    );

    _remoteDescSet = true;

    final answer = await _peerConnection.createAnswer();
    await _peerConnection.setLocalDescription(answer);

    _socket.emit('accept-call', {
      'to': widget.targetUserId,
      'answer': answer.toMap(),
    });
  }

  // ================= TIMER =================
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _callDuration++);
    });
  }

  String _time() {
    final m = _callDuration ~/ 60;
    final s = _callDuration % 60;
    return "$m:$s";
  }

  // ================= CONTROLS =================
  void _toggleMute() {
    _isMuted = !_isMuted;
    _localStream?.getAudioTracks().forEach((t) => t.enabled = !_isMuted);
    setState(() {});
  }

  void _toggleCamera() {
    _isCameraOff = !_isCameraOff;
    _localStream?.getVideoTracks().forEach((t) => t.enabled = !_isCameraOff);
    setState(() {});
  }

  void _endCall() {
    _socket.emit('end-call', {'to': widget.targetUserId});
    _endLocal();
  }

  void _endLocal() {
    _timer?.cancel();

    _localStream?.dispose();
    _remoteStream?.dispose();
    _peerConnection.close();

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _endLocal();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          RTCVideoView(_remoteRenderer),

          Positioned(
            top: 40,
            right: 10,
            child: SizedBox(
              width: 120,
              height: 160,
              child: RTCVideoView(_localRenderer, mirror: true),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(_isCallConnected ? _time() : "Connecting...",
                    style: const TextStyle(color: Colors.white)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                        color: Colors.white,
                        onPressed: _toggleMute),

                    IconButton(
                        icon: Icon(_isCameraOff
                            ? Icons.videocam_off
                            : Icons.videocam),
                        color: Colors.white,
                        onPressed: _toggleCamera),

                    IconButton(
                        icon: const Icon(Icons.call_end),
                        color: Colors.red,
                        onPressed: _endCall),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}