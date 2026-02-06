import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../theme/app_theme.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick and crop an image with 4:3 aspect ratio
  static Future<File?> pickAndCropImage({
    required BuildContext context,
    ImageSource source = ImageSource.gallery,
    bool cropEnabled = true,
  }) async {
    try {
      // Step 1: Pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1440,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      // Step 2: Crop image if enabled
      if (cropEnabled) {
        if (!context.mounted) return null;
        final croppedFile = await _cropImage(pickedFile.path, context);
        return croppedFile;
      }

      return File(pickedFile.path);
    } catch (e) {
      debugPrint('Error picking/cropping image: $e');
      return null;
    }
  }

  /// Crop image with 4:3 aspect ratio
  static Future<File?> _cropImage(
    String imagePath,
    BuildContext context,
  ) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
        compressQuality: 85,
        maxWidth: 1200,
        maxHeight: 900,
        uiSettings: [
          // Android UI Settings
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppTheme.primaryNavy,
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: AppTheme.premiumGold,
            initAspectRatio: CropAspectRatioPreset.ratio4x3,
            lockAspectRatio: true, // Lock to 4:3 ratio
            aspectRatioPresets: [CropAspectRatioPreset.ratio4x3],
          ),
          // iOS UI Settings
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
            rotateButtonsHidden: false,
            aspectRatioPresets: [CropAspectRatioPreset.ratio4x3],
          ),
          // Web UI Settings
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(width: 720, height: 540),
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }

      return null;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return null;
    }
  }

  /// Show image source selection dialog
  static Future<File?> showImageSourceDialog(BuildContext context) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
          title: Text(
            'Select Image Source',
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.primaryNavy,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: AppTheme.premiumGold),
                title: Text(
                  'Gallery',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.primaryNavy,
                  ),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppTheme.premiumGold),
                title: Text(
                  'Camera',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.primaryNavy,
                  ),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source != null && context.mounted) {
      return await pickAndCropImage(
        context: context,
        source: source,
        cropEnabled: true,
      );
    }

    return null;
  }
}
