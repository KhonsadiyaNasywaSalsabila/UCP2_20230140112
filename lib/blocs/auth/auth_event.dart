import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// Event saat aplikasi baru dibuka (cek token)
class AuthCheckRequested extends AuthEvent {}

// Event saat tombol login ditekan
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

// Event saat tombol logout ditekan
class LogoutRequested extends AuthEvent {}