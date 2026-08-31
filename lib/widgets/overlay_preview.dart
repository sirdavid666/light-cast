import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/overlay_provider.dart';

class OverlayPreview extends ConsumerWidget {
  final String mainLabel;
  final String? pipLabel;

  const OverlayPreview({
    super.key,
    required this.mainLabel,
    this.pipLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showLogo = ref.watch(showLogoProvider);
    final showLyrics = ref.watch(showLyricsProvider);
    final showScripture = ref.watch(showScriptureProvider);
    final showLowerThirds = ref.watch(showLowerThirdsProvider);
    final logoPath = ref.watch(logoPathProvider);
    final lowerName = ref.watch(lowerThirdsNameProvider);
    final lowerTitle = ref.watch(lowerThirdsTitleProvider);
    final selectedSong = ref.watch(selectedSongProvider);
    final selectedScripture = ref.watch(selectedScriptureProvider);

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Main camera feed placeholder
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam, color: Colors.white54, size: 64),
                  const SizedBox(height: 12),
                  Text(
                    mainLabel,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // PIP
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person, color: Colors.white54, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        pipLabel!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Church Logo Overlay
            if (showLogo && logoPath != null)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      logoPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

            // Lower Thirds
            if (showLowerThirds && lowerName.isNotEmpty)
              Positioned(
                bottom: 80,
                left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      left: BorderSide(color: Colors.amber, width: 4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lowerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        lowerTitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Scripture Overlay
            if (showScripture && selectedScripture != null)
              Positioned(
                top: 120,
                left: 16,
                right: 16,
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
                      Text(
                        selectedScripture.reference,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedScripture.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Lyrics Overlay (top area)
            if (showLyrics && selectedSong != null)
              Positioned(
                top: pipLabel != null ? 110 : 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    selectedSong.title,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
