import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisi warna dasar sementara sebelum diterapkan di ThemeData
    const colorPrimary = Color(0xFF0F6E56);
    const colorBackground = Color(0xFFFAF9F5);
    const colorSurface = Color(0xFFFFFFFF);
    const colorTextPrimary = Color(0xFF2C2C2A);
    const colorTextSecondary = Color(0xFF8A8880);

    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        title: const Text('Resepsi Tamu Digital', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: colorBackground,
        foregroundColor: colorPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ilustrasi atau Icon utama
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: colorPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.supervised_user_circle_rounded,
                  size: 80,
                  color: colorPrimary,
                ),
              ),
              const SizedBox(height: 32),
              
              // Sambutan
              const Text(
                'Selamat Datang',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan catat kehadiran tamu hari ini.',
                style: TextStyle(
                  fontSize: 16,
                  color: colorTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Menu Cards
              _buildMenuCard(
                context: context,
                title: 'Isi resepsi tamu',
                subtitle: 'Tambah data tamu baru dan tanda tangan',
                icon: Icons.edit_document,
                route: '/guest_form',
                color: colorPrimary,
                surfaceColor: colorSurface,
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context: context,
                title: 'Lihat riwayat',
                subtitle: 'Daftar tamu yang telah hadir',
                icon: Icons.history_edu,
                route: '/history',
                color: const Color(0xFFBA7517), // Secondary color
                surfaceColor: colorSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
    required Color color,
    required Color surfaceColor,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
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
                      fontSize: 14,
                      color: Color(0xFF8A8880),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF8A8880),
            ),
          ],
        ),
      ),
    );
  }
}
