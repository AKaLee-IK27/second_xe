import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_config.dart';

class StorageService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Upload image to Supabase Storage
  static Future<String> uploadImage(File imageFile, String bucketName) async {
    try {
      // Generate a unique file name
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';

      // Upload the file
      final response = await _client.storage
          .from(bucketName)
          .upload(fileName, imageFile);

      // Get the public URL
      final imageUrl = _client.storage.from(bucketName).getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Delete image from Supabase Storage
  static Future<void> deleteImage(String imageUrl, String bucketName) async {
    try {
      // Extract file name from URL
      final fileName = imageUrl.split('/').last;

      await _client.storage.from(bucketName).remove([fileName]);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Get image URL from Supabase Storage
  static String getImageUrl(String fileName, String bucketName) {
    return _client.storage.from(bucketName).getPublicUrl(fileName);
  }

  // Upload any file to Supabase Storage (e.g., log file)
  static Future<String> uploadFile(File file, String bucketName) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final response = await _client.storage
          .from(bucketName)
          .upload(fileName, file);
      final fileUrl = _client.storage.from(bucketName).getPublicUrl(fileName);
      return fileUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
}
