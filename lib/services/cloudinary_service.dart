import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';

class CloudinaryService {
  static const String _cloudName = 'YOUR_CLOUD_NAME';
  static const String _uploadPreset = 'YOUR_UPLOAD_PRESET';

  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    _cloudName,
    _uploadPreset,
    cache: false,
  );

  Future<String?> uploadImage(File imageFile) async {
    try {
      // Upload the image with folder organization
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'profile_images', // Organizes images in a folder
        ),
      );

      debugPrint('Image uploaded successfully: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      debugPrint('Error uploading image to Cloudinary: $e');
      return null;
    }
  }
}
