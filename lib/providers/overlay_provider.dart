import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Visibility Toggles
final showLogoProvider = StateProvider<bool>((ref) => true);
final showLyricsProvider = StateProvider<bool>((ref) => false);
final showScriptureProvider = StateProvider<bool>((ref) => false);
final showLowerThirdsProvider = StateProvider<bool>((ref) => false);
final showTickerProvider = StateProvider<bool>((ref) => true);

// Data
final logoPathProvider = StateProvider<File?>((ref) => null);
final lowerThirdsNameProvider = StateProvider<String>((ref) => '');
final lowerThirdsTitleProvider = StateProvider<String>((ref) => '');
final tickerTextProvider = StateProvider<String>((ref) => 'Welcome to The Light of God Worldwide Ministry — Oke-Aanu');

// NEW: Director-only Position + Size for cropable overlays
final lyricsPositionProvider = StateProvider<Offset>((ref) => const Offset(16, 16));
final scripturePositionProvider = StateProvider<Offset>((ref) => const Offset(16, 120));
final lyricsSizeProvider = StateProvider<Size>((ref) => const Size(double.infinity, 60));
final scriptureSizeProvider = StateProvider<Size>((ref) => const Size(double.infinity, 120));
