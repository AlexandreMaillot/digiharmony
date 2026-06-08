import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'locale_event.dart';
part 'locale_state.dart';

/// Gère la langue active de l'application (état léger persistant).
///
/// État `null` = suivre la langue du système. Persiste via HydratedBloc.
/// JAMAIS de journal ici (DEC-001/002) — uniquement l'état léger « langue ».
class LocaleBloc extends HydratedBloc<LocaleEvent, LocaleState> {
  /// Démarre sans préférence (suit la langue système).
  LocaleBloc() : super(const LocaleState()) {
    on<LocaleChange>(_onLocaleChange, transformer: sequential());
    on<LocaleSysteme>(_onLocaleSysteme, transformer: sequential());
  }

  void _onLocaleChange(LocaleChange event, Emitter<LocaleState> emit) {
    emit(LocaleState(locale: event.locale));
  }

  void _onLocaleSysteme(LocaleSysteme event, Emitter<LocaleState> emit) {
    emit(const LocaleState());
  }

  static bool _isSupported(String code) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == code);

  @override
  LocaleState fromJson(Map<String, dynamic> json) {
    final code = json['languageCode'];
    if (code is! String) return const LocaleState();
    // Repli sûr : langue non supportée -> suivi système (DEC-002).
    if (!_isSupported(code)) return const LocaleState();
    return LocaleState(locale: Locale(code));
  }

  @override
  Map<String, dynamic>? toJson(LocaleState state) {
    final locale = state.locale;
    if (locale == null) return null;
    return <String, dynamic>{'languageCode': locale.languageCode};
  }
}
