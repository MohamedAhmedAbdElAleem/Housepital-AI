import 'package:flutter/material.dart';

/// Decorative background blobs used across doctor pages.
///
/// Wraps a child widget inside a [Stack] and positions two gradient
/// circles at the top-right and middle-left, creating the signature
/// Glass & Grid depth effect.
class BackgroundBlobs extends StatelessWidget {
  const BackgroundBlobs({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-right blob.
        Positioned(
          top: -120,
          right: -80,
          child: _Blob(
            size: 280,
            colors: const [Color(0x2A2664EC), Color(0x003498BB)],
          ),
        ),
        // Middle-left blob.
        Positioned(
          top: 220,
          left: -100,
          child: _Blob(
            size: 240,
            colors: const [Color(0x1A1136A8), Color(0x002664EC)],
          ),
        ),
        // Actual content layered on top.
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
    );
  }
}
