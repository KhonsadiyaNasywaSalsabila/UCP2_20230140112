class KategoriModel {
  final int idKategori;
  final String namaKategori;
  final String? deskripsi;

  KategoriModel({
    required this.idKategori,
    required this.namaKategori,
    this.deskripsi,
  });

  // Mengubah dari JSON (API) menjadi Object Flutter
  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    return KategoriModel(
      idKategori: json['id_kategori'] ?? 0,
      namaKategori: json['nama_kategori'] ?? '',
      deskripsi: json['deskripsi'],
    );
  }

  // Mengubah dari Object Flutter menjadi JSON (untuk dikirim ke API)
  Map<String, dynamic> toJson() {
    return {
      'id_kategori': idKategori,
      'nama_kategori': namaKategori,
      'deskripsi': deskripsi,
    };
  }
}