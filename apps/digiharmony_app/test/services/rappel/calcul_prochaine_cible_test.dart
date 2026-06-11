import 'package:digiharmony_app/services/rappel/service_rappel_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    // tz.local reste sur UTC (comme en production) : calculerProchaineCible
    // raisonne en heure locale via DateTime puis convertit avec
    // TZDateTime.from. Les assertions comparent l'instant absolu, donc elles
    // restent déterministes quelle que soit la machine de test.
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  ServiceRappelNotifications buildService() => ServiceRappelNotifications();

  // Instant absolu attendu pour une cible exprimée en heure LOCALE (même
  // conversion que la fonction testée).
  tz.TZDateTime cibleLocale(int year, int month, int day, int hour) =>
      tz.TZDateTime.from(DateTime(year, month, day, hour), tz.local);

  group('calculerProchaineCible — DEC-R-04 / MAJOR-1', () {
    // Le rappel est configuré à 20h00 (heure locale de l'appareil).
    const heure = TimeOfDay(hour: 20, minute: 0);

    // CC-1 : dejaNoteAujourdhui=true → cible toujours demain, peu importe
    //         l'heure actuelle (même si l'heure est dans le futur).
    test(
      'CC-1 : dejaNoteAujourdhui=true => cible = demain a 20h00, '
      'meme si heure rappel est dans le futur',
      () {
        final service = buildService();
        // Maintenant = 08h00 (heure non passée, mais déjà noté)
        final now = DateTime(2025, 6, 11, 8);
        final cible = service.calculerProchaineCible(
          heure: heure,
          dejaNoteAujourdhui: true,
          now: now,
        );
        expect(cible, cibleLocale(2025, 6, 12, 20));
      },
    );

    // CC-2 : dejaNoteAujourdhui=false + heure NON passée → aujourd'hui.
    test(
      'CC-2 : dejaNoteAujourdhui=false + heure rappel dans le futur => '
      'cible = aujourd hui a 20h00',
      () {
        final service = buildService();
        // Maintenant = 15h00 (avant 20h00)
        final now = DateTime(2025, 6, 11, 15);
        final cible = service.calculerProchaineCible(
          heure: heure,
          dejaNoteAujourdhui: false,
          now: now,
        );
        expect(cible, cibleLocale(2025, 6, 11, 20));
      },
    );

    // CC-3 : dejaNoteAujourdhui=false + heure passée → demain.
    test(
      'CC-3 : dejaNoteAujourdhui=false + heure rappel passée => '
      'cible = demain à 20h00',
      () {
        final service = buildService();
        // Maintenant = 21h30 (après 20h00)
        final now = DateTime(2025, 6, 11, 21, 30);
        final cible = service.calculerProchaineCible(
          heure: heure,
          dejaNoteAujourdhui: false,
          now: now,
        );
        expect(cible, cibleLocale(2025, 6, 12, 20));
      },
    );

    // CC-4 : cas limite — maintenant = exactement l'heure du rappel
    //         → isBefore est false, donc aujourd'hui.
    test(
      'CC-4 : heure actuelle == heure rappel (exactement) => '
      'cible = aujourd hui (isBefore=false)',
      () {
        final service = buildService();
        final now = DateTime(2025, 6, 11, 20);
        final cible = service.calculerProchaineCible(
          heure: heure,
          dejaNoteAujourdhui: false,
          now: now,
        );
        expect(cible, cibleLocale(2025, 6, 11, 20));
      },
    );
  });
}
