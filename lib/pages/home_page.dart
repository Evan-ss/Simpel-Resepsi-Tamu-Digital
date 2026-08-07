import 'package:flutter/material.dart';
import '../utils/app_logger.dart';
import '../database/database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onNavigateToTab});

  /// Dipanggil saat kartu menu diklik untuk berpindah tab
  /// pada navigation bar (di MainShellPage).
  final ValueChanged<int>? onNavigateToTab;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeInContent;
  late final Animation<Offset> _slideUpCards;

  final Color _primary = const Color(0xFF0F6E56);
  final Color _gold = const Color(0xFFBA7517);
  final Color _bg = const Color(0xFFFAF9F5);
  final Color _textSecondary = const Color(0xFF8A8880);

  // ─── Statistik ───
  int _totalTamu = 0;
  int _todayTamu = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    AppLogger.pageOpen('HomePage');

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeInContent = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideUpCards = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final total = await DatabaseHelper().getTotalTamu();
      final today = await DatabaseHelper().getTodayTamu();
      if (mounted) {
        setState(() {
          _totalTamu = total;
          _todayTamu = today;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      AppLogger.error('Gagal load stats', error: e);
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  /// Pindah ke tab lain pada navigation bar.
  void _goToTab(int index) {
    widget.onNavigateToTab?.call(index);
  }

  /// Dipanggil oleh MainShellPage setiap kali tab Beranda dipilih
  /// agar statistik selalu terbaru.
  Future<void> refreshStats() => _loadStats();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeInContent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildStatsRow(),
                const SizedBox(height: 32),

                SlideTransition(
                  position: _slideUpCards,
                  child: Column(
                    children: [
                      _buildMenuCard(
                        title: 'Isi Resepsi Tamu',
                        subtitle: 'Tambah data tamu baru, tanda tangan & foto',
                        icon: Icons.edit_note_rounded,
                        iconBgColor: _primary.withOpacity(0.1),
                        iconColor: _primary,
                        onTap: () {
                          AppLogger.buttonTap('Menu: Isi Resepsi Tamu');
                          _goToTab(1); // tab Form Tamu
                        },
                        gradientColors: [
                          _primary.withOpacity(0.02),
                          _primary.withOpacity(0.06),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildMenuCard(
                        title: 'Lihat Riwayat',
                        subtitle: 'Daftar tamu yang telah hadir & export data',
                        icon: Icons.history_rounded,
                        iconBgColor: _gold.withOpacity(0.1),
                        iconColor: _gold,
                        onTap: () {
                          AppLogger.buttonTap('Menu: Lihat Riwayat');
                          _goToTab(2); // tab Riwayat
                        },
                        gradientColors: [
                          _gold.withOpacity(0.02),
                          _gold.withOpacity(0.06),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/icon/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.people_alt_rounded,
                    color: _primary,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: TextStyle(
                    fontSize: 14,
                    color: _textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Buku Tamu Digital',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primary,
            const Color(0xFF0A5542),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem(
                Icons.people_outline,
                'Total Tamu',
                _isLoadingStats ? '...' : _totalTamu.toString(),
              ),
              _statItem(
                Icons.today_outlined,
                'Hari Ini',
                _isLoadingStats ? '...' : _todayTamu.toString(),
              ),
              _statItem(
                Icons.history_rounded,
                'Tercatat',
                _isLoadingStats ? '...' : _totalTamu.toString(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            width: 60,
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Silakan pilih menu di bawah untuk memulai',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
    required List<Color> gradientColors,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.95, end: 1.0),
          duration: const Duration(milliseconds: 100),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.black.withOpacity(0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                splashColor: iconColor.withOpacity(0.08),
                highlightColor: iconColor.withOpacity(0.04),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(icon, color: iconColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C2C2A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8A8880),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: iconColor,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '© ${DateTime.now().year} Buku Tamu Digital',
            style: TextStyle(
              fontSize: 12,
              color: _textSecondary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dibuat dengan ❤️ untuk acara spesialmu',
            style: TextStyle(
              fontSize: 11,
              color: _textSecondary.withOpacity(0.4),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'Selamat Pagi ☀️';
    if (hour < 15) return 'Selamat Siang 🌤️';
    if (hour < 18) return 'Selamat Sore 🌅';
    return 'Selamat Malam 🌙';
  }
}
