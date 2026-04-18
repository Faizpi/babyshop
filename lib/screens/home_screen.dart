import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import '../utils/app_theme.dart';
import '../utils/app_icons.dart';
import 'barang_list_screen.dart';
import 'tambah_barang_screen.dart';
import 'riwayat_screen.dart';
import 'settings_screen.dart';
import 'detail_barang_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Public method to switch tabs from child widgets
  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  List<Widget> get _screens => [
    const DashboardTab(key: PageStorageKey('dashboard')),
    const BarangListScreen(key: PageStorageKey('barang')),
    const RiwayatScreen(key: PageStorageKey('riwayat')),
    const SettingsScreen(key: PageStorageKey('settings')),
  ];

  Future<void> _loadData() async {
    if (!mounted) return;
    final warungProvider = context.read<WarungProvider>();
    if (warungProvider.selectedWarung != null) {
      await context.read<BarangProvider>().loadBarang(
        warungProvider.selectedWarung!.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? _buildFAB()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNav() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                isSelected: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavItem(
                icon: Icons.inventory_2_rounded,
                label: 'Barang',
                isSelected: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              const SizedBox(width: 56), // Space for FAB
              _NavItem(
                icon: Icons.history_rounded,
                label: 'Riwayat',
                isSelected: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _NavItem(
                icon: Icons.settings_rounded,
                label: 'Pengaturan',
                isSelected: _currentIndex == 3,
                onTap: () => setState(() => _currentIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
          onPressed: () => _navigateToTambahBarang(),
          elevation: 4,
          child: const Icon(Icons.add_a_photo, size: 28),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 1500.ms,
          curve: Curves.easeInOut,
        );
  }

  void _navigateToTambahBarang() async {
    final warungProvider = context.read<WarungProvider>();
    if (warungProvider.selectedWarung == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih warung terlebih dahulu!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TambahBarangScreen(warungId: warungProvider.selectedWarung!.id),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryPink.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryPink
                  : theme.iconTheme.color?.withValues(alpha: 0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppTheme.primaryPink
                    : theme.textTheme.bodySmall?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Dashboard Tab
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<WarungProvider, BarangProvider>(
      builder: (context, warungProvider, barangProvider, child) {
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Greeting
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Consumer<UserProvider>(
                              builder: (context, userProvider, _) {
                                return Text(
                                  'Halo, ${userProvider.currentUser?.nama ?? "Bunda"}!',
                                  style: theme.textTheme.titleLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getGreeting(),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      // Warung switcher
                      WarungHeader(
                        warung: warungProvider.selectedWarung,
                        onTap: () => _showWarungSwitcher(context),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),
              ),

              // Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: StatsRow(
                    stats: barangProvider.stats,
                    onStokMenipisTap: barangProvider.jumlahStokMenipis > 0
                        ? () => _showStokMenipis(context, barangProvider)
                        : null,
                  ),
                ),
              ),

              // Low stock warning
              if (barangProvider.jumlahStokMenipis > 0)
                SliverToBoxAdapter(
                  child: _LowStockWarning(
                    count: barangProvider.jumlahStokMenipis,
                    onTap: () => _showStokMenipis(context, barangProvider),
                  ),
                ),

              // Recent items header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.package,
                        color: AppTheme.primaryPink,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Barang Terbaru',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // Switch to Barang tab
                          final homeState = context
                              .findAncestorStateOfType<_HomeScreenState>();
                          homeState?.switchToTab(1);
                        },
                        child: const Text('Lihat Semua'),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms),
              ),

              // Recent items grid
              if (barangProvider.isLoading)
                const SliverFillRemaining(
                  child: LoadingWidget(message: 'Memuat barang...'),
                )
              else if (barangProvider.allBarangList.isEmpty)
                SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: AppIcons.package,
                    title: 'Belum Ada Barang',
                    subtitle: 'Mulai tambah barang pertamamu!',
                    buttonText: 'Tambah Barang',
                    onButtonPressed: () {
                      final homeState = context
                          .findAncestorStateOfType<_HomeScreenState>();
                      homeState?._navigateToTambahBarang();
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= 6) {
                          return null; // Show only 6 items on dashboard
                        }
                        final barang = barangProvider.allBarangList[index];
                        final kategori = barangProvider.getKategoriById(
                          barang.kategoriId,
                        );

                        return BarangCard(
                          barang: barang,
                          kategori: kategori,
                          showActions: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailBarangScreen(barang: barang),
                              ),
                            );
                          },
                        );
                      },
                      childCount: barangProvider.allBarangList.length > 6
                          ? 6
                          : barangProvider.allBarangList.length,
                    ),
                  ),
                ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
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
            Icon(
              Icons.storefront_rounded,
              size: 24,
              color: AppTheme.primaryPink,
            ),
            const SizedBox(width: 8),
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
                      content: Text('Warung berhasil ditambahkan!'),
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

  void _showStokMenipis(BuildContext context, BarangProvider barangProvider) {
    final theme = Theme.of(context);
    final items = barangProvider.barangStokMenipis;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 24,
                    color: AppTheme.warningOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Stok Menipis (${items.length})',
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // List
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final barang = items[index];
                  return _LowStockItem(
                    barang: barang,
                    onTambahStok: () => _updateStok(context, barang, 1),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateStok(BuildContext context, barang, int delta) async {
    final barangProvider = context.read<BarangProvider>();
    final success = await barangProvider.updateStok(barang, delta);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            delta > 0
                ? '✅ Stok ${barang.nama} bertambah!'
                : '📦 Stok ${barang.nama} berkurang',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}

class _LowStockWarning extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _LowStockWarning({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.warningOrange.withValues(alpha: 0.2),
              AppTheme.warningOrange.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.warningOrange.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count barang stoknya menipis',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.warningOrange,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Tap untuk lihat dan restok',
                    style: TextStyle(fontSize: 12, color: AppTheme.textGray),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.warningOrange,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0);
  }
}

class _LowStockItem extends StatelessWidget {
  final dynamic barang;
  final VoidCallback onTambahStok;

  const _LowStockItem({required this.barang, required this.onTambahStok});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHabis = barang.stok <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHabis
              ? AppTheme.errorRed.withValues(alpha: 0.3)
              : AppTheme.warningOrange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Status emoji
          Text(isHabis ? '😱' : '⚠️', style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barang.nama,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isHabis
                      ? 'HABIS! Segera restok'
                      : 'Sisa ${barang.stok} ${barang.satuan} (min: ${barang.stokMinimum})',
                  style: TextStyle(
                    fontSize: 12,
                    color: isHabis ? AppTheme.errorRed : AppTheme.warningOrange,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Add button
          ElevatedButton.icon(
            onPressed: onTambahStok,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Restok'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}
