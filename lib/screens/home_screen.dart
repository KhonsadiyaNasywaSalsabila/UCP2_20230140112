import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/catalog/katalog_bloc.dart';
import '../blocs/catalog/katalog_event.dart';
import '../blocs/catalog/katalog_state.dart';
import '../services/katalog_service.dart';
import '../services/api_config.dart';
import 'add_katalog_screen.dart';
import 'edit_katalog_screen.dart';
import 'kategori_screen.dart';
import 'detail_katalog_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    context.read<KatalogBloc>().add(FetchKatalog());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Background aplikasi lebih soft
      appBar: AppBar(
        elevation: 0,
        title: const Text('DriveEase', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.category_rounded),
            tooltip: 'Kategori',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KategoriScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
          )
        ],
      ),
      body: BlocBuilder<KatalogBloc, KatalogState>(
        builder: (context, state) {
          if (state is KatalogLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is KatalogError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(state.message, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          } else if (state is KatalogLoaded) {
            final katalogList = state.katalogList;

            if (katalogList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_car_filled, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text('Katalog armada masih kosong.\nSilakan tambah data baru!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              );
            }

            final filteredList = katalogList.where((mobil) {
              final namaMatch = mobil.namaMobil.toLowerCase().contains(_searchKeyword.toLowerCase());
              final merekMatch = mobil.merek.toLowerCase().contains(_searchKeyword.toLowerCase());
              return namaMatch || merekMatch;
            }).toList();

            final serverUrl = ApiConfig.baseUrl.replaceAll('/api', '');

            return Column(
              children: [
                // --- MODERN SEARCH BAR ---
                Container(
                  color: Colors.blue.shade700,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Cari nama mobil atau merek...',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.blue),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onChanged: (value) => setState(() => _searchKeyword = value),
                    ),
                  ),
                ),
                
                // --- DAFTAR MOBIL MODERN ---
                Expanded(
                  child: filteredList.isEmpty
                      ? const Center(child: Text('Mobil tidak ditemukan.', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 80, left: 16, right: 16), // Bottom padding agar tidak tertutup FAB
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final mobil = filteredList[index];
                            
                            return Card(
                              elevation: 4,
                              shadowColor: Colors.black12,
                              margin: const EdgeInsets.only(bottom: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailKatalogScreen(mobil: mobil))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1. BAGIAN GAMBAR BESAR DI ATAS
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                          child: mobil.gambar != null && mobil.gambar!.isNotEmpty
                                              ? Image.network(
                                                  '$serverUrl${mobil.gambar}',
                                                  height: 180,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (ctx, err, stack) => _buildPlaceholderImage(),
                                                )
                                              : _buildPlaceholderImage(),
                                        ),
                                        // Badge Status mengambang di atas gambar
                                        Positioned(
                                          top: 12,
                                          right: 12,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: mobil.status == 'tersedia' ? Colors.green : Colors.red,
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                            ),
                                            child: Text(
                                              mobil.status.toUpperCase(),
                                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    // 2. BAGIAN INFORMASI
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // --- Mencegah Merek Ganda ---
                                          Text(
                                            mobil.namaMobil.toLowerCase().contains(mobil.merek.toLowerCase())
                                                ? mobil.namaMobil
                                                : '${mobil.merek} ${mobil.namaMobil}',
                                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                                              const SizedBox(width: 6),
                                              Text(mobil.namaKategori ?? '-', style: TextStyle(color: Colors.grey.shade700)),
                                              const SizedBox(width: 16),
                                              Icon(Icons.pin_drop, size: 16, color: Colors.grey.shade600),
                                              const SizedBox(width: 6),
                                              Text(mobil.platNomor, style: TextStyle(color: Colors.grey.shade700)),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Rp ${mobil.hargaSewa.toInt()} /hari',
                                                style: TextStyle(fontSize: 18, color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                                              ),
                                              Text('Stok: ${mobil.stok}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.orange)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // 3. BAGIAN TOMBOL EDIT & HAPUS
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                                        border: Border(top: BorderSide(color: Colors.grey.shade200)),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            icon: const Icon(Icons.edit_rounded, color: Colors.orange, size: 20),
                                            label: const Text('Edit', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditKatalogScreen(mobil: mobil))),
                                          ),
                                          TextButton.icon(
                                            icon: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                                            label: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                            onPressed: () => _confirmDelete(context, mobil),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      // --- FLOATING ACTION BUTTON MODERN ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddKatalogScreen())),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Mobil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Widget bantuan untuk gambar kosong
  Widget _buildPlaceholderImage() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text('Tidak ada gambar', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // Fungsi bantuan untuk menghapus (Biar kode build tidak terlalu panjang)
  Future<void> _confirmDelete(BuildContext context, mobil) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Mobil?'),
        content: Text('Yakin ingin menghapus ${mobil.namaMobil}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await KatalogService().deleteKatalog(mobil.idKatalog);
        if (context.mounted) {
          context.read<KatalogBloc>().add(FetchKatalog());
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil dihapus'), backgroundColor: Colors.green));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }
}