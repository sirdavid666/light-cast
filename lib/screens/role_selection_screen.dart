import 'package:flutter/material.dart';
import 'director_dashboard.dart';
import 'camera_client_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                const Text('LightCast',
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 32,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 48),
                _roleButton(
                  context,
                  label: 'Director Console',
                  filled: true,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DirectorDashboard()),
                  ),
                ),
                const SizedBox(height: 16),
                _roleButton(
                  context,
                  label: 'Pastor Camera',
                  filled: false,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CameraClientScreen(
                            role: 'pastor', label: 'PASTOR CAMERA')),
                  ),
                ),
                const SizedBox(height: 16),
                _roleButton(
                  context,
                  label: 'Crowd Camera',
                  filled: false,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CameraClientScreen(
                            role: 'crowd', label: 'CROWD CAMERA')),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleButton(BuildContext context,
      {required String label, required bool filled, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: filled
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: onTap,
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            )
          : OutlinedButton(
              onPressed: onTap,
              child: Text(label, style: const TextStyle(color: Colors.white)),
            ),
    );
  }
}
