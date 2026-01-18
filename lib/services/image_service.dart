import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  static final ImageService instance = ImageService._init();
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  ImageService._init();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = path.join(directory.path, 'warungku_images');
    final imageDir = Directory(imagePath);
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return imagePath;
  }

  /// Take a photo using camera
  Future<String?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        return await _saveImage(image);
      }
      return null;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

  /// Pick image from gallery
  Future<String?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        return await _saveImage(image);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Save image to local storage
  Future<String> _saveImage(XFile image) async {
    final localPath = await _localPath;
    final extension = path.extension(image.path);
    final fileName = '${_uuid.v4()}$extension';
    final savedPath = path.join(localPath, fileName);

    final File newImage = await File(image.path).copy(savedPath);
    return newImage.path;
  }

  /// Delete image from local storage
  Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Check if image exists
  Future<bool> imageExists(String imagePath) async {
    final file = File(imagePath);
    return await file.exists();
  }

  /// Get all images in local storage (for cleanup)
  Future<List<String>> getAllImagePaths() async {
    try {
      final localPath = await _localPath;
      final directory = Directory(localPath);
      final List<FileSystemEntity> files = directory.listSync();
      return files.whereType<File>().map((file) => file.path).toList();
    } catch (e) {
      print('Error getting all images: $e');
      return [];
    }
  }

  /// Get total size of all images (in bytes)
  Future<int> getTotalImageSize() async {
    try {
      final paths = await getAllImagePaths();
      int totalSize = 0;
      for (var imagePath in paths) {
        final file = File(imagePath);
        if (await file.exists()) {
          totalSize += await file.length();
        }
      }
      return totalSize;
    } catch (e) {
      print('Error calculating image size: $e');
      return 0;
    }
  }

  /// Format bytes to readable string
  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
