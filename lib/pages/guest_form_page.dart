import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import '../database/database_helper.dart';
import '../utils/app_logger.dart';

class GuestFormPage extends StatefulWidget {
  const GuestFormPage({super.key});

  @override
  State<GuestFormPage> createState() => _GuestFormPageState();
}

class _GuestFormPageState extends State<GuestFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _instansiController = TextEditingController();
  final TextEditingController _pesanController = TextEditingController();

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  final ImagePicker _picker = ImagePicker();
  File? _fotoFile;

  String? _selectedKategori;
  final List<String> _kategoriList = [
    'Rapat',
    'Kunjungan',
    'Pengiriman',
    'Lainnya',
  ];

  final Color _colorPrimary = const Color(0xFF0F6E56);
  final Color _colorBackground = const Color(0xFFFAF9F5);
  final Color _colorSurface = const Color(0xFFFFFFFF);
  final Color _colorTextPrimary = const Color(0xFF2C2C2A);
  final Color _colorTextSecondary = const Color(0xFF8A8880);
  final Color _colorDanger = const Color(0xFFE24B4A);

  late final AnimationController _animController;
  late final List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    AppLogger.pageOpen('GuestFormPage');

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _cardAnimations = List.generate(5, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(
            index * 0.12,
            0.5 + index * 0.08,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _instansiController.dispose();
    _pesanController.dispose();
    _signatureController.dispose();
    _animController.dispose();
    super.dispose();
  }

  bool get _isMobilePlatform => Platform.isAndroid || Platform.isIOS;

  Future<void> _ambilFoto() async {
    final isMobile = _isMobilePlatform;
    AppLogger.buttonTap(isMobile ? 'Ambil Foto Tamu' : 'Pilih Foto Tamu');
    try {
      final XFile? foto = await _picker.pickImage(
        source: isMobile ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (foto != null) {
        setState(() => _fotoFile = File(foto.path));
        AppLogger.success('Foto berhasil diambil (${foto.path.split('/').last})');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Foto berhasil diambil!'),
                ],
              ),
              backgroundColor: Color(0xFF639922),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Gagal ambil foto', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Gagal: $e')),
              ],
            ),
            backgroundColor: _colorDanger,
          ),
        );
      }
    }
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
              _staggerCard(0, _buildInputCard(
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
                      validator: (value) => (value == null || value.isEmpty) ? 'Nama tidak boleh kosong' : null,
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
                      validator: (value) => (value == null || value.isEmpty) ? 'Instansi tidak boleh kosong' : null,
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 24),

              _staggerCard(1, _buildInputCard(
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
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (newValue) {
                    AppLogger.formInput('Kategori', value: newValue);
                    setState(() => _selectedKategori = newValue);
                  },
                  validator: (value) => (value == null || value.isEmpty) ? 'Pilih kategori keperluan' : null,
                ),
              )),
              const SizedBox(height: 24),

              _staggerCard(2, _buildInputCard(
                title: 'Pesan & Kesan',
                child: TextFormField(
                  controller: _pesanController,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Tulis pesan, kesan, atau saran...',
                    hintStyle: TextStyle(color: _colorTextSecondary.withOpacity(0.7)),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 48),
                      child: Icon(Icons.message_outlined, color: _colorPrimary),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _colorPrimary, width: 2),
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 24),

              _staggerCard(3, _buildInputCard(
                title: 'Foto Tamu',
                child: Column(
                  children: [
                    if (_fotoFile != null)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Image.file(_fotoFile!, height: 240, width: double.infinity, fit: BoxFit.cover),
                            Positioned(
                              top: 8, right: 8,
                              child: InkWell(
                                onTap: () => setState(() => _fotoFile = null),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8, right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, color: Color(0xFF639922), size: 16),
                                    SizedBox(width: 4),
                                    Text('Foto tersimpan', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, size: 48, color: _colorTextSecondary.withOpacity(0.5)),
                              const SizedBox(height: 8),
                              Text('Belum ada foto', style: TextStyle(color: _colorTextSecondary.withOpacity(0.7), fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _ambilFoto,
                        icon: Icon(_isMobilePlatform ? Icons.camera_alt_outlined : Icons.image_outlined, color: _colorPrimary),
                        label: Text(
                          _fotoFile != null ? 'Ambil Ulang Foto' : (_isMobilePlatform ? 'Ambil Foto Tamu' : 'Pilih Foto Tamu'),
                          style: TextStyle(color: _colorPrimary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _colorPrimary.withOpacity(0.4)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 24),

              _staggerCard(4, _buildInputCard(
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
                          AppLogger.buttonTap('Hapus Tanda Tangan');
                          _signatureController.clear();
                        },
                        icon: Icon(Icons.clear, color: _colorDanger),
                        label: Text('Hapus Tanda Tangan', style: TextStyle(color: _colorDanger)),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 32),

              // === TOMBOL SIMPAN ===
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
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
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_signatureController.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tanda tangan tidak boleh kosong'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      AppLogger.buttonTap('Simpan Data Tamu', detail: _namaController.text);
                      _simpanData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colorPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Simpan Data Tamu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _staggerCard(int index, Widget card) {
    return AnimatedBuilder(
      animation: _cardAnimations[index],
      builder: (context, child) {
        final animValue = _cardAnimations[index].value;
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animValue)),
            child: child,
          ),
        );
      },
      child: card,
    );
  }

  Future<void> _simpanData() async {
    AppLogger.info('Menyimpan data tamu...');
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final directory = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      final signatureData = await _signatureController.toPngBytes();
      final String signaturePath = '${directory.path}/signature_$timestamp.png';
      final File signatureFile = File(signaturePath);
      await signatureFile.writeAsBytes(signatureData!);

      String? fotoPath;
      if (_fotoFile != null) {
        final imageDir = Directory('${directory.path}/images');
        if (!await imageDir.exists()) await imageDir.create(recursive: true);
        final String fotoFileName = 'foto_$timestamp.jpg';
        fotoPath = '${imageDir.path}/$fotoFileName';
        await _fotoFile!.copy(fotoPath);
      }

      final row = {
        'nama': _namaController.text,
        'instansi': _instansiController.text,
        'keperluan': _selectedKategori,
        'pesan': _pesanController.text,
        'tanggal_waktu': DateTime.now().toIso8601String(),
        'path_tanda_tangan': signaturePath,
        'path_foto': fotoPath ?? '',
      };

      await DatabaseHelper().insertTamu(row);

      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Data berhasil disimpan!'),
              ],
            ),
            backgroundColor: Color(0xFF639922),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan data: $e'), backgroundColor: _colorDanger),
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
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _colorPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _colorTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
