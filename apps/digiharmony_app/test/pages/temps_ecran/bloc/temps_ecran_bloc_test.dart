import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/pages/temps_ecran/bloc/temps_ecran_bloc.dart';
import 'package:digiharmony_app/pages/temps_ecran/modeles/resume_temps_ecran.dart';
import 'package:digiharmony_app/pages/temps_ecran/services/service_temps_ecran.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockService extends Mock implements ServiceTempsEcran {}

UsageAppVue _u(String pkg, int minutes) => UsageAppVue(
  nomApp: pkg,
  packageName: pkg,
  duree: Duration(minutes: minutes),
  fractionDuTotal: 0,
);

void main() {
  late _MockService service;
  late AppDatabase database;

  setUp(() {
    service = _MockService();
    database = AppDatabase.forTesting(NativeDatabase.memory());
    when(() => service.plateformeSupportee).thenReturn(true);
  });

  tearDown(() => database.close());

  TempsEcranBloc build() =>
      TempsEcranBloc(service: service, database: database);

  blocTest<TempsEcranBloc, TempsEcranState>(
    'AC6 : plateforme non supportée → indisponible',
    setUp: () => when(() => service.plateformeSupportee).thenReturn(false),
    build: build,
    act: (b) => b.add(const TempsEcranDemarre()),
    expect: () => [
      const TempsEcranState(status: TempsEcranStatus.indisponible),
    ],
  );

  blocTest<TempsEcranBloc, TempsEcranState>(
    'AC1 : accès non accordé → permissionRequise',
    setUp: () => when(() => service.aLAcces()).thenAnswer((_) async => false),
    build: build,
    act: (b) => b.add(const TempsEcranDemarre()),
    expect: () => [
      const TempsEcranState(status: TempsEcranStatus.chargement),
      const TempsEcranState(status: TempsEcranStatus.permissionRequise),
    ],
  );

  blocTest<TempsEcranBloc, TempsEcranState>(
    'AC5 : accès OK mais aucune donnée → vide',
    setUp: () {
      when(() => service.aLAcces()).thenAnswer((_) async => true);
      when(() => service.usageDuJour()).thenAnswer((_) async => const []);
    },
    build: build,
    act: (b) => b.add(const TempsEcranDemarre()),
    expect: () => [
      const TempsEcranState(status: TempsEcranStatus.chargement),
      const TempsEcranState(status: TempsEcranStatus.vide),
    ],
  );

  blocTest<TempsEcranBloc, TempsEcranState>(
    'AC4 : accès OK + données → pret avec résumé agrégé',
    setUp: () {
      when(() => service.aLAcces()).thenAnswer((_) async => true);
      when(
        () => service.usageDuJour(),
      ).thenAnswer((_) async => [_u('com.a', 30), _u('com.b', 10)]);
    },
    build: build,
    act: (b) => b.add(const TempsEcranDemarre()),
    expect: () => [
      const TempsEcranState(status: TempsEcranStatus.chargement),
      isA<TempsEcranState>()
          .having((s) => s.status, 'status', TempsEcranStatus.pret)
          .having(
            (s) => s.resume!.total,
            'total',
            const Duration(minutes: 40),
          ),
    ],
  );

  blocTest<TempsEcranBloc, TempsEcranState>(
    'AC7 : exception → erreur',
    setUp: () {
      when(() => service.aLAcces()).thenAnswer((_) async => true);
      when(() => service.usageDuJour()).thenThrow(Exception('boom'));
    },
    build: build,
    act: (b) => b.add(const TempsEcranDemarre()),
    expect: () => [
      const TempsEcranState(status: TempsEcranStatus.chargement),
      const TempsEcranState(status: TempsEcranStatus.erreur),
    ],
  );

  blocTest<TempsEcranBloc, TempsEcranState>(
    'AC2 : TempsEcranPermissionDemandee → ouvre les réglages',
    setUp: () =>
        when(() => service.ouvrirReglagesAcces()).thenAnswer((_) async {}),
    build: build,
    act: (b) => b.add(const TempsEcranPermissionDemandee()),
    verify: (_) => verify(() => service.ouvrirReglagesAcces()).called(1),
  );

  blocTest<TempsEcranBloc, TempsEcranState>(
    'AC3 : retour au premier plan → re-vérifie et bascule pret',
    setUp: () {
      when(() => service.aLAcces()).thenAnswer((_) async => true);
      when(
        () => service.usageDuJour(),
      ).thenAnswer((_) async => [_u('com.a', 5)]);
    },
    build: build,
    act: (b) => b.add(const TempsEcranRevenuAuPremierPlan()),
    expect: () => [
      const TempsEcranState(status: TempsEcranStatus.chargement),
      isA<TempsEcranState>().having(
        (s) => s.status,
        'status',
        TempsEcranStatus.pret,
      ),
    ],
  );

  blocTest<TempsEcranBloc, TempsEcranState>(
    'AC8 : agrégat total persisté dans Drift (historique local)',
    setUp: () {
      when(() => service.aLAcces()).thenAnswer((_) async => true);
      when(
        () => service.usageDuJour(),
      ).thenAnswer((_) async => [_u('com.a', 15)]);
    },
    build: build,
    act: (b) => b.add(const TempsEcranDemarre()),
    verify: (_) async {
      final hist = await database.observerHistoriqueUsage().first;
      expect(hist, hasLength(1));
      expect(hist.first.totalSecondes, const Duration(minutes: 15).inSeconds);
    },
  );
}
