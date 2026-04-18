import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';

class WarungSwitcher extends StatelessWidget {
  final List<Warung> warungList;
  final Warung? selectedWarung;
  final Function(Warung) onWarungSelected;
  final VoidCallback? onAddWarung;

  const WarungSwitcher({
    super.key,
    required this.warungList,
    this.selectedWarung,
    required this.onWarungSelected,
    this.onAddWarung,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.storefront_rounded,
                size: 28,
                color: AppTheme.primaryPink,
              ),
              const SizedBox(width: 12),
              Text('Pilih Warung', style: theme.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          ...warungList.asMap().entries.map((entry) {
            final index = entry.key;
            final warung = entry.value;
            final isSelected = selectedWarung?.id == warung.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _WarungTile(
                warung: warung,
                isSelected: isSelected,
                onTap: () {
                  onWarungSelected(warung);
                  Navigator.pop(context);
                },
              ).animate().fadeIn(delay: (100 * index).ms, duration: 300.ms),
            );
          }),
          if (onAddWarung != null) ...[
            const SizedBox(height: 8),
            _AddWarungTile(onTap: onAddWarung!),
          ],
        ],
      ),
    );
  }
}

class _WarungTile extends StatelessWidget {
  final Warung warung;
  final bool isSelected;
  final VoidCallback onTap;

  const _WarungTile({
    required this.warung,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryPink.withValues(alpha: isDark ? 0.3 : 0.1)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppTheme.palePink.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPink : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Warung photo or icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.lightPink.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: warung.fotoPath != null && warung.fotoPath!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(warung.fotoPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.storefront_rounded,
                            size: 24,
                            color: AppTheme.primaryPink,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.storefront_rounded,
                        size: 24,
                        color: AppTheme.primaryPink,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Warung info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    warung.nama,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? AppTheme.primaryPink : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (warung.alamat != null && warung.alamat!.isNotEmpty)
                    Text(
                      warung.alamat!,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Check icon
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddWarungTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddWarungTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AppTheme.palePink.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryPink.withValues(alpha: 0.3),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: AppTheme.primaryPink),
            const SizedBox(width: 8),
            Text(
              'Tambah Warung Baru',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppTheme.primaryPink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 300.ms);
  }
}

// Header widget for showing current warung
class WarungHeader extends StatelessWidget {
  final Warung? warung;
  final VoidCallback onTap;

  const WarungHeader({super.key, this.warung, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (warung == null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.storefront_rounded,
                size: 18,
                color: AppTheme.primaryPink,
              ),
              const SizedBox(width: 8),
              Text(
                'Pilih Warung',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.primaryPink,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.primaryPink,
                size: 20,
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryPink.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.lightPink.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: warung!.fotoPath != null && warung!.fotoPath!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(warung!.fotoPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.storefront_rounded,
                            size: 14,
                            color: AppTheme.primaryPink,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.storefront_rounded,
                        size: 14,
                        color: AppTheme.primaryPink,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                warung!.nama,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
      ),
    );
  }
}
