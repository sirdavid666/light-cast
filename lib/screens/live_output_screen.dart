import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/camera_mode.dart';
import '../providers/camera_provider.dart';
import '../widgets/overlay_preview.dart';
import '../services/stream_service.dart';

class LiveOutputScreen extends ConsumerWidget {
  const LiveOutputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraMode = ref.watch(cameraModeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(children: [Expanded(child: _buildPreview(cameraMode))]),
            Positioned(
              top: 8,
              right: 8,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await StreamService.stopStream();
                  ref.read(isLiveProvider.notifier).state = false;
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.stop, size: 16),
                label: const Text('END LIVE', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(CameraMode mode) {
    switch (mode) {
      case CameraMode.pastor:
        return const OverlayPreview(mainLabel: 'PASTOR CAM');
      case CameraMode.crowd:
        return const OverlayPreview(mainLabel: 'CROWD CAM');
      case CameraMode.pipPastorMain:
        return const OverlayPreview(mainLabel: 'PASTOR CAM', pipLabel: 'CROWD PIP');
      case CameraMode.pipCrowdMain:
        return const OverlayPreview(mainLabel: 'CROWD CAM', pipLabel: 'PASTOR PIP');
    }
  }
}
