import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

ImageProvider<Object>? avatarImageProvider({
  String? base64Data,
  String? url,
}) {
  final encoded = base64Data?.trim();
  if (encoded != null && encoded.isNotEmpty) {
    try {
      final payload = encoded.contains(',') ? encoded.split(',').last : encoded;
      final Uint8List bytes = base64Decode(payload);
      if (bytes.isNotEmpty) return MemoryImage(bytes);
    } on FormatException {
      // Fall through to the legacy remote URL.
    }
  }

  final remoteUrl = url?.trim();
  return remoteUrl != null && remoteUrl.isNotEmpty
      ? NetworkImage(remoteUrl)
      : null;
}

class AvatarImage extends StatelessWidget {
  const AvatarImage({
    super.key,
    required this.radius,
    this.base64Data,
    this.url,
    this.fallbackText = '?',
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
  });

  final double radius;
  final String? base64Data;
  final String? url;
  final String fallbackText;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final image = avatarImageProvider(base64Data: base64Data, url: url);
    final fallback = Center(
      child: Text(
        fallbackText.isEmpty
            ? '?'
            : fallbackText.characters.first.toUpperCase(),
        style: textStyle ??
            TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
    final size = radius * 2;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ??
            Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: image == null
          ? fallback
          : Image(
              image: image,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback,
            ),
    );
  }
}
