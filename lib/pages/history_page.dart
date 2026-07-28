import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../utils/app_logger.dart';
import '../utils/exporter.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;
  
  List<Map<String, dynamic>> _allTamu = [];
  List<Map<String, dynamic>> _filteredTamu = [];
  
  bool _isLoading = true;

  // Warna sementara
  final Color _colorPrimary = const Color(0xFF0F6E56);
  final Color _colorSecondary = const Color(0xFFBA7517);
  final Color _colorBackground = const Color(0xFFFAF9F5);
  final Color _colorSurface = const Color(0xFFFFFFFF);
  final Color _colorTextPrimary = const Color(0xFF2C2C2A);
  final Color _colorTextSecondary = const Color(0xFF8A8880);


  @override
  void initState() {
    super.initState();
    AppLogger.pageOpen('HistoryPage');
    _loadData();
  }

  Future<void> _loadData() async {
    AppLogger.database('SELECT', table: 'tamu', detail: 'memuat semua data');
    setState(() => _isLoading = true);
    final data = await DatabaseHelper().getAllTamu();
    AppLogger.success('Data dimuat: ${data.length} tamu ditemukan');
    setState(() {
      _allTamu = data;
      _isLoading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final keyword = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredTamu = _allTamu.where((item) {
        // Filter nama
        final namaMatch = item['nama'].toString().toLowerCase().contains(keyword);
        
        // Filter tanggal
        bool dateMatch = true;
        if (_selectedDate != null) {
          final itemDate = DateTime.parse(item['tanggal_waktu']);
          dateMatch = itemDate.year == _selectedDate!.year &&
                      itemDate.month == _selectedDate!.month &&
                      itemDate.day == _selectedDate!.day;
        }

        return namaMatch && dateMatch;
      }).toList();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _colorPrimary,
              onPrimary: Colors.white,
              onSurface: _colorTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _applyFilters();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
    _applyFilters();
  }

  /// Tampilkan dialog pilih format export
  void _showExportDialog() {
    AppLogger.buttonTap('Buka dialog Export');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _colorSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _colorPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.file_download_outlined, size: 28, color: Color(0xFF0F6E56)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Export Data Tamu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pilih format file yang diinginkan',
              style: TextStyle(fontSize: 13, color: Color(0xFF8A8880)),
            ),
            const SizedBox(height: 20),

            // Tombol Excel
            _exportOption(
              icon: Icons.table_chart_outlined,
              title: 'Microsoft Excel',
              subtitle: '.xls — Bisa dibuka di Excel & Browser',
              color: const Color(0xFF217346),
              onTap: () {
                Navigator.pop(context);
                _exportToExcel();
              },
            ),
            const SizedBox(height: 10),

            // Tombol PDF
            _exportOption(
              icon: Icons.picture_as_pdf_outlined,
              title: 'Dokumen PDF',
              subtitle: '.pdf — Dengan tanda tangan & foto',
              color: const Color(0xFFBA0C2F),
              onTap: () {
                Navigator.pop(context);
                _exportToPDF();
              },
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8A8880),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget opsi export di dialog
  Widget _exportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
            color: color.withOpacity(0.04),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _colorTextPrimary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: _colorTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color.withOpacity(0.5), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Export ke Excel — dengan progress bar 10 detik
  Future<void> _exportToExcel() => _runExportWithProgress(
    'Excel',
    Exporter.exportToExcel(),
  );

  /// Export ke PDF — dengan progress bar 10 detik
  Future<void> _exportToPDF() => _runExportWithProgress(
    'PDF',
    Exporter.exportToPDF(),
  );

  /// Jalankan export dengan progress bar 10 detik (tidak berpacu pada kecepatan download)
  Future<void> _runExportWithProgress(String format, Future<String> exportFuture) async {
    AppLogger.buttonTap('Export ke $format');
    try {
      if (!mounted) return;

      // Tampilkan progress dialog — dialog akan auto-close setelah 10 detik + export selesai
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ExportProgressDialog(exportFuture: exportFuture),
      );

      if (result == null || !mounted) return;

      final error = result['error'];
      if (error != null) {
        AppLogger.error('Gagal export $format', error: error);
        if (mounted) _showErrorSnackBar(error);
        return;
      }

      final filePath = result['path'] as String?;
      if (filePath != null && mounted) {
        AppLogger.success('$format berhasil disimpan: $filePath');
        _showSuccessSnackBar(filePath, 'Export $format berhasil!');
      }
    } catch (e) {
      AppLogger.error('Gagal export $format', error: e);
      if (mounted) _showErrorSnackBar(e);
    }
  }

  /// SnackBar sukses
  void _showSuccessSnackBar(String filePath, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    filePath.split('\\').last,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _openFile(filePath),
              child: const Text('BUKA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF639922),
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// SnackBar error
  void _showErrorSnackBar(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal export: $error'),
        backgroundColor: _colorPrimary,
      ),
    );
  }

  Future<void> _openFile(String filePath) async {
    AppLogger.buttonTap('Buka File Excel');
    try {
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', filePath]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [filePath]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [filePath]);
      }
    } catch (e) {
      AppLogger.error('Gagal buka file', error: e);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Mengelompokkan data per tanggal
  Map<String, List<Map<String, dynamic>>> _groupDataByDate(List<Map<String, dynamic>> data) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in data) {
      final dateObj = DateTime.parse(item['tanggal_waktu']);
      final dateStr = DateFormat('dd MMMM yyyy').format(dateObj);
      if (!grouped.containsKey(dateStr)) {
        grouped[dateStr] = [];
      }
      grouped[dateStr]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = _groupDataByDate(_filteredTamu);
    final sortedDates = groupedData.keys.toList(); // Karena dari DB sudah diurutkan DESC, tanggal akan mengikuti

    return Scaffold(
      backgroundColor: _colorBackground,
      appBar: AppBar(
        title: const Text('Riwayat Tamu', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: _colorBackground,
        foregroundColor: _colorPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Tooltip(
              message: 'Export Data',
              child: Container(
                decoration: BoxDecoration(
                  color: _colorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _allTamu.isEmpty ? null : _showExportDialog,
                  icon: const Icon(Icons.file_download_outlined),
                  color: _allTamu.isEmpty ? _colorTextSecondary : _colorPrimary,
                  tooltip: 'Export Data',
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Bagian Pencarian & Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: _colorBackground,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    AppLogger.formInput('Cari nama', value: value.isNotEmpty ? value : '(semua)');
                    _applyFilters();
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari nama tamu...',
                    prefixIcon: Icon(Icons.search, color: _colorTextSecondary),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          AppLogger.buttonTap('Filter Tanggal');
                          _pickDate();
                        },
                        icon: Icon(Icons.calendar_today, size: 18, color: _colorPrimary),
                        label: Text(
                          _selectedDate == null 
                            ? 'Filter Tanggal' 
                            : DateFormat('dd MMM yyyy').format(_selectedDate!),
                          style: TextStyle(color: _colorPrimary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _colorPrimary.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    if (_selectedDate != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          AppLogger.buttonTap('Hapus Filter Tanggal');
                          _clearDateFilter();
                        },
                        icon: const Icon(Icons.clear),
                        color: Colors.red,
                        tooltip: 'Hapus filter tanggal',
                      )
                    ]
                  ],
                ),
              ],
            ),
          ),
          
          // List Riwayat
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: _colorPrimary))
              : _filteredTamu.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: sortedDates.length,
                    itemBuilder: (context, index) {
                      final date = sortedDates[index];
                      final items = groupedData[date]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 8),
                            child: Text(
                              date,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _colorTextPrimary,
                              ),
                            ),
                          ),
                          ...items.map((item) => _buildTamuCard(item)).toList(),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: _colorTextSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data tamu ditemukan.',
            style: TextStyle(color: _colorTextSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTamuCard(Map<String, dynamic> item) {
    final timeStr = DateFormat('HH:mm').format(DateTime.parse(item['tanggal_waktu']));
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        color: _colorSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          title: Text(
            item['nama'],
            style: TextStyle(fontWeight: FontWeight.bold, color: _colorTextPrimary, fontSize: 16),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['instansi'], style: TextStyle(color: _colorTextSecondary)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _colorSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['keperluan'],
                    style: TextStyle(color: _colorSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(timeStr, style: TextStyle(fontWeight: FontWeight.bold, color: _colorPrimary)),
              const SizedBox(height: 4),
            ],
          ),
          onTap: () {
            AppLogger.buttonTap('Lihat Detail Tamu', detail: item['nama']);
            _showDetailDialog(item);
          },
        ),
      ),
    );
  }
  
  void _showDetailDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: _colorSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan foto (jika ada)
                if (item['path_foto'] != null && item['path_foto'].toString().isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.file(
                      File(item['path_foto']),
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 120,
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama tamu
                      Text(
                        item['nama'],
                        style: TextStyle(
                          color: _colorPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _colorSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['keperluan'],
                          style: TextStyle(
                            color: _colorSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info detail
                      _detailInfoRow(Icons.business, 'Instansi', item['instansi']),
                      const SizedBox(height: 8),
                      _detailInfoRow(
                        Icons.access_time_rounded,
                        'Waktu',
                        DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(item['tanggal_waktu'])),
                      ),

                      // Pesan / Kesan (jika ada)
                      if (item['pesan'] != null && item['pesan'].toString().isNotEmpty) ...[                        
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.message_outlined, size: 18, color: _colorPrimary),
                            const SizedBox(width: 6),
                            Text(
                              'Pesan & Kesan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _colorTextPrimary,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBA7517).withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBA7517).withOpacity(0.15)),
                          ),
                          child: Text(
                            item['pesan'],
                            style: TextStyle(
                              color: _colorTextPrimary,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],

                      // Tanda Tangan
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.draw_outlined, size: 18, color: _colorPrimary),
                          const SizedBox(width: 6),
                          Text(
                            'Tanda Tangan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _colorTextPrimary,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: item['path_tanda_tangan'] != null && item['path_tanda_tangan'].toString().isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(item['path_tanda_tangan']),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Text('Gambar tidak ditemukan'),
                                ),
                              ),
                            )
                          : const Center(child: Text('Tidak ada tanda tangan')),
                      ),
                    ],
                  ),
                ),

                // Tombol tutup
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _colorPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _colorPrimary.withOpacity(0.7)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: _colorTextSecondary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: _colorTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ─── Progress Bar Dialog (10 detik, tidak berpacu pada download) ───
class _ExportProgressDialog extends StatefulWidget {
  final Future<String> exportFuture;

  const _ExportProgressDialog({required this.exportFuture});

  @override
  State<_ExportProgressDialog> createState() => _ExportProgressDialogState();
}

class _ExportProgressDialogState extends State<_ExportProgressDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _exportDone = false;
  String? _resultPath;
  Object? _error;

  @override
  void initState() {
    super.initState();

    // Animasi progress 0→100% dalam 10 detik
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkDone();
      }
    });

    // Jalankan export di background
    _runExport();
  }

  Future<void> _runExport() async {
    try {
      final path = await widget.exportFuture;
      _resultPath = path;
    } catch (e) {
      _error = e;
    }
    _exportDone = true;
    _checkDone();
  }

  void _checkDone() {
    // Tutup dialog kalau export selesai DAN animasi 10 detik juga sudah selesai
    if (_exportDone && _controller.isCompleted && mounted) {
      Navigator.of(context).pop({'path': _resultPath, 'error': _error});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon animasi (subtle rotation)
              RotationTransition(
                turns: _controller,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F6E56).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.file_download_outlined,
                    size: 28,
                    color: Color(0xFF0F6E56),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mengexport Data...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mohon tunggu, sedang memproses...',
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF8A8880),
                ),
              ),
              const SizedBox(height: 24),
              // Progress bar
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final progress = _controller.value;
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor:
                              const Color(0xFF0F6E56).withOpacity(0.12),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Color(0xFF0F6E56)),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F6E56),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
