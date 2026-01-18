import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/image_service.dart';
import '../utils/app_theme.dart';

class PhotoPicker extends StatelessWidget {
  final String? currentPhotoPath;
  final Function(String) onPhotoPicked;
  final double size;
  final bool showEditButton;

  const PhotoPicker({
    super.key,
    this.currentPhotoPath,
    required this.onPhotoPicked,
    this.size = 150,
    this.showEditButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = currentPhotoPath != null && currentPhotoPath!.isNotEmpty;

    return GestureDetector(
      onTap: () => _showPhotoOptions(context),
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppTheme.palePink,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryPink.withValues(alpha: 0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: hasPhoto
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(
                      File(currentPhotoPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    ),
                  )
                : _buildPlaceholder(),
          ),
          if (showEditButton)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPink.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  hasPhoto ? Icons.edit : Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          size: 40,
          color: AppTheme.primaryPink.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 8),
        Text(
          'Tambah Foto',
          style: TextStyle(
            color: AppTheme.primaryPink.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showPhotoOptions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? theme.cardColor : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Pilih Foto', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _PhotoOptionButton(
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    color: AppTheme.primaryPink,
                    onTap: () async {
                      Navigator.pop(context);
                      final path = await ImageService.instance.takePhoto();
                      if (path != null) {
                        onPhotoPicked(path);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _PhotoOptionButton(
                    icon: Icons.photo_library,
                    label: 'Galeri',
                    color: AppTheme.accentPurple,
                    onTap: () async {
                      Navigator.pop(context);
                      final path = await ImageService.instance
                          .pickFromGallery();
                      if (path != null) {
                        onPhotoPicked(path);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PhotoOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PhotoOptionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Quick camera button for fast item adding
class QuickCameraButton extends StatelessWidget {
  final Function(String) onPhotoCaptured;
  final double size;

  const QuickCameraButton({
    super.key,
    required this.onPhotoCaptured,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: () async {
            final path = await ImageService.instance.takePhoto();
            if (path != null) {
              onPhotoCaptured(path);
            }
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(size / 3),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPink.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add_a_photo, color: Colors.white, size: 28),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 1000.ms,
        );
  }
}
