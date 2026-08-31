import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/camera_mode.dart';

final cameraModeProvider = StateNotifierProvider<CameraNotifier, CameraMode>((ref) {
  return CameraNotifier();
});

class CameraNotifier extends StateNotifier<CameraMode> {
  CameraNotifier() : super(CameraMode.pastor);

  void setMode(CameraMode mode) {
    state = mode;
  }

  void cycleMode() {
    final values = CameraMode.values;
    final currentIndex = values.indexOf(state);
    state = values[(currentIndex + 1) % values.length];
  }
}

final isLiveProvider = StateProvider<bool>((ref) => false);
