import 'dart:async';
import 'dart:developer';

import 'package:digiharmony_app/services/rappel/service_rappel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Implémentation du [ServiceRappel] via `flutter_local_notifications`.
///
/// Canal minimal, aucun son custom, aucune action riche (plan section D).
/// 100 % locale — aucune donnée émise (DEC-R-01, CLAUDE.md).
class ServiceRappelNotifications implements ServiceRappel {
  static const int _idNotif = 1001;
  static const String _canalId = 'rappel_humeur';
  static const String _canalNom = 'Rappel humeur';
  static const String _payloadRoute = 'saisie_humeur';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Callback déclenché lors du tap sur la notification (depuis le fond).
  ///
  /// Injecté au bootstrap pour router vers la saisie d'humeur sans créer
  /// de dépendance circulaire.
  static void Function(String? payload)? onTapNotification;

  @override
  Future<void> initialiser() async {
    try {
      tz.initializeTimeZones();
      // Tente de récupérer le fuseau horaire local (best-effort, repli UTC).
      try {
        final localName = tz.local.name;
        if (localName.isNotEmpty) {
          tz.setLocalLocation(tz.getLocation(localName));
        }
      } on Object {
        // Repli UTC sans crasher (DEC-R-04 : replanification couvre les cas
        // limites, un écart de quelques minutes sur le fuseau est acceptable).
      }

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          onTapNotification?.call(details.payload);
        },
        onDidReceiveBackgroundNotificationResponse: _onBackgroundTap,
      );
    } on Object catch (error, stackTrace) {
      log(
        'ServiceRappelNotifications.initialiser failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> demanderPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        return granted ?? false;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final granted = await ios.requestPermissions(alert: true, badge: true);
        return granted ?? false;
      }
      return false;
    } on Object catch (error, stackTrace) {
      log(
        'ServiceRappelNotifications.demanderPermission failed',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  Future<bool> permissionAccordee() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.areNotificationsEnabled();
        return granted ?? false;
      }
      // iOS : on interroge les settings de notification.
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        // checkPermissions n'existe pas en v18 ; on utilise requestPermissions
        // qui retourne true si déjà accordé sans redemander.
        final granted = await ios.requestPermissions();
        return granted ?? false;
      }
      return false;
    } on Object catch (error, stackTrace) {
      log(
        'ServiceRappelNotifications.permissionAccordee failed',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  Future<void> planifierProchainRappel({
    required TimeOfDay heure,
    required bool dejaNoteAujourdhui,
    required String titre,
    required String corps,
  }) async {
    // Garde-fou : titre/corps ne doivent jamais être vides (BLOCKER-1).
    assert(
      titre.isNotEmpty,
      'planifierProchainRappel: titre ne doit pas être vide',
    );
    assert(
      corps.isNotEmpty,
      'planifierProchainRappel: corps ne doit pas être vide',
    );
    try {
      await annulerTout();
      final cible = calculerProchaineCible(
        heure: heure,
        dejaNoteAujourdhui: dejaNoteAujourdhui,
      );
      const androidDetails = AndroidNotificationDetails(
        _canalId,
        _canalNom,
        channelDescription: 'Rappel quotidien pour noter ton humeur',
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      );
      await _plugin.zonedSchedule(
        _idNotif,
        titre,
        corps,
        cible,
        details,
        payload: _payloadRoute,
        // BLOCKER-2 : inexactAllowWhileIdle ne requiert aucune permission
        // SCHEDULE_EXACT_ALARM / USE_EXACT_ALARM (interdites par DEC-R-01).
        // La précision à la minute est suffisante pour un rappel quotidien.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on Object catch (error, stackTrace) {
      log(
        'ServiceRappelNotifications.planifierProchainRappel: '
        'échec de planification — rappel NON programmé',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> annulerTout() async {
    try {
      await _plugin.cancel(_idNotif);
    } on Object catch (error, stackTrace) {
      log(
        'ServiceRappelNotifications.annulerTout failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calcule la prochaine occurrence selon DEC-R-04.
  ///
  /// Exposée comme `@visibleForTesting` pour permettre des tests unitaires
  /// purs sans plugin (MAJOR-1). Le paramètre [now] est injecté pour
  /// contrôler le temps dans les tests ; en production il est `null` et on
  /// utilise `tz.TZDateTime.now(tz.local)`.
  @visibleForTesting
  tz.TZDateTime calculerProchaineCible({
    required TimeOfDay heure,
    required bool dejaNoteAujourdhui,
    tz.TZDateTime? now,
  }) {
    final maintenant = now ?? tz.TZDateTime.now(tz.local);
    final cibleAujourdhui = tz.TZDateTime(
      tz.local,
      maintenant.year,
      maintenant.month,
      maintenant.day,
      heure.hour,
      heure.minute,
    );
    if (dejaNoteAujourdhui || cibleAujourdhui.isBefore(maintenant)) {
      return cibleAujourdhui.add(const Duration(days: 1));
    }
    return cibleAujourdhui;
  }
}

/// Handler de tap en arrière-plan (top-level, requis par le plugin).
@pragma('vm:entry-point')
void _onBackgroundTap(NotificationResponse details) {
  ServiceRappelNotifications.onTapNotification?.call(details.payload);
}
