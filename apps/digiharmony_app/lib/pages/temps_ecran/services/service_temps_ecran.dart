import 'dart:io';

import 'package:app_usage/app_usage.dart';
import 'package:digiharmony_app/pages/temps_ecran/modeles/resume_temps_ecran.dart';
import 'package:flutter/services.dart';

/// Façade plateforme du temps d'écran (mockable via `mocktail`, DEC-TE-08).
///
/// Isole le `MethodChannel` natif et `app_usage` pour tester le Bloc sans
/// dépendre de la plateforme.
abstract interface class ServiceTempsEcran {
  /// True si l'app détient l'accès aux statistiques d'usage (Android).
  ///
  /// False sinon (accès non accordé, ou iOS).
  Future<bool> aLAcces();

  /// Ouvre l'écran système Settings.ACTION_USAGE_ACCESS_SETTINGS (Android).
  Future<void> ouvrirReglagesAcces();

  /// Usage du jour `[minuit local, now]` (DEC-TE-11).
  ///
  /// Liste vide si pas d'accès / iOS / aucune donnée.
  Future<List<UsageAppVue>> usageDuJour();

  /// True si la plateforme supporte la lecture (Android), false sinon.
  bool get plateformeSupportee;
}

/// Implémentation concrète Android (`app_usage` + MethodChannel maison).
class ServiceTempsEcranImpl implements ServiceTempsEcran {
  /// Crée l'implémentation.
  ///
  /// [canal] et [appUsage] sont injectables pour les tests ; en prod ils
  /// pointent sur le channel natif `digiharmony/usage_access` et le singleton
  /// `AppUsage`.
  ServiceTempsEcranImpl({
    MethodChannel? canal,
    AppUsage? appUsage,
  }) : _canal = canal ?? const MethodChannel('digiharmony/usage_access'),
       _appUsage = appUsage ?? AppUsage();

  final MethodChannel _canal;
  final AppUsage _appUsage;

  @override
  bool get plateformeSupportee => Platform.isAndroid;

  @override
  Future<bool> aLAcces() async {
    if (!plateformeSupportee) return false;
    final resultat = await _canal.invokeMethod<bool>('aLAcces');
    return resultat ?? false;
  }

  @override
  Future<void> ouvrirReglagesAcces() {
    if (!plateformeSupportee) return Future<void>.value();
    return _canal.invokeMethod<void>('ouvrirReglagesAcces');
  }

  @override
  Future<List<UsageAppVue>> usageDuJour() async {
    if (!plateformeSupportee) return const [];
    final now = DateTime.now();
    final minuit = DateTime(now.year, now.month, now.day);
    final infos = await _appUsage.getAppUsage(minuit, now);
    return [
      for (final info in infos)
        if (info.usage > Duration.zero)
          UsageAppVue(
            nomApp: nomLisible(info.packageName),
            packageName: info.packageName,
            duree: info.usage,
            // Fraction recalculée lors de l'agrégation (agregeUsage).
            fractionDuTotal: 0,
          ),
    ];
  }
}
