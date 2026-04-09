import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:permission_handler/permission_handler.dart';

class WebRTCCallScreen extends StatefulWidget {
  final String userId;
  final String targetUserId;
  final String targetName;
  final bool isIncoming;
  final Map<String, dynamic>? incomingOffer;

  const WebRTCCallScreen({
    super.key,
    required this.userId,
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
    _peerConnection.onTrack = (event) async {
      print("TRACK RECEIVED: ${event.track.kind}");

      if (event.streams.isNotEmpty) {
        print("STREAM FOUND");
        _remoteStream = event.streams[0];
        _remoteRenderer.srcObject = _remoteStream;
      } else {
        print("NO STREAM → USING TRACK FALLBACK");
        _remoteStream ??= await createLocalMediaStream("remoteStream");
        _remoteStream!.addTrack(event.track);
        _remoteRenderer.srcObject = _remoteStream;
      }

      setState(() {
        _isCallConnected = true;
      });

      _startTimer();
    };

    _peerConnection.onConnectionState = (state) {
      print("CONNECTION STATE: $state");
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        setState(() => _isCallConnected = true);
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        _endLocal();
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
    _socket = IO.io('https://mediscribeapp.onrender.com/', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.onConnect((_) {
      print("Connected to server");
  // replace dynamically
       _socket.emit("register", widget.userId);
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
          // Background: Remote Video
          Center(
            child: RTCVideoView(
              _remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),

          // Top Overlay: Local Video (Picture-in-Picture)
          Positioned(
            top: 60,
            right: 20,
            child: Container(
              width: 110,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: RTCVideoView(
                  _localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
          ),

          // Bottom Controls Overlay
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Caller Name and Timer
                Text(
                  widget.targetName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isCallConnected ? _time() : "Connecting...",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),

                // Controls Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _controlButton(
                      icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      color: _isMuted ? Colors.white24 : Colors.white12,
                      onPressed: _toggleMute,
                    ),
                    _controlButton(
                      icon: Icons.call_end_rounded,
                      color: Colors.red,
                      size: 72,
                      onPressed: _endCall,
                    ),
                    _controlButton(
                      icon: _isCameraOff
                          ? Icons.videocam_off_rounded
                          : Icons.videocam_rounded,
                      color: _isCameraOff ? Colors.white24 : Colors.white12,
                      onPressed: _toggleCamera,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 60,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}