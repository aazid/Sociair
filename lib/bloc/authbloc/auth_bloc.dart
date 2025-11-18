import 'package:bloc/bloc.dart';
import 'package:ludo/bloc/authbloc/auth_event.dart';
import 'package:ludo/bloc/authbloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_login);
    on<LogoutRequested>(_logout);
  }
  void _login(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(Duration(seconds: 1));

    if (event.email == "demo@sociair.com" && event.password == "1234") {
      emit(AuthLoaded(email: event.email));
    } else {
      emit(AuthError(message: "Invalid credential"));
    }
  }

  void _logout(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthInitial());
  }
}
