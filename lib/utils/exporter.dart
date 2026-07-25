import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../database/database_helper.dart';

class Exporter {
  /// ─── EXCEL (HTML) ───
  /// Export data tamu ke file HTML (bisa dibuka di Excel)
  static Future<String> exportToExcel() async {
    final data = await DatabaseHelper().getAllTamu();

    if (data.isEmpty) {
      throw Exception('Tidak ada data tamu untuk di-export.');
    }

    final html = _generateHtml(data);

    final dir = await getApplicationDocumentsDirectory();
    final appDir = Directory(dir.path);
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${appDir.path}/Laporan_Tamu_$timestamp.xls';
    await File(filePath).writeAsString(html);

    return filePath;
  }

  /// ─── PDF ───
  /// Export data tamu ke PDF dengan tanda tangan & foto embedded
  static Future<String> exportToPDF() async {
    final data = await DatabaseHelper().getAllTamu();

    if (data.isEmpty) {
      throw Exception('Tidak ada data tamu untuk di-export.');
    }

    final pdf = pw.Document();

    const primaryColor = PdfColor.fromInt(0xFF0F6E56);
    const goldColor = PdfColor.fromInt(0xFFBA7517);
    const textColor = PdfColor.fromInt(0xFF2C2C2A);
    const borderColor = PdfColor.fromInt(0xFFCCCCCC);
    const rowEvenColor = PdfColor.fromInt(0xFFF4FBF8);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        header: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Text(
            'Diexport pada ${DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
          ),
        ),
        footer: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 12),
          child: pw.Text(
            'Halaman',
            style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
          ),
        ),
        build: (context) => [
          // ── Judul ──
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'Laporan Data Tamu',
                  style: pw.TextStyle(
                    fontSize: 18,
                    color: primaryColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Total: ${data.length} tamu',
                  style: pw.TextStyle(fontSize: 10, color: goldColor),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),

          // ── Tabel ──
          pw.Table(
            border: pw.TableBorder.all(color: borderColor, width: 0.4),
            columnWidths: {
              0: const pw.FixedColumnWidth(24),
              1: const pw.FixedColumnWidth(65),
              2: const pw.FixedColumnWidth(95),
              3: const pw.FixedColumnWidth(75),
              4: const pw.FixedColumnWidth(52),
              5: const pw.FixedColumnWidth(75),
              6: const pw.FixedColumnWidth(45),
              7: const pw.FixedColumnWidth(58),
            },
            children: [
              // ── Header ──
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: primaryColor),
                children: [
                  _pdfCell('No', isHeader: true, align: pw.Alignment.center),
                  _pdfCell('Tanggal', isHeader: true),
                  _pdfCell('Nama', isHeader: true),
                  _pdfCell('Instansi', isHeader: true),
                  _pdfCell('Keperluan', isHeader: true, align: pw.Alignment.center),
                  _pdfCell('Pesan & Kesan', isHeader: true),
                  _pdfCell('TTD', isHeader: true, align: pw.Alignment.center),
                  _pdfCell('Foto', isHeader: true, align: pw.Alignment.center),
                ],
              ),
              // ── Data ──
              for (int i = 0; i < data.length; i++)
                _buildDataRow(data[i], i, rowEvenColor, goldColor, textColor, borderColor),
            ],
          ),

          pw.SizedBox(height: 16),
          pw.Text(
            'Dibuat dengan Simpel Resepsi Tamu Digital',
            style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    final bytes = await pdf.save();

    final dir = await getApplicationDocumentsDirectory();
    final appDir = Directory(dir.path);
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${appDir.path}/Laporan_Tamu_$timestamp.pdf';
    await File(filePath).writeAsBytes(bytes);

    return filePath;
  }

  /// Bangun satu baris data tabel PDF
  static pw.TableRow _buildDataRow(
    Map<String, dynamic> item,
    int index,
    PdfColor rowEvenColor,
    PdfColor goldColor,
    PdfColor textColor,
    PdfColor borderColor,
  ) {
    final rowBg = index % 2 == 0 ? rowEvenColor : PdfColors.white;
    final noStr = (index + 1).toString();

    final tanggal = item['tanggal_waktu'] != null
        ? DateFormat('dd MMM\nyyyy').format(DateTime.parse(item['tanggal_waktu'].toString()))
        : '-';
    final waktu = item['tanggal_waktu'] != null
        ? DateFormat('HH:mm').format(DateTime.parse(item['tanggal_waktu'].toString()))
        : '';
    final nama = item['nama']?.toString() ?? '-';
    final instansi = item['instansi']?.toString() ?? '-';
    final keperluan = item['keperluan']?.toString() ?? '-';
    final pesan = item['pesan']?.toString() ?? '';

    return pw.TableRow(
      decoration: pw.BoxDecoration(color: rowBg),
      verticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        // No
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          alignment: pw.Alignment.center,
          child: pw.Text(noStr, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        ),
        // Tanggal
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(tanggal, style: pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
              if (waktu.isNotEmpty)
                pw.Text(waktu, style: pw.TextStyle(fontSize: 6, color: PdfColors.grey500)),
            ],
          ),
        ),
        // Nama
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: pw.Text(
            nama,
            style: pw.TextStyle(fontSize: 8, color: textColor, fontWeight: pw.FontWeight.bold),
          ),
        ),
        // Instansi
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: pw.Text(instansi, style: pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
        ),
        // Keperluan (badge gold solid — teks hitam)
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          alignment: pw.Alignment.center,
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: pw.BoxDecoration(
              color: goldColor,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
            ),
            child: pw.Text(
              keperluan,
              style: pw.TextStyle(fontSize: 7, color: textColor, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ),
        // Pesan & Kesan
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: pw.Text(
            pesan.isNotEmpty ? pesan : '-',
            style: pw.TextStyle(fontSize: 6.5, color: PdfColors.grey700),
          ),
        ),
        // Tanda Tangan
        _buildImageCell(item['path_tanda_tangan'], height: 22),
        // Foto
        _buildImageCell(item['path_foto'], height: 28),
      ],
    );
  }

  /// Bungkus gambar di dalam sel tabel (handle error)
  static pw.Container _buildImageCell(String? path, {required double height}) {
    pw.Widget imageWidget;

    if (path != null && path.isNotEmpty) {
      try {
        final file = File(path);
        if (file.existsSync()) {
          final bytes = file.readAsBytesSync();
          imageWidget = pw.Image(
            pw.MemoryImage(bytes),
            fit: pw.BoxFit.contain,
            height: height,
          );
        } else {
          imageWidget = pw.Text('-',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500));
        }
      } catch (_) {
        imageWidget =
            pw.Text('-', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500));
      }
    } else {
      imageWidget =
          pw.Text('-', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500));
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      alignment: pw.Alignment.center,
      child: imageWidget,
    );
  }

  /// Helper cell sederhana untuk header
  static pw.Container _pdfCell(
    String text, {
    bool isHeader = false,
    pw.Alignment? align,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 6),
      alignment: align ?? pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 8 : 7,
          color: isHeader ? PdfColors.white : null,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }

  /// ─── HTML GENERATOR (Excel) ───
  static String _generateHtml(List<Map<String, dynamic>> data) {
    const clrPrimary  = '#0F6E56';
    const clrGold     = '#BA7517';
    const clrText     = '#2C2C2A';
    const clrSubtext  = '#6B6B69';
    const clrBorder   = '#CCCCCC';
    const clrRowEven  = '#F4FBF8';

    final StringBuffer rows = StringBuffer();
    int no = 1;
    for (final item in data) {
      final nama      = _escapeHtml(item['nama']?.toString() ?? '-');
      final instansi  = _escapeHtml(item['instansi']?.toString() ?? '-');
      final keperluan = _escapeHtml(item['keperluan']?.toString() ?? '-');
      final pesan     = _escapeHtml(item['pesan']?.toString() ?? '');
      final tanggal   = item['tanggal_waktu'] != null
          ? DateFormat('dd MMM yyyy, HH:mm')
              .format(DateTime.parse(item['tanggal_waktu'].toString()))
          : '-';

      final rowBg = no % 2 == 0 ? clrRowEven : '#ffffff';

      rows.writeln('''
        <tr>
          <td style="background:$rowBg;color:$clrSubtext;text-align:center;font-size:12px;padding:9px 8px;border:1px solid $clrBorder;">$no</td>
          <td style="background:$rowBg;color:$clrText;font-size:13px;padding:9px 12px;border:1px solid $clrBorder;white-space:nowrap;">$tanggal</td>
          <td style="background:$rowBg;color:$clrText;font-size:13px;font-weight:bold;padding:9px 12px;border:1px solid $clrBorder;">$nama</td>
          <td style="background:$rowBg;color:$clrSubtext;font-size:13px;padding:9px 12px;border:1px solid $clrBorder;">$instansi</td>
          <td style="background:$rowBg;text-align:center;padding:9px 8px;border:1px solid $clrBorder;">
            <span style="background:$clrGold;color:$clrText;font-size:11px;font-weight:bold;padding:3px 10px;">${keperluan}</span>
          </td>
          <td style="background:$rowBg;color:$clrText;font-size:12px;padding:9px 12px;border:1px solid $clrBorder;">${pesan.isNotEmpty ? pesan : '-'}</td>
        </tr>''');
      no++;
    }

    return '''<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<body style="margin:20px;font-family:'Segoe UI',Calibri,Arial,sans-serif;">

<table cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;width:100%;">
  <thead>
    <tr>
      <th style="background:$clrPrimary;color:#fff;font-size:12px;font-weight:700;padding:12px 8px;text-align:center;border:1px solid #0A4D3C;width:40px;">No</th>
      <th style="background:$clrPrimary;color:#fff;font-size:12px;font-weight:700;padding:12px 12px;text-align:left;border:1px solid #0A4D3C;">Tanggal</th>
      <th style="background:$clrPrimary;color:#fff;font-size:12px;font-weight:700;padding:12px 12px;text-align:left;border:1px solid #0A4D3C;">Nama</th>
      <th style="background:$clrPrimary;color:#fff;font-size:12px;font-weight:700;padding:12px 12px;text-align:left;border:1px solid #0A4D3C;">Instansi</th>
      <th style="background:$clrPrimary;color:#fff;font-size:12px;font-weight:700;padding:12px 8px;text-align:center;border:1px solid #0A4D3C;">Keperluan</th>
      <th style="background:$clrPrimary;color:#fff;font-size:12px;font-weight:700;padding:12px 12px;text-align:left;border:1px solid #0A4D3C;">Pesan &amp; Kesan</th>
    </tr>
  </thead>
  <tbody>
$rows
  </tbody>
</table>

</body>
</html>
''';
  }

  /// Escape HTML special characters
  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
  }
}
