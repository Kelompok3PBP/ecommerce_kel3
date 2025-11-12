import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/language_cubit.dart';
import 'localization_service.dart';

/// Extension on BuildContext untuk mudah akses translations
extension LocalizationExtension on BuildContext {
  /// Get current language code
  String get currentLanguage {
    try {
      // use watch so widgets that call context.t(...) rebuild when language changes
      return watch<LanguageCubit>().state.languageCode;
    } catch (_) {
      return 'id'; // default
    }
  }

  /// Translate string key
  /// Usage: context.t('home') or context.t('home', lang: 'en')
  String t(String key, {String? lang}) {
    final languageCode = lang ?? currentLanguage;
    return AppLocalizations.t(key, languageCode: languageCode);
  }
}
