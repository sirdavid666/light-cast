import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scripture.dart';
import '../providers/scripture_provider.dart';
import '../providers/overlay_provider.dart';

class ScriptureLibraryScreen extends ConsumerStatefulWidget {
  const ScriptureLibraryScreen({super.key});

  @override
  ConsumerState<ScriptureLibraryScreen> createState() =>
      _ScriptureLibraryScreenState();
}

class _ScriptureLibraryScreenState
    extends ConsumerState<ScriptureLibraryScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scriptureListProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Scripture Library',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e',
            style: const TextStyle(color: Colors.white))),
        data: (scriptures) {
          if (scriptures.isEmpty) {
            return const Center(
              child: Text('No scriptures yet',
                  style: TextStyle(color: Colors.white54)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: scriptures.length,
            itemBuilder: (context, index) {
              final s = scriptures[index];
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(s.reference,
                      style: const TextStyle(color: Colors.amber,
                          fontWeight: FontWeight.bold)),
                  subtitle: Text(s.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.amber),
                        onPressed: () {
                          ref.read(selectedScriptureProvider.notifier).state = s;
                          ref.read(showScriptureProvider.notifier).state = true;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Scripture displayed on stream')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showScriptureDialog(scripture: s),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => ref
                            .read(scriptureListProvider.notifier)
                            .deleteScripture(s.id!),
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
        onPressed: () => _showScriptureDialog(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _showScriptureDialog({Scripture? scripture}) {
    final refController =
        TextEditingController(text: scripture?.reference ?? '');
    final textController =
        TextEditingController(text: scripture?.text ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(scripture == null ? 'Add Scripture' : 'Edit Scripture',
            style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: refController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Reference (e.g. John 3:16)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              style: const TextStyle(color: Colors.white),
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Text',
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
              final newS = Scripture(
                id: scripture?.id,
                reference: refController.text.trim(),
                text: textController.text.trim(),
              );
              if (scripture == null) {
                ref.read(scriptureListProvider.notifier).addScripture(newS);
              } else {
                ref.read(scriptureListProvider.notifier).updateScripture(newS);
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
