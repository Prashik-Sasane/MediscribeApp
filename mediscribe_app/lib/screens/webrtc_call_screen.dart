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
  bool _permissionsGranted = false;
  String? _errorMessage;

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
    try {
      print('[WebRTC] Starting initialization...');
      
      // Step 1: Request and verify permissions
      final permissionsOk = await _requestPermissions();
      if (!permissionsOk) {
        print('[WebRTC] ❌ Permissions denied');
        if (mounted) {
          setState(() {
            _errorMessage = 'Camera/Microphone permission denied. Please grant permissions and try again.';
          });
        }
        return;
      }
      _permissionsGranted = true;
      print('[WebRTC] ✅ Permissions granted');

      // Step 2: Initialize renderers
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();

      // Step 3: Setup socket with timeout
      _setupSocket();
      
      print('[WebRTC] Waiting for socket connection...');
      try {
        await _waitForSocketConnection();
        print('[WebRTC] ✅ Socket connected');
      } catch (e) {
        print('[WebRTC] ⚠️ Socket timeout, proceeding anyway...');
        // Continue anyway - socket might connect later
      }

      // Step 4: Create peer connection
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
          {
            'urls': 'turn:openrelay.metered.ca:80?transport=tcp',
            'username': 'openrelayproject',
            'credential': 'openrelayproject',
          },
        ]
      });
      await _peerConnection.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
        init: RTCRtpTransceiverInit(
          direction: TransceiverDirection.SendRecv,
        ),
      );

      await _peerConnection.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
        init: RTCRtpTransceiverInit(
          direction: TransceiverDirection.SendRecv,
        ),
      );
          // Step 5: Setup peer connection handlers
      _setupPeerConnection();
      
      // Step 6: Get local media
      await _getLocalMedia();

      // Step 7: Start or accept call
      if (widget.isIncoming && widget.incomingOffer != null) {
        print('[WebRTC] Handling incoming call');
        await _handleIncoming(widget.incomingOffer!);
      } else {
        print('[WebRTC] Starting outgoing call');
        await _startCall();
      }
    } catch (e) {
      print('[WebRTC] ❌ Initialization error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize call: $e';
        });
      }
    }
  }

  void _refreshVideo() {
    if (_remoteStream != null) {
      setState(() {
        _remoteRenderer.srcObject = null;
        _remoteRenderer.srcObject = _remoteStream;
      });
      print('[WebRTC] 🔄 Video refresh triggered');
    }
  }
  
  Future<void> _renegotiateIfNeeded() async {
    if (_remoteStream != null) return; // Already has video
    
    print('[WebRTC] 🔥 Attempting renegotiation...');
    try {
      // Create new offer to trigger media flow
      final offer = await _peerConnection.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      await _peerConnection.setLocalDescription(offer);
      await Future.delayed(Duration(seconds: 1));

      _socket.emit('call-user', {
        'to': widget.targetUserId,
        'offer': offer.toMap(),
        'callerName': widget.targetName,
        'callerRole': widget.isIncoming ? 'patient' : 'doctor',
        'renegotiate': true, // Flag for renegotiation
      });
      
      print('[WebRTC] Renegotiation offer sent');
    } catch (e) {
      print('[WebRTC] ⚠️ Renegotiation failed: $e');
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

  Future<bool> _requestPermissions() async {
    print('[WebRTC] Requesting permissions...');
    
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    
    print('[WebRTC] Camera: ${cameraStatus.name}');
    print('[WebRTC] Microphone: ${micStatus.name}');
    
    final granted = cameraStatus.isGranted && micStatus.isGranted;
    
    if (!granted) {
      if (cameraStatus.isDenied || micStatus.isDenied) {
        print('[WebRTC] ⚠️ Permissions denied by user');
      } else if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
        print('[WebRTC] ❌ Permissions permanently denied - need to open settings');
      }
    }
    
    return granted;
  }

  Future<void> _getLocalMedia() async {
    try {
      print('[WebRTC] Getting local media...');
      
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': 'user',
        }
      });

      if (_localStream == null) {
        throw Exception('Failed to get local media stream');
      }

      _localRenderer.srcObject = _localStream;
      
      final trackCount = _localStream!.getTracks().length;
      print('[WebRTC] ✅ Local stream obtained with $trackCount tracks');
      
      // Verify tracks are enabled
      for (var track in _localStream!.getTracks()) {
        print('[WebRTC]   - ${track.kind}: enabled=${track.enabled}');
      }

      for (var track in _localStream!.getTracks()) {
        await _peerConnection.addTrack(track, _localStream!);
        print('[WebRTC] ✅ Added local track: ${track.kind}');
      }
    } catch (e) {
      print('[WebRTC] ❌ Error getting local media: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to access camera/microphone: $e';
        });
      }
      rethrow;
    }
  }

  // ================= PEER =================
  void _setupPeerConnection() {
    print('[WebRTC] Setting up peer connection...');
    
    // 🔥 CRITICAL FALLBACK: onAddStream (for Android compatibility)
    _peerConnection.onAddStream = (stream) {
      print('[WebRTC] 🔥 onAddStream triggered');
      print('[WebRTC] Stream has ${stream.getTracks().length} tracks');
      
      setState(() {
        _remoteStream = stream;
        _remoteRenderer.srcObject = _remoteStream;
        _isCallConnected = true;
      });
      
      _startTimer();
      
      // Force video refresh
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _refreshVideo();
        }
      });
    };
    
    _peerConnection.onTrack = (event) async {
      print('[WebRTC] 🔥 ===== TRACK RECEIVED =====');
      print('[WebRTC] Track kind: ${event.track.kind}');
      print('[WebRTC] Track enabled: ${event.track.enabled}');
      print('[WebRTC] Streams count: ${event.streams.length}');

      if (event.streams.isNotEmpty) {
        final remoteStream = event.streams[0];
        print('[WebRTC] Stream has ${remoteStream.getTracks().length} tracks');
        
        for (var track in remoteStream.getTracks()) {
          print('[WebRTC]   - Track: ${track.kind}, enabled: ${track.enabled}');
        }
        
        setState(() {
          _remoteStream = remoteStream;
          _remoteRenderer.srcObject = _remoteStream;
          _isCallConnected = true;
        });
        
        print('[WebRTC] ✅ Remote video stream assigned to renderer');
        
        // Force video to refresh after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _refreshVideo();
          }
        });
      } else {
        print('[WebRTC] No streams in event, creating fallback stream');
        final fallbackStream = await createLocalMediaStream('remoteFallback');
        fallbackStream.addTrack(event.track);
        
        setState(() {
          _remoteStream = fallbackStream;
          _remoteRenderer.srcObject = _remoteStream;
          _isCallConnected = true;
        });
        
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _refreshVideo();
          }
        });
      }

      _startTimer();
    };

    _peerConnection.onConnectionState = (state) {
      print('[WebRTC] 🔥 ===== CONNECTION STATE =====: $state');
      
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        print('[WebRTC] ✅✅✅ CALL CONNECTED SUCCESSFULLY ✅✅✅');
        setState(() => _isCallConnected = true);
        
        // If video not received after connection, trigger check
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            if (_remoteStream == null) {
              print('[WebRTC] ⚠️ Connected but NO VIDEO received!');
              print('[WebRTC] Checking if renegotiation needed...');
              // Try to renegotiate
            } else {
              print('[WebRTC] ✅ Video stream is active');
            }
          }
        });
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnecting) {
        print('[WebRTC] ⏳ Connecting...');
        setState(() => _isCallConnected = false);
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        print('[WebRTC] ❌ Call ended: $state');
        if (mounted) {
          // Show message before navigating
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Call disconnected'),
              duration: Duration(seconds: 2),
            ),
          );
        }
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
      print('[WebRTC] 🔥 Call accepted, setting remote description');
      try {
        await _peerConnection.setRemoteDescription(
          RTCSessionDescription(
            data['answer']['sdp'],
            data['answer']['type'],
          ),
        );
        print('[WebRTC] ✅ Remote description set successfully');
        _remoteDescSet = true;
        
        // 🔥 CRITICAL: Wait for ICE to stabilize
        await Future.delayed(const Duration(milliseconds: 300));
        print('[WebRTC] 🔥 Forcing ICE candidate processing...');

        // Apply pending ICE candidates
        print('[WebRTC] Applying ${_pendingCandidates.length} pending ICE candidates');
        for (var c in _pendingCandidates) {
          try {
            await _peerConnection.addCandidate(c);
            print('[WebRTC] ✅ ICE candidate added');
          } catch (e) {
            print('[WebRTC] ⚠️ Failed to add ICE candidate: $e');
          }
        }
        _pendingCandidates.clear();
        print('[WebRTC] ✅ All pending ICE candidates applied');
      } catch (e) {
        print('[WebRTC] ❌ Error setting remote description: $e');
      }
    });

    _socket.on('ice-candidate', (data) async {
      try {
        final candidate = RTCIceCandidate(
          data['candidate']['candidate'],
          data['candidate']['sdpMid'],
          data['candidate']['sdpMLineIndex'],
        );

        print('[WebRTC] 📨 Received ICE candidate: ${candidate.sdpMid}');

        if (_remoteDescSet) {
          await _peerConnection.addCandidate(candidate);
          print('[WebRTC] ✅ ICE candidate added immediately');
        } else {
          _pendingCandidates.add(candidate);
          print('[WebRTC] ⏳ ICE candidate queued (${_pendingCandidates.length} pending)');
        }
      } catch (e) {
        print('[WebRTC] ❌ Error adding ICE candidate: $e');
      }
    });

   _socket.on('end-call', (_) {
      print('[WebRTC] 🔥 Remote user ended call');

      if (mounted) {
        // Show message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Call ended by other user'),
            duration: Duration(seconds: 1),
          ),
        );

        _timer?.cancel();

        _localStream?.getTracks().forEach((t) => t.stop());
        _remoteStream?.getTracks().forEach((t) => t.stop());

        _localRenderer.srcObject = null;
        _remoteRenderer.srcObject = null;

        try {
          _peerConnection.close();
        } catch (e) {
          print("Error closing peer: $e");
        }

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        });
      }
    });
  }

  Future<void> _startCall() async {
    print('[WebRTC] 🔥 Creating offer...');
    final offer = await _peerConnection.createOffer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': true,
    });
    await _peerConnection.setLocalDescription(offer);
    await Future.delayed(Duration(seconds: 1));
    print('[WebRTC] ✅ Offer created and local description set');

    _socket.emit('call-user', {
      'to': widget.targetUserId,
      'offer': offer.toMap(),
      'callerName': widget.targetName,
      'callerRole': widget.isIncoming ? 'patient' : 'doctor',
    });
    print('[WebRTC] ✅ Offer sent to ${widget.targetUserId}');
  }

  Future<void> _handleIncoming(Map offer) async {
    print('[WebRTC] Handling incoming offer...');
    try {
      await _peerConnection.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );
      print('[WebRTC] Remote description (offer) set successfully');
      _remoteDescSet = true;

      final answer = await _peerConnection.createAnswer({
         'offerToReceiveAudio': true,
         'offerToReceiveVideo': true,
    });
      await _peerConnection.setLocalDescription(answer);
      await Future.delayed(Duration(seconds: 1));
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
    print('[WebRTC] Ending call...');
    
    try {
      // Notify remote user
      if (_socket.connected) {
        _socket.emit('end-call', {'to': widget.targetUserId});
        print('[WebRTC] Sent end-call signal to ${widget.targetUserId}');
      }
    } catch (e) {
      print('[WebRTC] Error sending end-call signal: $e');
    }
    
    _endLocal();
  }

  void _endLocal() {
    print('[WebRTC] Cleaning up local resources...');
    
    try {
      // Cancel timer
      _timer?.cancel();
      _timer = null;

      // Stop and dispose local stream
      if (_localStream != null) {
        for (var track in _localStream!.getTracks()) {
          track.stop();
          print('[WebRTC] Stopped local track: ${track.kind}');
        }
        _localStream!.dispose();
        _localStream = null;
      }

      // Stop and dispose remote stream
      if (_remoteStream != null) {
        for (var track in _remoteStream!.getTracks()) {
          track.stop();
        }
        _remoteStream!.dispose();
        _remoteStream = null;
      }

      // Clear renderers
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;

      // Close peer connection
      _peerConnection.close();
      print('[WebRTC] ✅ Peer connection closed');

      // Navigate back
      if (mounted) {
        print('[WebRTC] Navigating back...');
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('[WebRTC] ❌ Error during cleanup: $e');
      // Force navigate back even if cleanup fails
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    print('[WebRTC] Disposing WebRTC call screen...');
    _endLocal();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    // Show error if initialization failed
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 80,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Call Error',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7DFF),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background: Remote Video (with fallback)
          Center(
            child: _remoteStream != null
                ? RTCVideoView(
                    _remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                : Container(
                    color: const Color(0xFF1E293B),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_off,
                          color: Colors.white.withOpacity(0.3),
                          size: 100,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isCallConnected
                              ? 'Remote video not available'
                              : 'Connecting...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 18,
                          ),
                        ),
                        if (!_isCallConnected) ...[
                          const SizedBox(height: 24),
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              color: Color(0xFF2E7DFF),
                              strokeWidth: 3,
                            ),
                          ),
                        ],
                      ],
                    ),
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
                child: _localStream != null
                    ? RTCVideoView(
                        _localRenderer,
                        mirror: true,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                    : Container(
                        color: Colors.black,
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            color: Colors.white38,
                            size: 50,
                          ),
                        ),
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
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isCallConnected ? Icons.check_circle : Icons.schedule,
                        color: _isCallConnected ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCallConnected ? _time() : "Connecting...",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Controls Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _controlButton(
                      icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      color: _isMuted ? Colors.red.withOpacity(0.3) : Colors.white.withOpacity(0.2),
                      onPressed: _toggleMute,
                      label: _isMuted ? 'Unmute' : 'Mute',
                    ),
                    _controlButton(
                      icon: Icons.call_end_rounded,
                      color: Colors.red,
                      size: 72,
                      onPressed: _endCall,
                      label: 'End',
                    ),
                    _controlButton(
                      icon: _isCameraOff
                          ? Icons.videocam_off_rounded
                          : Icons.videocam_rounded,
                      color: _isCameraOff ? Colors.red.withOpacity(0.3) : Colors.white.withOpacity(0.2),
                      onPressed: _toggleCamera,
                      label: _isCameraOff ? 'Start Video' : 'Stop Video',
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
    String? label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: size * 0.5,
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}