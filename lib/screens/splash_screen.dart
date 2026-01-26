import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_icons.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../main.dart' show isFirebaseInitialized;
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Load theme
      await context.read<ThemeProvider>().loadTheme();

      // Check Firebase auth status (only if Firebase is initialized)
      if (isFirebaseInitialized) {
        await context.read<AuthProvider>().checkAuthStatus();
      }

      // Check local user status
      await context.read<UserProvider>().checkLoginStatus();

      // Load warung list
      await context.read<WarungProvider>().loadWarungList();

      // Load categories
      await context.read<BarangProvider>().loadKategori();

      // Small delay for splash animation
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        final userProvider = context.read<UserProvider>();

        // If Firebase is not initialized, use offline mode (check local user only)
        if (!isFirebaseInitialized) {
          if (userProvider.currentUser == null) {
            // No local user - go to onboarding
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
          } else {
            // Has local user - go to home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
          return;
        }

        // Firebase is initialized - check auth
        final authProvider = context.read<AuthProvider>();

        if (!authProvider.isLoggedIn) {
          // Not authenticated with Firebase - go to login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else if (userProvider.currentUser == null) {
          // Authenticated but no local user - setup warung
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PostRegisterSetupScreen()),
          );
        } else {
          // Fully authenticated - go to home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
      // Navigate to onboarding on error (offline mode)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryPink, AppTheme.lightPink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      'assets/images/logoamara.png',
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 24),
              // App name
              const Text(
                'Warung Amara',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
              const SizedBox(height: 8),
              const Text(
                'Kelola Stok Warung Bayimu',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
              const SizedBox(height: 48),
              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _warungNameController = TextEditingController();
  int _currentStep = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _warungNameController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (_nameController.text.isEmpty || _warungNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi nama dan nama warung ya! 😊'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create user
      final userCreated = await context.read<UserProvider>().createUser(
        _nameController.text.trim(),
      );

      if (!userCreated) {
        throw Exception('Gagal membuat user');
      }

      // Create first warung
      final warungCreated = await context.read<WarungProvider>().addWarung(
        _warungNameController.text.trim(),
      );

      if (!warungCreated) {
        throw Exception('Gagal membuat warung');
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Oops, terjadi kesalahan: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: _currentStep == 0
                    ? _buildWelcomeStep(theme)
                    : _buildSetupStep(theme),
              ),
              // Navigation
              Row(
                children: [
                  if (_currentStep > 0)
                    TextButton.icon(
                      onPressed: () => setState(() => _currentStep--),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Kembali'),
                    ),
                  const Spacer(),
                  if (_currentStep == 0)
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _currentStep++),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Mulai'),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _completeOnboarding,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check),
                      label: Text(_isLoading ? 'Menyimpan...' : 'Selesai'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeStep(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppIcons.primaryPink.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.waving_hand_rounded,
            size: 60,
            color: AppIcons.primaryPink,
          ),
        ).animate().fadeIn().scale(),
        const SizedBox(height: 24),
        Text(
          'Selamat Datang!',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),
        Text(
          'Warung Amara membantu mengelola stok warung kebutuhan bayi dengan mudah dan menyenangkan!',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 32),
        // Features
        _FeatureItem(
          icon: Icons.camera_alt_rounded,
          text: 'Foto barang langsung dari kamera',
          delay: 600,
        ),
        _FeatureItem(
          icon: Icons.inventory_2_outlined,
          text: 'Update stok dengan satu tap',
          delay: 700,
        ),
        _FeatureItem(
          icon: Icons.notifications_active_outlined,
          text: 'Notifikasi stok menipis',
          delay: 800,
        ),
        _FeatureItem(
          icon: Icons.storefront_rounded,
          text: 'Kelola banyak warung',
          delay: 900,
        ),
      ],
    );
  }

  Widget _buildSetupStep(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppIcons.primaryPink.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                size: 48,
                color: AppIcons.primaryPink,
              ),
            ).animate().fadeIn().scale(),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Yuk, Kenalan Dulu!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 200.ms),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Isi data singkat untuk memulai',
              style: theme.textTheme.bodyMedium,
            ).animate().fadeIn(delay: 300.ms),
          ),
          const SizedBox(height: 40),
          // Name input
          Text(
            'Nama Kamu',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Contoh: Nurmalia',
              prefixIcon: Icon(Icons.person_outline),
            ),
            textCapitalization: TextCapitalization.words,
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 24),
          // Warung name input
          Text(
            'Nama Warung',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _warungNameController,
            decoration: const InputDecoration(
              hintText: 'Contoh: Warung Amara',
              prefixIcon: Icon(Icons.store_outlined),
            ),
            textCapitalization: TextCapitalization.words,
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: theme.textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4),
              Text(
                'Kamu bisa menambah warung lain nanti',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final int delay;

  const _FeatureItem({
    required this.icon,
    required this.text,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppIcons.primaryPink),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }
}
