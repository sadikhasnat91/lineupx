import 'dart:convert';

import 'package:flutter/material.dart';

/// Renders asset, network, blob, or base64 data images with a fallback widget.
class SmartImage extends StatelessWidget {
  final String? source;
  final BoxFit fit;
  final Widget fallback;
  final double? width;
  final double? height;

  const SmartImage({
    super.key,
    required this.source,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final value = source?.trim();
    if (value == null || value.isEmpty) return fallback;

    if (value.startsWith('data:image')) {
      try {
        final commaIndex = value.indexOf(',');
        if (commaIndex == -1) return fallback;
        final bytes = base64Decode(value.substring(commaIndex + 1));
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => fallback,
        );
      } catch (_) {
        return fallback;
      }
    }

    if (value.startsWith('assets/')) {
      return Image.asset(
        value,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return Image.network(
      value,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback,
      loadingBuilder: (_, child, progress) => progress == null ? child : fallback,
    );
  }
}
