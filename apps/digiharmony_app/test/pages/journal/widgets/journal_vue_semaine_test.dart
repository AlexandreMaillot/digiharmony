import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/journal/bloc/journal_bloc/journal_bloc.dart';
import 'package:digiharmony_app/pages/journal/widgets/journal_vue_semaine.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockJournalBloc extends MockBloc<JournalEvent, JournalState>
    implements JournalBloc {}

extension PumpSemaine on WidgetTester {
  Future<void> pumpVueSemaine(JournalBloc bloc) {
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
              child: const JournalVueSemaine(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lundi de la semaine contenant [date].
DateTime _lundi(DateTime date) {
  final n = DateTime(date.year, date.month, date.day);
  return n.subtract(Duration(days: n.weekday - 1));
}

JournalState _stateSemaine(List<EntreeHumeur> entrees) {
  final now = DateTime.now();
  return JournalState(
    moisAffiche: DateTime(now.year, now.month),
    status: JournalStatus.pret,
    entreesSemaine: entrees,
    conseilDuJourCle: 'tipDay01',
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

  group('JournalVueSemaine', () {
    // VS-1 : 7 cases rendues (7 colonnes jours).
    testWidgets('VS-1 : 7 cases semaine rendues', (tester) async {
      when(() => bloc.state).thenReturn(_stateSemaine([]));
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpVueSemaine(bloc);

      // Le marqueur "·" apparaît 7 fois (aucune entrée).
      expect(find.text('·'), findsNWidgets(7));
    });

    // VS-2 : jour avec entrée → emoji ; jour sans entrée → « · ».
    testWidgets('VS-2 : jour avec humeur → emoji, sans humeur → ·', (
      tester,
    ) async {
      final lundi = _lundi(DateTime.now());
      final entree = _entree('happy', lundi);
      when(() => bloc.state).thenReturn(_stateSemaine([entree]));
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpVueSemaine(bloc);

      expect(find.text('😊'), findsOneWidget);
      expect(find.text('·'), findsNWidgets(6));
    });

    // VS-3 : résumé journalWeekSummary avec count = 1.
    testWidgets('VS-3 : résumé journalWeekSummary (1 entrée)', (tester) async {
      final lundi = _lundi(DateTime.now());
      final entree = _entree('calm', lundi);
      when(() => bloc.state).thenReturn(_stateSemaine([entree]));
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpVueSemaine(bloc);

      expect(
        find.textContaining('1 of 7 days'),
        findsOneWidget,
      );
    });

    // VS-4 : semaine vide → journalWeekSummaryEmpty.
    testWidgets('VS-4 : semaine vide → journalWeekSummaryEmpty', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(_stateSemaine([]));
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpVueSemaine(bloc);

      expect(
        find.text('No mood logged this week yet.'),
        findsOneWidget,
      );
    });

    // VS-5 : titre journalWeekTitle présent.
    testWidgets('VS-5 : titre This week présent', (tester) async {
      when(() => bloc.state).thenReturn(_stateSemaine([]));
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpVueSemaine(bloc);
      expect(find.text('This week'), findsOneWidget);
    });
  });
}
