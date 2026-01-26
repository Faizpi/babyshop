import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'providers/providers.dart';
import 'services/services.dart';
import 'utils/app_theme.dart';
import 'screens/screens.dart';
import 'models/barang.dart';

bool _firebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (with error handling for missing config)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firebaseInitialized = true;
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('App will run in offline-only mode');
    _firebaseInitialized = false;
  }

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize database
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.database;

  // Initialize connectivity service
  final connectivityService = ConnectivityService.instance;
  await connectivityService.init();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(const WarungkuApp());
}

bool get isFirebaseInitialized => _firebaseInitialized;

class WarungkuApp extends StatelessWidget {
  const WarungkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WarungProvider()),
        ChangeNotifierProvider(create: (_) => BarangProvider()),
        ChangeNotifierProvider(create: (_) => RiwayatProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Warung Amara',
            debugShowCheckedModeBanner: false,

            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // Navigation
            initialRoute: '/',
            onGenerateRoute: _generateRoute,
          );
        },
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/barang':
        return MaterialPageRoute(builder: (_) => const BarangListScreen());
      case '/tambah':
        final args = settings.arguments as Map<String, dynamic>?;
        final warungId = args?['warungId'] as String;
        final photoPath = args?['photoPath'] as String?;
        return MaterialPageRoute(
          builder: (_) => TambahBarangScreen(
            warungId: warungId,
            initialPhotoPath: photoPath,
          ),
        );
      case '/detail':
        final args = settings.arguments as Map<String, dynamic>?;
        final barang = args?['barang'] as Barang?;
        if (barang != null) {
          return MaterialPageRoute(
            builder: (_) => DetailBarangScreen(barang: barang),
          );
        }
        return null;
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
