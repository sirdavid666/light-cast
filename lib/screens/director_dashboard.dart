import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/camera_mode.dart';
import '../providers/camera_provider.dart';
import '../providers/overlay_provider.dart';
import '../providers/lyrics_provider.dart';
import '../providers/scripture_provider.dart';
import '../widgets/camera_button.dart';
import '../widgets/overlay_preview.dart';
import '../widgets/lyrics_bar.dart';
import 'lyrics_library_screen.dart';
import 'scripture_library_screen.dart';
import 'logo_manager_screen.dart';

class DirectorDashboard extends ConsumerStatefulWidget {
  const DirectorDashboard({super.key});

  @override
  ConsumerState<DirectorDashboard> createState() =>
      _DirectorDashboardState();
}

class _DirectorDashboardState extends ConsumerState<DirectorDashboard> {
  @override
  Widget build(BuildContext context) {
    final cameraMode = ref.watch(cameraModeProvider);
    final isLive = ref.watch(isLiveProvider);

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
                color: isLive ? Colors.red : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'LightCast Director',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_music, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const LyricsLibraryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.menu_book, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ScriptureLibraryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.image, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const LogoManagerScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Preview area
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                child: _buildPreview(cameraMode),
              ),
            ),

            // Camera mode buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: CameraMode.values.map<Widget>((mode) {
                  return CameraButton(
                    mode: mode,
                    isSelected: cameraMode == mode,
                    onTap: () =>
                        ref.read(cameraModeProvider.notifier).setMode(mode),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            // Overlay toggles
            _buildOverlayToggles(),

            const SizedBox(height: 12),

            // Lyrics bar
            const LyricsBar(),

            const Spacer(),

            // Go Live / End Live button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(isLiveProvider.notifier).state = !isLive;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isLive ? 'Stream ended' : 'Going LIVE...'),
                        backgroundColor: isLive ? Colors.grey : Colors.red,
                      ),
                    );
                  },
                  icon: Icon(isLive ? Icons.stop : Icons.fiber_manual_record,
                      color: Colors.white),
                  label: Text(
                    isLive ? 'END LIVE' : 'GO LIVE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLive ? Colors.grey[800] : Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
        return const OverlayPreview(
          mainLabel: 'PASTOR CAM',
          pipLabel: 'CROWD PIP',
        );
      case CameraMode.pipCrowdMain:
        return const OverlayPreview(
          mainLabel: 'CROWD CAM',
          pipLabel: 'PASTOR PIP',
        );
    }
  }

  Widget _buildOverlayToggles() {
    final showLogo = ref.watch(showLogoProvider);
    final showLyrics = ref.watch(showLyricsProvider);
    final showScripture = ref.watch(showScriptureProvider);
    final showLowerThirds = ref.watch(showLowerThirdsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _toggleChip('Logo', showLogo, (v) => ref.read(showLogoProvider.notifier).state = v),
          _toggleChip('Lyrics', showLyrics, (v) => ref.read(showLyricsProvider.notifier).state = v),
          _toggleChip('Scripture', showScripture, (v) => ref.read(showScriptureProvider.notifier).state = v),
          _toggleChip('Lower 3rd', showLowerThirds, (v) => ref.read(showLowerThirdsProvider.notifier).state = v),
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
      labelStyle: TextStyle(color: value ? Colors.black : Colors.white),
    );
  }
}
