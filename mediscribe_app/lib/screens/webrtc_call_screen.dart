import 'dart:async';
import 'dart:convert';
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
  bool _socketConnected = false;

  bool _isCallConnected = false;
  bool _isMuted = false;
  bool _isCameraOff = false;

  int _callDuration = 0;
  Timer? _timer;

  List<RTCIceCandidate> _pendingCandidates = [];
  bool _remoteDescSet = false;
  Completer<void>? _socketCompleter;

  @override
  void initState() {
    super.initState();
    _init();
  }

  // ================= INIT =================
  Future<void> _init() async {
    print('[WebRTC] Starting initialization...');
    await _requestPermissions();

    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    _setupSocket();
    
    // Wait for socket connection before proceeding
    print('[WebRTC] Waiting for socket connection...');
    await _waitForSocketConnection();
    print('[WebRTC] Socket connected, proceeding with call setup');

    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
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
    });

    _setupPeerConnection();
    await _getLocalMedia();

    if (widget.isIncoming && widget.incomingOffer != null) {
      print('[WebRTC] Handling incoming call');
      await _handleIncoming(widget.incomingOffer!);
    } else {
      print('[WebRTC] Starting outgoing call');
      await _startCall();
    }
  }

  Future<void> _waitForSocketConnection() async {
    if (_socketConnected) return;
    
    _socketCompleter = Completer<void>();
    await _socketCompleter!.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print('[WebRTC] Socket connection timeout');
        throw Exception('Socket connection timeout');
      },
    );
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
    print('[WebRTC] Getting local media...');
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {
        'facingMode': 'user',
      }
    });

    _localRenderer.srcObject = _localStream;
    print('[WebRTC] Local stream obtained with ${_localStream!.getTracks().length} tracks');

    for (var track in _localStream!.getTracks()) {
      await _peerConnection.addTrack(track, _localStream!);
      print('[WebRTC] Added local track: ${track.kind}');
    }
  }

  // ================= PEER =================
  void _setupPeerConnection() {
    print('[WebRTC] Setting up peer connection...');
    
    _peerConnection.onTrack = (event) async {
      print('[WebRTC] TRACK RECEIVED: ${event.track.kind}');
      print('[WebRTC] Streams count: ${event.streams.length}');

      if (event.streams.isNotEmpty) {
        final remoteStream = event.streams[0];
        print('[WebRTC] Using stream with ${remoteStream.getTracks().length} tracks');
        
        setState(() {
          _remoteStream = remoteStream;
          _remoteRenderer.srcObject = _remoteStream;
          _isCallConnected = true;
        });
        
        print('[WebRTC] Remote video stream assigned to renderer');
      } else {
        print('[WebRTC] No streams in event, creating fallback stream');
        final fallbackStream = await createLocalMediaStream('remoteFallback');
        fallbackStream.addTrack(event.track);
        
        setState(() {
          _remoteStream = fallbackStream;
          _remoteRenderer.srcObject = _remoteStream;
          _isCallConnected = true;
        });
      }

      _startTimer();
    };

    _peerConnection.onConnectionState = (state) {
      print('[WebRTC] CONNECTION STATE: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        print('[WebRTC] Call connected successfully');
        setState(() => _isCallConnected = true);
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        print('[WebRTC] Call ended: $state');
        _endLocal();
      }
    };

    _peerConnection.onIceConnectionState = (state) {
      print('[WebRTC] ICE CONNECTION STATE: $state');
    };

    _peerConnection.onIceCandidate = (c) {
      if (c.candidate != null) {
        print('[WebRTC] Sending ICE candidate: ${c.sdpMid}');
        _socket.emit('ice-candidate', {
          'to': widget.targetUserId,
          'candidate': c.toMap(),
        });
      }
    };
  }

  // ================= SOCKET =================
  void _setupSocket() {
    print('[WebRTC] Setting up socket connection...');
    _socket = IO.io('https://mediscribeapp.onrender.com', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.onConnect((_) {
      print('[WebRTC] Socket connected successfully');
      _socketConnected = true;
      _socket.emit('register', widget.userId);
      
      // Complete the socket connection waiter
      if (_socketCompleter != null && !_socketCompleter!.isCompleted) {
        _socketCompleter!.complete();
      }
    });

    _socket.onDisconnect((_) {
      print('[WebRTC] Socket disconnected');
      _socketConnected = false;
    });

    _socket.on('call-accepted', (data) async {
      print('[WebRTC] Call accepted, setting remote description');
      try {
        await _peerConnection.setRemoteDescription(
          RTCSessionDescription(
            data['answer']['sdp'],
            data['answer']['type'],
          ),
        );
        print('[WebRTC] Remote description set successfully');
        _remoteDescSet = true;

        // Apply pending ICE candidates
        print('[WebRTC] Applying ${_pendingCandidates.length} pending ICE candidates');
        for (var c in _pendingCandidates) {
          await _peerConnection.addCandidate(c);
        }
        _pendingCandidates.clear();
        print('[WebRTC] All pending ICE candidates applied');
      } catch (e) {
        print('[WebRTC] Error setting remote description: $e');
      }
    });

    _socket.on('ice-candidate', (data) async {
      try {
        final candidate = RTCIceCandidate(
          data['candidate']['candidate'],
          data['candidate']['sdpMid'],
          data['candidate']['sdpMLineIndex'],
        );

        print('[WebRTC] Received ICE candidate: ${candidate.sdpMid}');

        if (_remoteDescSet) {
          await _peerConnection.addCandidate(candidate);
          print('[WebRTC] ICE candidate added immediately');
        } else {
          _pendingCandidates.add(candidate);
          print('[WebRTC] ICE candidate queued (${_pendingCandidates.length} pending)');
        }
      } catch (e) {
        print('[WebRTC] Error adding ICE candidate: $e');
      }
    });

    _socket.on('end-call', (_) {
      print('[WebRTC] Call ended by remote');
      _endLocal();
    });
  }

  // ================= CALL =================
  Future<void> _startCall() async {
    print('[WebRTC] Creating offer...');
    final offer = await _peerConnection.createOffer();
    await _peerConnection.setLocalDescription(offer);
    print('[WebRTC] Offer created and local description set');

    _socket.emit('call-user', {
      'to': widget.targetUserId,
      'offer': offer.toMap(),
      'callerName': widget.targetName,
      'callerRole': 'doctor',
    });
    print('[WebRTC] Offer sent to ${widget.targetUserId}');
  }

  Future<void> _handleIncoming(Map offer) async {
    print('[WebRTC] Handling incoming offer...');
    try {
      await _peerConnection.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );
      print('[WebRTC] Remote description (offer) set successfully');
      _remoteDescSet = true;

      final answer = await _peerConnection.createAnswer();
      await _peerConnection.setLocalDescription(answer);
      print('[WebRTC] Answer created and local description set');

      _socket.emit('accept-call', {
        'to': widget.targetUserId,
        'answer': answer.toMap(),
      });
      print('[WebRTC] Answer sent to ${widget.targetUserId}');

      // Apply any pending ICE candidates
      if (_pendingCandidates.isNotEmpty) {
        print('[WebRTC] Applying ${_pendingCandidates.length} pending ICE candidates');
        for (var c in _pendingCandidates) {
          await _peerConnection.addCandidate(c);
        }
        _pendingCandidates.clear();
      }
    } catch (e) {
      print('[WebRTC] Error handling incoming call: $e');
    }
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