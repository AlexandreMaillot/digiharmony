part of 'locale_bloc.dart';

/// État du [LocaleBloc] : locale active ou `null` (système).
final class LocaleState extends Equatable {
  /// Crée l'état. [locale] `null` = suivre la langue système.
  const LocaleState({this.locale});

  /// Locale active, `null` si suivi système.
  final Locale? locale;

  /// Retourne une copie avec les champs modifiés (sentinelle pour nullable).
  LocaleState copyWith({Object? locale = _sentinel}) {
    return LocaleState(
      locale: locale == _sentinel ? this.locale : locale as Locale?,
    );
  }

  @override
  List<Object?> get props => [locale];
}

/// Sentinelle interne pour distinguer `null` explicite de « non fourni ».
const _sentinel = Object();
