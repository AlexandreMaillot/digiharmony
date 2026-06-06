import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/temps_ecran/bloc/temps_ecran_bloc.dart';
import 'package:digiharmony_app/pages/temps_ecran/modeles/resume_temps_ecran.dart';
import 'package:digiharmony_app/pages/temps_ecran/services/service_temps_ecran.dart';
import 'package:digiharmony_app/pages/temps_ecran/views/temps_ecran_view.dart';
import 'package:digiharmony_app/pages/temps_ecran/widgets/vue_autorisation_ios.dart';
import 'package:digiharmony_app/pages/temps_ecran/widgets/vue_permission.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBloc extends MockBloc<TempsEcranEvent, TempsEcranState>
    implements TempsEcranBloc {}

class _MockService extends Mock implements ServiceTempsEcran {}

extension on WidgetTester {
  Future<void> pumpVue(
    TempsEcranBloc bloc, {
    ServiceTempsEcran? service,
  }) {
    final svc = service ?? (_MockService()..stubAndroid());
    return pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          theme: AppTheme.dark,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RepositoryProvider<ServiceTempsEcran>.value(
            value: svc,
            child: BlocProvider<TempsEcranBloc>.value(
              value: bloc,
              child: const TempsEcranView(),
            ),
          ),
        ),
      ),
    );
  }
}

extension on _MockService {
  /// Stub Android defaults (rapportEmbarque = false).
  void stubAndroid() {
    when(() => rapportEmbarque).thenReturn(false);
    when(() => plateformeSupportee).thenReturn(true);
  }

  /// Stub iOS defaults (rapportEmbarque = true).
  void stubIos() {
    when(() => rapportEmbarque).thenReturn(true);
    when(() => plateformeSupportee).thenReturn(true);
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

  testWidgets('AC4 : pret → jauge + intro + actions (maquette Banani)', (
    tester,
  ) async {
    const resume = ResumeTempsEcran(
      total: Duration(minutes: 40),
      topApps: [],
      autres: Duration.zero,
    );
    stub(
      const TempsEcranState(
        status: TempsEcranStatus.pret,
        resume: resume,
      ),
    );
    await tester.pumpVue(bloc);
    await tester.pump();
    // Intro.
    expect(find.text('Here is your screen time today'), findsOneWidget);
    // Label sous la jauge.
    expect(find.text('today'), findsOneWidget);
    // Label semaine.
    expect(find.text('this week'), findsOneWidget);
    // Section actions.
    expect(find.text('WHAT NOW?'), findsOneWidget);
    expect(find.text('Take a break'), findsOneWidget);
    expect(find.text('Silence my notifications'), findsOneWidget);
    // Top-apps ne s'affichent plus.
    expect(find.text('Your apps'), findsNothing);
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

  testWidgets(
      'AC9 : carte confidentialité « données locales » présente en état pret',
      (tester) async {
    const resume = ResumeTempsEcran(
      total: Duration(minutes: 40),
      topApps: [],
      autres: Duration.zero,
    );
    stub(
      const TempsEcranState(
        status: TempsEcranStatus.pret,
        resume: resume,
      ),
    );
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

  // ── iOS path tests ─────────────────────────────────────────────────────────

  group('iOS (rapportEmbarque = true)', () {
    late _MockService iosService;

    setUp(() {
      iosService = _MockService()..stubIos();
    });

    testWidgets(
        'iOS-AC1 : permissionRequise → VueAutorisationIos (pas VuePermission)',
        (tester) async {
      stub(const TempsEcranState(status: TempsEcranStatus.permissionRequise));
      await tester.pumpVue(bloc, service: iosService);
      await tester.pump();
      expect(find.byType(VueAutorisationIos), findsOneWidget);
      expect(find.byType(VuePermission), findsNothing);
      expect(find.text('Allow'), findsOneWidget);
    });

    testWidgets(
        'iOS-AC2 : tap CTA autorisation iOS → ajoute PermissionDemandee',
        (tester) async {
      stub(const TempsEcranState(status: TempsEcranStatus.permissionRequise));
      await tester.pumpVue(bloc, service: iosService);
      await tester.pump();
      await tester.tap(find.text('Allow'));
      await tester.pump();
      verify(() => bloc.add(const TempsEcranPermissionDemandee())).called(1);
    });

    testWidgets(
        'iOS-AC3 : pret → footer données système affiché (pas VueResume)',
        (tester) async {
      stub(const TempsEcranState(status: TempsEcranStatus.pret));
      await tester.pumpVue(bloc, service: iosService);
      await tester.pump();
      expect(
        find.text("This data stays in your iPhone; the app can't see it."),
        findsOneWidget,
      );
    });

    testWidgets(
        'iOS-AC4 : Android VuePermission absent sur permissionRequise iOS',
        (tester) async {
      stub(const TempsEcranState(status: TempsEcranStatus.permissionRequise));
      await tester.pumpVue(bloc, service: iosService);
      await tester.pump();
      expect(find.text('Enable access in settings'), findsNothing);
    });
  });
}
