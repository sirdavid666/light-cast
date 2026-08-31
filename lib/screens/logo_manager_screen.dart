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
  late final TextEditingController _tickerCtrl;
  late final TextEditingController _lowerNameCtrl;
  late final TextEditingController _lowerTitleCtrl;

  @override
  void initState() {
    super.initState();
    // Initialize once from providers
    _tickerCtrl = TextEditingController(text: ref.read(tickerTextProvider));
    _lowerNameCtrl = TextEditingController(text: ref.read(lowerThirdsNameProvider));
    _lowerTitleCtrl = TextEditingController(text: ref.read(lowerThirdsTitleProvider));
  }

  @override
  void dispose() {
    _tickerCtrl.dispose();
    _lowerNameCtrl.dispose();
    _lowerTitleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file!= null) {
      ref.read(logoPathProvider.notifier).state = File(file.path);
    }
  }

  void _clearLogo() {
    ref.read(logoPathProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final logoPath = ref.watch(logoPathProvider);
    final showLogo = ref.watch(showLogoProvider);

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
            _sectionTitle('Church Logo'),
            const SizedBox(height: 12),
            _logoPreview(logoPath),
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
                  child: OutlinedButton.icon(
                    onPressed: _clearLogo,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white30),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final newState =!showLogo;
                ref.read(showLogoProvider.notifier).state = newState;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(newState? 'Logo shown on stream' : 'Logo hidden'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: showLogo? Colors.green : Colors.grey[800],
              ),
              child: Text(
                showLogo? 'Hide Logo' : 'Show Logo',
                style: const TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 24),
            _sectionTitle('Scrolling Ticker Text'),
            const SizedBox(height: 12),
            TextField(
              controller: _tickerCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Text that scrolls along the bottom'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ref.read(tickerTextProvider.notifier).state = _tickerCtrl.text;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ticker text updated')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: const Text('Save Ticker Text', style: TextStyle(color: Colors.black)),
            ),

            const SizedBox(height: 24),
            _sectionTitle('Lower Thirds'),
            const SizedBox(height: 12),
            TextField(
              controller: _lowerNameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Name (e.g. Prophet Hamzat Shinayomi)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lowerTitleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Title (e.g. Senior Pastor)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ref.read(lowerThirdsNameProvider.notifier).state = _lowerNameCtrl.text;
                ref.read(lowerThirdsTitleProvider.notifier).state = _lowerTitleCtrl.text;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lower thirds updated')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: const Text('Save Lower Thirds', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.amber,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white30),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.amber),
      ),
    );
  }

  Widget _logoPreview(File? logoPath) {
    return Container(
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
                  Icon(Icons.image, color: Colors.white30, size: 48),
                  SizedBox(height: 8),
                  Text('No logo uploaded', style: TextStyle(color: Colors.white54)),
                ],
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(logoPath, fit: BoxFit.contain),
            ),
    );
  }
}
