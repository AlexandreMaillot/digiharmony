import 'package:digiharmony_app/services/rappel/service_rappel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// Mock du [ServiceRappel] — aucun canal OS réel (plan section M / DEC-R-01).
class MockServiceRappel extends Mock implements ServiceRappel {}

void main() {
  late MockServiceRappel service;

  setUpAll(() {
    // Enregistrement du fallback pour TimeOfDay (requis par mocktail).
    registerFallbackValue(const TimeOfDay(hour: 20, minute: 0));
  });

  setUp(() {
    service = MockServiceRappel();
    // Stubs pour éviter les MissingStubError.
    when(() => service.annulerTout()).thenAnswer((_) async {});
    when(
      () => service.planifierProchainRappel(
        heure: any(named: 'heure'),
        dejaNoteAujourdhui: any(named: 'dejaNoteAujourdhui'),
        titre: any(named: 'titre'),
        corps: any(named: 'corps'),
      ),
    ).thenAnswer((_) async {});
    when(() => service.permissionAccordee()).thenAnswer((_) async => true);
    when(() => service.demanderPermission()).thenAnswer((_) async => true);
  });

  group('ServiceRappel — contrat (via mock)', () {
    // SR-1 : planifierProchainRappel avec dejaNoteAujourdhui=true
    //        → le mock doit pouvoir être appelé sans levée d'exception.
    test(
      'SR-1 : planifierProchainRappel(dejaNoteAujourdhui: true) '
      'est appelable sans erreur',
      () async {
        await expectLater(
          service.planifierProchainRappel(
            heure: const TimeOfDay(hour: 20, minute: 0),
            dejaNoteAujourdhui: true,
            titre: 'Comment tu vas ?',
            corps: 'Prends un moment.',
          ),
          completes,
        );
        verify(
          () => service.planifierProchainRappel(
            heure: const TimeOfDay(hour: 20, minute: 0),
            dejaNoteAujourdhui: true,
            titre: any(named: 'titre'),
            corps: any(named: 'corps'),
          ),
        ).called(1);
      },
    );

    // SR-2 : planifierProchainRappel avec dejaNoteAujourdhui=false
    test(
      'SR-2 : planifierProchainRappel(dejaNoteAujourdhui: false) '
      'est appelable sans erreur',
      () async {
        await expectLater(
          service.planifierProchainRappel(
            heure: const TimeOfDay(hour: 8, minute: 30),
            dejaNoteAujourdhui: false,
            titre: 'How are you feeling today?',
            corps: 'Take a moment to log your mood.',
          ),
          completes,
        );
      },
    );

    // SR-3 : annulerTout est appelable.
    test('SR-3 : annulerTout est appelable sans erreur', () async {
      await expectLater(service.annulerTout(), completes);
      verify(() => service.annulerTout()).called(1);
    });

    // SR-4 : demanderPermission retourne un bool.
    test('SR-4 : demanderPermission retourne un bool', () async {
      final result = await service.demanderPermission();
      expect(result, isA<bool>());
    });

    // SR-5 : permissionAccordee retourne un bool.
    test('SR-5 : permissionAccordee retourne un bool', () async {
      final result = await service.permissionAccordee();
      expect(result, isA<bool>());
    });
  });

  group('ServiceRappel — logique de cible (calcul de date)', () {
    // Ces tests vérifient le comportement attendu du mock selon DEC-R-04.
    // Le calcul réel de TZDateTime est couvert en intégration.

    // SR-6 : si dejaNoteAujourdhui=true, true est bien transmis au service.
    test(
      'SR-6 : dejaNoteAujourdhui=true est bien transmis au service',
      () async {
        await service.planifierProchainRappel(
          heure: const TimeOfDay(hour: 20, minute: 0),
          dejaNoteAujourdhui: true,
          titre: 'Titre',
          corps: 'Corps',
        );
        final captured = verify(
          () => service.planifierProchainRappel(
            heure: captureAny(named: 'heure'),
            dejaNoteAujourdhui: captureAny(named: 'dejaNoteAujourdhui'),
            titre: any(named: 'titre'),
            corps: any(named: 'corps'),
          ),
        ).captured;
        // captured = [heure, dejaNoteAujourdhui]
        expect(captured[1], isTrue);
      },
    );

    // SR-7 : si dejaNoteAujourdhui=false, false est transmis.
    test(
      'SR-7 : dejaNoteAujourdhui=false est bien transmis au service',
      () async {
        await service.planifierProchainRappel(
          heure: const TimeOfDay(hour: 9, minute: 0),
          dejaNoteAujourdhui: false,
          titre: 'Titre',
          corps: 'Corps',
        );
        final captured = verify(
          () => service.planifierProchainRappel(
            heure: captureAny(named: 'heure'),
            dejaNoteAujourdhui: captureAny(named: 'dejaNoteAujourdhui'),
            titre: any(named: 'titre'),
            corps: any(named: 'corps'),
          ),
        ).captured;
        expect(captured[1], isFalse);
      },
    );
  });
}
