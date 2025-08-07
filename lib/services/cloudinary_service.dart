import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';

class CloudinaryService {
  static const String _cloudName = 'YOUR_CLOUD_NAME'; // Replace with your Cloudinary cloud name
  static const String _uploadPreset = 'YOUR_UPLOAD_PRESET'; // Replace with your upload preset

  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    _cloudName,
    _uploadPreset,
    cache: false,
  );

  /// Uploads an image file to Cloudinary and returns the secure URL
  /// Returns null if upload fails
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

/// Note: The cloudinary_public package doesn't support image deletion
/// from the client side. Image deletion should be handled from your backend
/// or through Cloudinary's admin API for security reasons.
///
/// For now, we'll just keep the old image URLs in the database
/// and let Cloudinary handle unused image cleanup through their
/// auto-moderation features or manual cleanup.
}
