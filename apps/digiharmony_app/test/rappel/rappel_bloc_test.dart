import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/rappel/rappel_bloc.dart';
import 'package:digiharmony_app/services/rappel/service_rappel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/hydrated_storage.dart';

class _MockServiceRappel extends Mock implements ServiceRappel {}

/// Lecteur Drift mocké (retourne false par défaut).
bool _humeurNonNotee = false;
Future<bool> _humeurDuJourEstNotee() async => _humeurNonNotee;

/// Crée un [RappelBloc] avec le mock service et le lecteur Drift injectés.
RappelBloc _buildBloc(_MockServiceRappel service) {
  return RappelBloc(
    serviceRappel: service,
    humeurDuJourEstNotee: _humeurDuJourEstNotee,
  );
}

void main() {
  late _MockServiceRappel service;

  setUpAll(() {
    registerFallbackValue(const TimeOfDay(hour: 20, minute: 0));
  });

  setUp(() {
    initMockHydratedStorage();
    service = _MockServiceRappel();
    _humeurNonNotee = false;
    // Stubs par défaut (toutes les méthodes async).
    when(
      () => service.planifierProchainRappel(
        heure: any(named: 'heure'),
        dejaNoteAujourdhui: any(named: 'dejaNoteAujourdhui'),
        titre: any(named: 'titre'),
        corps: any(named: 'corps'),
      ),
    ).thenAnswer((_) async {});
    when(() => service.annulerTout()).thenAnswer((_) async {});
    when(() => service.permissionAccordee()).thenAnswer((_) async => true);
    when(() => service.demanderPermission()).thenAnswer((_) async => true);
  });

  group('RappelBloc — état par défaut (M3 AC1)', () {
    test(
      'RB-1 : état à froid = actif=false, invitationDejaProposee=false',
      () async {
        final bloc = _buildBloc(service);
        expect(bloc.state.actif, isFalse);
        expect(bloc.state.invitationDejaProposee, isFalse);
        expect(bloc.state.permissionRefusee, isFalse);
        expect(bloc.state.heureHeure, 20);
        expect(bloc.state.heureMinute, 0);
        await bloc.close();
      },
    );
  });

  group('RappelBloc — hydratation round-trip (M3 AC2)', () {
    test(
      'RB-2 : toJson/fromJson préserve tous les champs '
      '(actif, heure, permissionRefusee, invitationDejaProposee)',
      () async {
        final bloc = _buildBloc(service);
        const etat = RappelState(
          actif: true,
          heureHeure: 9,
          heureMinute: 30,
          permissionRefusee: true,
          invitationDejaProposee: true,
        );
        final json = bloc.toJson(etat);
        expect(json['actif'], isTrue);
        expect(json['heureHeure'], 9);
        expect(json['heureMinute'], 30);
        expect(json['permissionRefusee'], isTrue);
        expect(json['invitationDejaProposee'], isTrue);

        final restaure = bloc.fromJson(json);
        expect(restaure.actif, isTrue);
        expect(restaure.heureHeure, 9);
        expect(restaure.heureMinute, 30);
        expect(restaure.permissionRefusee, isTrue);
        expect(restaure.invitationDejaProposee, isTrue);
        await bloc.close();
      },
    );

    test(
      'RB-3 : fromJson avec json vide/null → valeurs par défaut',
      () async {
        final bloc = _buildBloc(service);
        final restaure = bloc.fromJson(<String, dynamic>{});
        expect(restaure.actif, isFalse);
        expect(restaure.heureHeure, 20);
        expect(restaure.heureMinute, 0);
        expect(restaure.permissionRefusee, isFalse);
        expect(restaure.invitationDejaProposee, isFalse);
        await bloc.close();
      },
    );
  });

  group('RappelBloc — RappelActivationDemandee (M3 AC3)', () {
    blocTest<RappelBloc, RappelState>(
      'RB-4 : RappelActivationDemandee → actif=true, '
      'planifierProchainRappel appelée',
      build: () => _buildBloc(service),
      act: (bloc) => bloc.add(const RappelActivationDemandee()),
      expect: () => [
        isA<RappelState>()
            .having((s) => s.actif, 'actif', isTrue)
            .having(
              (s) => s.permissionRefusee,
              'permissionRefusee',
              isFalse,
            ),
      ],
      verify: (_) {
        verify(
          () => service.planifierProchainRappel(
            heure: any(named: 'heure'),
            dejaNoteAujourdhui: any(named: 'dejaNoteAujourdhui'),
            titre: any(named: 'titre'),
            corps: any(named: 'corps'),
          ),
        ).called(1);
      },
    );
  });

  group('RappelBloc — RappelDesactive (M3 AC4)', () {
    blocTest<RappelBloc, RappelState>(
      'RB-5 : RappelDesactive → actif=false + annulerTout appelée',
      build: () => _buildBloc(service),
      seed: () => const RappelState(actif: true),
      act: (bloc) => bloc.add(const RappelDesactive()),
      expect: () => [
        isA<RappelState>().having((s) => s.actif, 'actif', isFalse),
      ],
      verify: (_) {
        verify(() => service.annulerTout()).called(1);
      },
    );
  });

  group('RappelBloc — RappelHeureChangee (M3 AC5)', () {
    blocTest<RappelBloc, RappelState>(
      'RB-6 : RappelHeureChangee (actif=true) → heure mise à jour + '
      'replanification',
      build: () => _buildBloc(service),
      seed: () => const RappelState(actif: true),
      act: (bloc) => bloc.add(
        const RappelHeureChangee(TimeOfDay(hour: 8, minute: 15)),
      ),
      expect: () => [
        isA<RappelState>()
            .having((s) => s.heureHeure, 'heureHeure', 8)
            .having((s) => s.heureMinute, 'heureMinute', 15),
      ],
      verify: (_) {
        verify(
          () => service.planifierProchainRappel(
            heure: any(named: 'heure'),
            dejaNoteAujourdhui: any(named: 'dejaNoteAujourdhui'),
            titre: any(named: 'titre'),
            corps: any(named: 'corps'),
          ),
        ).called(1);
      },
    );

    blocTest<RappelBloc, RappelState>(
      'RB-7 : RappelHeureChangee (actif=false) → heure mise à jour, '
      'PAS de replanification',
      build: () => _buildBloc(service),
      seed: () => const RappelState(),
      act: (bloc) => bloc.add(
        const RappelHeureChangee(TimeOfDay(hour: 8, minute: 15)),
      ),
      expect: () => [
        isA<RappelState>()
            .having((s) => s.heureHeure, 'heureHeure', 8)
            .having((s) => s.heureMinute, 'heureMinute', 15),
      ],
      verify: (_) {
        verifyNever(
          () => service.planifierProchainRappel(
            heure: any(named: 'heure'),
            dejaNoteAujourdhui: any(named: 'dejaNoteAujourdhui'),
            titre: any(named: 'titre'),
            corps: any(named: 'corps'),
          ),
        );
      },
    );
  });

  group('RappelBloc — RappelPermissionRefusee (M3 AC6)', () {
    blocTest<RappelBloc, RappelState>(
      'RB-8 : RappelPermissionRefusee → actif=false + permissionRefusee=true',
      build: () => _buildBloc(service),
      seed: () => const RappelState(actif: true),
      act: (bloc) => bloc.add(const RappelPermissionRefusee()),
      expect: () => [
        isA<RappelState>()
            .having((s) => s.actif, 'actif', isFalse)
            .having(
              (s) => s.permissionRefusee,
              'permissionRefusee',
              isTrue,
            ),
      ],
    );
  });

  group('RappelBloc — RappelReplanificationDemandee (M3 AC7)', () {
    blocTest<RappelBloc, RappelState>(
      'RB-9 : replanification avec humeurDuJour=true → '
      'planifie pour demain',
      build: () {
        _humeurNonNotee = true;
        return _buildBloc(service);
      },
      seed: () => const RappelState(actif: true),
      act: (bloc) => bloc.add(const RappelReplanificationDemandee()),
      // Pas d'émission d'état si permission OK et actif=true.
      verify: (_) {
        verify(
          () => service.planifierProchainRappel(
            heure: any(named: 'heure'),
            dejaNoteAujourdhui: true,
            titre: any(named: 'titre'),
            corps: any(named: 'corps'),
          ),
        ).called(1);
      },
    );

    blocTest<RappelBloc, RappelState>(
      'RB-10 : replanification + permissionAccordee=false → '
      'actif=false + permissionRefusee=true',
      build: () {
        when(
          () => service.permissionAccordee(),
        ).thenAnswer((_) async => false);
        return _buildBloc(service);
      },
      seed: () => const RappelState(actif: true),
      act: (bloc) => bloc.add(const RappelReplanificationDemandee()),
      expect: () => [
        isA<RappelState>()
            .having((s) => s.actif, 'actif', isFalse)
            .having(
              (s) => s.permissionRefusee,
              'permissionRefusee',
              isTrue,
            ),
      ],
    );

    blocTest<RappelBloc, RappelState>(
      'RB-11 : replanification avec actif=false → rien ne se passe',
      build: () => _buildBloc(service),
      seed: () => const RappelState(),
      act: (bloc) => bloc.add(const RappelReplanificationDemandee()),
      expect: () => <RappelState>[],
      verify: (_) {
        verifyNever(
          () => service.planifierProchainRappel(
            heure: any(named: 'heure'),
            dejaNoteAujourdhui: any(named: 'dejaNoteAujourdhui'),
            titre: any(named: 'titre'),
            corps: any(named: 'corps'),
          ),
        );
      },
    );
  });

  group('RappelBloc — RappelInvitationProposee (M3 AC8)', () {
    blocTest<RappelBloc, RappelState>(
      'RB-12 : RappelInvitationProposee → invitationDejaProposee=true',
      build: () => _buildBloc(service),
      seed: () => const RappelState(),
      act: (bloc) => bloc.add(const RappelInvitationProposee()),
      expect: () => [
        isA<RappelState>().having(
          (s) => s.invitationDejaProposee,
          'invitationDejaProposee',
          isTrue,
        ),
      ],
    );

    blocTest<RappelBloc, RappelState>(
      'RB-13 : RappelInvitationProposee idempotent — '
      '2e appel = aucun état émis',
      build: () => _buildBloc(service),
      seed: () => const RappelState(invitationDejaProposee: true),
      act: (bloc) => bloc.add(const RappelInvitationProposee()),
      // Idempotent : aucun nouvel état si le flag est déjà posé.
      expect: () => <RappelState>[],
    );
  });
}
