import 'dart:typed_data';

/// Local photo chosen from camera/gallery, or a bundled demo asset.
class AttachedPhoto {
  const AttachedPhoto({
    this.assetPath,
    this.filePath,
    this.bytes,
  });

  final String? assetPath;
  final String? filePath;
  final Uint8List? bytes;

  bool get hasImage =>
      (assetPath != null && assetPath!.isNotEmpty) ||
      (filePath != null && filePath!.isNotEmpty) ||
      (bytes != null && bytes!.isNotEmpty);

  static AttachedPhoto? fromParts({
    String? assetPath,
    String? filePath,
    Uint8List? bytes,
  }) {
    final photo = AttachedPhoto(
      assetPath: assetPath,
      filePath: filePath,
      bytes: bytes,
    );
    return photo.hasImage ? photo : null;
  }
}
