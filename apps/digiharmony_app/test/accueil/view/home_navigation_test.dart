import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/accueil/bloc/accueil_bloc.dart';
import 'package:digiharmony_app/accueil/view/accueil_view.dart';
import 'package:digiharmony_app/common/placeholder_screen.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAccueilBloc extends MockBloc<AccueilEvent, AccueilState>
    implements AccueilBloc {}

/// Pompe l'AccueilView avec animations désactivées.
extension PumpNav on WidgetTester {
  Future<void> pumpNavTest(AccueilBloc bloc) {
    return pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<AccueilBloc>.value(
            value: bloc,
            child: const AccueilView(),
          ),
        ),
      ),
    );
  }
}

void main() {
  late MockAccueilBloc bloc;
  final hapticLog = <MethodCall>[];

  setUp(() {
    bloc = MockAccueilBloc();
    hapticLog.clear();
    // Intercepte les appels haptiques via le canal de plateforme.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            hapticLog.add(call);
            return null;
          },
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  /// Vérifie qu'au moins un appel haptique lightImpact a été fait.
  void expectHaptique() {
    expect(
      hapticLog.any(
        (c) =>
            c.method == 'HapticFeedback.vibrate' ||
            c.method == 'SystemSound.play' ||
            c.method.contains('haptic') ||
            c.method.contains('Haptic'),
      ),
      isTrue,
      reason: 'HapticFeedback.lightImpact() attendu mais non déclenché',
    );
    hapticLog.clear();
  }

  group('Navigation placeholders + haptique (AC5)', () {
    // HN-1 : bouton Réglages → PlaceholderScreen.
    testWidgets(
      'HN-1 : Réglages → PlaceholderScreen',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpNavTest(bloc);
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();
        expect(find.byType(PlaceholderScreen), findsOneWidget);
        expectHaptique();
      },
    );

    // HN-2 : CTA « Log my mood » (État A) → PlaceholderScreen.
    testWidgets(
      'HN-2 : Log my mood → PlaceholderScreen',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpNavTest(bloc);
        await tester.tap(find.text('Log my mood'));
        await tester.pumpAndSettle();
        expect(find.byType(PlaceholderScreen), findsOneWidget);
        expectHaptique();
      },
    );

    // HN-3 : « See my journal » → PlaceholderScreen.
    testWidgets(
      'HN-3 : See my journal → PlaceholderScreen',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpNavTest(bloc);
        await tester.tap(find.text('See my journal'));
        await tester.pumpAndSettle();
        expect(find.byType(PlaceholderScreen), findsOneWidget);
        expectHaptique();
      },
    );

    // HN-4 : tuile « Choose your bubble » → PlaceholderScreen.
    testWidgets(
      'HN-4 : Choose your bubble → PlaceholderScreen',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpNavTest(bloc);
        await tester.tap(find.text('Choose your bubble'));
        await tester.pumpAndSettle();
        expect(find.byType(PlaceholderScreen), findsOneWidget);
        expectHaptique();
      },
    );

    // HN-5 : tuile « Tip of the day » → PlaceholderScreen.
    testWidgets(
      'HN-5 : Tip of the day → PlaceholderScreen',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpNavTest(bloc);
        await tester.tap(find.text('Tip of the day'));
        await tester.pumpAndSettle();
        expect(find.byType(PlaceholderScreen), findsOneWidget);
        expectHaptique();
      },
    );

    // HN-6 : pilule « Take a break » → PlaceholderScreen.
    testWidgets(
      'HN-6 : Take a break → PlaceholderScreen',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpNavTest(bloc);
        // Scroll pour rendre le widget visible.
        await tester.scrollUntilVisible(
          find.text('Take a break'),
          100,
        );
        await tester.tap(find.text('Take a break'));
        await tester.pumpAndSettle();
        expect(find.byType(PlaceholderScreen), findsOneWidget);
        expectHaptique();
      },
    );

    // HN-7 : lien « My screen time » → PlaceholderScreen.
    testWidgets(
      'HN-7 : My screen time → PlaceholderScreen',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
        );
        await tester.pumpNavTest(bloc);
        // Scroll pour rendre le widget visible.
        await tester.scrollUntilVisible(
          find.text('My screen time'),
          100,
        );
        await tester.tap(find.text('My screen time'));
        await tester.pumpAndSettle();
        expect(find.byType(PlaceholderScreen), findsOneWidget);
        expectHaptique();
      },
    );
  });
}
