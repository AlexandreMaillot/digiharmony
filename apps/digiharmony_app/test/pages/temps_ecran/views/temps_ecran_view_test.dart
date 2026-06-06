import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/temps_ecran/bloc/temps_ecran_bloc.dart';
import 'package:digiharmony_app/pages/temps_ecran/modeles/resume_temps_ecran.dart';
import 'package:digiharmony_app/pages/temps_ecran/views/temps_ecran_view.dart';
import 'package:digiharmony_app/pages/temps_ecran/widgets/vue_permission.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBloc extends MockBloc<TempsEcranEvent, TempsEcranState>
    implements TempsEcranBloc {}

extension on WidgetTester {
  Future<void> pumpVue(TempsEcranBloc bloc) {
    return pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          theme: AppTheme.dark,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<TempsEcranBloc>.value(
            value: bloc,
            child: const TempsEcranView(),
          ),
        ),
      ),
    );
  }
}

void main() {
  late _MockBloc bloc;

  setUp(() => bloc = _MockBloc());

  void stub(TempsEcranState state) {
    whenListen(
      bloc,
      const Stream<TempsEcranState>.empty(),
      initialState: state,
    );
  }

  testWidgets('AC1 : permissionRequise → VuePermission + CTA', (tester) async {
    stub(const TempsEcranState(status: TempsEcranStatus.permissionRequise));
    await tester.pumpVue(bloc);
    await tester.pump();
    expect(find.byType(VuePermission), findsOneWidget);
    expect(find.text('Enable access in settings'), findsOneWidget);
  });

  testWidgets('AC4 : pret → total + section apps', (tester) async {
    const resume = ResumeTempsEcran(
      total: Duration(minutes: 40),
      topApps: [
        UsageAppVue(
          nomApp: 'Instagram',
          packageName: 'com.instagram.android',
          duree: Duration(minutes: 30),
          fractionDuTotal: 0.75,
        ),
      ],
      autres: Duration(minutes: 10),
    );
    stub(
      const TempsEcranState(
        status: TempsEcranStatus.pret,
        resume: resume,
      ),
    );
    await tester.pumpVue(bloc);
    await tester.pump();
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Your apps'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    // Bucket « autres ».
    expect(find.text('Others'), findsOneWidget);
  });

  testWidgets('AC5 : vide → message bienveillant', (tester) async {
    stub(const TempsEcranState(status: TempsEcranStatus.vide));
    await tester.pumpVue(bloc);
    await tester.pump();
    expect(find.text('No data for today yet'), findsOneWidget);
  });

  testWidgets('AC6 : indisponible (iOS) → état dégradé, pas de crash', (
    tester,
  ) async {
    stub(const TempsEcranState(status: TempsEcranStatus.indisponible));
    await tester.pumpVue(bloc);
    await tester.pump();
    expect(
      find.text('Screen time is only available on Android for now.'),
      findsOneWidget,
    );
  });

  testWidgets('AC7 : erreur → message + Réessayer', (tester) async {
    stub(const TempsEcranState(status: TempsEcranStatus.erreur));
    await tester.pumpVue(bloc);
    await tester.pump();
    expect(find.text("Can't read screen time right now."), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('AC9 : footer « données locales » présent', (tester) async {
    stub(const TempsEcranState(status: TempsEcranStatus.vide));
    await tester.pumpVue(bloc);
    await tester.pump();
    expect(
      find.text('This data stays on your device and is never sent.'),
      findsOneWidget,
    );
  });

  testWidgets('AC2 : tap CTA permission → ajoute PermissionDemandee', (
    tester,
  ) async {
    stub(const TempsEcranState(status: TempsEcranStatus.permissionRequise));
    await tester.pumpVue(bloc);
    await tester.pump();
    await tester.tap(find.text('Enable access in settings'));
    await tester.pump();
    verify(() => bloc.add(const TempsEcranPermissionDemandee())).called(1);
  });
}
