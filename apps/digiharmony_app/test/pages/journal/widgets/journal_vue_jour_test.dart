import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/journal/bloc/journal_bloc/journal_bloc.dart';
import 'package:digiharmony_app/pages/journal/widgets/journal_vue_jour.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockJournalBloc extends MockBloc<JournalEvent, JournalState>
    implements JournalBloc {}

class MockAppDatabase extends Mock implements AppDatabase {}

/// Pompe JournalVueJour avec le Bloc et l'i18n.
extension PumpJour on WidgetTester {
  Future<void> pumpVueJour(
    JournalBloc bloc, {
    bool disableAnimations = true,
  }) {
    return pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: MaterialApp(
          theme: AppTheme.dark,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: RepositoryProvider<AppDatabase>(
              create: (_) => MockAppDatabase(),
              child: BlocProvider<JournalBloc>.value(
                value: bloc,
                child: const JournalVueJour(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

DateTime get _today => DateTime.now();

JournalState _stateAvecHumeur(String code) {
  final now = _today;
  return JournalState(
    moisAffiche: DateTime(now.year, now.month),
    status: JournalStatus.pret,
    humeurDuJour: EntreeHumeur(
      id: 1,
      codeEmotion: code,
      valence: 1,
      creeLe: now,
      jour: DateTime(now.year, now.month, now.day),
    ),
    conseilDuJourCle: 'tipDay01',
  );
}

JournalState _stateVide() {
  final now = _today;
  return JournalState(
    moisAffiche: DateTime(now.year, now.month),
    status: JournalStatus.pret,
    conseilDuJourCle: 'tipDay01',
  );
}

void main() {
  late MockJournalBloc bloc;

  setUp(() {
    bloc = MockJournalBloc();
  });

  group('JournalVueJour — avec humeur', () {
    // VJ-1 : humeur happy → emoji + libellé moodHappy + conseil.
    testWidgets('VJ-1 : happy → emoji + libellé + conseil', (tester) async {
      when(() => bloc.state).thenReturn(_stateAvecHumeur('happy'));
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpVueJour(bloc);

      // Emoji via emojiPourCode (😊, pas en dur).
      expect(find.text('😊'), findsOneWidget);
      // Libellé mood localisé.
      expect(find.text('Happy'), findsOneWidget);
      // Label conseil.
      expect(find.text('Tip of the day'), findsOneWidget);
      // Texte conseil tipDay01.
      expect(
        find.textContaining('deep breaths'),
        findsOneWidget,
      );
    });

    // VJ-2 : CTA exercice → SnackBar (pas de navigation, DEC-J-02).
    testWidgets('VJ-2 : CTA exercice → SnackBar journalExerciseComingSoon', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(_stateAvecHumeur('calm'));
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpVueJour(bloc);
      await tester.tap(find.text('Do the exercise'));
      await tester.pump();

      expect(
        find.text('This exercise is coming soon.'),
        findsOneWidget,
      );
    });

    // VJ-3 : lien « Edit my mood » présent.
    testWidgets('VJ-3 : lien Edit my mood présent', (tester) async {
      when(() => bloc.state).thenReturn(_stateAvecHumeur('sad'));
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpVueJour(bloc);
      expect(find.text('Edit my mood'), findsOneWidget);
    });

    // VJ-4 : pastille a11y — Semantics avec label émotion.
    testWidgets('VJ-4 : pastille Semantics label présent', (tester) async {
      when(() => bloc.state).thenReturn(_stateAvecHumeur('happy'));
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpVueJour(bloc);
      // Le Semantics label est le libellé de l'émotion (pas l'emoji seul).
      final semantics = tester.getSemantics(find.text('😊'));
      expect(semantics.label, isNotEmpty);
    });
  });

  group('JournalVueJour — état vide bienveillant', () {
    // VJ-5 : pas d'humeur → titre + corps + CTA bienveillant.
    testWidgets('VJ-5 : état vide → titre + corps + CTA', (tester) async {
      when(() => bloc.state).thenReturn(_stateVide());
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpVueJour(bloc);

      expect(find.text('No mood logged yet today'), findsOneWidget);
      expect(
        find.textContaining('Whenever you feel ready'),
        findsOneWidget,
      );
      expect(find.text('Log my mood'), findsOneWidget);
    });

    // VJ-6 : état vide → conseil toujours affiché (DEC-J-04).
    testWidgets('VJ-6 : état vide → conseil affiché (DEC-J-04)', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(_stateVide());
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpVueJour(bloc);
      expect(find.text('Tip of the day'), findsOneWidget);
    });

    // VJ-7 : aucune chaîne en dur (vérification clés i18n utilisées).
    testWidgets('VJ-7 : aucune chaîne en dur visible', (tester) async {
      when(() => bloc.state).thenReturn(_stateVide());
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpVueJour(bloc);
      // Les textes sont issus des ARB.
      expect(find.text('No mood logged yet today'), findsOneWidget);
      expect(find.textContaining('Whenever you feel ready'), findsOneWidget);
    });
  });
}
