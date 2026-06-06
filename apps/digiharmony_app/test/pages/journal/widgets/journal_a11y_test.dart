import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/journal/bloc/journal_bloc/journal_bloc.dart';
import 'package:digiharmony_app/pages/journal/widgets/journal_vue_jour.dart';
import 'package:digiharmony_app/pages/journal/widgets/journal_vue_mois.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockJournalBloc extends MockBloc<JournalEvent, JournalState>
    implements JournalBloc {}

class MockAppDatabase extends Mock implements AppDatabase {}

Widget _harness(
  JournalBloc bloc,
  Widget child, {
  bool disableAnimations = true,
}) {
  return MediaQuery(
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
            child: child,
          ),
        ),
      ),
    ),
  );
}

JournalState _stateAvecHumeur(String code) {
  final now = DateTime.now();
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

JournalState _stateMoisBorne() {
  return JournalState(
    moisAffiche: DateTime.now(),
    status: JournalStatus.pret,
  );
}

void main() {
  late MockJournalBloc bloc;

  setUp(() {
    bloc = MockJournalBloc();
  });

  group('A11y — reduced-motion', () {
    // A11Y-1 : disableAnimations=true → rendu statique (pas de crash).
    testWidgets(
      'A11Y-1 : disableAnimations=true → JournalVueJour rendu statique',
      (tester) async {
        when(() => bloc.state).thenReturn(_stateAvecHumeur('happy'));
        when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(_harness(bloc, const JournalVueJour()));

        // Le widget se rend sans crash et affiche les éléments normaux.
        expect(find.text('😊'), findsOneWidget);
        expect(find.text('Happy'), findsOneWidget);
      },
    );

    // A11Y-2 : disableAnimations=false → même rendu (aucune animation active).
    testWidgets(
      'A11Y-2 : disableAnimations=false → même rendu (aucune animation)',
      (tester) async {
        when(() => bloc.state).thenReturn(_stateAvecHumeur('calm'));
        when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(
          _harness(bloc, const JournalVueJour(), disableAnimations: false),
        );
        await tester.pump();

        // Pas de différence de rendu.
        expect(find.text('😌'), findsOneWidget);
      },
    );
  });

  group('A11y — sémantique mois', () {
    // A11Y-3 : flèche suivant désactivée annoncée comme telle.
    testWidgets(
      'A11Y-3 : flèche suivant désactivée → Semantics enabled=false',
      (tester) async {
        when(() => bloc.state).thenReturn(_stateMoisBorne());
        when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(_harness(bloc, const JournalVueMois()));

        // Le bouton est désactivé (onPressed == null).
        final iconBtn = tester.widget<IconButton>(
          find.byWidgetPredicate(
            (w) =>
                w is IconButton &&
                w.icon is Icon &&
                (w.icon as Icon).icon == Icons.chevron_right,
          ),
        );
        expect(iconBtn.onPressed, isNull);
      },
    );
  });

  group('A11y — cibles tactiles ≥ 48dp', () {
    // A11Y-4 : flèches mois ≥ 48dp.
    testWidgets('A11Y-4 : flèches mois ≥ 48×48dp', (tester) async {
      when(() => bloc.state).thenReturn(_stateMoisBorne());
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_harness(bloc, const JournalVueMois()));

      final fleches = find.byWidgetPredicate(
        (w) => w is SizedBox && (w.width ?? 0) >= 48 && (w.height ?? 0) >= 48,
      );
      expect(fleches, findsWidgets);
    });
  });
}
