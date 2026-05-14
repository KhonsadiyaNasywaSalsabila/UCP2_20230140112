class KatalogModel {
  final int idKatalog;
  final int idKategori;
  final String? namaKategori; // Didapat dari JOIN database
  final String namaMobil;
  final String merek;
  final int tahun;
  final String warna;
  final String platNomor;
  final double hargaSewa;
  final int stok;
  final String deskripsi;
  final String status;
  final String? gambar;

  KatalogModel({
    required this.idKatalog,
    required this.idKategori,
    this.namaKategori,
    required this.namaMobil,
    required this.merek,
    required this.tahun,
    required this.warna,
    required this.platNomor,
    required this.hargaSewa,
    required this.stok,
    required this.deskripsi,
    required this.status,
    this.gambar,
  });

  factory KatalogModel.fromJson(Map<String, dynamic> json) {
    return KatalogModel(
      idKatalog: json['id_katalog'],
      idKategori: json['id_kategori'],
      namaKategori: json['nama_kategori'], 
      namaMobil: json['nama_mobil'],
      merek: json['merek'],
      tahun: json['tahun'],
      warna: json['warna'] ?? '-',
      platNomor: json['plat_nomor'] ?? '',
      // Parsing harga_sewa dengan aman (kadang dari MySQL terbaca sebagai String)
      hargaSewa: double.tryParse(json['harga_sewa'].toString()) ?? 0.0,
      stok: json['stok'] ?? 0,
      deskripsi: json['deskripsi'] ?? '',
      status: json['status'] ?? 'tersedia',
      gambar: json['gambar'],
    );
  }
}