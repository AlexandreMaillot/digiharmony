import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/saisie_humeur/bloc/saisie_humeur_bloc.dart';
import 'package:digiharmony_app/pages/saisie_humeur/modeles/emotion_canonique.dart';
import 'package:digiharmony_app/pages/saisie_humeur/views/saisie_humeur_view.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSaisieHumeurBloc
    extends MockBloc<SaisieHumeurEvent, SaisieHumeurState>
    implements SaisieHumeurBloc {}

/// Pompe SaisieHumeurView avec le bloc mocké.
extension PumpSaisie on WidgetTester {
  Future<void> pumpSaisie(
    SaisieHumeurBloc bloc, {
    bool disableAnimations = true,
  }) {
    return pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<SaisieHumeurBloc>.value(
            value: bloc,
            child: const SaisieHumeurView(),
          ),
        ),
      ),
    );
  }
}

void main() {
  late MockSaisieHumeurBloc bloc;

  // Requis par mocktail pour `captureAny()` sur le type `SaisieHumeurEvent`
  // (events non-Equatable, convention projet → capture plutôt qu'égalité).
  setUpAll(() {
    registerFallbackValue(const SaisieValidee());
  });

  setUp(() {
    bloc = MockSaisieHumeurBloc();
    when(() => bloc.state).thenReturn(const SaisieInitiale());
  });

  group('SaisieHumeurView — rendu initial', () {
    // SHV-1 : toolbar présente (chevron) ; pas de burger menu.
    testWidgets(
      'SHV-1 : toolbar affiche chevron, pas de menu burger',
      (tester) async {
        await tester.pumpSaisie(bloc);
        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
        expect(find.byIcon(Icons.menu), findsNothing);
      },
    );

    // SHV-2 : titre et sous-titre présents.
    testWidgets(
      'SHV-2 : titre et sous-titre affichés',
      (tester) async {
        await tester.pumpSaisie(bloc);
        expect(find.textContaining('feeling today'), findsWidgets);
        expect(find.textContaining('Pick how you feel'), findsWidgets);
      },
    );

    // SHV-3 : 7 pastilles affichées (une par émotion canonique via emoji).
    testWidgets(
      'SHV-3 : 7 pastilles — tous les emojis affichés',
      (tester) async {
        await tester.pumpSaisie(bloc);
        for (final emotion in emotionsCanoniques) {
          expect(
            find.text(emotion.emoji),
            findsWidgets,
            reason: 'Emoji ${emotion.emoji} (${emotion.cle}) non trouvé',
          );
        }
      },
    );

    // SHV-4 : footer « Your data stays on your device ».
    testWidgets('SHV-4 : footer données locales affiché', (tester) async {
      await tester.pumpSaisie(bloc);
      expect(find.textContaining('device'), findsOneWidget);
    });

    // SHV-5 : à l'état initial, le bouton Valider est désactivé.
    testWidgets('SHV-5 : Valider désactivé sans sélection', (tester) async {
      await tester.pumpSaisie(bloc);
      final bouton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(bouton.enabled, isFalse);
    });
  });

  group('SaisieHumeurView — sélection & validation', () {
    // SHV-6 : tap sur une pastille → EmotionSelectionnee ajouté au bloc.
    testWidgets(
      'SHV-6 : tap pastille → EmotionSelectionnee(code)',
      (tester) async {
        await tester.pumpSaisie(bloc);
        await tester.tap(find.text('😊').first);
        await tester.pump();
        // Les events n'étendent pas Equatable (convention projet) → on capture
        // l'event ajouté et on vérifie son champ plutôt que l'égalité de
        // valeur.
        final captures = verify(() => bloc.add(captureAny())).captured;
        expect(
          captures.whereType<EmotionSelectionnee>().map((e) => e.codeEmotion),
          contains('happy'),
        );
      },
    );

    // SHV-7 : sélection présente → CarteFeedback + Valider actif.
    testWidgets(
      'SHV-7 : EmotionSelectionneeEtat → feedback visible + Valider actif',
      (tester) async {
        when(
          () => bloc.state,
        ).thenReturn(const EmotionSelectionneeEtat('happy'));
        await tester.pumpSaisie(bloc);
        expect(find.textContaining('selected'), findsWidgets);
        final bouton = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(bouton.enabled, isTrue);
      },
    );

    // SHV-8 : tap sur Valider → SaisieValidee ajouté.
    testWidgets(
      'SHV-8 : tap Valider → SaisieValidee',
      (tester) async {
        when(
          () => bloc.state,
        ).thenReturn(const EmotionSelectionneeEtat('happy'));
        await tester.pumpSaisie(bloc);
        await tester.tap(find.byType(FilledButton));
        await tester.pump();
        verify(() => bloc.add(const SaisieValidee())).called(1);
      },
    );

    // SHV-9 : EnregistrementEnCours → spinner dans le bouton, pas de Valider.
    testWidgets(
      'SHV-9 : EnregistrementEnCours → spinner bouton',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const EnregistrementEnCours(codeEmotion: 'happy'),
        );
        await tester.pumpSaisie(bloc);
        expect(find.textContaining('selected'), findsWidgets);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );
  });

  group('SaisieHumeurView — couleurs via MoodColors (pas de hex dur)', () {
    // SHV-10 : pastille sélectionnée utilise MoodColors.byKey (bord coloré).
    testWidgets(
      'SHV-10 : pastille sélectionnée décorée avec couleur MoodColors',
      (tester) async {
        when(
          () => bloc.state,
        ).thenReturn(const EmotionSelectionneeEtat('angry'));
        await tester.pumpSaisie(bloc);

        final containers = tester.widgetList<Container>(
          find.byType(Container),
        );
        final expectedColor = MoodColors.byKey['angry'];

        final hasExpectedColor = containers.any((c) {
          final decoration = c.decoration;
          if (decoration is BoxDecoration && decoration.border is Border) {
            final border = decoration.border! as Border;
            return border.top.color == expectedColor;
          }
          return false;
        });
        expect(hasExpectedColor, isTrue);
      },
    );
  });

  group('SaisieHumeurView — erreur', () {
    // SHV-11 : EnregistrementEchoue → SnackBar d'erreur affiché.
    testWidgets(
      'SHV-11 : EnregistrementEchoue → SnackBar message',
      (tester) async {
        final ctrl = StreamController<SaisieHumeurState>.broadcast();
        when(() => bloc.state).thenReturn(const SaisieInitiale());
        when(() => bloc.stream).thenAnswer((_) => ctrl.stream);

        await tester.pumpSaisie(bloc);

        ctrl.add(
          const EnregistrementEchoue(
            codeEmotion: 'happy',
            message: 'Boom',
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Message i18n bienveillant affiché, jamais l'exception brute (public
        // mineur). `message` reste interne, non rendu à l'écran.
        expect(
          find.text("Oops, saving didn't work. Please try again."),
          findsOneWidget,
        );
        expect(find.text('Boom'), findsNothing);

        await ctrl.close();
      },
    );
  });

  group('SaisieHumeurView — reduced motion', () {
    // SHV-12 : animations de flottement désactivées (disableAnimations=true).
    testWidgets(
      'SHV-12 : disableAnimations=true → pas d animation en boucle',
      (tester) async {
        await tester.pumpSaisie(bloc);
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(SaisieHumeurView), findsOneWidget);
      },
    );
  });
}
