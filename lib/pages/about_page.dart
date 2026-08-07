import 'package:flutter/material.dart';

/// Halaman "Tentang Aplikasi" yang dibuka lewat tombol **Tentang**
/// pada navigation bar.
///
/// Berisi deskripsi aplikasi, profil pengembang (Tentang saya),
/// dan daftar fitur utama.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const Color _primary = Color(0xFF0F6E56);
  static const Color _gold = Color(0xFFBA7517);
  static const Color _bg = Color(0xFFFAF9F5);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF2C2C2A);
  static const Color _textSecondary = Color(0xFF8A8880);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHero(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  children: [
                    // ── Deskripsi ──
                    _buildCard(
                      icon: Icons.description_outlined,
                      iconColor: _primary,
                      title: 'Deskripsi Aplikasi',
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.55,
                            color: _textSecondary,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Simpel Resepsi Tamu Digital',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' adalah aplikasi buku tamu digital modern '
                                  'yang dirancang untuk menggantikan buku tamu '
                                  'fisik konvensional di instansi, kantor, '
                                  'sekolah, maupun acara-acara penting.\n\n'
                                  'Dengan tampilan yang bersih dan mudah '
                                  'dipakai, mencatat kehadiran tamu kini hanya '
                                  'butuh hitungan detik: isi nama, instansi, '
                                  'dan keperluan kunjungan, lalu bubuhkan ',
                            ),
                            TextSpan(
                              text: 'tanda tangan digital',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' langsung di layar perangkat — tanpa perlu '
                                  'kertas, pulpen, ataupun tinta.\n\n'
                                  'Semua data tersimpan aman dan rapi di '
                                  'perangkat Anda secara ',
                            ),
                            TextSpan(
                              text: 'offline',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' menggunakan database lokal (SQLite). '
                                  'Artinya, aplikasi tetap berjalan normal '
                                  'meski tanpa koneksi internet, sekaligus '
                                  'menjaga privasi data tamu Anda.\n\n'
                                  'Riwayat kunjungan dikelompokkan otomatis '
                                  'berdasarkan tanggal, dilengkapi pencarian '
                                  'dan filter, sehingga mengecek data tamu '
                                  'menjadi cepat dan praktis.\n\n'
                                  'Dibangun menggunakan Flutter, aplikasi ini '
                                  'berjalan mulus di perangkat Android maupun '
                                  'Windows Desktop — siap menemani resepsi dan '
                                  'acara Anda dengan cara yang lebih modern, '
                                  'cepat, dan ramah lingkungan.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Tentang saya ──
                    _buildCard(
                      icon: Icons.person_outline,
                      iconColor: _primary,
                      title: 'Tentang saya',
                      child: Column(
                        children: [
                          Text(
                            'Kami adalah anak SMKS Jakarta Pusat 1, dan ini '
                            'adalah aplikasi yang kami buat untuk menggantikan '
                            'buku tamu konvensional. Kami mengerjakan aplikasi '
                            'ini sebagai tugas pembuatan aplikasi dari sekolah.',
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: _textSecondary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _infoRow(
                            Icons.badge_outlined,
                            'Nama',
                            'Evan Fadillah & Reihan Saputra',
                          ),
                          _infoRow(
                            Icons.school_outlined,
                            'Kelas',
                            'XII RPL 2',
                          ),
                          _infoRow(
                            Icons.location_city_outlined,
                            'Sekolah',
                            'SMKS Jakarta Pusat 1',
                          ),
                          // ✏️ Tambahkan baris lain di sini bila perlu
                          // (misalnya: Peran, Hobi, dll.).
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Fitur Utama ──
                    _buildCard(
                      icon: Icons.auto_awesome_outlined,
                      iconColor: _gold,
                      title: 'Fitur Utama',
                      child: Column(
                        children: [
                          _featureItem(
                            Icons.edit_note_rounded,
                            'Pencatatan tamu cepat',
                            'Form input nama, instansi & keperluan',
                          ),
                          _featureItem(
                            Icons.draw_outlined,
                            'Tanda tangan digital',
                            'Canvas tanda tangan langsung di layar',
                          ),
                          _featureItem(
                            Icons.history_rounded,
                            'Riwayat terstruktur',
                            'Dikelompokkan otomatis per tanggal',
                          ),
                          _featureItem(
                            Icons.cloud_off_outlined,
                            'Penyimpanan offline',
                            'Data tersimpan aman di perangkat',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header dengan logo & judul ───
  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F6E56), Color(0xFF0A5542)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/icon/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.people_alt_rounded,
                  size: 44,
                  color: Color(0xFF0F6E56),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Tentang Aplikasi',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Buku Tamu Digital',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 2,
              fontWeight: FontWeight.w300,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Kartu konten umum ───
  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ─── Satu baris fitur ───
  Widget _featureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: _primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12.5, color: _textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Satu baris informasi ───
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _textSecondary),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: _textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
