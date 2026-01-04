import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tracky_mobile/theme.dart';
import 'package:tracky_mobile/core/services/storage_service.dart';
import 'package:tracky_mobile/core/services/notification_service.dart';
import 'package:tracky_mobile/features/auth/providers/auth_provider.dart';
import 'package:tracky_mobile/features/auth/screens/role_selection_screen.dart';
import 'package:tracky_mobile/features/miner/screens/miner_dashboard_screen.dart';
import 'package:tracky_mobile/features/official/screens/official_dashboard_screen.dart';
import 'package:tracky_mobile/features/auth/models/user_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize storage service
  await StorageService.init();

  // Initialize notification service
  await NotificationService().init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime.now().millisecondsSinceEpoch;
    return MaterialApp(
      title: 'Traky - Gold Traceability',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    debugPrint(
      'AppInitializer: isLoading=${authState.isLoading}, isAuthenticated=${authState.isAuthenticated}, user=${authState.user}',
    );

    if (authState.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white, // Explicit background
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      );
    }

    if (authState.isAuthenticated && authState.user != null) {
      debugPrint(
        'AppInitializer: Redirecting to dashboard as ${authState.user!.role}',
      );
      return authState.user!.role == UserRole.user
          ? const MinerDashboardScreen()
          : const OfficialDashboardScreen();
    }

    debugPrint('AppInitializer: Showing RoleSelectionScreen');
    return const RoleSelectionScreen();
  }
}
