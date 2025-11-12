import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthState {
  final bool loading;
  final bool loggedIn;
  final String? email;

  AuthState({required this.loading, required this.loggedIn, this.email});

  factory AuthState.unknown() => AuthState(loading: true, loggedIn: false);

  AuthState copyWith({bool? loading, bool? loggedIn, String? email}) {
    return AuthState(
      loading: loading ?? this.loading,
      loggedIn: loggedIn ?? this.loggedIn,
      email: email ?? this.email,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState.unknown()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    emit(state.copyWith(loading: true));
    final logged = await AuthService.isLoggedIn();
    final email = logged ? await AuthService.getLoggedInEmail() : null;
    emit(state.copyWith(loading: false, loggedIn: logged, email: email));
  }

  /// This helper clears saved login and notifies listeners.
  Future<void> logout() async {
    emit(state.copyWith(loading: true));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('current_user');
    emit(state.copyWith(loading: false, loggedIn: false, email: null));
  }
}
