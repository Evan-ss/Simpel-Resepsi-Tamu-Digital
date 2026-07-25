@echo off
title Memulai Simpel Resepsi Tamu Digital...
:: Mengubah warna teks menjadi Light Aqua (agar terlihat lebih ramah & rapi)
color 0B

echo =========================================================================
echo.
echo    SELAMAT DATANG DI APLIKASI "SIMPEL RESEPSI TAMU DIGITAL"
echo.
echo    Skrip otomatis ini akan menyiapkan semuanya untuk Anda.
echo    Tolong biarkan jendela hitam (Terminal) ini tetap terbuka ya!
echo.
echo =========================================================================
echo.

:: 1. Cek apakah Flutter terinstall dan sudah masuk Path
echo [Pengecekan Sistem] Memeriksa mesin instalasi Flutter...
WHERE flutter >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    :: Mengubah warna teks menjadi Merah Terang (Tanda Peringatan)
    color 0C
    echo.
    echo =========================================================================
    echo   [X] ERROR: MESIN FLUTTER BELUM DITEMUKAN ATAU BELUM DI-SETTING!
    echo =========================================================================
    echo.
    echo Aplikasi ini membutuhkan mesin pembuatnya (Flutter) agar bisa berjalan.
    echo Sepertinya komputer Anda belum memilikinya, atau Anda belum mendaftarkan
    echo folder ekstrak Flutter ke dalam "Environment Variables" Windows Anda.
    echo.
    echo SILAKAN IKUTI LANGKAH BERIKUT:
    echo 1. Buka file "README.md" yang ada di folder ini.
    echo 2. Baca bagian "TAHAP 1: Persiapan Aplikasi Wajib".
    echo 3. Lakukan instalasi Visual Studio 2022 dan Flutter SDK sesuai panduan.
    echo 4. JANGAN LUPA: Pastikan Anda sudah memasukkan path direktori bin Flutter 
    echo    (contoh: C:\flutter\bin) ke dalam pengaturan "Environment Variables".
    echo.
    echo Jika Anda sudah melakukan semua perbaikan di atas, tutup jendela ini, 
    echo lalu klik ganda (double-click) file start.bat ini lagi.
    echo.
    pause
    exit /b
)

echo [OK] Mesin Flutter berhasil ditemukan!
echo.

:: 2. Proses Setup
echo =========================================================================
echo    MENYIAPKAN APLIKASI... (Mohon tunggu sebentar, butuh internet)
echo =========================================================================
echo.

echo [Langkah 1/3] Membersihkan file sisa agar aplikasi fresh kembali...
call flutter clean >nul 2>&1
echo               Selesai dibersihkan!
echo.

echo [Langkah 2/3] Mengunduh bahan pendukung aplikasi ke komputer Anda...
call flutter pub get
echo.

echo [Langkah 3/3] Sedang membangun dan membuka aplikasi di layar Anda...
echo               (Catatan: Proses ini butuh 1-2 menit pada percobaan pertama)
echo.

:: Menjalankan aplikasi untuk Windows Desktop
call flutter run -d windows

echo.
echo =========================================================================
echo    APLIKASI TELAH DITUTUP. TERIMA KASIH!
echo =========================================================================
pause
