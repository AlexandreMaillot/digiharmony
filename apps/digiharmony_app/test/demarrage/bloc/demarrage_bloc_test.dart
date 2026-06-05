import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/bienvenue/bloc/bienvenue_bloc.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/demarrage/bloc/demarrage_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/hydrated_storage.dart';

class _MockAppDatabase extends Mock implements AppDatabase {}

class _MockBienvenueBloc extends MockBloc<BienvenueEvent, BienvenueState>
    implements BienvenueBloc {}

void main() {
  late _MockAppDatabase database;
  late _MockBienvenueBloc bienvenue;

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    initMockHydratedStorage();
    database = _MockAppDatabase();
    bienvenue = _MockBienvenueBloc();
    // Warm-up Drift par défaut : succès immédiat.
    when(() => database.conseilDuJour(any())).thenAnswer(
      (_) async => const Conseil(id: 1, cleConseil: 'tipDay01'),
    );
    // Bienvenue non vue par défaut.
    when(() => bienvenue.state).thenReturn(const BienvenueState());
  });

  DemarrageBloc build() =>
      DemarrageBloc(database: database, bienvenueBloc: bienvenue);

  const court = Duration(milliseconds: 10);

  test('SB-1 : état initial = DemarrageInitial', () {
    expect(build().state, const DemarrageInitial());
  });

  blocTest<DemarrageBloc, DemarrageState>(
    'SB-2/SB-5 : DemarrageDemarre -> EnCours puis PretPourBienvenue (flag false)',
    build: build,
    act: (b) => b.add(const DemarrageDemarre(dureeMinimale: court)),
    wait: const Duration(milliseconds: 60),
    expect: () => const [
      DemarrageEnCours(),
      DemarragePretPourBienvenue(),
    ],
  );

  blocTest<DemarrageBloc, DemarrageState>(
    'SB-6 : flag true -> PretPourAccueil',
    build: () {
      when(() => bienvenue.state).thenReturn(
        const BienvenueState(estBienvenueVue: true),
      );
      return build();
    },
    act: (b) => b.add(const DemarrageDemarre(dureeMinimale: court)),
    wait: const Duration(milliseconds: 60),
    expect: () => const [
      DemarrageEnCours(),
      DemarragePretPourAccueil(),
    ],
  );

  blocTest<DemarrageBloc, DemarrageState>(
    'SB-4 : warm-up lent (> d) -> nav après init (pas après d)',
    build: () {
      when(() => database.conseilDuJour(any())).thenAnswer(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 80));
          return const Conseil(id: 1, cleConseil: 'tipDay01');
        },
      );
      return build();
    },
    act: (b) => b.add(const DemarrageDemarre(dureeMinimale: court)),
    // À 40 ms : d écoulé (10 ms) mais init (80 ms) pas finie → pas prêt.
    wait: const Duration(milliseconds: 40),
    expect: () => const [DemarrageEnCours()],
  );

  blocTest<DemarrageBloc, DemarrageState>(
    'SB-7/SB-8 : warm-up échoue + flag false -> DemarrageErreur(versBienvenue:true)',
    build: () {
      when(() => database.conseilDuJour(any())).thenThrow(
        StateError('Drift KO'),
      );
      return build();
    },
    act: (b) => b.add(const DemarrageDemarre(dureeMinimale: court)),
    wait: const Duration(milliseconds: 60),
    expect: () => const [
      DemarrageEnCours(),
      DemarrageErreur(versBienvenue: true),
    ],
  );

  blocTest<DemarrageBloc, DemarrageState>(
    'SB-9 : warm-up échoue + flag true -> DemarrageErreur(versBienvenue:false)',
    build: () {
      when(() => bienvenue.state).thenReturn(
        const BienvenueState(estBienvenueVue: true),
      );
      when(() => database.conseilDuJour(any())).thenThrow(
        StateError('Drift KO'),
      );
      return build();
    },
    act: (b) => b.add(const DemarrageDemarre(dureeMinimale: court)),
    wait: const Duration(milliseconds: 60),
    expect: () => const [
      DemarrageEnCours(),
      DemarrageErreur(versBienvenue: false),
    ],
  );

  blocTest<DemarrageBloc, DemarrageState>(
    'SB-3/SB-10 : délai long injecté -> nav seulement après le délai',
    build: build,
    act: (b) => b.add(
      const DemarrageDemarre(dureeMinimale: Duration(milliseconds: 100)),
    ),
    // À 30 ms : init OK mais délai (100 ms) pas écoulé → pas prêt.
    wait: const Duration(milliseconds: 30),
    expect: () => const [DemarrageEnCours()],
  );
}
