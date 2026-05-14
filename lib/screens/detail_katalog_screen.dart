import 'package:flutter/material.dart';
import '../models/katalog_model.dart';
import '../services/api_config.dart';

class DetailKatalogScreen extends StatelessWidget {
  final KatalogModel mobil;

  const DetailKatalogScreen({super.key, required this.mobil});

  @override
  Widget build(BuildContext context) {
    final serverUrl = ApiConfig.baseUrl.replaceAll('/api', '');

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // --- HERO IMAGE HEADER (Gambar bisa mengecil saat discroll) ---
          SliverAppBar(
            expandedHeight: 320.0,
            pinned: true,
            backgroundColor: Colors.blue.shade700,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gambar Utama
                  mobil.gambar != null && mobil.gambar!.isNotEmpty
                      ? Image.network(
                          '$serverUrl${mobil.gambar}',
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                  
                  // Efek gradasi hitam transparan agar tombol "Back" tetap terbaca di gambar terang
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black54, Colors.transparent, Colors.transparent, Colors.black87],
                        stops: [0.0, 0.2, 0.8, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- KONTEN HALAMAN ---
          SliverToBoxAdapter(
            child: Container(
              // Efek kontainer putih melengkung yang menimpa bagian bawah gambar
              transform: Matrix4.translationValues(0.0, -30.0, 0.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Padding(
                // PERBAIKAN: Jarak atas diperbesar menjadi 48.0
                padding: const EdgeInsets.fromLTRB(24.0, 48.0, 24.0, 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- NAMA & STATUS ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mobil.merek.toUpperCase(),
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w700, letterSpacing: 1),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mobil.namaMobil,
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, height: 1.2),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: mobil.status == 'tersedia' ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: mobil.status == 'tersedia' ? Colors.green.shade200 : Colors.red.shade200),
                          ),
                          child: Text(
                            mobil.status.toUpperCase(),
                            style: TextStyle(
                              color: mobil.status == 'tersedia' ? Colors.green.shade700 : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- HIGHLIGHT HARGA ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Harga Sewa', style: TextStyle(color: Colors.blue.shade800, fontSize: 14, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${mobil.hargaSewa.toInt()}',
                                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.blue.shade900),
                              ),
                            ],
                          ),
                          Text('/ hari', style: TextStyle(fontSize: 16, color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- GRID SPESIFIKASI ---
                    const Text('Spesifikasi Utama', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16, // Jarak horizontal antar card
                      runSpacing: 16, // Jarak vertikal antar baris
                      children: [
                        _buildSpecCard(context, Icons.category_rounded, 'Kategori', mobil.namaKategori ?? '-'),
                        _buildSpecCard(context, Icons.calendar_month_rounded, 'Tahun', mobil.tahun.toString()),
                        _buildSpecCard(context, Icons.color_lens_rounded, 'Warna', mobil.warna.isNotEmpty ? mobil.warna : '-'),
                        _buildSpecCard(context, Icons.pin_outlined, 'Plat Nomor', mobil.platNomor),
                        _buildSpecCard(context, Icons.inventory_2_rounded, 'Stok Tersedia', '${mobil.stok} Unit'),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- DESKRIPSI KENDARAAN ---
                    const Text('Deskripsi Kendaraan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Text(
                      mobil.deskripsi.isNotEmpty ? mobil.deskripsi : 'Tidak ada deskripsi rinci untuk kendaraan ini.',
                      style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey.shade700),
                    ),
                    
                    const SizedBox(height: 60), // Extra padding bawah
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Gambar Default
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.directions_car, size: 100, color: Colors.grey),
      ),
    );
  }

  // Widget Pembuat Kartu Spesifikasi Kecil (Grid)
  Widget _buildSpecCard(BuildContext context, IconData icon, String label, String value) {
    // Menghitung lebar agar pas 2 kolom (48 margin layar, 16 jarak tengah)
    final cardWidth = (MediaQuery.of(context).size.width - 48 - 16) / 2;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}