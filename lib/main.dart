import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/guest_form_page.dart';
import 'pages/history_page.dart';

void main() {
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
      title: 'Resepsi Tamu Digital',
      theme: ThemeData(
        scaffoldBackgroundColor: colorBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorPrimary,
          primary: colorPrimary,
          secondary: colorSecondary,
          surface: colorSurface,
          background: colorBackground,
        ),
        appBarTheme: const AppBarTheme(
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
        fontFamily: 'Inter', // Bisa diganti Poppins jika ditambahkan di pubspec
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: colorTextPrimary),
          bodyMedium: TextStyle(color: colorTextPrimary),
          bodySmall: TextStyle(color: colorTextSecondary),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/':
            page = const HomePage();
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
            // Fade + slide-up singkat
            const begin = Offset(0.0, 0.05);
            const end = Offset.zero;
            const curve = Curves.easeOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            var fadeAnimation = animation.drive(CurveTween(curve: Curves.easeIn));

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: offsetAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    );
  }
}
