import 'dart:ui';

import 'package:core_package/core_package.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Langue de l'app, persistee entre sessions (HydratedBloc).
///
/// Etat leger UNIQUEMENT (DEC-002) — jamais le journal/agregats.
///
/// Au tout premier lancement (stockage vide), la langue par defaut est celle
/// du device si elle fait partie des 8 langues supportees, sinon repli `en`.
/// Aux lancements suivants, HydratedBloc restaure le choix memorise.
class LangueCubit extends HydratedCubit<Locale> {
  /// {@macro langue_cubit}
  LangueCubit({Locale? deviceLocale})
    : super(_localeInitiale(deviceLocale ?? _localeSysteme()));

  /// Bascule vers [locale] si elle fait partie des langues supportees.
  void setLocale(Locale locale) {
    if (_estSupportee(locale.languageCode)) {
      emit(Locale(locale.languageCode));
    }
  }

  static bool _estSupportee(String code) =>
      kLanguesSupportees.any((l) => l.code == code);

  static Locale _localeSysteme() => PlatformDispatcher.instance.locale;

  static Locale _localeInitiale(Locale device) {
    if (_estSupportee(device.languageCode)) {
      return Locale(device.languageCode);
    }
    return const Locale('en');
  }

  @override
  Locale fromJson(Map<String, dynamic> json) {
    final code = json['languageCode'] as String?;
    if (code != null && _estSupportee(code)) {
      return Locale(code);
    }
    return const Locale('en');
  }

  @override
  Map<String, dynamic> toJson(Locale state) => <String, dynamic>{
    'languageCode': state.languageCode,
  };
}
