import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../models/katalog_model.dart';
import '../services/kategori_service.dart';
import '../services/katalog_service.dart';
import '../services/api_config.dart';
import '../blocs/catalog/katalog_bloc.dart';
import '../blocs/catalog/katalog_event.dart';

class EditKatalogScreen extends StatefulWidget {
  final KatalogModel mobil;

  const EditKatalogScreen({super.key, required this.mobil});

  @override
  State<EditKatalogScreen> createState() => _EditKatalogScreenState();
}

class _EditKatalogScreenState extends State<EditKatalogScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _namaController;
  late TextEditingController _merekController;
  late TextEditingController _tahunController;
  late TextEditingController _warnaController;
  late TextEditingController _platController;
  late TextEditingController _hargaController;
  late TextEditingController _stokController;
  late TextEditingController _deskripsiController;
  
  int? _selectedKategoriId;
  String? _selectedStatus;
  List<dynamic> _kategoriList = [];
  bool _isLoading = false;
  final List<String> _statusList = ['tersedia', 'disewa', 'tidak tersedia'];

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? _existingImageUrl; 

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.mobil.namaMobil);
    _merekController = TextEditingController(text: widget.mobil.merek);
    _tahunController = TextEditingController(text: widget.mobil.tahun.toString());
    _warnaController = TextEditingController(text: widget.mobil.warna);
    _platController = TextEditingController(text: widget.mobil.platNomor);
    _hargaController = TextEditingController(text: widget.mobil.hargaSewa.toInt().toString());
    _stokController = TextEditingController(text: widget.mobil.stok.toString());
    _deskripsiController = TextEditingController(text: widget.mobil.deskripsi);
    
    _selectedKategoriId = widget.mobil.idKategori;
    _selectedStatus = widget.mobil.status;
    _existingImageUrl = widget.mobil.gambar; 
    
    _fetchKategori();

    // --- LOGIKA OTOMATISASI STOK ---
    // Mendengarkan setiap perubahan angka yang diketik di kolom Stok saat Edit
    _stokController.addListener(() {
      final stok = int.tryParse(_stokController.text) ?? 0;

      if (stok == 0) {
        // Jika stok diubah jadi 0, otomatis status jadi 'tidak tersedia'
        if (_selectedStatus != 'tidak tersedia') {
          setState(() => _selectedStatus = 'tidak tersedia');
        }
      } else if (stok > 0 && _selectedStatus == 'tidak tersedia') {
        // Jika stok > 0 dan status nyangkut di 'tidak tersedia', kembalikan ke 'tersedia'
        setState(() => _selectedStatus = 'tersedia');
      }
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _merekController.dispose();
    _tahunController.dispose();
    _warnaController.dispose();
    _platController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _fetchKategori() async {
    try {
      final data = await KategoriService().getKategori();
      setState(() => _kategoriList = data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error kategori: $e')));
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate() && _selectedKategoriId != null) {
      setState(() => _isLoading = true);
      
      try {
        String? finalImageUrl = _existingImageUrl; 
        
        if (_selectedImage != null) {
          finalImageUrl = await KatalogService().uploadGambar(_selectedImage!);
        }

        final dataMobil = {
          "id_kategori": _selectedKategoriId,
          "nama_mobil": _namaController.text,
          "merek": _merekController.text,
          "tahun": int.parse(_tahunController.text),
          "warna": _warnaController.text,
          "plat_nomor": _platController.text,
          "harga_sewa": double.parse(_hargaController.text),
          "stok": int.parse(_stokController.text),
          "deskripsi": _deskripsiController.text,
          "status": _selectedStatus,
          "gambar": finalImageUrl 
        };

        final success = await KatalogService().updateKatalog(widget.mobil.idKatalog, dataMobil);
        
        if (success && mounted) {
          context.read<KatalogBloc>().add(FetchKatalog());
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perubahan disimpan!'), backgroundColor: Colors.green));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // --- WIDGET HELPER UNTUK DESAIN INPUT MODERN ---
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: Colors.blue.shade300),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serverUrl = ApiConfig.baseUrl.replaceAll('/api', '');

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Background sedikit abu agar kotak form putih menonjol
      appBar: AppBar(
        title: const Text('Edit Armada', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: _kategoriList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- WIDGET GAMBAR MODERN ---
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                            ),
                            child: _selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity),
                                  )
                                : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.network(
                                          '$serverUrl$_existingImageUrl',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_photo_alternate_outlined, size: 50, color: Colors.blue.shade300),
                                          const SizedBox(height: 8),
                                          Text('Tap untuk ubah foto', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                          ),
                          // Lencana Edit di pojok kanan bawah gambar
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
                              ),
                              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- FORM INPUT LAINNYA ---
                    DropdownButtonFormField<int>(
                      value: _selectedKategoriId,
                      decoration: _buildInputDecoration('Kategori', Icons.category_rounded),
                      items: _kategoriList.map((kategori) => DropdownMenuItem<int>(value: kategori.idKategori, child: Text(kategori.namaKategori),)).toList(),
                      onChanged: (val) => setState(() => _selectedKategoriId = val),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _namaController, 
                      decoration: _buildInputDecoration('Nama Mobil', Icons.directions_car_rounded), 
                      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _merekController, decoration: _buildInputDecoration('Merek', Icons.verified_rounded), validator: (val) => val!.isEmpty ? 'Wajib diisi' : null)),
                        const SizedBox(width: 16),
                        Expanded(child: TextFormField(controller: _warnaController, decoration: _buildInputDecoration('Warna', Icons.color_lens_rounded))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _tahunController, keyboardType: TextInputType.number, decoration: _buildInputDecoration('Tahun', Icons.calendar_month_rounded), validator: (val) => val!.isEmpty ? 'Wajib diisi' : null)),
                        const SizedBox(width: 16),
                        Expanded(child: TextFormField(controller: _platController, decoration: _buildInputDecoration('Plat Nomor', Icons.pin_outlined), validator: (val) => val!.isEmpty ? 'Wajib diisi' : null)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _hargaController, keyboardType: TextInputType.number, decoration: _buildInputDecoration('Harga (Rp)', Icons.payments_rounded), validator: (val) => val!.isEmpty ? 'Wajib diisi' : null)),
                        const SizedBox(width: 16),
                        Expanded(child: TextFormField(controller: _stokController, keyboardType: TextInputType.number, decoration: _buildInputDecoration('Stok', Icons.inventory_2_rounded), validator: (val) => val!.isEmpty ? 'Wajib diisi' : null)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: _buildInputDecoration('Status', Icons.toggle_on_rounded),
                      items: _statusList.map((s) => DropdownMenuItem<String>(value: s, child: Text(s.toUpperCase()))).toList(),
                      onChanged: (val) => setState(() => _selectedStatus = val!),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _deskripsiController,
                      maxLines: 4,
                      decoration: _buildInputDecoration('Deskripsi Kendaraan', Icons.description_rounded).copyWith(alignLabelWithHint: true),
                    ),
                    const SizedBox(height: 32),
                    
                    // --- TOMBOL SIMPAN MODERN ---
                    Container(
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.orange.shade400, Colors.orange.shade700]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _isLoading ? null : _submitData,
                        icon: _isLoading ? const SizedBox() : const Icon(Icons.save_rounded, color: Colors.white),
                        label: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white) 
                            : const Text('Simpan Perubahan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}