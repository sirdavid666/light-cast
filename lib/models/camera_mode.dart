enum CameraMode {
  pastor,
  crowd,
  pipPastorMain,   // Pastor main + Crowd PIP
  pipCrowdMain,    // Crowd main + Pastor PIP
}

extension CameraModeExtension on CameraMode {
  String get displayName {
    switch (this) {
      case CameraMode.pastor:
        return 'Pastor Cam';
      case CameraMode.crowd:
        return 'Crowd Cam';
      case CameraMode.pipPastorMain:
        return 'PIP (Pastor Main)';
      case CameraMode.pipCrowdMain:
        return 'PIP (Crowd Main)';
    }
  }

  String get icon {
    switch (this) {
      case CameraMode.pastor:
        return '🎤';
      case CameraMode.crowd:
        return '👥';
      case CameraMode.pipPastorMain:
        return '🔲';
      case CameraMode.pipCrowdMain:
        return '🔳';
    }
  }
}
