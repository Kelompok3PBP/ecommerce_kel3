import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/language_cubit.dart';
import 'localization_service.dart';

extension LocalizationExtension on BuildContext {
  String get currentLanguage {
    try {
      return watch<LanguageCubit>().state.languageCode;
    } catch (_) {
      return 'id';
    }
  }

  String t(String key, {String? lang}) {
    final languageCode = lang ?? currentLanguage;
    return AppLocalizations.t(key, languageCode: languageCode);
  }
}
