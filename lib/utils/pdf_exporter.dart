import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../database/database_helper.dart';

class PdfExporter {
  // Palet warna yang sama dengan aplikasi
  static final _cPrimary   = PdfColor.fromHex('0F6E56');
  static final _cPrimaryDk = PdfColor.fromHex('0A4D3C');
  static final _cGold      = PdfColor.fromHex('BA7517');
  static final _cBg        = PdfColor.fromHex('FAF9F5');
  static final _cSurface   = PdfColors.white;
  static final _cText      = PdfColor.fromHex('2C2C2A');
  static final _cSubtext   = PdfColor.fromHex('8A8880');
  static final _cBorder    = PdfColor.fromHex('E8E8E5');
  static final _cRowEven   = PdfColor.fromHex('F0F7F4');
  static final _cDanger    = PdfColor.fromHex('E24B4A');

  /// Warna badge berdasarkan kategori keperluan
  static PdfColor _badgeColor(String keperluan) {
    switch (keperluan) {
      case 'Rapat':      return PdfColor.fromHex('1565C0');
      case 'Kunjungan':  return PdfColor.fromHex('2E7D32');
      case 'Pengiriman': return PdfColor.fromHex('6A1B9A');
      default:           return _cGold;
    }
  }

  /// Export semua data tamu ke PDF, kembalikan path file
  static Future<String> exportToPdf() async {
    final data = await DatabaseHelper().getAllTamu();
    if (data.isEmpty) {
      throw Exception('Tidak ada data tamu untuk di-export.');
    }

    final pdf = pw.Document();
    final now = DateTime.now();
    final dateNow = DateFormat('dd MMMM yyyy, HH:mm').format(now);

    // Kelompokkan per tanggal
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in data) {
      final dateKey = DateFormat('dd MMMM yyyy')
          .format(DateTime.parse(item['tanggal_waktu']));
      grouped.putIfAbsent(dateKey, () => []).add(item);
    }

    // ===== HALAMAN COVER =====
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (ctx) => _buildCoverPage(dateNow, data.length, grouped.length),
      ),
    );

    // ===== HALAMAN DATA (tiap tamu = 1 card, beberapa per halaman) =====
    final List<pw.Widget> cards = [];
    int no = 1;
    for (final dateKey in grouped.keys) {
      // Header tanggal
      cards.add(_buildDateHeader(dateKey));
      for (final item in grouped[dateKey]!) {
        cards.add(await _buildGuestCard(item, no));
        no++;
      }
    }

    // Bagi cards ke halaman-halaman A4
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        header: (ctx) => _buildPageHeader(ctx.pageNumber, ctx.pagesCount),
        footer: (ctx) => _buildPageFooter(dateNow),
        build: (ctx) => cards,
      ),
    );

    // Simpan file
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(now);
    final filePath = '${dir.path}/Laporan_Tamu_$timestamp.pdf';
    await File(filePath).writeAsBytes(await pdf.save());

    return filePath;
  }

  // ========== COVER PAGE ==========
  static pw.Widget _buildCoverPage(
      String dateNow, int totalTamu, int totalHari) {
    return pw.Stack(
      children: [
        // Background utama (emerald gelap)
        pw.Positioned.fill(
          child: pw.Container(color: _cPrimaryDk),
        ),

        // Dekorasi lingkaran kanan atas
        pw.Positioned(
          top: -80, right: -80,
          child: pw.Container(
            width: 300, height: 300,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: PdfColor.fromHex('1A7A60'),
            ),
          ),
        ),

        // Dekorasi lingkaran kiri bawah
        pw.Positioned(
          bottom: -100, left: -60,
          child: pw.Container(
            width: 360, height: 360,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: PdfColor.fromHex('0D5A46'),
            ),
          ),
        ),

        // Konten cover
        pw.Padding(
          padding: const pw.EdgeInsets.all(56),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Badge atas
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                      color: PdfColor.fromHex('4A9A7A'), width: 1),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  'LAPORAN RESMI',
                  style: pw.TextStyle(
                    color: PdfColor.fromHex('C8EDE2'),
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              pw.SizedBox(height: 40),

              // Label kecil
              pw.Text(
                'RESEPSI TAMU DIGITAL',
                style: pw.TextStyle(
                  color: PdfColor.fromHex('88CCAA'),
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              pw.SizedBox(height: 12),

              // Judul besar
              pw.Text(
                'Laporan\nData Tamu',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 44,
                  fontWeight: pw.FontWeight.bold,
                  lineSpacing: 4,
                ),
              ),
              pw.SizedBox(height: 16),

              // Garis aksen emas
              pw.Container(
                width: 60, height: 4,
                decoration: pw.BoxDecoration(
                  color: _cGold,
                  borderRadius: pw.BorderRadius.circular(2),
                ),
              ),

              pw.SizedBox(height: 24),
              pw.Text(
                'Digenerate pada $dateNow',
                style: pw.TextStyle(
                  color: PdfColor.fromHex('99CCBB'),
                  fontSize: 12,
                ),
              ),

              pw.Spacer(),

              // Stat cards row
              pw.Row(children: [
                _coverStatCard('Total Tamu', '$totalTamu', 'entri'),
                pw.SizedBox(width: 16),
                _coverStatCard('Total Hari', '$totalHari', 'hari'),
                pw.SizedBox(width: 16),
                _coverStatCard('Status', 'Offline', 'lokal'),
              ]),

              pw.SizedBox(height: 40),

              // Garis bawah
              pw.Divider(color: PdfColor.fromHex('2A7A60'), thickness: 1),
              pw.SizedBox(height: 12),
              pw.Text(
                'Database tersimpan di perangkat lokal  •  Dokumen ini dibuat secara otomatis',
                style: pw.TextStyle(
                  color: PdfColor.fromHex('77AAAA'),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _coverStatCard(String label, String value, String unit) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('1A7A60'),
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColor.fromHex('3A9A7A'), width: 1),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: pw.TextStyle(
                    color: PdfColor.fromHex('88CCAA'),
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 0.8)),
            pw.SizedBox(height: 6),
            pw.Text(value,
                style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold)),
            pw.Text(unit,
                style: pw.TextStyle(
                    color: PdfColor.fromHex('77AAAA'), fontSize: 9)),
          ],
        ),
      ),
    );
  }

  // ========== HEADER HALAMAN DATA ==========
  static pw.Widget _buildPageHeader(int page, int total) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: pw.BoxDecoration(
        color: _cPrimary,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Laporan Data Tamu  •  Resepsi Tamu Digital',
            style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Halaman $page / $total',
            style: pw.TextStyle(color: PdfColor.fromHex('C8EDE2'), fontSize: 9),
          ),
        ],
      ),
    );
  }

  // ========== FOOTER HALAMAN ==========
  static pw.Widget _buildPageFooter(String dateNow) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Resepsi Tamu Digital  •  ${DateTime.now().year}',
              style: pw.TextStyle(color: PdfColors.grey600, fontSize: 8)),
          pw.Text('Digenerate: $dateNow',
              style: pw.TextStyle(color: PdfColors.grey600, fontSize: 8)),
        ],
      ),
    );
  }

  // ========== HEADER TANGGAL ==========
  static pw.Widget _buildDateHeader(String dateStr) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 16, bottom: 8),
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: pw.BoxDecoration(
        color: _cPrimary,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(children: [
        pw.Container(
          width: 3, height: 14,
          color: _cGold,
          margin: const pw.EdgeInsets.only(right: 8),
        ),
        pw.Text(
          dateStr,
          style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold),
        ),
      ]),
    );
  }

  // ========== KARTU TAMU ==========
  static Future<pw.Widget> _buildGuestCard(
      Map<String, dynamic> item, int no) async {
    final nama      = item['nama']?.toString() ?? '-';
    final instansi  = item['instansi']?.toString() ?? '-';
    final keperluan = item['keperluan']?.toString() ?? '-';
    final pesan     = item['pesan']?.toString() ?? '';
    final waktu     = item['tanggal_waktu'] != null
        ? DateFormat('HH:mm').format(DateTime.parse(item['tanggal_waktu']))
        : '-';

    // Load gambar tanda tangan
    pw.Widget? signatureWidget;
    final sigPath = item['path_tanda_tangan']?.toString() ?? '';
    if (sigPath.isNotEmpty) {
      final sigFile = File(sigPath);
      if (await sigFile.exists()) {
        try {
          final bytes = await sigFile.readAsBytes();
          final img = pw.MemoryImage(bytes);
          signatureWidget = pw.Image(img, height: 60, fit: pw.BoxFit.contain);
        } catch (_) {}
      }
    }

    // Load gambar foto tamu
    pw.Widget? fotoWidget;
    final fotoPath = item['path_foto']?.toString() ?? '';
    if (fotoPath.isNotEmpty) {
      final fotoFile = File(fotoPath);
      if (await fotoFile.exists()) {
        try {
          final bytes = await fotoFile.readAsBytes();
          final img = pw.MemoryImage(bytes);
          fotoWidget = pw.ClipRRect(
            horizontalRadius: 6,
            verticalRadius: 6,
            child: pw.Image(img,
                width: 80, height: 80, fit: pw.BoxFit.cover),
          );
        } catch (_) {}
      }
    }

    final badgeColor = _badgeColor(keperluan);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      decoration: pw.BoxDecoration(
        color: _cSurface,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: _cBorder, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [

          // ── TOP BAR: nomor + nama + waktu + badge keperluan ──
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: pw.BoxDecoration(
              color: _cRowEven,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(10),
                topRight: pw.Radius.circular(10),
              ),
            ),
            child: pw.Row(
              children: [
                // Nomor urut
                pw.Container(
                  width: 26, height: 26,
                  decoration: pw.BoxDecoration(
                    color: _cPrimary,
                    shape: pw.BoxShape.circle,
                  ),
                  alignment: pw.Alignment.center,
                  child: pw.Text('$no',
                      style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(width: 10),

                // Nama
                pw.Expanded(
                  child: pw.Text(nama,
                      style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: _cText)),
                ),

                // Badge keperluan
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: pw.BoxDecoration(
                    color: badgeColor,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(keperluan,
                      style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(width: 10),

                // Jam
                pw.Text(waktu,
                    style: pw.TextStyle(
                        color: _cPrimary,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),

          // ── BODY: foto + info + tanda tangan ──
          pw.Padding(
            padding: const pw.EdgeInsets.all(14),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                // Foto tamu (jika ada)
                if (fotoWidget != null) ...[
                  pw.Column(children: [
                    fotoWidget,
                    pw.SizedBox(height: 4),
                    pw.Text('Foto Tamu',
                        style: pw.TextStyle(
                            color: _cSubtext, fontSize: 7)),
                  ]),
                  pw.SizedBox(width: 14),
                ],

                // Info tamu
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _infoRow('Instansi', instansi),
                      pw.SizedBox(height: 6),
                      if (pesan.isNotEmpty) ...[
                        _infoRow('Pesan & Kesan', ''),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('FFF8EC'),
                            borderRadius: pw.BorderRadius.circular(5),
                            border: pw.Border.all(
                                color: PdfColor.fromHex('E8D5A0'), width: 0.5),
                          ),
                          child: pw.Text(pesan,
                              style: pw.TextStyle(
                                  color: _cText,
                                  fontSize: 9,
                                  lineSpacing: 2)),
                        ),
                      ] else
                        pw.Text('Tidak ada pesan',
                            style: pw.TextStyle(
                                color: PdfColors.grey400, fontSize: 9,
                                fontStyle: pw.FontStyle.italic)),
                    ],
                  ),
                ),

                // Tanda tangan (jika ada)
                pw.SizedBox(width: 14),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      width: 110, height: 65,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey50,
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(color: _cBorder, width: 0.5),
                      ),
                      alignment: pw.Alignment.center,
                      child: signatureWidget ??
                          pw.Text('Tidak ada\ntanda tangan',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                  color: PdfColors.grey400,
                                  fontSize: 7,
                                  fontStyle: pw.FontStyle.italic)),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Tanda Tangan',
                        style: pw.TextStyle(color: _cSubtext, fontSize: 7)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper: baris info label-value
  static pw.Widget _infoRow(String label, String value) {
    return pw.RichText(
      text: pw.TextSpan(children: [
        pw.TextSpan(
          text: '$label: ',
          style: pw.TextStyle(
              color: PdfColors.grey600,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold),
        ),
        pw.TextSpan(
          text: value,
          style: pw.TextStyle(color: PdfColors.grey800, fontSize: 9),
        ),
      ]),
    );
  }
}
