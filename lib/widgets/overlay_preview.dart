import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../providers/overlay_provider.dart';
import '../providers/network_provider.dart';
import 'scrolling_ticker.dart';

class OverlayPreview extends ConsumerWidget {
  final String mainLabel;
  final String? pipLabel;

  const OverlayPreview({super.key, required this.mainLabel, this.pipLabel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showLogo = ref.watch(showLogoProvider);
    final showLyrics = ref.watch(showLyricsProvider);
    final showScripture = ref.watch(showScriptureProvider);
    final showLowerThirds = ref.watch(showLowerThirdsProvider);
    final showTicker = ref.watch(showTickerProvider);
    final tickerText = ref.watch(tickerTextProvider);
    final logoPath = ref.watch(logoPathProvider);
    final lowerName = ref.watch(lowerThirdsNameProvider);
    final lowerTitle = ref.watch(lowerThirdsTitleProvider);
    final selectedSong = ref.watch(selectedSongProvider);
    final selectedScripture = ref.watch(selectedScriptureProvider);

    final lyricsPos = ref.watch(lyricsPositionProvider);
    final scripturePos = ref.watch(scripturePositionProvider);

    final pastorRenderer = ref.watch(pastorVideoRendererProvider);
    final crowdRenderer = ref.watch(crowdVideoRendererProvider);
    final pastorConnected = ref.watch(pastorConnectedProvider);
    final crowdConnected = ref.watch(crowdCameraConnectedProvider);

    final isMainPastor = mainLabel == 'PASTOR CAM';
    final mainRenderer = isMainPastor ? pastorRenderer : crowdRenderer;
    final mainConnected = isMainPastor ? pastorConnected : crowdConnected;

    return Expanded(
      child: Container(
        decoration:
            BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Main feed
              Positioned.fill(
                child: mainConnected
                    ? RTCVideoView(mainRenderer,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
                    : Center(
                        child: Text(
                          'Waiting for ${isMainPastor ? "Pastor" : "Crowd"} Camera to connect...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ),
              ),

              // PIP feed
              if (pipLabel != null)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    width: 120,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (isMainPastor ? crowdConnected : pastorConnected)
                          ? RTCVideoView(isMainPastor ? crowdRenderer : pastorRenderer,
                              objectFit:
                                  RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
                          : const Center(
                              child: Icon(Icons.person, color: Colors.white54, size: 24),
                            ),
                    ),
                  ),
                ),

              // Church Logo Overlay
              if (showLogo && logoPath != null)
                Positioned(
                  top: 16,
                  left: 16,
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(logoPath, fit: BoxFit.contain),
                    ),
                  ),
                ),

              // Lower Thirds
              if (showLowerThirds && lowerName.isNotEmpty)
                Positioned(
                  bottom: 80,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(8),
                      border: const Border(left: BorderSide(color: Colors.amber, width: 4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lowerName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text(lowerTitle,
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ),

              // Scripture Overlay - NOW DRAGGABLE
              if (showScripture && selectedScripture != null)
                Positioned(
                  top: scripturePos.dy,
                  left: scripturePos.dx,
                  right: 16,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      ref.read(scripturePositionProvider.notifier).state = Offset(
                        scripturePos.dx + details.delta.dx,
                        scripturePos.dy + details.delta.dy,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selectedScripture.reference,
                              style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(selectedScripture.text,
                              style: const TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),

              // Lyrics Overlay - NOW DRAGGABLE
              if (showLyrics && selectedSong != null)
                Positioned(
                  top: lyricsPos.dy,
                  left: lyricsPos.dx,
                  right: 16,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      ref.read(lyricsPositionProvider.notifier).state = Offset(
                        lyricsPos.dx + details.delta.dx,
                        lyricsPos.dy + details.delta.dy,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        selectedSong.title,
                        style: const TextStyle(
                            color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

              // Scrolling ticker
              if (showTicker)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ScrollingTicker(text: tickerText),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
