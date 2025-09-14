import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:greenai/notification_service.dart';
import 'package:greenai/profile_screen.dart';
import 'package:greenai/remainder_screen.dart';
import 'package:greenai/settings_screen.dart';
import 'package:greenai/signup_screen.dart';
import 'package:greenai/splash_screen.dart';
import 'package:greenai/theme.dart';
import 'community_screen.dart';
import 'greenai.dart';
import 'helpline_screen.dart';
import 'home_screen.dart';
import 'livemap_screen.dart';
import 'login_screen.dart';
import 'market_price.dart';
import 'menu_screen.dart';

void main() async {
  // Ensure Flutter is initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data for alarm functionality
  tz.initializeTimeZones();

  // Initialize notification service for alarms
  await NotificationService().initialize();

  // Initialize the theme controller
  Get.put(ThemeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GreenGram',

      // Light Theme - Will apply to ALL pages automatically
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // Your green color
          brightness: Brightness.light,
        ),

        // Custom scaffold background for light theme
        scaffoldBackgroundColor: const Color(0xFFBDBDBD),

        // AppBar theme - applies to all AppBars
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),

        // Card theme - applies to all Cards
        cardTheme: CardTheme(
          color: const Color(0xFF81C784),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),

        // Elevated button theme - applies to all ElevatedButtons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),

        // Text theme - applies to all text
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),

        // Dialog theme - applies to all dialogs
        dialogTheme: const DialogTheme(
          backgroundColor: Color(0xFFBDBDBD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),

        // List tile theme
        listTileTheme: const ListTileThemeData(
          textColor: Colors.black87,
          iconColor: Colors.black87,
        ),

        // Input decoration theme for text fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF81C784),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      // Dark Theme - Will apply to ALL pages automatically
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // Your green color
          brightness: Brightness.dark,
        ),

        // Custom scaffold background for dark theme
        scaffoldBackgroundColor: const Color(0xFF303030),

        // AppBar theme - applies to all AppBars
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),

        // Card theme - applies to all Cards
        cardTheme: CardTheme(
          color: const Color(0xFF424242),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),

        // Elevated button theme - applies to all ElevatedButtons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),

        // Text theme - applies to all text
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),

        // Dialog theme - applies to all dialogs
        dialogTheme: const DialogTheme(
          backgroundColor: Color(0xFF424242),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),

        // List tile theme
        listTileTheme: const ListTileThemeData(
          textColor: Colors.white,
          iconColor: Colors.white,
        ),

        // Input decoration theme for text fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF424242),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      // Start with light theme, can be changed by user
      themeMode: ThemeMode.light,

      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/signup', page: () => const SignupScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/menu', page: () => const MenuScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
        GetPage(name: '/settings', page: () => const SettingsScreen()),
        GetPage(name: '/green-ai', page: () => const GreenAiScreen()),
        GetPage(name: '/live-map', page: () => const LiveMapScreen()),
        GetPage(name: '/market-price', page: () => const MarketPriceScreen()),
        GetPage(name: '/reminder', page: () => const ReminderScreen()),
        GetPage(name: '/community', page: () => const CommunityScreen()),
        GetPage(name: '/helpline', page: () => const HelplineScreen()),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}