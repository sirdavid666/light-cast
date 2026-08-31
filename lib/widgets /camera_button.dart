import 'package:flutter/material.dart';
import '../models/camera_mode.dart';

class CameraButton extends StatelessWidget {
  final CameraMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const CameraButton({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.grey[600]!,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mode.icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              mode.displayName,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
