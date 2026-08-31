import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/camera_mode.dart';
import '../providers/camera_provider.dart';
import '../providers/overlay_provider.dart';
import '../providers/network_provider.dart';
import '../widgets/camera_button.dart';
import '../widgets/overlay_preview.dart';
import '../widgets/lyrics_bar.dart';
import '../services/stream_service.dart';
import 'lyrics_library_screen.dart';
import 'scripture_library_screen.dart';
import 'logo_manager_screen.dart';

class DirectorDashboard extends ConsumerStatefulWidget {
  const DirectorDashboard({super.key});

  @override
  ConsumerState<DirectorDashboard> createState() => _DirectorDashboardState();
}

class _DirectorDashboardState extends ConsumerState<DirectorDashboard> {
  @override
  Widget build(BuildContext context) {
    ref.watch(directorSignalingProvider); // starts the local signaling server
    final cameraMode = ref.watch(cameraModeProvider);
    final isLive = ref.watch(isLiveProvider);
    final ipAsync = ref.watch(directorIpProvider);
    final pastorConnected = ref.watch(pastorConnectedProvider);
    final crowdConnected = ref.watch(crowdCameraConnectedProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isLive? Colors.red : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('LightCast Director',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ipAsync.when(
                    data: (ip) => Text('IP: ${ip?? "unknown"}',
                        style: const TextStyle(color: Colors.white38, fontSize: 10)),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_music, color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LyricsLibraryScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.menu_book, color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ScriptureLibraryScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.image, color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LogoManagerScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.42,
                child: _buildPreview(cameraMode),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statusDot('Pastor', pastorConnected),
                  _statusDot('Crowd', crowdConnected),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: CameraMode.values.map((mode) {
                  return CameraButton(
                    mode: mode,
                    isSelected: cameraMode == mode,
                    onTap: () => ref.read(cameraModeProvider.notifier).setMode(mode),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _buildOverlayToggles(),
            const SizedBox(height: 12),
            const LyricsBar(),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _handleGoLive(context, isLive),
                  icon: Icon(isLive? Icons.stop : Icons.fiber_manual_record,
                      color: Colors.white),
                  label: Text(
                    isLive? 'END LIVE' : 'GO LIVE',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLive? Colors.grey[800] : Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusDot(String label, bool connected) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: connected? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Future<void> _handleGoLive(BuildContext context, bool currentlyLive) async {
    if (!currentlyLive) {
      final url = await _promptForRtmpUrl(context);
      if (url == null || url.trim().isEmpty) return;

      bool granted = false;
      try {
        granted = await StreamService.requestScreenCapture();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
             .showSnackBar(SnackBar(content: Text('Screen capture error: $e')));
        }
        return;
      }
      if (!granted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Screen capture permission denied')));
        }
        return;
      }

      try {
        await StreamService.startStream(url: url.trim());
        ref.read(isLiveProvider.notifier).state = true;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Going LIVE...'), backgroundColor: Colors.red));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
             .showSnackBar(SnackBar(content: Text('Failed to start stream: $e')));
        }
      }
    } else {
      await StreamService.stopStream();
      ref.read(isLiveProvider.notifier).state = false;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stream ended'), backgroundColor: Colors.grey));
      }
    }
  }

  Future<String?> _promptForRtmpUrl(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Facebook Live RTMP URL', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'rtmps://live-api-s.facebook.com:443/rtmp/YOUR-KEY',
            hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
            enabledBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Go Live', style: TextStyle(color: Colors.black)),
          ),
        ],
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

  Widget _buildOverlayToggles() {
    final showLogo = ref.watch(showLogoProvider);
    final showLyrics = ref.watch(showLyricsProvider);
    final showScripture = ref.watch(showScriptureProvider);
    final showLowerThirds = ref.watch(showLowerThirdsProvider);
    final showTicker = ref.watch(showTickerProvider); // ADDED

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _toggleChip(
              'Logo', showLogo, (v) => ref.read(showLogoProvider.notifier).state = v),
          _toggleChip('Lyrics', showLyrics,
              (v) => ref.read(showLyricsProvider.notifier).state = v),
          _toggleChip('Scripture', showScripture,
              (v) => ref.read(showScriptureProvider.notifier).state = v),
          _toggleChip('Lower 3rd', showLowerThirds,
              (v) => ref.read(showLowerThirdsProvider.notifier).state = v),
          _toggleChip('Ticker', showTicker, // ADDED
              (v) => ref.read(showTickerProvider.notifier).state = v),
        ],
      ),
    );
  }

  Widget _toggleChip(String label, bool value, ValueChanged<bool> onChanged) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: value,
      onSelected: onChanged,
      selectedColor: Colors.amber,
      backgroundColor: Colors.grey[800],
      labelStyle: TextStyle(color: value? Colors.black : Colors.white),
    );
  }
}
