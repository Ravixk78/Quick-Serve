import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/bookings/booking_screen.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/services/service_details_screen.dart';
import 'screens/services/service_list_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/services/add_service_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'theme/app_theme.dart';
import 'models/service_model.dart';
import 'services/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isSupabaseConfigured = false;
  try {
    if (SupabaseConfig.supabaseUrl != 'YOUR_SUPABASE_URL' &&
        SupabaseConfig.supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY') {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      isSupabaseConfigured = true;
    }
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
  }

  // Initialize notifications
  await LocalNotificationService.initialize();

  runApp(MyApp(isSupabaseConfigured: isSupabaseConfigured));
}

class MyApp extends StatelessWidget {
  final bool isSupabaseConfigured;
  const MyApp({super.key, required this.isSupabaseConfigured});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'QuickServe',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            navigatorKey: LocalNotificationService.navigatorKey,
            initialRoute: '/',
            builder: (context, child) {
              if (!isSupabaseConfigured) {
                return Stack(children: [child!, _buildConfigWarning(context)]);
              }
              return child!;
            },
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(
                    builder: (_) => const SplashScreen(),
                  );
                case '/onboarding':
                  return MaterialPageRoute(
                    builder: (_) => const OnboardingScreen(),
                  );
                case '/login':
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                case '/signup':
                  return MaterialPageRoute(
                    builder: (_) => const SignupScreen(),
                  );
                case '/main':
                  return MaterialPageRoute(builder: (_) => const MainScreen());
                case '/services':
                  final args = settings.arguments as Map<String, dynamic>?;
                  return MaterialPageRoute(
                    builder: (_) => ServiceListScreen(
                      categoryId: args?['categoryId'] as String?,
                      searchQuery: args?['search'] as String?,
                      providerId: args?['providerId'] as String?,
                    ),
                  );
                case '/service-details':
                  final service = settings.arguments as ServiceModel;
                  return MaterialPageRoute(
                    builder: (_) => ServiceDetailsScreen(service: service),
                  );
                case '/booking':
                  final service = settings.arguments as ServiceModel;
                  return MaterialPageRoute(
                    builder: (_) => BookingScreen(service: service),
                  );
                case '/settings':
                  return MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  );
                case '/add-service':
                  return MaterialPageRoute(
                    builder: (_) => const AddServiceScreen(),
                  );
                case '/forgot-password':
                  return MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen(),
                  );
                case '/edit-service':
                  return MaterialPageRoute(
                    builder: (_) => const AddServiceScreen(),
                    settings: settings,
                  );
                default:
                  return MaterialPageRoute(
                    builder: (_) => const SplashScreen(),
                  );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildConfigWarning(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade800,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.2 * 255).toInt()),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Supabase not configured. Check config/supabase_config.dart',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () {
                  // This is a simple visual warning, usually for the developer.
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
