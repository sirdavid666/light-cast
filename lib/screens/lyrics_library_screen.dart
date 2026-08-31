import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/song.dart';
import '../providers/lyrics_provider.dart';

class LyricsLibraryScreen extends ConsumerStatefulWidget {
  const LyricsLibraryScreen({super.key});

  @override
  ConsumerState<LyricsLibraryScreen> createState() =>
      _LyricsLibraryScreenState();
}

class _LyricsLibraryScreenState extends ConsumerState<LyricsLibraryScreen> {
  @override
  Widget build(BuildContext context) {
    final lyricsState = ref.watch(lyricsListProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Lyrics Library',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: lyricsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e',
            style: const TextStyle(color: Colors.white))),
        data: (songs) {
          if (songs.isEmpty) {
            return const Center(
              child: Text('No songs yet',
                  style: TextStyle(color: Colors.white54)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(song.title,
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  subtitle: Text('${song.verses.length} verses',
                      style: const TextStyle(color: Colors.white70)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.amber),
                        onPressed: () {
                          ref.read(selectedSongProvider.notifier).state = song;
                          ref.read(showLyricsProvider.notifier).state = true;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Song displayed on stream')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showSongDialog(song: song),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            ref.read(lyricsListProvider.notifier).deleteSong(song.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () => _showSongDialog(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _showSongDialog({Song? song}) {
    final titleController = TextEditingController(text: song?.title ?? '');
    final versesController = TextEditingController(
        text: song?.verses.join('\n\n') ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(song == null ? 'Add Song' : 'Edit Song',
            style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: versesController,
              style: const TextStyle(color: Colors.white),
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Verses (separate with blank line)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              final newSong = Song(
                id: song?.id,
                title: titleController.text.trim(),
                verses: versesController.text
                    .split('\n\n')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList(),
              );
              if (song == null) {
                ref.read(lyricsListProvider.notifier).addSong(newSong);
              } else {
                ref.read(lyricsListProvider.notifier).updateSong(newSong);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
