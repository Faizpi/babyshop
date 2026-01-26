import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../utils/app_theme.dart';
import '../utils/app_icons.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              '⚙️ Pengaturan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 24),

            // Theme Section
            _SectionHeader(title: '🎨 Tampilan'),
            _ThemeToggle(),
            const SizedBox(height: 24),

            // Warung Section
            _SectionHeader(title: '🏪 Kelola Warung'),
            _WarungSection(),
            const SizedBox(height: 24),

            // Export Section
            _SectionHeader(title: '📤 Ekspor Data'),
            _ExportSection(),
            const SizedBox(height: 24),

            // Info Section
            _SectionHeader(title: 'ℹ️ Informasi'),
            _InfoSection(),
            const SizedBox(height: 24),

            // Logout Section
            _SectionHeader(title: '🚪 Akun'),
            _LogoutSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPink.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: AppTheme.primaryPink,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mode Gelap',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      themeProvider.isDarkMode ? 'Aktif' : 'Tidak aktif',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
                activeColor: AppTheme.primaryPink,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
      },
    );
  }
}

class _WarungSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<WarungProvider>(
      builder: (context, warungProvider, _) {
        return Column(
          children: [
            // List warung
            ...warungProvider.warungList.map((warung) {
              final isSelected = warungProvider.selectedWarung?.id == warung.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(color: AppTheme.primaryPink, width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPink.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.getWarungIcon(warung.nama),
                      size: 32,
                      color: AppTheme.primaryPink,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            warung.nama,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (warung.alamat != null)
                            Text(
                              warung.alamat!,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPink.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Aktif',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryPink,
                          ),
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        color: AppTheme.textLight,
                        onPressed: () => warungProvider.selectWarung(warung),
                      ),
                  ],
                ),
              );
            }),

            // Add warung button
            OutlinedButton.icon(
              onPressed: () => _showAddWarungDialog(context, warungProvider),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Warung'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryPink,
                side: const BorderSide(color: AppTheme.primaryPink),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
      },
    );
  }

  void _showAddWarungDialog(BuildContext context, WarungProvider provider) {
    final namaController = TextEditingController();
    final alamatController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🏪', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Warung Baru'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: InputDecoration(
                labelText: 'Nama Warung',
                hintText: 'Misal: Toko Baby Shop',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryPink,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: alamatController,
              decoration: InputDecoration(
                labelText: 'Alamat (opsional)',
                hintText: 'Misal: Jl. Raya No. 123',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryPink,
                    width: 2,
                  ),
                ),
              ),
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
              if (namaController.text.isNotEmpty) {
                await provider.addWarung(
                  namaController.text,
                  alamat: alamatController.text.isNotEmpty
                      ? alamatController.text
                      : null,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

class _ExportSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _ExportTile(
            icon: Icons.table_chart_rounded,
            title: 'Ekspor Stok (CSV)',
            subtitle: 'Format spreadsheet',
            onTap: () => _exportCSV(context),
          ),
          Divider(
            height: 1,
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
          ),
          _ExportTile(
            icon: Icons.description_rounded,
            title: 'Ekspor Stok (Teks)',
            subtitle: 'Format sederhana',
            onTap: () => _exportText(context),
          ),
          Divider(
            height: 1,
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
          ),
          _ExportTile(
            icon: Icons.share_rounded,
            title: 'Bagikan Ringkasan',
            subtitle: 'Kirim via WhatsApp dll',
            onTap: () => _shareReport(context),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }

  Future<void> _exportCSV(BuildContext context) async {
    final warungProvider = context.read<WarungProvider>();
    final barangProvider = context.read<BarangProvider>();

    if (warungProvider.selectedWarung == null) return;

    final exportService = ExportService();
    await exportService.exportToCSV(
      barangProvider.barangList,
      warungProvider.selectedWarung!.nama,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Text('✅'),
              SizedBox(width: 8),
              Text('File CSV tersimpan!'),
            ],
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  Future<void> _exportText(BuildContext context) async {
    final warungProvider = context.read<WarungProvider>();
    final barangProvider = context.read<BarangProvider>();

    if (warungProvider.selectedWarung == null) return;

    final exportService = ExportService();
    await exportService.exportToText(
      barangProvider.barangList,
      warungProvider.selectedWarung!.nama,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Text('✅'),
              SizedBox(width: 8),
              Text('File teks tersimpan!'),
            ],
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  Future<void> _shareReport(BuildContext context) async {
    final warungProvider = context.read<WarungProvider>();
    final barangProvider = context.read<BarangProvider>();

    if (warungProvider.selectedWarung == null) return;

    final exportService = ExportService();
    await exportService.shareReport(
      barangProvider.barangList,
      warungProvider.selectedWarung!.nama,
    );
  }
}

class _ExportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppTheme.primaryPink),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/logoamara.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Warung Amara',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryPink,
                      ),
                    ),
                    Text('Versi 1.0.0', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Aplikasi manajemen inventaris bayi yang sederhana dan mudah digunakan. '
            'Dibuat dengan cinta untuk para orang tua yang sibuk.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _InfoChip(icon: Icons.offline_bolt_outlined, label: 'Offline'),
              _InfoChip(icon: Icons.camera_alt_outlined, label: 'Photo-first'),
              _InfoChip(icon: Icons.storefront_rounded, label: 'Multi-warung'),
              _InfoChip(
                icon: Icons.notifications_active_outlined,
                label: 'Notifikasi',
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryPink),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryPink,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;
          
          return Column(
            children: [
              // User info
              if (user != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.primaryPink.withValues(alpha: 0.1),
                        backgroundImage: user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                        child: user.photoURL == null
                            ? Icon(
                                Icons.person,
                                color: AppTheme.primaryPink,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName ?? 'Pengguna',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              user.email ?? user.phoneNumber ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (user != null)
                Divider(
                  height: 1,
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                ),
              
              // Logout button
              InkWell(
                onTap: () => _showLogoutDialog(context),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: AppTheme.errorRed,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Keluar',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.errorRed,
                              ),
                            ),
                            Text(
                              'Logout dari akun Anda',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppTheme.textLight,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🚪', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Keluar'),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Logout
              await context.read<AuthProvider>().signOut();
              
              // Navigate to login
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
