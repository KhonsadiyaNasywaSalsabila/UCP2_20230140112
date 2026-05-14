import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    
    // Handler untuk cek apakah sudah ada token saat aplikasi dibuka
    on<AuthCheckRequested>((event, emit) async {
      emit(AuthLoading());
      final token = await authService.getToken();
      if (token != null) {
        emit(AuthAuthenticated());
      } else {
        emit(AuthUnauthenticated());
      }
    });

    // Handler untuk proses Login
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authService.login(event.email, event.password);
        emit(AuthAuthenticated());
      } catch (e) {
        // Mengambil pesan error aslinya saja, menghilangkan teks "Exception: "
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        emit(AuthError(errorMessage));
        emit(AuthUnauthenticated());
      }
    });

    // Handler untuk Logout
    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      await authService.logout();
      emit(AuthUnauthenticated());
    });
  }
}