import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../utils/app_theme.dart';
import '../utils/app_icons.dart';
import '../utils/formatters.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRiwayat();
    });
  }

  Future<void> _loadRiwayat() async {
    if (!mounted) return;
    final warungProvider = context.read<WarungProvider>();
    final riwayatProvider = context.read<RiwayatProvider>();

    if (warungProvider.selectedWarung != null) {
      await riwayatProvider.loadRiwayat(warungProvider.selectedWarung!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(AppIcons.history, color: AppTheme.primaryPink, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Riwayat',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Consumer<WarungProvider>(
                  builder: (context, warungProvider, _) {
                    return WarungHeader(
                      warung: warungProvider.selectedWarung,
                      onTap: () => _showWarungSwitcher(context),
                    );
                  },
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          // Content
          Expanded(
            child: Consumer<RiwayatProvider>(
              builder: (context, riwayatProvider, child) {
                if (riwayatProvider.isLoading) {
                  return const LoadingWidget(message: 'Memuat riwayat...');
                }

                if (riwayatProvider.riwayatList.isEmpty) {
                  return EmptyStateWidget(
                    icon: AppIcons.history,
                    title: 'Belum Ada Riwayat',
                    subtitle: 'Riwayat perubahan stok akan muncul di sini',
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadRiwayat,
                  color: AppTheme.primaryPink,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: riwayatProvider.riwayatList.length,
                    itemBuilder: (context, index) {
                      final item = riwayatProvider.riwayatList[index];
                      final riwayat = Riwayat.fromMap(item);
                      final barangNama = item['barang_nama'] as String?;

                      // Group by date
                      final currentDate = DateFormatter.formatShort(
                        riwayat.createdAt,
                      );
                      String? prevDate;
                      if (index > 0) {
                        final prevItem = riwayatProvider.riwayatList[index - 1];
                        final prevRiwayat = Riwayat.fromMap(prevItem);
                        prevDate = DateFormatter.formatShort(
                          prevRiwayat.createdAt,
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date header
                          if (currentDate != prevDate)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 8,
                              ),
                              child: _DateHeader(date: riwayat.createdAt),
                            ),
                          // Riwayat card
                          _RiwayatCard(
                            riwayat: riwayat,
                            barangNama: barangNama,
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showWarungSwitcher(BuildContext context) {
    final warungProvider = context.read<WarungProvider>();
    final riwayatProvider = context.read<RiwayatProvider>();
    final barangProvider = context.read<BarangProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WarungSwitcher(
        warungList: warungProvider.warungList,
        selectedWarung: warungProvider.selectedWarung,
        onWarungSelected: (warung) async {
          await warungProvider.selectWarung(warung);
          await barangProvider.loadBarang(warung.id);
          await riwayatProvider.loadRiwayat(warung.id);
        },
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;

  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String label;

    if (DateFormatter.isToday(date)) {
      label = 'Hari Ini';
    } else if (DateFormatter.isYesterday(date)) {
      label = 'Kemarin';
    } else {
      label = DateFormatter.formatShort(date);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.calendar, size: 14, color: AppTheme.primaryPink),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryPink,
            ),
          ),
        ],
      ),
    );
  }
}

class _RiwayatCard extends StatelessWidget {
  final Riwayat riwayat;
  final String? barangNama;

  const _RiwayatCard({required this.riwayat, this.barangNama});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPink.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getBackgroundColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    _getRiwayatIcon(),
                    color: _getBackgroundColor(),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      riwayat.tipeText,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (barangNama != null)
                      Text(
                        barangNama!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryPink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    _buildValueChange(theme),
                  ],
                ),
              ),
              // Time
              Text(
                DateFormatter.formatTime(riwayat.createdAt),
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0, duration: 300.ms);
  }

  Widget _buildValueChange(ThemeData theme) {
    if (riwayat.nilaiLama == null && riwayat.nilaiBaru == null) {
      if (riwayat.catatan != null && riwayat.catatan!.isNotEmpty) {
        return Text(
          riwayat.catatan!,
          style: theme.textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }
      return const SizedBox.shrink();
    }

    // For price changes
    if (riwayat.tipe == TipeRiwayat.editHarga) {
      return Row(
        children: [
          Flexible(
            child: Text(
              CurrencyFormatter.format(riwayat.nilaiLama ?? 0),
              style: theme.textTheme.bodySmall?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: AppTheme.textLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('→'),
          ),
          Flexible(
            child: Text(
              CurrencyFormatter.format(riwayat.nilaiBaru ?? 0),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.successGreen,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      );
    }

    // For stock changes
    final delta = (riwayat.nilaiBaru ?? 0) - (riwayat.nilaiLama ?? 0);
    final isIncrease = delta > 0;

    return Row(
      children: [
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${riwayat.nilaiLama ?? 0}',
                  style: theme.textTheme.bodySmall,
                ),
                TextSpan(text: ' → ', style: theme.textTheme.bodySmall),
                TextSpan(
                  text: '${riwayat.nilaiBaru ?? 0}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isIncrease
                ? AppTheme.successGreen.withValues(alpha: 0.1)
                : AppTheme.errorRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            isIncrease ? '+$delta' : '$delta',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isIncrease ? AppTheme.successGreen : AppTheme.errorRed,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getBackgroundColor() {
    switch (riwayat.tipe) {
      case TipeRiwayat.tambahStok:
        return AppTheme.successGreen;
      case TipeRiwayat.kurangStok:
        return AppTheme.errorRed;
      case TipeRiwayat.editHarga:
        return AppTheme.warningOrange;
      case TipeRiwayat.tambahBarang:
        return AppTheme.infoBlue;
      case TipeRiwayat.hapusBarang:
        return AppTheme.errorRed;
      case TipeRiwayat.auditStok:
        return AppTheme.accentPurple;
      default:
        return AppTheme.primaryPink;
    }
  }

  IconData _getRiwayatIcon() {
    switch (riwayat.tipe) {
      case TipeRiwayat.tambahStok:
        return AppIcons.stockIn;
      case TipeRiwayat.kurangStok:
        return AppIcons.stockOut2;
      case TipeRiwayat.editHarga:
        return AppIcons.money;
      case TipeRiwayat.tambahBarang:
        return AppIcons.add;
      case TipeRiwayat.hapusBarang:
        return AppIcons.delete;
      case TipeRiwayat.auditStok:
        return AppIcons.adjustment;
      default:
        return AppIcons.history;
    }
  }
}
