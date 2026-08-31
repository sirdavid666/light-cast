import 'package:flutter/material.dart';

class ScrollingTicker extends StatefulWidget {
  final String text;

  const ScrollingTicker({super.key, required this.text});

  @override
  State<ScrollingTicker> createState() => _ScrollingTickerState();
}

class _ScrollingTickerState extends State<ScrollingTicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant ScrollingTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.reset();
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      height: 32,
      color: Colors.black.withOpacity(0.75),
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final offset =
                    constraints.maxWidth - (_controller.value * constraints.maxWidth * 2);
                return Stack(
                  children: [
                    Positioned(
                      left: offset,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Text(
                          widget.text,
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          softWrap: false,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
