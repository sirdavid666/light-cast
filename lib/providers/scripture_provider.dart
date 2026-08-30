import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scripture.dart';
import '../utils/database_helper.dart';

final scriptureListProvider =
    StateNotifierProvider<ScriptureNotifier, AsyncValue<List<Scripture>>>((ref) {
  return ScriptureNotifier();
});

final selectedScriptureProvider = StateProvider<Scripture?>((ref) => null);

class ScriptureNotifier extends StateNotifier<AsyncValue<List<Scripture>>> {
  final DatabaseHelper _db = DatabaseHelper();

  ScriptureNotifier() : super(const AsyncValue.loading()) {
    loadScriptures();
  }

  Future<void> loadScriptures() async {
    state = const AsyncValue.loading();
    try {
      final scriptures = await _db.getAllScriptures();
      state = AsyncValue.data(scriptures);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addScripture(Scripture scripture) async {
    await _db.insertScripture(scripture);
    await loadScriptures();
  }

  Future<void> updateScripture(Scripture scripture) async {
    await _db.updateScripture(scripture);
    await loadScriptures();
  }

  Future<void> deleteScripture(int id) async {
    await _db.deleteScripture(id);
    await loadScriptures();
  }
}
