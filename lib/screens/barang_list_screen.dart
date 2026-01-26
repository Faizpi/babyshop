import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../utils/app_theme.dart';
import 'detail_barang_screen.dart';
import 'tambah_barang_screen.dart';

class BarangListScreen extends StatefulWidget {
  const BarangListScreen({super.key});

  @override
  State<BarangListScreen> createState() => _BarangListScreenState();
}

class _BarangListScreenState extends State<BarangListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<WarungProvider, BarangProvider>(
      builder: (context, warungProvider, barangProvider, child) {
        return SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '📦 Daftar Barang',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        WarungHeader(
                          warung: warungProvider.selectedWarung,
                          onTap: () => _showWarungSwitcher(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    SearchBarWidget(
                      controller: _searchController,
                      hintText: 'Cari barang... 🔍',
                      onChanged: (query) {
                        barangProvider.setSearchQuery(query);
                      },
                      onClear: () {
                        barangProvider.clearFilters();
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              // Category chips
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: KategoriChips(
                  kategoriList: barangProvider.kategoriList,
                  selectedId: barangProvider.selectedKategoriId,
                  onSelected: (kategoriId) {
                    barangProvider.setKategoriFilter(kategoriId);
                  },
                ),
              ),

              // Barang list
              Expanded(child: _buildContent(barangProvider, warungProvider)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BarangProvider barangProvider,
    WarungProvider warungProvider,
  ) {
    if (warungProvider.selectedWarung == null) {
      return const EmptyStateWidget(
        icon: Icons.storefront_rounded,
        title: 'Belum Ada Warung',
        subtitle: 'Pilih atau buat warung terlebih dahulu',
      );
    }

    if (barangProvider.isLoading) {
      return const LoadingWidget(message: 'Memuat barang...');
    }

    if (barangProvider.barangList.isEmpty) {
      if (barangProvider.searchQuery.isNotEmpty ||
          barangProvider.selectedKategoriId != null) {
        return EmptyStateWidget(
          icon: Icons.search_off_rounded,
          title: 'Tidak Ditemukan',
          subtitle: 'Coba kata kunci atau kategori lain',
          buttonText: 'Reset Filter',
          onButtonPressed: () {
            _searchController.clear();
            barangProvider.clearFilters();
          },
        );
      }
      return EmptyStateWidget(
        icon: Icons.inventory_2_outlined,
        title: 'Belum Ada Barang',
        subtitle: 'Yuk mulai tambah barang pertamamu!',
        buttonText: 'Tambah Barang',
        onButtonPressed: () =>
            _navigateToTambahBarang(warungProvider.selectedWarung!.id),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          barangProvider.loadBarang(warungProvider.selectedWarung!.id),
      color: AppTheme.primaryPink,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: barangProvider.barangList.length,
        itemBuilder: (context, index) {
          final barang = barangProvider.barangList[index];
          final kategori = barangProvider.getKategoriById(barang.kategoriId);

          return BarangCard(
            barang: barang,
            kategori: kategori,
            onTap: () => _navigateToDetail(barang),
            showActions: false,
          );
        },
      ),
    );
  }

  void _showWarungSwitcher(BuildContext context) {
    final warungProvider = context.read<WarungProvider>();
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
          _searchController.clear();
          barangProvider.clearFilters();
        },
        onAddWarung: () {
          Navigator.pop(context);
          _showAddWarungDialog(context);
        },
      ),
    );
  }

  void _showAddWarungDialog(BuildContext context) {
    final controller = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Text('🏪 ', style: TextStyle(fontSize: 24)),
            Text('Warung Baru', style: theme.textTheme.titleLarge),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nama warung',
            prefixIcon: Icon(Icons.store_outlined),
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final warungProvider = context.read<WarungProvider>();
                final success = await warungProvider.addWarung(
                  controller.text.trim(),
                );
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Warung berhasil ditambahkan! 🎉'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _navigateToTambahBarang(String warungId) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TambahBarangScreen(warungId: warungId)),
    );

    if (result == true && mounted) {
      context.read<BarangProvider>().loadBarang(warungId);
    }
  }

  void _navigateToDetail(Barang barang) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DetailBarangScreen(barang: barang)),
    );

    if (result == true && mounted) {
      final warungProvider = context.read<WarungProvider>();
      if (warungProvider.selectedWarung != null) {
        context.read<BarangProvider>().loadBarang(
          warungProvider.selectedWarung!.id,
        );
      }
    }
  }
}
