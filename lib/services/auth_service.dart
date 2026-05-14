import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';
import '../models/user_model.dart';

class AuthService {
  // Inisialisasi secure storage untuk menyimpan token
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _tokenKey = 'jwt_token';

  // 1. Fungsi Login
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Jika sukses, simpan token ke secure storage
        final token = data['token'];
        await _storage.write(key: _tokenKey, value: token);
        
        // Kembalikan data UserModel
        return UserModel.fromJson(data['user'], token);
      } else {
        // Jika gagal (status 401 dll), lempar pesan error dari backend
        throw Exception(data['message'] ?? 'Terjadi kesalahan saat login');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // 2. Fungsi Logout (Hapus Token)
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  // 3. Fungsi Cek Token (Apakah user sedang login?)
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
}