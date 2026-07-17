import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import '../database/database_helper.dart';

class GuestFormPage extends StatefulWidget {
  const GuestFormPage({super.key});

  @override
  State<GuestFormPage> createState() => _GuestFormPageState();
}

class _GuestFormPageState extends State<GuestFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _instansiController = TextEditingController();
  
  // Setup controller untuk tanda tangan
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  String? _selectedKategori;
  final List<String> _kategoriList = [
    'Rapat',
    'Kunjungan',
    'Pengiriman',
    'Lainnya',
  ];

  // Definisi warna sementara
  final Color _colorPrimary = const Color(0xFF0F6E56);
  final Color _colorBackground = const Color(0xFFFAF9F5);
  final Color _colorSurface = const Color(0xFFFFFFFF);
  final Color _colorTextPrimary = const Color(0xFF2C2C2A);
  final Color _colorDanger = const Color(0xFFE24B4A);

  @override
  void dispose() {
    _namaController.dispose();
    _instansiController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorBackground,
      appBar: AppBar(
        title: const Text('Isi Form Tamu', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: _colorBackground,
        foregroundColor: _colorPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputCard(
                title: 'Data Diri',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: Icon(Icons.person_outline, color: _colorPrimary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _colorPrimary, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _instansiController,
                      decoration: InputDecoration(
                        labelText: 'Instansi / Perusahaan',
                        prefixIcon: Icon(Icons.business, color: _colorPrimary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _colorPrimary, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Instansi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildInputCard(
                title: 'Keperluan',
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Kategori Keperluan',
                    prefixIcon: Icon(Icons.label_outline, color: _colorPrimary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _colorPrimary, width: 2),
                    ),
                  ),
                  value: _selectedKategori,
                  items: _kategoriList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedKategori = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pilih kategori keperluan';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              _buildInputCard(
                title: 'Tanda Tangan',
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Signature(
                          controller: _signatureController,
                          height: 200,
                          backgroundColor: Colors.grey.shade50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          _signatureController.clear();
                        },
                        icon: Icon(Icons.clear, color: _colorDanger),
                        label: Text('Hapus Tanda Tangan', style: TextStyle(color: _colorDanger)),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_signatureController.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tanda tangan tidak boleh kosong'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    _simpanData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _colorPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Simpan Data Tamu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _simpanData() async {
    try {
      // Tampilkan indikator loading (opsional)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 1. Dapatkan gambar tanda tangan
      final signatureData = await _signatureController.toPngBytes();
      
      // 2. Simpan gambar ke storage lokal
      final directory = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = '${directory.path}/signature_$timestamp.png';
      
      final File file = File(filePath);
      await file.writeAsBytes(signatureData!);

      // 3. Simpan data ke SQLite
      final row = {
        'nama': _namaController.text,
        'instansi': _instansiController.text,
        'keperluan': _selectedKategori,
        'tanggal_waktu': DateTime.now().toIso8601String(),
        'path_tanda_tangan': filePath,
      };

      await DatabaseHelper().insertTamu(row);

      // Tutup dialog loading
      if (mounted) Navigator.pop(context);

      // 4. Notifikasi sukses dan kembali
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil disimpan'),
            backgroundColor: Color(0xFF639922), // Success color
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Tutup dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e'),
            backgroundColor: _colorDanger,
          ),
        );
      }
    }
  }

  Widget _buildInputCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _colorSurface,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _colorTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
