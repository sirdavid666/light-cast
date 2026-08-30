import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/overlay_provider.dart';

class LogoManagerScreen extends ConsumerStatefulWidget {
  const LogoManagerScreen({super.key});

  @override
  ConsumerState<LogoManagerScreen> createState() => _LogoManagerScreenState();
}

class _LogoManagerScreenState extends ConsumerState<LogoManagerScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickLogo() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ref.read(logoPathProvider.notifier).state = File(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final logoPath = ref.watch(logoPathProvider);
    final showLogo = ref.watch(showLogoProvider);
    final lowerName = ref.watch(lowerThirdsNameProvider);
    final lowerTitle = ref.watch(lowerThirdsTitleProvider);
    final lowerNameCtrl = TextEditingController(text: lowerName);
    final lowerTitleCtrl = TextEditingController(text: lowerTitle);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Logo & Overlays',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo section
            const Text('Church Logo',
                style: TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: logoPath == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image,
                              color: Colors.white30, size: 48),
                          SizedBox(height: 8),
                          Text('No logo uploaded',
                              style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(logoPath, fit: BoxFit.contain),
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickLogo,
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload Logo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(showLogoProvider.notifier).state = !showLogo;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(showLogo
                                ? 'Logo hidden'
                                : 'Logo shown on stream')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          showLogo ? Colors.green : Colors.grey[800],
                    ),
                    child: Text(showLogo ? 'Hide Logo' : 'Show Logo',
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Lower Thirds section
            const Text('Lower Thirds',
                style: TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: lowerNameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Name (e.g. Prophet Hamzat Shinayomi)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lowerTitleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Title (e.g. Senior Pastor)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ref.read(lowerThirdsNameProvider.notifier).state =
                    lowerNameCtrl.text;
                ref.read(lowerThirdsTitleProvider.notifier).state =
                    lowerTitleCtrl.text;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lower thirds updated')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: const Text('Save Lower Thirds',
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
