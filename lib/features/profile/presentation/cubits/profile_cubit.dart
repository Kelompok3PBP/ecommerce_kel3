import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileState {
  final bool loading;
  final String? name;
  final String? email;
  final String? avatarUrl;

  ProfileState({required this.loading, this.name, this.email, this.avatarUrl});

  factory ProfileState.initial() => ProfileState(loading: true);

  ProfileState copyWith({
    bool? loading,
    String? name,
    String? email,
    String? avatarUrl,
  }) {
    return ProfileState(
      loading: loading ?? this.loading,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState.initial()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    emit(state.copyWith(loading: true));
    final prefs = await SharedPreferences.getInstance();
    final name =
        prefs.getString('user_name') ?? prefs.getString('profile_name');
    final email =
        prefs.getString('user_email') ?? prefs.getString('profile_email');
    final avatarPath = prefs.getString('profile_picture_path');
    final avatarBase64 = prefs.getString('profile_picture_base64');
    final avatar =
        avatarPath ?? avatarBase64 ?? prefs.getString('profile_avatar');
    emit(
      state.copyWith(
        loading: false,
        name: name,
        email: email,
        avatarUrl: avatar,
      ),
    );
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? avatarUrl,
  }) async {
    emit(state.copyWith(loading: true));
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString('user_name', name);
    if (email != null) await prefs.setString('user_email', email);
    if (avatarUrl != null)
      await prefs.setString('profile_picture_path', avatarUrl);
    await loadProfile();
  }
}
