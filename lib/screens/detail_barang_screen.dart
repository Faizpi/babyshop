import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import '../utils/app_icons.dart';
import '../utils/formatters.dart';
import '../services/database_helper.dart';

class DetailBarangScreen extends StatefulWidget {
  final Barang barang;

  const DetailBarangScreen({super.key, required this.barang});

  @override
  State<DetailBarangScreen> createState() => _DetailBarangScreenState();
}

class _DetailBarangScreenState extends State<DetailBarangScreen> {
  late Barang _barang;
  List<Riwayat> _riwayat = [];
  bool _isLoadingRiwayat = true;

  @override
  void initState() {
    super.initState();
    _barang = widget.barang;
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    final riwayatProvider = context.read<RiwayatProvider>();
    final riwayat = await riwayatProvider.getRiwayatByBarang(_barang.id);
    if (mounted) {
      setState(() {
        _riwayat = riwayat;
        _isLoadingRiwayat = false;
      });
    }
  }

  void _refreshBarang() async {
    final db = DatabaseHelper.instance;
    final updated = await db.getBarangById(_barang.id);
    if (updated != null && mounted) {
      setState(() => _barang = updated);
    }
    _loadRiwayat();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barangProvider = context.read<BarangProvider>();
    final kategori = barangProvider.getKategoriById(_barang.kategoriId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: isDark
                ? theme.scaffoldBackgroundColor
                : AppTheme.palePink,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppTheme.primaryPink,
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: AppTheme.primaryPink),
                ),
                onPressed: () => _showEditDialog(),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.errorRed,
                  ),
                ),
                onPressed: () => _showDeleteConfirmation(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _barang.fotoPath.isNotEmpty
                  ? Image.file(
                      File(_barang.fotoPath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category badge
                        if (kategori != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _parseColor(
                                kategori.warna,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  AppIcons.getKategoriIcon(kategori.iconName),
                                  size: 14,
                                  color: _parseColor(kategori.warna),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  kategori.nama,
                                  style: TextStyle(
                                    color: _parseColor(kategori.warna),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(),

                        const SizedBox(height: 12),

                        // Name
                        Text(
                          _barang.nama,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(delay: 100.ms),

                        const SizedBox(height: 8),

                        // Price
                        Text(
                          CurrencyFormatter.format(_barang.harga),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryPink,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(delay: 150.ms),

                        const SizedBox(height: 24),

                        // Stock section
                        _buildStockSection(theme),

                        const SizedBox(height: 24),

                        // Quick stock buttons
                        _buildQuickStockButtons(),

                        const SizedBox(height: 24),

                        // Info cards
                        Row(
                          children: [
                            Expanded(
                              child: _InfoCard(
                                icon: Icons.calendar_today_outlined,
                                title: 'Dibuat',
                                value: DateFormatter.formatShort(
                                  _barang.createdAt,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InfoCard(
                                icon: Icons.update_outlined,
                                title: 'Terakhir Update',
                                value: DateFormatter.formatRelative(
                                  _barang.updatedAt,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 400.ms),

                        const SizedBox(height: 24),

                        // History section
                        _buildHistorySection(theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.palePink,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 80, color: AppTheme.lightPink),
      ),
    );
  }

  Widget _buildStockSection(ThemeData theme) {
    final isLow = _barang.isStokMenipis;
    final isEmpty = _barang.isStokHabis;

    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isEmpty
                  ? [
                      AppTheme.errorRed.withValues(alpha: 0.15),
                      AppTheme.errorRed.withValues(alpha: 0.05),
                    ]
                  : isLow
                  ? [
                      AppTheme.warningOrange.withValues(alpha: 0.15),
                      AppTheme.warningOrange.withValues(alpha: 0.05),
                    ]
                  : [
                      AppTheme.successGreen.withValues(alpha: 0.15),
                      AppTheme.successGreen.withValues(alpha: 0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isEmpty
                  ? AppTheme.errorRed.withValues(alpha: 0.3)
                  : isLow
                  ? AppTheme.warningOrange.withValues(alpha: 0.3)
                  : AppTheme.successGreen.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isEmpty
                        ? '😱'
                        : isLow
                        ? '⚠️'
                        : '✅',
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STOK',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        '${_barang.stok} ${_barang.satuan}',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isEmpty
                              ? AppTheme.errorRed
                              : isLow
                              ? AppTheme.warningOrange
                              : AppTheme.successGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (isLow && !isEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Stok di bawah batas minimum (${_barang.stokMinimum})',
                  style: TextStyle(
                    color: AppTheme.warningOrange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (isEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'HABIS! Segera restok',
                  style: TextStyle(
                    color: AppTheme.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 300.ms,
        );
  }

  Widget _buildQuickStockButtons() {
    return Row(
      children: [
        Expanded(
          child: _StockActionButton(
            label: 'Kurang',
            icon: Icons.remove,
            color: AppTheme.errorRed,
            isEnabled: _barang.stok > 0,
            onTap: () => _quickUpdateStock(-1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StockActionButton(
            label: 'Tambah',
            icon: Icons.add,
            color: AppTheme.successGreen,
            isEnabled: true,
            onTap: () => _quickUpdateStock(1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StockActionButton(
            label: 'Edit',
            icon: Icons.edit,
            color: AppTheme.primaryPink,
            isEnabled: true,
            onTap: () => _showStockEditDialog(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildHistorySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history_rounded, size: 22, color: AppTheme.primaryPink),
            const SizedBox(width: 8),
            Text(
              'Riwayat Perubahan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingRiwayat)
          const Center(child: CircularProgressIndicator())
        else if (_riwayat.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('Belum ada riwayat')),
          )
        else
          ...(_riwayat.take(10).map((r) => _RiwayatItem(riwayat: r))),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  void _quickUpdateStock(int delta) async {
    final barangProvider = context.read<BarangProvider>();
    final success = await barangProvider.updateStok(_barang, delta);

    if (success) {
      _refreshBarang();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              delta > 0 ? '✅ Stok bertambah!' : '📦 Stok berkurang',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _showStockEditDialog() {
    final controller = TextEditingController(text: _barang.stok.toString());
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Text('📦 ', style: TextStyle(fontSize: 24)),
            Text('Edit Stok', style: theme.textTheme.titleLarge),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_barang.nama, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Jumlah stok',
                suffixText: _barang.satuan,
                prefixIcon: const Icon(Icons.inventory_2_outlined),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newStok = int.tryParse(controller.text) ?? _barang.stok;
              final delta = newStok - _barang.stok;

              if (delta != 0) {
                final barangProvider = context.read<BarangProvider>();
                await barangProvider.updateStok(_barang, delta, isAudit: true);
                _refreshBarang();
              }

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Stok berhasil diupdate!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    final namaController = TextEditingController(text: _barang.nama);
    final hargaController = TextEditingController(
      text: CurrencyFormatter.formatNumber(_barang.harga),
    );
    final stokMinController = TextEditingController(
      text: _barang.stokMinimum.toString(),
    );
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Text('✏️ ', style: TextStyle(fontSize: 24)),
            Text('Edit Barang', style: theme.textTheme.titleLarge),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama Barang', style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              TextField(
                controller: namaController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.label_outline),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              Text('Harga', style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              TextField(
                controller: hargaController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.payments_outlined),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              Text('Stok Minimum', style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              TextField(
                controller: stokMinController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.warning_amber_outlined),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final barangProvider = context.read<BarangProvider>();
              final harga =
                  CurrencyFormatter.parse(hargaController.text) ??
                  _barang.harga;
              final stokMin =
                  int.tryParse(stokMinController.text) ?? _barang.stokMinimum;

              // Update harga if changed
              if (harga != _barang.harga) {
                await barangProvider.updateHarga(_barang, harga);
              }

              // Update other fields
              final updated = _barang.copyWith(
                nama: namaController.text.trim(),
                stokMinimum: stokMin,
              );
              await barangProvider.updateBarang(updated);

              _refreshBarang();

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Barang berhasil diupdate!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Text('🗑️ ', style: TextStyle(fontSize: 24)),
            Text('Hapus Barang?', style: theme.textTheme.titleLarge),
          ],
        ),
        content: Text(
          'Yakin mau hapus "${_barang.nama}"?\n\nData yang dihapus tidak bisa dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final barangProvider = context.read<BarangProvider>();
              await barangProvider.deleteBarang(_barang);

              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Go back
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🗑️ Barang berhasil dihapus'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Hapus'),
          ),
        ],
      ),
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primaryPink),
              const SizedBox(width: 6),
              Text(title, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StockActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isEnabled;
  final VoidCallback onTap;

  const _StockActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isEnabled
              ? color.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled
                ? color.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isEnabled ? color : Colors.grey, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isEnabled ? color : Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiwayatItem extends StatelessWidget {
  final Riwayat riwayat;

  const _RiwayatItem({required this.riwayat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.getRiwayatIcon(riwayat.tipe),
            size: 22,
            color: AppTheme.primaryPink,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  riwayat.tipeText,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (riwayat.nilaiLama != null || riwayat.nilaiBaru != null)
                  Text(
                    '${riwayat.nilaiLama ?? "-"} → ${riwayat.nilaiBaru ?? "-"}',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Text(
            DateFormatter.formatRelative(riwayat.createdAt),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
