import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

/// Storage service for Firebase Storage operations
/// Handles image upload/download as binary data
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Storage paths
  static const String reportsPath = 'images/reports';
  static const String rescuesPath = 'images/rescues';
  static const String medicalPath = 'images/medical';
  static const String profilesPath = 'images/profiles';

  // ==================== IMAGE UPLOAD ====================

  /// Upload image for animal report
  /// Returns the storage reference path
  Future<String> uploadReportImage({
    required String reportId,
    required File imageFile,
  }) async {
    try {
      final String fileName = '${reportId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = '$reportsPath/$fileName';

      final ref = _storage.ref().child(path);
      
      // Upload as binary data
      final bytes = await imageFile.readAsBytes();
      await ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'reportId': reportId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      return path;
    } catch (e) {
      throw Exception('Failed to upload report image: $e');
    }
  }

  /// Upload image from bytes (for camera capture)
  Future<String> uploadImageFromBytes({
    required String folder,
    required String id,
    required Uint8List bytes,
  }) async {
    try {
      final String fileName = '${id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = 'images/$folder/$fileName';

      final ref = _storage.ref().child(path);
      
      await ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'id': id,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      return path;
    } catch (e) {
      throw Exception('Failed to upload image from bytes: $e');
    }
  }

  /// Upload rescue image
  Future<String> uploadRescueImage({
    required String reportId,
    required File imageFile,
  }) async {
    try {
      final String fileName = '${reportId}_rescue_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = '$rescuesPath/$fileName';

      final ref = _storage.ref().child(path);
      final bytes = await imageFile.readAsBytes();
      
      await ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'reportId': reportId,
            'type': 'rescue',
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      return path;
    } catch (e) {
      throw Exception('Failed to upload rescue image: $e');
    }
  }

  /// Upload medical image
  Future<String> uploadMedicalImage({
    required String recordId,
    required File imageFile,
  }) async {
    try {
      final String fileName = '${recordId}_medical_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = '$medicalPath/$fileName';

      final ref = _storage.ref().child(path);
      final bytes = await imageFile.readAsBytes();
      
      await ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'recordId': recordId,
            'type': 'medical',
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      return path;
    } catch (e) {
      throw Exception('Failed to upload medical image: $e');
    }
  }

  /// Upload profile picture
  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final String fileName = '$userId.jpg';
      final String path = '$profilesPath/$fileName';

      final ref = _storage.ref().child(path);
      final bytes = await imageFile.readAsBytes();
      
      await ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      return path;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  // ==================== IMAGE DOWNLOAD ====================

  /// Get download URL for an image
  /// This URL can be used to display the image
  Future<String> getImageUrl(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get image URL: $e');
    }
  }

  /// Download image as bytes
  /// Useful for offline caching or image processing
  Future<Uint8List?> downloadImageBytes(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      return await ref.getData();
    } catch (e) {
      throw Exception('Failed to download image bytes: $e');
    }
  }

  /// Download image to file
  Future<File> downloadImageToFile(String storagePath, String localPath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final file = File(localPath);
      await ref.writeToFile(file);
      return file;
    } catch (e) {
      throw Exception('Failed to download image to file: $e');
    }
  }

  // ==================== IMAGE DELETION ====================

  /// Delete image from storage
  Future<void> deleteImage(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Delete multiple images
  Future<void> deleteImages(List<String> storagePaths) async {
    try {
      for (final path in storagePaths) {
        await deleteImage(path);
      }
    } catch (e) {
      throw Exception('Failed to delete images: $e');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Get metadata for an image
  Future<FullMetadata> getImageMetadata(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      return await ref.getMetadata();
    } catch (e) {
      throw Exception('Failed to get image metadata: $e');
    }
  }

  /// List all images in a folder
  Future<List<String>> listImagesInFolder(String folderPath) async {
    try {
      final ref = _storage.ref().child(folderPath);
      final result = await ref.listAll();
      
      return result.items.map((item) => item.fullPath).toList();
    } catch (e) {
      throw Exception('Failed to list images: $e');
    }
  }

  /// Get storage usage statistics
  Future<Map<String, dynamic>> getStorageStats(String folderPath) async {
    try {
      final ref = _storage.ref().child(folderPath);
      final result = await ref.listAll();
      
      int totalSize = 0;
      int fileCount = result.items.length;

      for (final item in result.items) {
        final metadata = await item.getMetadata();
        totalSize += metadata.size ?? 0;
      }

      return {
        'fileCount': fileCount,
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      throw Exception('Failed to get storage stats: $e');
    }
  }

  /// Compress image before upload (optional utility)
  /// Note: Requires image compression package
  Future<Uint8List> compressImage(File imageFile, {int quality = 85}) async {
    try {
      // This is a placeholder - implement with image compression package
      // Example: using flutter_image_compress
      return await imageFile.readAsBytes();
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }
}
