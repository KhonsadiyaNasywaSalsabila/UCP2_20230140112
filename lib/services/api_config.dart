import 'dart:io';

class ApiConfig {
  // Jika menggunakan Android Emulator, gunakan 10.0.2.2
  // Jika mengetes menggunakan perangkat asli (Real Device) atau iOS Simulator, 
  // gunakan IP Address komputermu (misal: 192.168.1.5)
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    } else {
      return 'http://localhost:3000/api'; 
    }
  }

  // --- Daftar Endpoint ---
  
  // Auth
  static String get login => '$baseUrl/auth/login';
  
  // Katalog (Mobil)
  static String get katalog => '$baseUrl/katalog';
  
  // Kategori
  static String get kategori => '$baseUrl/kategori';
}