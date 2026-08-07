import 'package:flutter/material.dart';
import 'home_page.dart';
import 'guest_form_page.dart';
import 'history_page.dart';
import 'about_page.dart';

/// Wadah utama aplikasi setelah Splash Screen.
///
/// Berisi **navigation bar** di bagian bawah dengan 4 menu:
/// Beranda, Form Tamu, Riwayat, dan Tentang (About).
/// Menggunakan [IndexedStack] agar setiap halaman tetap
/// tersimpan keadaannya saat berpindah tab.
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  static const Color _primary = Color(0xFF0F6E56);
  static const Color _muted = Color(0xFF8A8880);

  /// Kunci untuk memanggil refresh statistik di halaman Beranda.
  final GlobalKey<HomePageState> _homeKey = GlobalKey<HomePageState>();

  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(key: _homeKey, onNavigateToTab: _goToTab),
      const GuestFormPage(),
      const HistoryPage(),
      const AboutPage(),
    ];
  }

  /// Berpindah tab pada navigation bar.
  void _goToTab(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    // Setiap kali kembali ke Beranda, muat ulang statistik tamu
    // agar angkanya selalu terbaru.
    if (index == 0) {
      _homeKey.currentState?.refreshStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          indicatorColor: _primary.withOpacity(0.12),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: isSelected ? _primary : _muted,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? _primary : _muted,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _goToTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.edit_note_outlined),
              selectedIcon: Icon(Icons.edit_note_rounded),
              label: 'Form Tamu',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history_rounded),
              label: 'Riwayat',
            ),
            NavigationDestination(
              icon: Icon(Icons.info_outline_rounded),
              selectedIcon: Icon(Icons.info_rounded),
              label: 'Tentang',
            ),
          ],
        ),
      ),
    );
  }
}
