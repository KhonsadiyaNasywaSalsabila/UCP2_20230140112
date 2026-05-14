import 'package:flutter/material.dart';
import '../services/kategori_service.dart';
import '../models/kategori_model.dart'; // Impor model

class KategoriScreen extends StatefulWidget {
  const KategoriScreen({super.key});

  @override
  State<KategoriScreen> createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  // PERBAIKAN: Gunakan List<KategoriModel> bukan List<dynamic>
  List<KategoriModel> _kategoriList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKategori();
  }

  Future<void> _fetchKategori() async {
    setState(() => _isLoading = true);
    try {
      // Sekarang data yang kembali sudah berupa List<KategoriModel>
      final data = await KategoriService().getKategori();
      if (!mounted) return;
      setState(() => _kategoriList = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- DIALOG HAPUS KATEGORI MODERN ---
  void _deleteKategori(int id, String nama) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Kategori?'),
        content: Text('Yakin ingin menghapus kategori $nama?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await KategoriService().deleteKategori(id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kategori dihapus'), backgroundColor: Colors.green),
                );
                _fetchKategori();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception: ', '')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- DIALOG FORM TAMBAH/EDIT MODERN ---
  void _showFormDialog({KategoriModel? kategori}) {
    final isEdit = kategori != null;
    // PERBAIKAN: Akses properti menggunakan objek model
    final namaController = TextEditingController(text: isEdit ? kategori.namaKategori : '');
    final deskripsiController = TextEditingController(text: isEdit ? kategori.deskripsi ?? '' : '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
              titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                    child: Icon(isEdit ? Icons.edit_rounded : Icons.add_circle_outline_rounded, color: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 12),
                  Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Kategori',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.blue.shade300, width: 2)),
                      ),
                      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: deskripsiController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.blue.shade300, width: 2)),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.only(right: 24, bottom: 24, left: 24),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: Text('Batal', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setDialogState(() => isSubmitting = true);
                            try {
                              if (isEdit) {
                                await KategoriService().updateKategori(
                                  kategori.idKategori, // Gunakan properti model
                                  namaController.text,
                                  deskripsiController.text,
                                );
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori diubah'), backgroundColor: Colors.green));
                              } else {
                                await KategoriService().tambahKategori(
                                  namaController.text,
                                  deskripsiController.text,
                                );
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori ditambahkan'), backgroundColor: Colors.green));
                              }
                              if (context.mounted) {
                                Navigator.pop(dialogContext);
                                _fetchKategori();
                              }
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
                            } finally {
                              if (mounted) setDialogState(() => isSubmitting = false);
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Manajemen Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _kategoriList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('Belum ada kategori.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _kategoriList.length,
                  itemBuilder: (context, index) {
                    final kat = _kategoriList[index];
                    return Card(
                      elevation: 2,
                      shadowColor: Colors.black12,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16)),
                              child: Icon(Icons.category_rounded, color: Colors.blue.shade400, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    kat.namaKategori, // PERBAIKAN: Akses Properti Model
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    kat.deskripsi ?? 'Tidak ada deskripsi', // PERBAIKAN: Akses Properti Model
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded, color: Colors.orange),
                                  style: IconButton.styleFrom(backgroundColor: Colors.orange.shade50),
                                  onPressed: () => _showFormDialog(kategori: kat),
                                ),
                                const SizedBox(height: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_rounded, color: Colors.red),
                                  style: IconButton.styleFrom(backgroundColor: Colors.red.shade50),
                                  onPressed: () => _deleteKategori(kat.idKategori, kat.namaKategori),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Kategori', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}