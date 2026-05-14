import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/kategori_model.dart'; // Impor model yang baru dibuat
import 'api_config.dart';

class KategoriService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- HELPER UNTUK AMBIL TOKEN ---
  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // 1. READ (Mengembalikan List<KategoriModel>)
  Future<List<KategoriModel>> getKategori() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(ApiConfig.kategori),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body)['data'];
        // Mengubah List Map menjadi List Object KategoriModel
        return body.map((item) => KategoriModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat kategori');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // 2. CREATE (Menggunakan Parameter Nama dan Deskripsi)
  Future<bool> tambahKategori(String nama, String deskripsi) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse(ApiConfig.kategori),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          "nama_kategori": nama, 
          "deskripsi": deskripsi
        }),
      );

      if (response.statusCode == 201) return true;
      final msg = jsonDecode(response.body)['message'];
      throw Exception(msg ?? 'Gagal menambah kategori');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // 3. UPDATE (Menggunakan Parameter ID, Nama, dan Deskripsi)
  Future<bool> updateKategori(int id, String nama, String deskripsi) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('${ApiConfig.kategori}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          "nama_kategori": nama, 
          "deskripsi": deskripsi
        }),
      );

      if (response.statusCode == 200) return true;
      final msg = jsonDecode(response.body)['message'];
      throw Exception(msg ?? 'Gagal mengubah kategori');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // 4. DELETE
  Future<bool> deleteKategori(int id) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.kategori}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) return true;
      final msg = jsonDecode(response.body)['message'];
      throw Exception(msg ?? 'Gagal menghapus kategori');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}