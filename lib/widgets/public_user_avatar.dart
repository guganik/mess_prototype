import 'dart:io';

import 'package:flutter/material.dart';

class PublicUserAvatar extends StatelessWidget {
  final String? localPath;
  final String username;
  final double size;

  const PublicUserAvatar({
    super.key,
    required this.localPath,
    required this.username,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        localPath != null &&
        localPath!.isNotEmpty;

    if (hasAvatar) {
      final file = File(localPath!);

      if (file.existsSync()) {
        return ClipOval(
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return _placeholder();
            },
          ),
        );
      }
    }

    return _placeholder();
  }

  Widget _placeholder() {
    final letter = username.isNotEmpty
        ? username[0].toUpperCase()
        : '?';

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromRGBO(
          75,
          75,
          75,
          0.35,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}