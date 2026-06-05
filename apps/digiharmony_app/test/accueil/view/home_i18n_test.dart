import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/accueil/bloc/accueil_bloc.dart';
import 'package:digiharmony_app/pages/accueil/views/accueil_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAccueilBloc extends MockBloc<AccueilEvent, AccueilState>
    implements AccueilBloc {}

Future<void> pumpI18n(
  WidgetTester tester,
  AccueilBloc bloc,
  Locale locale,
) async {
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<AccueilBloc>.value(
          value: bloc,
          child: const AccueilView(),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  late MockAccueilBloc bloc;

  setUp(() {
    bloc = MockAccueilBloc();
    when(() => bloc.state).thenReturn(
      const AccueilPret(conseil: ConseilDuJourVue(cle: 'tipDay01')),
    );
  });

  group('i18n (AC8)', () {
    // I18-1 : locale fr → libellés français.
    testWidgets(
      'I18-1 : locale fr → heroLogMoodCta + homeGreeting en français',
      (tester) async {
        await pumpI18n(tester, bloc, const Locale('fr'));
        expect(find.text('Bonjour 👋'), findsOneWidget);
        expect(find.text('Noter mon humeur'), findsOneWidget);
      },
    );

    // I18-2 : locale en → libellés anglais.
    testWidgets(
      'I18-2 : locale en → heroLogMoodCta + homeGreeting en anglais',
      (tester) async {
        await pumpI18n(tester, bloc, const Locale('en'));
        expect(find.text('Hello 👋'), findsOneWidget);
        expect(find.text('Log my mood'), findsOneWidget);
      },
    );

    // I18-3 : wordmark DigiHarmony identique dans toutes les locales (AC8).
    testWidgets(
      'I18-3 : wordmark DIGIHARMONY identique en fr et en',
      (tester) async {
        // Français.
        await pumpI18n(tester, bloc, const Locale('fr'));
        expect(find.text('DIGIHARMONY'), findsOneWidget);

        // Anglais.
        await pumpI18n(tester, bloc, const Locale('en'));
        expect(find.text('DIGIHARMONY'), findsOneWidget);
      },
    );

    // I18-4 : locale partiellement traduite (mk) → repli en sans crash.
    testWidgets(
      'I18-4 : locale mk → repli en, pas de crash',
      (tester) async {
        await pumpI18n(tester, bloc, const Locale('mk'));
        // L'écran est rendu sans crash.
        expect(find.byType(AccueilView), findsOneWidget);
        // Le wordmark reste toujours DIGIHARMONY.
        expect(find.text('DIGIHARMONY'), findsOneWidget);
      },
    );

    // I18-5 : libellés d'humeur mappés depuis moodCode.
    testWidgets(
      'I18-5 : État B → libellé happy traduit en fr',
      (tester) async {
        when(() => bloc.state).thenReturn(
          AccueilPret(
            humeurDuJour: HumeurDuJourVue(
              codeEmotion: 'happy',
              emoji: '😊',
              noteeLe: DateTime(2026, 6, 5, 10),
            ),
            conseil: const ConseilDuJourVue(cle: 'tipDay01'),
          ),
        );
        await pumpI18n(tester, bloc, const Locale('fr'));
        // moodHappy en français.
        expect(find.text('Heureux·se'), findsOneWidget);
      },
    );
  });
}
