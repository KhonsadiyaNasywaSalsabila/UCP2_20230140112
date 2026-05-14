class UserModel {
  final int id;
  final String nama;
  final String email;
  final String role;
  final String token;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    required this.token,
  });

  // Fungsi untuk memetakan JSON dari response Login API
  factory UserModel.fromJson(Map<String, dynamic> json, String token) {
    return UserModel(
      id: json['id_user'],
      nama: json['nama'],
      email: json['email'],
      role: json['role'],
      token: token,
    );
  }
}