import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/attached_photo.dart';
import '../theme/app_theme.dart';
import 'attached_photo_view.dart';

class PhotoAttachField extends StatelessWidget {
  const PhotoAttachField({
    super.key,
    required this.photo,
    required this.onChanged,
    this.label = '사진 첨부',
    this.cameraLabel = '카메라로 촬영',
    this.galleryLabel = '갤러리에서 선택',
    this.removeLabel = '사진 삭제',
    this.dark = false,
    this.height = 148,
  });

  final AttachedPhoto? photo;
  final ValueChanged<AttachedPhoto?> onChanged;
  final String label;
  final String cameraLabel;
  final String galleryLabel;
  final String removeLabel;
  final bool dark;
  final double height;

  Future<void> _pick(BuildContext context, ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      onChanged(AttachedPhoto(filePath: file.path, bytes: bytes));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진을 가져오지 못했습니다. ($e)')),
      );
    }
  }

  Future<void> _showSourceSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: dark ? AppColors.chinguCard : Colors.white,
      builder: (context) {
        final color = dark ? Colors.white : AppColors.ink;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_camera_outlined, color: color),
                title: Text(cameraLabel, style: TextStyle(color: color)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: color),
                title: Text(galleryLabel, style: TextStyle(color: color)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
    if (selected == null || !context.mounted) return;
    await _pick(context, selected);
  }

  @override
  Widget build(BuildContext context) {
    final has = photo?.hasImage == true;
    final border = dark ? AppColors.chinguBorder : const Color(0xFFD4C8B4);
    final fill = dark ? AppColors.chinguCard : AppColors.canvasDeep;
    final fg = dark ? Colors.white70 : AppColors.ink;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => _showSourceSheet(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            clipBehavior: Clip.antiAlias,
            child: has
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      AttachedPhotoView(photo: photo!),
                      const Align(
                        alignment: Alignment.bottomCenter,
                        child: ColoredBox(
                          color: Color(0x88000000),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              '탭하여 사진 변경',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, color: fg, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: TextStyle(
                          color: fg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$cameraLabel · $galleryLabel',
                        style: TextStyle(
                          color: fg.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (has)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => onChanged(null),
              child: Text(removeLabel),
            ),
          ),
      ],
    );
  }
}

