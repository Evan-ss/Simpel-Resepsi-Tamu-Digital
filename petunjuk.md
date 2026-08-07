# Prompt Perbaikan Lokasi Penyimpanan PDF (Flutter)

Sistem pembuatan PDF saat ini menyimpan file ke direktori internal khusus aplikasi (`Android/data/...`). Pada Android 11+, folder ini disembunyikan oleh sistem keamanan OS sehingga file tidak bisa ditemukan oleh pengguna di File Manager.

Tolong perbaiki alur pembuatan & penyimpanan file PDF dengan spesifikasi di bawah ini.

---

## 🎯 Tujuan Refactoring

1. Simpan file PDF ke **folder publik `Download`** agar pengguna bisa menemukannya di File Manager / Storage HP.
2. Tambahkan aksi **langsung membuka file PDF** saat tombol `BUKA` di SnackBar diklik.

---

## 🛠️ Langkah Perubahan Kode

### 1. Tambahkan Dependency
Pastikan package `open_filex` dan `path_provider` ada di `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  path_provider: ^2.1.2
  open_filex: ^4.3.4
```

---

### 2. Ubah Logika Penentuan Path File PDF
Ganti penggunaan `getApplicationDocumentsDirectory()` atau `getExternalStorageDirectory()` menjadi direktori publik `Download`.

**Contoh Implementasi Kode:**

```dart
import 'dart:io';
import 'package:open_filex/open_filex.dart';

Future<String> getSavePath(String fileName) async {
  Directory? targetDir;

  if (Platform.isAndroid) {
    // Jalur langsung ke folder Download publik Android
    targetDir = Directory('/storage/emulated/0/Download');
    
    // Fallback jika direktori belum ada
    if (!await targetDir.exists()) {
      targetDir = await getExternalStorageDirectory();
    }
  } else {
    // Jalur untuk iOS
    targetDir = await getApplicationDocumentsDirectory();
  }

  return '${targetDir!.path}/$fileName';
}
```

---

### 3. Perbarui Fungsi Export & Action Tombol BUKA

Sesuaikan SnackBar atau Notification yang menampilkan pesan sukses agar tombol **BUKA** memanggil `OpenFilex.open(filePath)`:

```dart
// 1. Simpan file ke path Download
final String fileName = 'Buku_Tamu_Digital_${DateTime.now().millisecondsSinceEpoch}.pdf';
final String filePath = await getSavePath(fileName);

final File file = File(filePath);
await file.writeAsBytes(await pdf.save());

// 2. Tampilkan SnackBar dengan penangan klik "BUKA"
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    backgroundColor: const Color(0xFF558B2F), // Muted green sesuai UI
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAlignment.start,
      children: [
        const Text(
          'Export PDF berhasil!',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          filePath,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
    action: SnackBarAction(
      label: 'BUKA',
      textColor: Colors.white,
      onPressed: () async {
        final result = await OpenFilex.open(filePath);
        if (result.type != ResultType.done) {
          debugPrint('Gagal membuka file: ${result.message}');
        }
      },
    ),
  ),
);
```

---

### 4. Tambahkan Permission di `AndroidManifest.xml` (Khusus Android)

Buka `android/app/src/main/AndroidManifest.xml` dan pastikan izin penyimpanan terpasang di luar tag `<application>`:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

Jika menargetkan Android 10 (API level 29), tambahkan atribut berikut di dalam tag `<application>`:

```xml
<application
    ...
    android:requestLegacyExternalStorage="true">
```

---

## ✅ Indikator Keberhasilan

1. Setelah export berhasil, file PDF dapat ditemukan di folder **Internal Storage > Download**.
2. Saat tombol **BUKA** di SnackBar ditekan, HP langsung membuka aplikasi pembaca PDF bawaan untuk menampilkan dokumen tersebut.