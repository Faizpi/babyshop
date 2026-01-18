import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import '../utils/app_icons.dart';

class KategoriChips extends StatelessWidget {
  final List<Kategori> kategoriList;
  final String? selectedId;
  final Function(String?) onSelected;

  const KategoriChips({
    super.key,
    required this.kategoriList,
    this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // "Semua" chip
          _buildChip(
            context: context,
            label: 'Semua',
            icon: Icons.home_rounded,
            isSelected: selectedId == null,
            onTap: () => onSelected(null),
            color: AppTheme.primaryPink,
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          // Category chips
          ...kategoriList.map((kategori) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                context: context,
                label: kategori.nama,
                icon: AppIcons.getKategoriIcon(kategori.iconName),
                isSelected: selectedId == kategori.id,
                onTap: () => onSelected(kategori.id),
                color: _parseColor(kategori.warna),
                isDark: isDark,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
    required bool isDark,
  }) {
    return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? color
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : color.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: isSelected ? Colors.white : color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white : color),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(target: isSelected ? 1 : 0)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 200.ms,
        );
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) {
      return AppTheme.lightPink;
    }
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppTheme.lightPink;
    }
  }
}

class KategoriSelector extends StatelessWidget {
  final List<Kategori> kategoriList;
  final String? selectedId;
  final Function(String) onSelected;

  const KategoriSelector({
    super.key,
    required this.kategoriList,
    this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: kategoriList.length,
      itemBuilder: (context, index) {
        final kategori = kategoriList[index];
        final isSelected = selectedId == kategori.id;
        final color = _parseColor(kategori.warna);

        return GestureDetector(
              onTap: () => onSelected(kategori.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.2)
                      : theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? color : color.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.getKategoriIcon(kategori.iconName),
                      size: 28,
                      color: color,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kategori.nama,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? color : null,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
            .animate(target: isSelected ? 1 : 0)
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.05, 1.05),
              duration: 200.ms,
            );
      },
    );
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) {
      return AppTheme.lightPink;
    }
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppTheme.lightPink;
    }
  }
}
