import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:mediscribe_app/core/app_state.dart';

class WebRTCCallScreen extends StatefulWidget {
  final String targetUserId; // Doctor or Patient ID to call
  final String targetName; // Name to display
  final String targetImageUrl; // Profile image
  final bool isIncoming; // true if receiving a call
  final Map<String, dynamic>? incomingOffer; // SDP offer if incoming call

  const WebRTCCallScreen({
    super.key,
    required this.targetUserId,
    required this.targetName,
    required this.targetImageUrl,
    this.isIncoming = false,
    this.incomingOffer,
  });

  @override
  State<WebRTCCallScreen> createState() => _WebRTCCallScreenState();
}

class _WebRTCCallScreenState extends State<WebRTCCallScreen> {
  // WebRTC
  late RTCPeerConnection _peerConnection;

  // Media streams
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  // Video renderers
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  // Socket connection
  late IO.Socket _socket;

  // Call state
  bool _isCallConnected = false;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isFrontCamera = true;
  int _callDuration = 0;
  String _callStatus = 'Connecting...';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Initialize peer connection
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ]
    });

    // Initialize renderers
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    // Setup socket connection
    _setupSocket();

    // Get local media (camera & microphone)
    await _getLocalMedia();

    // Setup peer connection listeners
    _setupPeerConnection();

    // If incoming call, accept it
    if (widget.isIncoming && widget.incomingOffer != null) {
      await _handleIncomingCall(widget.incomingOffer!);
    } else {
      // Outgoing call - create offer
      await _makeOutgoingCall();
    }
  }

  void _setupSocket() {
    final appState = AppScope.of(context);
    final currentUserId = appState.currentUser?.email ?? '';

    _socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.onConnect((_) {
      print('Socket connected');
      // Register user
      _socket.emit('register', currentUserId);
    });

    // Listen for call events
    _socket.on('call-accepted', (data) async {
      print('Call accepted');
      final answer = RTCSessionDescription(data['answer']['sdp'], data['answer']['type']);
      await _peerConnection.setRemoteDescription(answer);
    });

    _socket.on('ice-candidate', (data) async {
      final candidate = RTCIceCandidate(
        data['candidate']['candidate'],
        data['candidate']['sdpMid'],
        data['candidate']['sdpMLineIndex'],
      );
      await _peerConnection.addCandidate(candidate);
    });

    _socket.on('call-ended', (data) {
      print('Call ended by remote');
      if (mounted) {
        setState(() => _callStatus = 'Call ended');
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      }
    });

    _socket.on('call-rejected', (data) {
      print('Call rejected');
      if (mounted) {
        setState(() => _callStatus = 'Call rejected');
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      }
    });
  }

  Future<void> _getLocalMedia() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': _isFrontCamera ? 'user' : 'environment',
        },
      });

      _localRenderer.srcObject = _localStream;
      setState(() {});
    } catch (e) {
      print('Error getting local media: $e');
    }
  }

  void _setupPeerConnection() {
    // Add local stream to peer connection
    _localStream?.getTracks().forEach((track) {
      _peerConnection.addTrack(track, _localStream!);
    });

    // Listen for remote stream
    _peerConnection.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        setState(() {
          _remoteStream = event.streams[0];
          _remoteRenderer.srcObject = _remoteStream;
          _isCallConnected = true;
          _callStatus = 'Connected';
          _startCallTimer();
        });
      }
    };

    // Listen for ICE candidates
    _peerConnection.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        _socket.emit('ice-candidate', {
          'to': widget.targetUserId,
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        });
      }
    };
  }

  Future<void> _makeOutgoingCall() async {
    setState(() => _callStatus = 'Ringing...');

    // Create offer
    final offer = await _peerConnection.createOffer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': true,
    });
    await _peerConnection.setLocalDescription(offer);

    // Send offer to remote user
    final appState = AppScope.of(context);
    _socket.emit('call-user', {
      'to': widget.targetUserId,
      'offer': {'sdp': offer.sdp, 'type': offer.type},
      'callerName': appState.currentUser?.name ?? 'User',
      'callerRole': appState.currentUser?.role ?? 'patient',
    });
  }

  Future<void> _handleIncomingCall(Map<String, dynamic> offer) async {
    setState(() => _callStatus = 'Accepting call...');

    // Set remote description
    final remoteDesc = RTCSessionDescription(offer['sdp'], offer['type']);
    await _peerConnection.setRemoteDescription(remoteDesc);

    // Create answer
    final answer = await _peerConnection.createAnswer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': true,
    });
    await _peerConnection.setLocalDescription(answer);

    // Send answer back
    _socket.emit('accept-call', {
      'to': widget.targetUserId,
      'answer': {'sdp': answer.sdp, 'type': answer.type},
    });
  }

  void _startCallTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isCallConnected) {
        setState(() => _callDuration++);
        _startCallTimer();
      }
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleMute() async {
    if (_localStream != null) {
      _localStream!.getAudioTracks().forEach((track) {
        track.enabled = _isMuted;
      });
      setState(() => _isMuted = !_isMuted);
    }
  }

  Future<void> _toggleCamera() async {
    if (_localStream != null) {
      _localStream!.getVideoTracks().forEach((track) {
        track.enabled = _isCameraOff;
      });
      setState(() => _isCameraOff = !_isCameraOff);
    }
  }

  Future<void> _switchCamera() async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      await videoTrack.switchCamera();
      setState(() => _isFrontCamera = !_isFrontCamera);
    }
  }

  Future<void> _endCall() async {
    _socket.emit('end-call', {'to': widget.targetUserId});
    _cleanup();
    Navigator.pop(context);
  }

  void _cleanup() {
    _localStream?.dispose();
    _remoteStream?.dispose();
    _peerConnection.close();
    _socket.disconnect();
  }

  @override
  void dispose() {
    _cleanup();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Remote video (full screen)
          Positioned.fill(
            child: RTCVideoView(
              _remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),

          // Local video (picture-in-picture)
          Positioned(
            top: 60,
            right: 20,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: RTCVideoView(
                  _localRenderer,
                  mirror: _isFrontCamera,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
          ),

          // Call controls overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Call info
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
                    _callStatus == 'Connected'
                        ? _formatDuration(_callDuration)
                        : _callStatus,
                    style: TextStyle(
                      color: _isCallConnected ? Colors.green : Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Call controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Mute button
                      _ControlButton(
                        icon: _isMuted ? Icons.mic_off : Icons.mic,
                        label: _isMuted ? 'Unmute' : 'Mute',
                        isActive: _isMuted,
                        onTap: _toggleMute,
                      ),
                      const SizedBox(width: 20),

                      // Camera toggle
                      _ControlButton(
                        icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                        label: _isCameraOff ? 'Show Video' : 'Hide Video',
                        isActive: _isCameraOff,
                        onTap: _toggleCamera,
                      ),
                      const SizedBox(width: 20),

                      // Switch camera
                      _ControlButton(
                        icon: Icons.switch_camera,
                        label: 'Switch',
                        onTap: _switchCamera,
                      ),
                      const SizedBox(width: 20),

                      // End call
                      Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.call_end, color: Colors.white, size: 35),
                          onPressed: _endCall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.black : Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
