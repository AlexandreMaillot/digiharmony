import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Gère la langue active de l'application (état léger persistant).
///
/// État `null` = suivre la langue du système. Persiste via HydratedBloc.
/// JAMAIS de journal ici (DEC-001/002) — uniquement l'état léger « langue ».
class LocaleCubit extends HydratedCubit<Locale?> {
  /// Démarre sans préférence (suit la langue système).
  LocaleCubit() : super(null);

  /// Force une [locale] (doit être supportée, sinon ignorée par MaterialApp).
  void setLocale(Locale locale) => emit(locale);

  /// Remet le suivi de la langue système.
  void useSystem() => emit(null);

  static bool _isSupported(String code) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == code);

  @override
  Locale? fromJson(Map<String, dynamic> json) {
    final code = json['languageCode'];
    if (code is! String) return null;
    // Repli sûr : langue non supportée -> suivi système (DEC-002).
    if (!_isSupported(code)) return null;
    return Locale(code);
  }

  @override
  Map<String, dynamic>? toJson(Locale? state) {
    if (state == null) return null;
    return <String, dynamic>{'languageCode': state.languageCode};
  }
}
