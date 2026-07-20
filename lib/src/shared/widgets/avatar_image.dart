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
