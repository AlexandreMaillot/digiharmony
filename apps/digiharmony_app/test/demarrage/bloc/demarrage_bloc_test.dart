import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/pages/demarrage/bloc/demarrage_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/hydrated_storage.dart';

class _MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late _MockAppDatabase database;

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    initMockHydratedStorage();
    database = _MockAppDatabase();
    // Warm-up Drift par défaut : succès immédiat.
    when(() => database.conseilDuJour(any())).thenAnswer(
      (_) async => const Conseil(
        id: 1,
        cleConseil: 'tipDay01',
        typeCarte: 'rappel',
        accentChrome: 'primary',
        ordre: 1,
      ),
    );
  });

  DemarrageBloc build() => DemarrageBloc(database: database);

  const court = Duration(milliseconds: 10);

  test('SB-1 : état initial = DemarrageInitial', () {
    expect(build().state, const DemarrageInitial());
  });

  blocTest<DemarrageBloc, DemarrageState>(
    'SB-2/SB-5 : DemarrageDemarre -> EnCours puis DemarragePret (route Accueil)',
    build: build,
    act: (b) => b.add(const DemarrageDemarre(dureeMinimale: court)),
    wait: const Duration(milliseconds: 60),
    expect: () => const [
      DemarrageEnCours(),
      DemarragePret(),
    ],
  );

  blocTest<DemarrageBloc, DemarrageState>(
    'SB-4 : warm-up lent (> d) -> nav après init (pas après d)',
    build: () {
      when(() => database.conseilDuJour(any())).thenAnswer(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 80));
          return const Conseil(
        id: 1,
        cleConseil: 'tipDay01',
        typeCarte: 'rappel',
        accentChrome: 'primary',
        ordre: 1,
      );
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
    'SB-7/SB-8 : warm-up échoue -> DemarrageErreur (route Accueil quand même)',
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
      DemarrageErreur(),
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
