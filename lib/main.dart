import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:image_picker_windows/image_picker_windows.dart';
import 'pages/splash_screen.dart';
import 'pages/main_shell_page.dart';
import 'pages/home_page.dart';
import 'pages/guest_form_page.dart';
import 'pages/history_page.dart';
import 'utils/app_logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Daftarkan jembatan kamera khusus untuk Windows Desktop
  if (Platform.isWindows) {
    ImagePickerPlatform.instance = ImagePickerWindows();
    AppLogger.info('📷 Kamera: mode Windows (image_picker_windows)');
  }

  AppLogger.info('🚀 Aplikasi dimulai');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color colorPrimary = Color(0xFF0F6E56);
    const Color colorSecondary = Color(0xFFBA7517);
    const Color colorBackground = Color(0xFFFAF9F5);
    const Color colorSurface = Color(0xFFFFFFFF);
    const Color colorTextPrimary = Color(0xFF2C2C2A);
    const Color colorTextSecondary = Color(0xFF8A8880);

    return MaterialApp(
      title: 'Buku Tamu Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: colorBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorPrimary,
          primary: colorPrimary,
          secondary: colorSecondary,
          surface: colorSurface,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colorBackground,
          foregroundColor: colorPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: colorPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: colorTextPrimary),
          bodyMedium: TextStyle(color: colorTextPrimary),
          bodySmall: TextStyle(color: colorTextSecondary),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        AppLogger.pageOpen(settings.name ?? '/');

        // SplashScreen tanpa transisi
        if (settings.name == '/splash') {
          return PageRouteBuilder(
            pageBuilder: (_, __, ___) => const SplashScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          );
        }

        Widget page;
        switch (settings.name) {
          case '/':
            // Halaman utama = wadah dengan navigation bar
            page = const MainShellPage();
            break;
          case '/guest_form':
            page = const GuestFormPage();
            break;
          case '/history':
            page = const HistoryPage();
            break;
          default:
            page = const HomePage();
        }

        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.04);
            const end = Offset.zero;
            final curve = Curves.easeOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeIn),
            );

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: SlideTransition(
                position: animation.drive(tween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        );
      },
    );
  }
}
