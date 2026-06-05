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
        expect(find.textContaining('single tap'), findsWidgets);
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
  });

  group('SaisieHumeurView — feedback sélection', () {
    // SHV-6 : état EnregistrementEnCours → CarteFeedback visible.
    testWidgets(
      'SHV-6 : EnregistrementEnCours → CarteFeedback avec libellé + spinner',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const EnregistrementEnCours(codeEmotion: 'happy'),
        );
        await tester.pumpSaisie(bloc);
        expect(find.textContaining('selected'), findsWidgets);
        expect(find.textContaining('Saving'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    // SHV-7 : état EnregistrementReussi → pas de spinner.
    testWidgets(
      'SHV-7 : EnregistrementReussi → CarteFeedback sans spinner',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const EnregistrementReussi(codeEmotion: 'calm'),
        );
        when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
        await tester.pumpSaisie(bloc);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );
  });

  group('SaisieHumeurView — couleurs via MoodColors (pas de hex dur)', () {
    // SHV-8 : pastille sélectionnée utilise MoodColors.byKey.
    testWidgets(
      'SHV-8 : pastille sélectionnée décorée avec couleur MoodColors',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const EnregistrementReussi(codeEmotion: 'angry'),
        );
        when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
        await tester.pumpSaisie(bloc);

        final containers = tester.widgetList<Container>(
          find.byType(Container),
        );
        final expectedColor = MoodColors.byKey['angry'];

        final hasExpectedColor = containers.any((c) {
          final decoration = c.decoration;
          if (decoration is BoxDecoration) {
            if (decoration.border is Border) {
              final border = decoration.border! as Border;
              return border.top.color == expectedColor;
            }
          }
          return false;
        });
        expect(hasExpectedColor, isTrue);
      },
    );
  });

  group('SaisieHumeurView — reduced motion', () {
    // SHV-9 : animations de flottement désactivées avec disableAnimations=true.
    testWidgets(
      'SHV-9 : disableAnimations=true → pas d animation en boucle',
      (tester) async {
        // disableAnimations=true est la valeur par défaut de pumpSaisie.
        await tester.pumpSaisie(bloc);
        await tester.pump(const Duration(seconds: 1));
        // Aucune exception de contrôleur d'animation non terminé = OK.
        expect(find.byType(SaisieHumeurView), findsOneWidget);
      },
    );
  });

  group('SaisieHumeurView — snackbar undo', () {
    // SHV-10 : EnregistrementReussi → SnackBar visible avec action Undo.
    testWidgets(
      'SHV-10 : EnregistrementReussi → SnackBar Undo visible',
      (tester) async {
        final ctrl = StreamController<SaisieHumeurState>.broadcast();
        when(() => bloc.state).thenReturn(const SaisieInitiale());
        when(() => bloc.stream).thenAnswer((_) => ctrl.stream);

        await tester.pumpSaisie(bloc);

        ctrl.add(const EnregistrementReussi(codeEmotion: 'happy'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.textContaining('saved'), findsOneWidget);
        expect(find.textContaining('Undo'), findsOneWidget);

        await ctrl.close();
      },
    );

    // SHV-11 : tap Undo → SaisieAnnulee ajouté.
    testWidgets(
      'SHV-11 : tap Undo → SaisieAnnulee ajouté au bloc',
      (tester) async {
        final ctrl = StreamController<SaisieHumeurState>.broadcast();
        when(() => bloc.state).thenReturn(const SaisieInitiale());
        when(() => bloc.stream).thenAnswer((_) => ctrl.stream);

        await tester.pumpSaisie(bloc);

        ctrl.add(const EnregistrementReussi(codeEmotion: 'happy'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(find.textContaining('Undo'));
        await tester.pump();

        verify(() => bloc.add(const SaisieAnnulee())).called(1);

        await ctrl.close();
      },
    );
  });
}
