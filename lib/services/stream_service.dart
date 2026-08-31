import 'package:flutter/services.dart';

class StreamService {
  static const _channel = MethodChannel('lightcast/rtmp');

  static Future<bool> requestScreenCapture() async {
    final granted = await _channel.invokeMethod<bool>('requestScreenCapture');
    return granted ?? false;
  }

  static Future<void> startStream({
    required String url,
    int width = 1280,
    int height = 720,
    int bitrate = 2500000,
    int fps = 30,
  }) async {
    await _channel.invokeMethod('startStream', {
      'url': url,
      'width': width,
      'height': height,
      'bitrate': bitrate,
      'fps': fps,
    });
  }

  static Future<void> stopStream() async {
    await _channel.invokeMethod('stopStream');
  }
}
