import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ucp2/blocs/catalog/katalog_bloc.dart';
import 'package:ucp2/services/katalog_service.dart';
import 'services/auth_service.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const DriveEaseApp());
}

class DriveEaseApp extends StatelessWidget {
  const DriveEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Membungkus aplikasi dengan MultiBlocProvider agar BLoC bisa diakses global
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          // Inisialisasi AuthBloc dan langsung jalankan event AuthCheckRequested
          // untuk mengecek apakah user sudah punya token (sudah login sebelumnya)
          create: (context) => AuthBloc(authService: AuthService())..add(AuthCheckRequested()),
        ),
        BlocProvider<KatalogBloc>(
          create: (context) => KatalogBloc(katalogService: KatalogService()),
        ),
      ],
      child: MaterialApp(
        title: 'DriveEase',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        // BlocBuilder akan mengubah halaman utama berdasarkan status Autentikasi
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const HomeScreen(); // Masuk ke beranda jika sudah login
            }
            if (state is AuthUnauthenticated) {
              return const LoginScreen(); // Ke halaman login jika belum/gagal login
            }
            // Menampilkan loading saat aplikasi baru pertama kali dibuka dan mengecek token
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}