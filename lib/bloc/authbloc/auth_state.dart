abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoaded extends AuthState {
  final String email;
  AuthLoaded({required this.email});
}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}
