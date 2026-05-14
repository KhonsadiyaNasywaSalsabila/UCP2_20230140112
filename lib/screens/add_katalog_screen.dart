import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../services/kategori_service.dart';
import '../services/katalog_service.dart';
import '../blocs/catalog/katalog_bloc.dart';
import '../blocs/catalog/katalog_event.dart';

class AddKatalogScreen extends StatefulWidget {
  const AddKatalogScreen({super.key});

  @override
  State<AddKatalogScreen> createState() => _AddKatalogScreenState();
}

class _AddKatalogScreenState extends State<AddKatalogScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _namaController = TextEditingController();
  final _merekController = TextEditingController();
  final _tahunController = TextEditingController();
  final _warnaController = TextEditingController();
  final _platController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();
  final _deskripsiController = TextEditingController();
  
  int? _selectedKategoriId;
  String _selectedStatus = 'tersedia';
  List<dynamic> _kategoriList = [];
  bool _isLoading = false;
  final List<String> _statusList = ['tersedia', 'disewa', 'tidak tersedia'];

  // --- VARIABEL UNTUK GAMBAR ---
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchKategori();

    // --- LOGIKA OTOMATISASI STOK ---
    // Mendengarkan setiap perubahan angka yang diketik di kolom Stok
    _stokController.addListener(() {
      final stok = int.tryParse(_stokController.text) ?? 0;

      if (stok == 0) {
        // Jika stok 0, otomatis ubah status ke 'tidak tersedia'
        if (_selectedStatus != 'tidak tersedia') {
          setState(() => _selectedStatus = 'tidak tersedia');
        }
      } else if (stok > 0 && _selectedStatus == 'tidak tersedia') {
        // Jika stok > 0 dan status sebelumnya 'tidak tersedia', kembalikan ke 'tersedia'
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
      setState(() {
        _kategoriList = data;
      });
    } catch (e) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat kategori: $e')),
        );
      }
    }
  }

  // --- FUNGSI MENGAMBIL GAMBAR DARI GALERI ---
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
        String? imageUrl;
        
        // 1. Upload gambar dulu jika admin memilih gambar
        if (_selectedImage != null) {
          imageUrl = await KatalogService().uploadGambar(_selectedImage!);
        }

        // 2. Siapkan data JSON
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
          "gambar": imageUrl // 3. Masukkan URL hasil upload
        };

        // 4. Kirim ke database
        final success = await KatalogService().tambahKatalog(dataMobil);
        
        if (success && mounted) {
          context.read<KatalogBloc>().add(FetchKatalog());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mobil berhasil ditambahkan!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else if (_selectedKategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih kategori!'), backgroundColor: Colors.orange),
      );
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Background soft agar form putih menonjol
      appBar: AppBar(
        title: const Text('Tambah Mobil Baru', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200, width: 2),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                                    child: Icon(Icons.add_a_photo_rounded, size: 40, color: Colors.blue.shade400),
                                  ),
                                  const SizedBox(height: 12),
                                  Text('Tap untuk pilih gambar', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text('Format: JPG, PNG', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- FORM INPUT LAINNYA ---
                    DropdownButtonFormField<int>(
                      decoration: _buildInputDecoration('Kategori', Icons.category_rounded),
                      items: _kategoriList.map((kategori) {
                        return DropdownMenuItem<int>(
                          value: kategori.idKategori,
                          child: Text(kategori.namaKategori),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedKategoriId = val),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _namaController,
                      decoration: _buildInputDecoration('Nama Mobil', Icons.directions_car_rounded),
                      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _merekController,
                            decoration: _buildInputDecoration('Merek', Icons.verified_rounded),
                            validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _warnaController,
                            decoration: _buildInputDecoration('Warna', Icons.color_lens_rounded),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tahunController,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration('Tahun', Icons.calendar_month_rounded),
                            validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _platController,
                            decoration: _buildInputDecoration('Plat Nomor', Icons.pin_outlined),
                            validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _hargaController,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration('Harga (Rp)', Icons.payments_rounded),
                            validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _stokController,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration('Stok', Icons.inventory_2_rounded),
                            validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: _buildInputDecoration('Status', Icons.toggle_on_rounded),
                      items: _statusList.map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status.toUpperCase()),
                        );
                      }).toList(),
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
                        gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade700]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
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
                            : const Text('Simpan Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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