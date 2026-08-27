import 'package:flutter/material.dart';

import '../models/attached_photo.dart';

class AttachedPhotoView extends StatelessWidget {
  const AttachedPhotoView({
    super.key,
    required this.photo,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final AttachedPhoto photo;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (photo.bytes != null && photo.bytes!.isNotEmpty) {
      image = Image.memory(photo.bytes!, fit: fit);
    } else if (photo.assetPath != null && photo.assetPath!.isNotEmpty) {
      image = Image.asset(
        photo.assetPath!,
        fit: fit,
        errorBuilder: (_, _, _) => const ColoredBox(
          color: Color(0xFFE6DCC8),
          child: Center(child: Icon(Icons.broken_image_outlined)),
        ),
      );
    } else {
      image = const ColoredBox(
        color: Color(0xFFE6DCC8),
        child: Center(child: Icon(Icons.image_outlined)),
      );
    }

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
