import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../utils/formatters.dart';
import '../utils/app_theme.dart';

class BarangCard extends StatelessWidget {
  final Barang barang;
  final Kategori? kategori;
  final VoidCallback? onTap;
  final VoidCallback? onTambahStok;
  final VoidCallback? onKurangStok;
  final bool showActions;

  const BarangCard({
    super.key,
    required this.barang,
    this.kategori,
    this.onTap,
    this.onTambahStok,
    this.onKurangStok,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? null
                  : const LinearGradient(
                      colors: [Colors.white, AppTheme.palePink],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: isDark ? theme.cardColor : null,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPink.withValues(
                    alpha: isDark ? 0.1 : 0.15,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo section
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      // Product image
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: _buildImage(),
                      ),

                      // Stock indicator badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _buildStockBadge(context),
                      ),

                      // Category badge
                      if (kategori != null)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _parseColor(
                                kategori!.warna,
                              ).withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              kategori!.nama,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Info section
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Product name
                        Text(
                          barang.nama,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 2),

                        // Price
                        Text(
                          CurrencyFormatter.format(barang.harga),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryPink,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),

                        const Spacer(),

                        // Stock controls
                        if (showActions) _buildStockControls(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 300.ms,
        );
  }

  Widget _buildImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.palePink,
      child: barang.fotoPath.isNotEmpty
          ? Image.file(
              File(barang.fotoPath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 48,
        color: AppTheme.lightPink.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildStockBadge(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;
    IconData icon;

    if (barang.isStokHabis) {
      backgroundColor = AppTheme.errorRed;
      icon = Icons.error_outline;
    } else if (barang.isStokMenipis) {
      backgroundColor = AppTheme.warningOrange;
      icon = Icons.warning_amber_rounded;
    } else {
      backgroundColor = AppTheme.successGreen;
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 14),
          const SizedBox(width: 4),
          Text(
            '${barang.stok}',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Minus button
        _StockButton(
          icon: Icons.remove,
          onTap: barang.stok > 0 ? onKurangStok : null,
          isEnabled: barang.stok > 0,
          isAdd: false,
        ),

        // Stock count
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.palePink.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${barang.stok} ${barang.satuan}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),

        // Plus button
        _StockButton(
          icon: Icons.add,
          onTap: onTambahStok,
          isEnabled: true,
          isAdd: true,
        ),
      ],
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

class _StockButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool isAdd;

  const _StockButton({
    required this.icon,
    this.onTap,
    required this.isEnabled,
    required this.isAdd,
  });

  @override
  State<_StockButton> createState() => _StockButtonState();
}

class _StockButtonState extends State<_StockButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isEnabled || widget.onTap == null) return;

    _controller.forward().then((_) {
      _controller.reverse();
      widget.onTap!();
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isAdd ? AppTheme.successGreen : AppTheme.errorRed;
    final disabledColor = Colors.grey.withValues(alpha: 0.3);

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.isEnabled ? color : disabledColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: widget.isEnabled
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(widget.icon, color: Colors.white, size: 20),
            ),
          );
        },
      ),
    );
  }
}
