import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/journal/bloc/journal_bloc/journal_bloc.dart';
import 'package:digiharmony_app/pages/journal/widgets/journal_vue_mois.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockJournalBloc extends MockBloc<JournalEvent, JournalState>
    implements JournalBloc {}

extension PumpMois on WidgetTester {
  Future<void> pumpVueMois(JournalBloc bloc) {
    return pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          theme: AppTheme.dark,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocProvider<JournalBloc>.value(
              value: bloc,
              child: const JournalVueMois(),
            ),
          ),
        ),
      ),
    );
  }
}

JournalState _stateMois({
  required DateTime moisAffiche,
  required bool peutAvancerMois,
  List<EntreeHumeur> entrees = const [],
}) {
  return JournalState(
    moisAffiche: moisAffiche,
    status: JournalStatus.pret,
    peutAvancerMois: peutAvancerMois,
    entreesMois: entrees,
  );
}

EntreeHumeur _entree(String code, DateTime at) {
  return EntreeHumeur(
    id: 1,
    codeEmotion: code,
    valence: 1,
    creeLe: at,
    jour: DateTime(at.year, at.month, at.day),
  );
}

void main() {
  late MockJournalBloc bloc;

  setUp(() {
    bloc = MockJournalBloc();
  });

  group('JournalVueMois — navigation bornée', () {
    // VM-1 : flèche suivant désactivée au mois courant.
    testWidgets('VM-1 : flèche suivant désactivée au mois courant', (
      tester,
    ) async {
      final now = DateTime.now();
      when(() => bloc.state).thenReturn(
        _stateMois(
          moisAffiche: DateTime(now.year, now.month),
          peutAvancerMois: false,
        ),
      );
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpVueMois(bloc);

      // Le bouton chevron_right doit être désactivé (onPressed == null).
      final btnSuivant = tester.widget<IconButton>(
        find.byWidgetPredicate(
          (w) =>
              w is IconButton &&
              w.icon is Icon &&
              (w.icon as Icon).icon == Icons.chevron_right,
        ),
      );
      expect(btnSuivant.onPressed, isNull);
    });

    // VM-2 : flèche suivant activée depuis un mois passé.
    testWidgets('VM-2 : flèche suivant activée depuis un mois passé', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(
        _stateMois(
          moisAffiche: DateTime(2026, 5),
          peutAvancerMois: true,
        ),
      );
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpVueMois(bloc);

      final btnSuivant = tester.widget<IconButton>(
        find.byWidgetPredicate(
          (w) =>
              w is IconButton &&
              w.icon is Icon &&
              (w.icon as Icon).icon == Icons.chevron_right,
        ),
      );
      expect(btnSuivant.onPressed, isNotNull);
    });

    // VM-3 : tap flèche précédent → JournalMoisPrecedent dispatché.
    testWidgets('VM-3 : tap précédent → JournalMoisPrecedent', (tester) async {
      final now = DateTime.now();
      when(() => bloc.state).thenReturn(
        _stateMois(
          moisAffiche: DateTime(now.year, now.month),
          peutAvancerMois: false,
        ),
      );
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpVueMois(bloc);
      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is IconButton &&
              w.icon is Icon &&
              (w.icon as Icon).icon == Icons.chevron_left,
        ),
      );
      verify(() => bloc.add(const JournalMoisPrecedent())).called(1);
    });
  });

  group('JournalVueMois — grille calendrier', () {
    // VM-4 : jour noté → emoji affiché.
    testWidgets('VM-4 : jour noté → emoji dans la grille', (tester) async {
      final juin = DateTime(2026, 6, 15);
      final entree = _entree('happy', juin);
      when(() => bloc.state).thenReturn(
        _stateMois(
          moisAffiche: DateTime(2026, 6),
          peutAvancerMois: true,
          entrees: [entree],
        ),
      );
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpVueMois(bloc);
      expect(find.text('😊'), findsOneWidget);
    });

    // VM-5 : jour non noté → numéro grisé (pas d'emoji).
    testWidgets('VM-5 : jour non noté → numéro grisé', (tester) async {
      when(() => bloc.state).thenReturn(
        _stateMois(
          moisAffiche: DateTime(2026, 6),
          peutAvancerMois: true,
        ),
      );
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpVueMois(bloc);
      // Le jour 1 de juin 2026 doit être affiché en numéro.
      expect(find.text('1'), findsOneWidget);
    });
  });

  group('JournalVueMois — synthèse', () {
    // VM-6 : 2 happy, 1 sad → lignes dans l'ordre emotionsCanoniques.
    testWidgets(
      'VM-6 : répartition ordre emotionsCanoniques (happy avant sad)',
      (tester) async {
        final juin1 = _entree('happy', DateTime(2026, 6));
        final juin2 = _entree('happy', DateTime(2026, 6, 2));
        final juin3 = _entree('sad', DateTime(2026, 6, 3));
        when(() => bloc.state).thenReturn(
          _stateMois(
            moisAffiche: DateTime(2026, 6),
            peutAvancerMois: true,
            entrees: [juin1, juin2, juin3],
          ),
        );
        when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpVueMois(bloc);

        // happy (index 0) avant sad (index 3) dans emotionsCanoniques.
        final happyPos = tester.getTopLeft(find.textContaining('Happy')).dy;
        final sadPos = tester.getTopLeft(find.textContaining('Sad')).dy;
        expect(happyPos, lessThan(sadPos));
      },
    );

    // VM-7 : mois vide → journalMonthSummaryEmpty.
    testWidgets('VM-7 : mois vide → journalMonthSummaryEmpty', (tester) async {
      when(() => bloc.state).thenReturn(
        _stateMois(
          moisAffiche: DateTime(2026, 6),
          peutAvancerMois: true,
        ),
      );
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpVueMois(bloc);
      expect(
        find.text('No mood logged this month yet.'),
        findsOneWidget,
      );
    });
  });
}
