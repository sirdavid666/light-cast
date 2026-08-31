import 'dart:async';
import 'package:flutter/material.dart';

class AutoScrollLyrics extends StatefulWidget {
  final String title;
  final List<String> verses;

  const AutoScrollLyrics({super.key, required this.title, required this.verses});

  @override
  State<AutoScrollLyrics> createState() => _AutoScrollLyricsState();
}

class _AutoScrollLyricsState extends State<AutoScrollLyrics> {
  final ScrollController _controller = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  @override
  void didUpdateWidget(covariant AutoScrollLyrics oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.verses != widget.verses) {
      if (_controller.hasClients) _controller.jumpTo(0);
      _startScrolling();
    }
  }

  void _startScrolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (!_controller.hasClients) return;
      final max = _controller.position.maxScrollExtent;
      if (max <= 0) return;
      final next = _controller.offset + 0.6;
      if (next >= max) {
        _controller.jumpTo(0);
      } else {
        _controller.jumpTo(next);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 6),
        SizedBox(
          height: 70,
          child: ListView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            children: widget.verses
                .map((v) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(v,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 13)),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
