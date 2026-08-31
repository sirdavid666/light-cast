import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'signaling_service.dart';

/// Runs on a Camera phone (Pastor or Crowd) — captures its own camera+mic
/// and sends the offer to the Director.
class CameraPeerService {
  final SignalingClient signaling;
  RTCPeerConnection? _pc;
  MediaStream? localStream;

  CameraPeerService(this.signaling);

  Future<void> start() async {
    localStream = await navigator.mediaDevices.getUserMedia({
      'video': {'facingMode': 'environment'},
      'audio': true,
    });

    _pc = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    });

    for (final track in localStream!.getTracks()) {
      await _pc!.addTrack(track, localStream!);
    }

    _pc!.onIceCandidate = (candidate) {
      signaling.send({'type': 'ice', 'candidate': candidate.toMap()});
    };

    signaling.onMessage = (msg) async {
      if (msg['type'] == 'answer') {
        await _pc!
            .setRemoteDescription(RTCSessionDescription(msg['sdp'], 'answer'));
      } else if (msg['type'] == 'ice') {
        final c = msg['candidate'];
        await _pc!.addCandidate(
            RTCIceCandidate(c['candidate'], c['sdpMid'], c['sdpMLineIndex']));
      }
    };

    final offer = await _pc!.createOffer();
    await _pc!.setLocalDescription(offer);
    signaling.send({'type': 'offer', 'sdp': offer.sdp});
  }

  Future<void> dispose() async {
    await localStream?.dispose();
    await _pc?.close();
  }
}

/// Runs on the Director — one instance per camera phone (one for Pastor,
/// one for Crowd), each writing into its own video renderer.
class DirectorPeerService {
  final SignalingServer signaling;
  final String role;
  final RTCVideoRenderer remoteRenderer;
  RTCPeerConnection? _pc;

  DirectorPeerService(this.signaling, this.role, this.remoteRenderer);

  Future<void> handleMessage(Map<String, dynamic> msg) async {
    if (msg['type'] == 'offer') {
      _pc = await createPeerConnection({
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'}
        ]
      });

      _pc!.onTrack = (event) {
        if (event.track.kind == 'video' && event.streams.isNotEmpty) {
          remoteRenderer.srcObject = event.streams[0];
        }
      };

      _pc!.onIceCandidate = (candidate) {
        signaling.send(role, {'type': 'ice', 'candidate': candidate.toMap()});
      };

      await _pc!
          .setRemoteDescription(RTCSessionDescription(msg['sdp'], 'offer'));
      final answer = await _pc!.createAnswer();
      await _pc!.setLocalDescription(answer);
      signaling.send(role, {'type': 'answer', 'sdp': answer.sdp});
    } else if (msg['type'] == 'ice') {
      final c = msg['candidate'];
      await _pc?.addCandidate(
          RTCIceCandidate(c['candidate'], c['sdpMid'], c['sdpMLineIndex']));
    }
  }

  Future<void> dispose() async {
    await _pc?.close();
  }
}
