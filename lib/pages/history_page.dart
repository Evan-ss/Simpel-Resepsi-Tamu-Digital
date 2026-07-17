import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

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
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper().getAllTamu();
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
                  onChanged: (value) => _applyFilters(),
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
                        onPressed: _pickDate,
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
                        onPressed: _clearDateFilter,
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
    
    return Card(
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
              Text(
                item['instansi'],
                style: TextStyle(color: _colorTextSecondary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              timeStr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _colorPrimary,
              ),
            ),
            const SizedBox(height: 4),
            // Opsional: Jika ingin menampilkan preview mini tanda tangan
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(4),
            //   child: Image.file(
            //     File(item['path_tanda_tangan']), 
            //     width: 40, 
            //     height: 20, 
            //     color: _colorPrimary,
            //   ),
            // ),
          ],
        ),
        onTap: () {
          // Navigasi ke detail tamu (opsional)
          _showDetailDialog(item);
        },
      ),
    );
  }
  
  void _showDetailDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _colorSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(item['nama'], style: TextStyle(color: _colorPrimary, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Instansi: ${item['instansi']}'),
              const SizedBox(height: 4),
              Text('Keperluan: ${item['keperluan']}'),
              const SizedBox(height: 4),
              Text('Waktu: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(item['tanggal_waktu']))}'),
              const SizedBox(height: 16),
              const Text('Tanda Tangan:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: item['path_tanda_tangan'] != null 
                  ? Image.file(File(item['path_tanda_tangan']), fit: BoxFit.contain)
                  : const Center(child: Text('Tidak ada tanda tangan')),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup', style: TextStyle(color: _colorPrimary)),
            ),
          ],
        );
      },
    );
  }
}
