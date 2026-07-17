# Prompt: Aplikasi Resepsi Tamu Digital

## Konteks
Saya sedang mengerjakan tugas sekolah membuat aplikasi Flutter untuk pencatatan resepsi tamu digital dengan fitur tanda tangan. Saya masih pemula di Flutter, jadi tolong bangun secara bertahap, dengan kode yang rapi dan mudah dipahami (beri komentar singkat di bagian penting), bukan langsung semua file sekaligus.

## Ringkasan aplikasi
Nama aplikasi: **Resepsi Tamu Digital** (repo GitHub: `Simpel-Resepsi-Tamu-Digital`). Tolong gunakan nama ini secara konsisten untuk judul aplikasi, AppBar, dan nama project/folder Flutter (misalnya nama project bisa `simpel_resepsi_tamu_digital`), supaya sesuai dengan repo yang sudah saya buat. Aplikasi offline untuk mencatat tamu yang datang ke sebuah instansi: input data tamu, tanda tangan digital, riwayat tamu yang dikelompokkan per tanggal, serta pencarian dan filter tanggal.

## Platform & teknologi
- Target platform: **Android** dan **Windows Desktop**
- Flutter (Dart)
- Database: `sqflite` untuk Android, `sqflite_common_ffi` untuk Windows (pastikan inisialisasi database bisa jalan di kedua platform)
- Package tanda tangan: `signature`
- Package pendukung: `path_provider` (menyimpan file gambar tanda tangan), `intl` (format tanggal)

## Struktur data (tabel `tamu`)
- id (integer, primary key, auto increment)
- nama (text)
- instansi (text)
- keperluan (text) — kategori: Rapat, Kunjungan, Pengiriman, Lainnya
- tanggal_waktu (text/datetime)
- path_tanda_tangan (text) — path ke file gambar signature

## Fitur yang harus dibangun (wajib, sesuai tugas)
1. **Halaman utama** — dua tombol: "Isi resepsi tamu" dan "Lihat riwayat"
2. **Form tamu** — input nama, instansi, dropdown kategori keperluan, area tanda tangan digital (canvas), tombol hapus dan simpan tanda tangan
3. **Simpan data** — simpan data tamu + path gambar tanda tangan ke SQLite, tampilkan notifikasi singkat "Data berhasil disimpan" setelah tersimpan
4. **Riwayat tamu** — daftar tamu dikelompokkan per tanggal (section header per tanggal, urut dari terbaru), dengan search bar (cari berdasarkan nama) dan filter tanggal (date picker)
5. **Detail tamu** (opsional, kalau waktu memungkinkan) — tampilkan detail satu tamu beserta gambar tanda tangannya saat item di riwayat diklik

## Fitur tambahan (opsional, kerjakan hanya jika fitur wajib sudah selesai dan berjalan lancar)
- Ringkasan jumlah tamu hari ini di halaman utama
- Badge warna berbeda di riwayat sesuai kategori keperluan

## Identitas desain
- Gaya: modern minimalist, flat design, hangat dan elegan (bukan norak/berlebihan)
- Sudut membulat lembut (12-16px) pada kartu dan tombol
- Tanpa shadow tebal, tanpa gradasi mencolok

### Palet warna
- Primary: Deep emerald `#0F6E56` — tombol utama, header, ikon aktif
- Secondary: Warm gold `#BA7517` — badge kategori, aksen kecil
- Background: Ivory cream `#FAF9F5`
- Surface/kartu: Putih `#FFFFFF`
- Teks utama: Charcoal `#2C2C2A`
- Teks sekunder: Warm gray `#8A8880`
- Danger: `#E24B4A` — tombol hapus/error
- Success: `#639922` — notifikasi berhasil

### Tipografi
Sans-serif modern (Inter atau Poppins), judul medium weight, body regular weight.

## Motion & interaksi (sederhana, jangan berlebihan)
- Transisi antar halaman: fade + slide-up singkat (gunakan `PageRouteBuilder` atau `AnimatedSwitcher`, durasi sekitar 300ms)
- Tombol ditekan: efek scale kecil bawaan Flutter (`InkWell`/`GestureDetector` sudah cukup, tidak perlu animasi custom rumit)
- List riwayat tamu: fade-in bertahap saat pertama kali dimuat (boleh pakai package `flutter_animate` kalau tersedia, atau `AnimatedList` bawaan Flutter — pilih yang paling sederhana untuk diimplementasikan)
- Notifikasi "berhasil disimpan": gunakan `SnackBar` bawaan Flutter, tidak perlu custom animation

## Yang TIDAK perlu dibangun (di luar scope tugas ini)
- Dashboard analytics, indikator kapasitas venue, activity feed
- Audit trail / metadata IP atau device
- Export ke PDF/Excel
- Print badge, flag record, sistem keamanan lanjutan
- Login/autentikasi admin
- Versi web

## Urutan pengerjaan yang diinginkan
Tolong bangun bertahap sesuai urutan berikut, jangan loncat tahap:
1. Setup project Flutter, aktifkan dukungan Windows desktop
2. Buat struktur navigasi dasar antar 3 halaman (Halaman Utama, Form Tamu, Riwayat)
3. Bangun Halaman Utama sesuai desain
4. Bangun Form Tamu (input + dropdown kategori)
5. Tambahkan widget tanda tangan digital di Form Tamu
6. Setup database SQLite (helper class untuk insert/read, kompatibel Android & Windows)
7. Hubungkan Form Tamu agar bisa menyimpan data ke database
8. Bangun Halaman Riwayat dengan pengelompokan per tanggal, search, dan filter tanggal
9. Terapkan palet warna dan gaya desain di atas ke seluruh aplikasi (lewat `ThemeData` terpusat)

Setiap selesai satu tahap, jelaskan singkat apa yang baru ditambahkan sebelum lanjut ke tahap berikutnya.