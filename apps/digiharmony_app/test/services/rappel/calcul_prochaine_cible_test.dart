import 'package:digiharmony_app/services/rappel/service_rappel_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    // Utilise UTC comme fuseau de référence pour des tests déterministes.
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  ServiceRappelNotifications buildService() => ServiceRappelNotifications();

  group('calculerProchaineCible — DEC-R-04 / MAJOR-1', () {
    // Contexte : le rappel est configuré à 20h00 UTC.
    const heure = TimeOfDay(hour: 20, minute: 0);

    // CC-1 : dejaNoteAujourdhui=true → cible toujours demain, peu importe
    //         l'heure actuelle (même si l'heure est dans le futur).
    test(
      'CC-1 : dejaNoteAujourdhui=true => cible = demain a 20h00, '
      'meme si heure rappel est dans le futur',
      () {
        final service = buildService();
        // Maintenant = 08h00 UTC (heure non passée, mais déjà noté)
        final now = tz.TZDateTime(tz.UTC, 2025, 6, 11, 8);
        final cible = service.calculerProchaineCible(
          heure: heure,
          dejaNoteAujourdhui: true,
          now: now,
        );
        expect(cible.day, 12, reason: 'doit être demain (jour 12)');
        expect(cible.hour, 20);
        expect(cible.minute, 0);
      },
    );

    // CC-2 : dejaNoteAujourdhui=false + heure NON passée → aujourd'hui.
    test(
      'CC-2 : dejaNoteAujourdhui=false + heure rappel dans le futur => '
      'cible = auhourd hui a 20h00',
      () {
        final service = buildService();
        // Maintenant = 15h00 UTC (avant 20h00)
        final now = tz.TZDateTime(tz.UTC, 2025, 6, 11, 15);
        final cible = service.calculerProchaineCible(
          heure: heure,
          dejaNoteAujourdhui: false,
          now: now,
        );
        expect(cible.day, 11, reason: 'doit etre aujourd hui (jour 11)');
        expect(cible.hour, 20);
        expect(cible.minute, 0);
      },
    );

    // CC-3 : dejaNoteAujourdhui=false + heure passée → demain.
    test(
      'CC-3 : dejaNoteAujourdhui=false + heure rappel passée → '
      'cible = demain à 20h00',
      () {
        final service = buildService();
        // Maintenant = 21h30 UTC (après 20h00)
        final now = tz.TZDateTime(tz.UTC, 2025, 6, 11, 21, 30);
        final cible = service.calculerProchaineCible(
          heure: heure,
          dejaNoteAujourdhui: false,
          now: now,
        );
        expect(cible.day, 12, reason: 'doit être demain (jour 12)');
        expect(cible.hour, 20);
        expect(cible.minute, 0);
      },
    );

    // CC-4 : cas limite — maintenant = exactement l'heure du rappel
    //         → isBefore est false, donc aujourd'hui.
    test(
      'CC-4 : heure actuelle == heure rappel (exactement) => '
      'cible = aujourd hui (isBefore=false)',
      () {
        final service = buildService();
        final now = tz.TZDateTime(tz.UTC, 2025, 6, 11, 20);
        final cible = service.calculerProchaineCible(
          heure: heure,
          dejaNoteAujourdhui: false,
          now: now,
        );
        // isBefore(maintenant) est false quand les deux sont égaux.
        expect(cible.day, 11, reason: 'exact match => cible = aujourd hui');
        expect(cible.hour, 20);
      },
    );
  });
}
