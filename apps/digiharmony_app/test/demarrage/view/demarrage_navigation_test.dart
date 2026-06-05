import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/accueil/accueil_page.dart';
import 'package:digiharmony_app/bienvenue/bienvenue_page.dart';
import 'package:digiharmony_app/demarrage/bloc/demarrage_bloc.dart';
import 'package:digiharmony_app/demarrage/view/demarrage_view.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDemarrageBloc extends MockBloc<DemarrageEvent, DemarrageState>
    implements DemarrageBloc {}

// La vue reçoit directement le bloc mocké : pas besoin de fournir
// AppDatabase / BienvenueCubit (warm-up + flag vivent dans le bloc).
// Reduced motion par défaut pour éviter les boucles d'animation infinies.
Widget _harnessNav({
  required Stream<DemarrageState> states,
  DemarrageState initialState = const DemarrageEnCours(),
}) {
  final bloc = _MockDemarrageBloc();
  whenListen<DemarrageState>(bloc, states, initialState: initialState);

  return BlocProvider<DemarrageBloc>.value(
    value: bloc,
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: DemarrageView(),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const DemarrageEnCours());
  });

  group('DemarrageView — navigation (NAV-1->NAV-5) —', () {
    testWidgets(
      'NAV-1 : PretPourBienvenue -> pushReplacement vers BienvenuePage',
      (tester) async {
        await tester.pumpWidget(
          _harnessNav(
            states: Stream.value(const DemarragePretPourBienvenue()),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(BienvenuePage), findsOneWidget);
        expect(find.byType(DemarrageView), findsNothing);
      },
    );

    testWidgets(
      'NAV-2 : PretPourAccueil -> pushReplacement vers AccueilPage',
      (tester) async {
        await tester.pumpWidget(
          _harnessNav(
            states: Stream.value(const DemarragePretPourAccueil()),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AccueilPage), findsOneWidget);
        expect(find.byType(DemarrageView), findsNothing);
      },
    );

    testWidgets(
      'NAV-3 : DemarrageErreur versBienvenue=true -> Bienvenue sans crash',
      (tester) async {
        await tester.pumpWidget(
          _harnessNav(
            states: Stream.value(
              const DemarrageErreur(versBienvenue: true),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(BienvenuePage), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'NAV-4 : après navigation, Demarrage plus dans la pile (no back)',
      (tester) async {
        await tester.pumpWidget(
          _harnessNav(
            states: Stream.value(const DemarragePretPourAccueil()),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AccueilPage), findsOneWidget);
        // pushReplacement : la pile ne contient plus DemarrageView.
        expect(find.byType(DemarrageView), findsNothing);
      },
    );

    testWidgets(
      'NAV-5 : DemarrageEnCours -> aucune navigation déclenchée',
      (tester) async {
        await tester.pumpWidget(
          _harnessNav(
            states: const Stream.empty(),
          ),
        );
        await tester.pump();
        expect(find.byType(DemarrageView), findsOneWidget);
        expect(find.byType(BienvenuePage), findsNothing);
        expect(find.byType(AccueilPage), findsNothing);
      },
    );
  });
}
