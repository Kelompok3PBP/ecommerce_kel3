import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageState {
  final String languageCode; // 'id', 'en', 'es', 'fr', 'de', 'ja', 'zh'
  final String languageName;
  final String flag;

  LanguageState({
    required this.languageCode,
    required this.languageName,
    required this.flag,
  });

  factory LanguageState.initial() => LanguageState(
    languageCode: 'id',
    languageName: 'Indonesia',
    flag: '🇮🇩',
  );

  LanguageState copyWith({
    String? languageCode,
    String? languageName,
    String? flag,
  }) {
    return LanguageState(
      languageCode: languageCode ?? this.languageCode,
      languageName: languageName ?? this.languageName,
      flag: flag ?? this.flag,
    );
  }
}

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageState.initial()) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('language_code') ?? 'id';
    final savedName = prefs.getString('language_name') ?? 'Indonesia';
    final savedFlag = prefs.getString('language_flag') ?? '🇮🇩';
    emit(
      LanguageState(
        languageCode: savedLang,
        languageName: savedName,
        flag: savedFlag,
      ),
    );
  }

  Future<void> changeLanguage(String code, String name, String flag) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
    await prefs.setString('language_name', name);
    await prefs.setString('language_flag', flag);
    emit(state.copyWith(languageCode: code, languageName: name, flag: flag));
  }
}
