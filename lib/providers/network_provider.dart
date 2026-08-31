import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../services/signaling_service.dart';
import '../services/webrtc_service.dart';

final directorIpProvider = FutureProvider<String?>((ref) async {
  return await NetworkInfo().getWifiIP();
});

final pastorVideoRendererProvider =
    Provider<RTCVideoRenderer>((ref) => RTCVideoRenderer());
final crowdVideoRendererProvider =
    Provider<RTCVideoRenderer>((ref) => RTCVideoRenderer());

final pastorConnectedProvider = StateProvider<bool>((ref) => false);
final crowdCameraConnectedProvider = StateProvider<bool>((ref) => false);

final pastorStatusProvider = StateProvider<String>((ref) => '');
final crowdStatusProvider = StateProvider<String>((ref) => '');

final directorSignalingProvider = Provider<SignalingServer>((ref) {
  final server = SignalingServer();
  final pastorRenderer = ref.watch(pastorVideoRendererProvider);
  final crowdRenderer = ref.watch(crowdVideoRendererProvider);
  pastorRenderer.initialize();
  crowdRenderer.initialize();

  final pastorPeer = DirectorPeerService(server, 'pastor', pastorRenderer);
  final crowdPeer = DirectorPeerService(server, 'crowd', crowdRenderer);
  pastorPeer.onStateChange = (s) => ref.read(pastorStatusProvider.notifier).state = s;
  crowdPeer.onStateChange = (s) => ref.read(crowdStatusProvider.notifier).state = s;

  server.onClientConnected = (role) {
    if (role == 'pastor') ref.read(pastorConnectedProvider.notifier).state = true;
    if (role == 'crowd') ref.read(crowdCameraConnectedProvider.notifier).state = true;
  };
  server.onClientDisconnected = (role) {
    if (role == 'pastor') ref.read(pastorConnectedProvider.notifier).state = false;
    if (role == 'crowd') ref.read(crowdCameraConnectedProvider.notifier).state = false;
  };
  server.onMessage = (role, msg) {
    if (role == 'pastor') pastorPeer.handleMessage(msg);
    if (role == 'crowd') crowdPeer.handleMessage(msg);
  };

  server.start();
  ref.onDispose(() {
    pastorPeer.dispose();
    crowdPeer.dispose();
    server.stop();
  });
  return server;
});
