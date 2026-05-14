import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';
import '../models/katalog_model.dart';

class KatalogService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Fungsi untuk mengambil semua data katalog
  Future<List<KatalogModel>> getAllKatalog() async {
    try {
      // 1. Ambil token dari brankas (secure storage)
      final token = await _storage.read(key: 'jwt_token');

      // 2. Tembak API dengan menyisipkan Header Authorization
      final response = await http.get(
        Uri.parse(ApiConfig.katalog),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // INI KUNCI PENTINGNYA!
        },
      );

      final data = jsonDecode(response.body);

      // 3. Cek respon dari Node.js
      if (response.statusCode == 200) {
        List<dynamic> listJson = data['data'];
        return listJson.map((json) => KatalogModel.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil data katalog');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Fungsi untuk menambah data mobil baru (CREATE)
  Future<bool> tambahKatalog(Map<String, dynamic> dataMobil) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final response = await http.post(
        Uri.parse(ApiConfig.katalog),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(dataMobil),
      );

      if (response.statusCode == 201) {
        return true; // Berhasil
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal menambah data');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Fungsi untuk UPDATE (Edit Mobil)
  Future<bool> updateKatalog(int idKatalog, Map<String, dynamic> dataMobil) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final response = await http.put(
        Uri.parse('${ApiConfig.katalog}/$idKatalog'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(dataMobil),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal mengubah data');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Fungsi untuk DELETE (Hapus Mobil)
  Future<bool> deleteKatalog(int idKatalog) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final response = await http.delete(
        Uri.parse('${ApiConfig.katalog}/$idKatalog'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal menghapus data');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Fungsi khusus untuk mengunggah gambar fisik
  Future<String> uploadGambar(File imageFile) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      
      // Menggunakan MultipartRequest karena kita mengirim File, bukan JSON biasa
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('${ApiConfig.baseUrl}/upload') // Pastikan endpoint ini sesuai dengan Node.js mu
      );

      // Sisipkan token
      request.headers['Authorization'] = 'Bearer $token';

      // Attach file gambar
      var multipartFile = await http.MultipartFile.fromPath(
        'gambar', // Harus sama dengan nama field di Node.js: upload.single('gambar')
        imageFile.path,
        contentType: MediaType('image', 'jpeg'), // Default anggap JPEG
      );
      
      request.files.add(multipartFile);

      // Kirim request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url']; // Mengembalikan URL string (misal: "/uploads/12345.jpg")
      } else {
        throw Exception('Gagal upload gambar');
      }
    } catch (e) {
      throw Exception('Error Upload: $e');
    }
  }
}