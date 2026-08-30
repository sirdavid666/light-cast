import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final showLogoProvider = StateProvider<bool>((ref) => false);
final showLyricsProvider = StateProvider<bool>((ref) => false);
final showScriptureProvider = StateProvider<bool>((ref) => false);
final showLowerThirdsProvider = StateProvider<bool>((ref) => false);

final logoPathProvider = StateProvider<File?>((ref) => null);
final lowerThirdsNameProvider = StateProvider<String>((ref) => '');
final lowerThirdsTitleProvider = StateProvider<String>((ref) => '');
