import 'package:flutter/material.dart';
import '../services/signaling_service.dart';
import '../services/webrtc_service.dart';

class CameraClientScreen extends StatefulWidget {
  final String role; // 'pastor' or 'crowd'
  final String label; // 'PASTOR CAMERA' or 'CROWD CAMERA'

  const CameraClientScreen({super.key, required this.role, required this.label});

  @override
  State<CameraClientScreen> createState() => _CameraClientScreenState();
}

class _CameraClientScreenState extends State<CameraClientScreen> {
  final _ipController = TextEditingController();
  bool _connected = false;
  bool _connecting = false;
  String? _error;
  SignalingClient? _signaling;
  CameraPeerService? _peer;

  Future<void> _connect() async {
    setState(() {
      _connecting = true;
      _error = null;
    });
    try {
      _signaling = SignalingClient();
      await _signaling!.connect(_ipController.text.trim(), widget.role);
      _peer = CameraPeerService(_signaling!);
      await _peer!.start();
      setState(() {
        _connected = true;
        _connecting = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not connect: $e';
        _connecting = false;
      });
    }
  }

  @override
  void dispose() {
    _peer?.dispose();
    _signaling?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.label, style: const TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _connected ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(_connected ? 'Connected ●' : 'Not connected',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 32),
            if (!_connected) ...[
              TextField(
                controller: _ipController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Director phone's IP address",
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: 'e.g. 192.168.1.42',
                  hintStyle: TextStyle(color: Colors.white38),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30)),
                ),
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _connecting ? null : _connect,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                child: Text(_connecting ? 'Connecting...' : 'Connect',
                    style: const TextStyle(color: Colors.black)),
              ),
            ] else
              const Text(
                'Streaming to Director. Keep this screen open and this phone unlocked.',
                style: TextStyle(color: Colors.white70),
              ),
          ],
        ),
      ),
    );
  }
}
