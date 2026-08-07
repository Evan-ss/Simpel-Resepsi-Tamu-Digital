// Smoke test aplikasi:
// 1. Memastikan aplikasi dapat dibangun, Splash Screen tampil,
//    lalu navigation bar dengan 4 menu muncul.
// 2. Memastikan tombol Tentang (About) menampilkan halaman
//    Tentang Aplikasi.
//
// Untuk menjalankan: `flutter test`

import 'package:flutter_test/flutter_test.dart';

import 'package:simpel_resepsi_tamu_digital/main.dart';

void main() {
  testWidgets('Aplikasi dapat dibangun, splash tampil, lalu navigation bar muncul',
      (WidgetTester tester) async {
    // Build aplikasi dan render frame pertama
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Splash Screen tampil lebih dulu
    expect(find.text('Buku Tamu'), findsOneWidget);
    expect(find.text('Digital'), findsOneWidget);

    // Jalankan waktu melewati timer splash (3,2 detik)...
    await tester.pump(const Duration(seconds: 4));

    // ...lalu beri frame tambahan agar transisi route (350 ms) selesai.
    // (Catatan: sengaja tidak memakai pumpAndSettle karena halaman
    // Riwayat menunggu database yang tidak tersedia di lingkungan test,
    // sehingga animasi loading tidak akan pernah selesai.)
    await tester.pump(const Duration(milliseconds: 500));

    // Navigation bar dengan 4 menu muncul
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Form Tamu'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Tentang'), findsOneWidget);
  });

  testWidgets('Tombol Tentang (About) menampilkan halaman Tentang Aplikasi',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));

    // Buka tab Tentang lewat navigation bar
    await tester.tap(find.text('Tentang'));
    await tester.pump();

    // Halaman About tampil dengan konten aplikasi
    expect(find.text('Tentang Aplikasi'), findsOneWidget);
    expect(find.text('Deskripsi Aplikasi'), findsOneWidget);
    expect(find.text('Fitur Utama'), findsOneWidget);
  });
}
