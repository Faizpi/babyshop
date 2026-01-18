import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';
import '../utils/app_icons.dart';
import '../utils/formatters.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? AppTheme.primaryPink;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cardColor.withValues(alpha: isDark ? 0.3 : 0.15),
                  cardColor.withValues(alpha: isDark ? 0.1 : 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cardColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: cardColor, size: 24),
                    ),
                    const Spacer(),
                    if (onTap != null)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(title, style: theme.textTheme.bodyMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}

class StatsRow extends StatelessWidget {
  final Map<String, dynamic> stats;
  final VoidCallback? onStokMenipisTap;

  const StatsRow({super.key, required this.stats, this.onStokMenipisTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _MiniStatsCard(
            icon: AppIcons.package,
            value: '${stats['totalBarang'] ?? 0}',
            label: 'Jenis',
            color: AppTheme.primaryPink,
          ),
          const SizedBox(width: 12),
          _MiniStatsCard(
            icon: AppIcons.tag,
            value: '${stats['totalStok'] ?? 0}',
            label: 'Total Stok',
            color: AppTheme.accentBlue,
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onStokMenipisTap,
            child: _MiniStatsCard(
              icon: AppIcons.warning,
              value: '${stats['stokMenipis'] ?? 0}',
              label: 'Menipis',
              color: AppTheme.warningOrange,
              highlight: (stats['stokMenipis'] ?? 0) > 0,
            ),
          ),
          const SizedBox(width: 12),
          _MiniStatsCard(
            icon: AppIcons.money,
            value: CurrencyFormatter.formatCompact(stats['totalNilai'] ?? 0),
            label: 'Nilai',
            color: AppTheme.successGreen,
          ),
        ],
      ),
    );
  }
}

class _MiniStatsCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool highlight;

  const _MiniStatsCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: highlight
            ? color.withValues(alpha: 0.2)
            : (isDark ? theme.cardColor : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? color : color.withValues(alpha: 0.2),
          width: highlight ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: highlight ? 0.2 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
