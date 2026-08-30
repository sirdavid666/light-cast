import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/song.dart';
import '../utils/database_helper.dart';

final lyricsListProvider =
    StateNotifierProvider<LyricsNotifier, AsyncValue<List<Song>>>((ref) {
  return LyricsNotifier();
});

final selectedSongProvider = StateProvider<Song?>((ref) => null);

class LyricsNotifier extends StateNotifier<AsyncValue<List<Song>>> {
  final DatabaseHelper _db = DatabaseHelper();

  LyricsNotifier() : super(const AsyncValue.loading()) {
    loadSongs();
  }

  Future<void> loadSongs() async {
    state = const AsyncValue.loading();
    try {
      final songs = await _db.getAllSongs();
      state = AsyncValue.data(songs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addSong(Song song) async {
    await _db.insertSong(song);
    await loadSongs();
  }

  Future<void> updateSong(Song song) async {
    await _db.updateSong(song);
    await loadSongs();
  }

  Future<void> deleteSong(int id) async {
    await _db.deleteSong(id);
    await loadSongs();
  }
}
