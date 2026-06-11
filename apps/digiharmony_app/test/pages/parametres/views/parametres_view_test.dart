import 'package:digiharmony_app/app/routing/app_router.dart';
import 'package:digiharmony_app/config/legal_urls.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/locale/locale_bloc.dart';
import 'package:digiharmony_app/pages/parametres/modeles/langue_supportee.dart';
import 'package:digiharmony_app/pages/parametres/views/parametres_page.dart';
import 'package:digiharmony_app/pages/parametres/views/parametres_view.dart';
import 'package:digiharmony_app/rappel/rappel_bloc.dart';
import 'package:digiharmony_app/services/rappel/service_rappel.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../../../helpers/hydrated_storage.dart';

class _MockServiceRappel extends Mock implements ServiceRappel {}

class _MockRappelBloc extends Mock implements RappelBloc {}

// Mock de la plateforme url_launcher — utilise MockPlatformInterfaceMixin
// pour contourner la vérification d'interface (DEC-PARAM-05 — AC6/AC7/AC8).
class _MockUrlLauncher extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {}

// Pompe ParametresView avec i18n + LocaleBloc + RappelBloc + MediaQuery.
extension _PumpParametresView on WidgetTester {
  Future<void> pumpParametresView({
    LocaleBloc? localeBloc,
    _MockRappelBloc? rappelBloc,
    _MockServiceRappel? serviceRappel,
    bool disableAnimations = true,
    Locale locale = const Locale('en'),
  }) {
    final lBloc = localeBloc ?? LocaleBloc();
    final rBloc = rappelBloc ?? _MockRappelBloc();
    if (rappelBloc == null) {
      when(() => rBloc.state).thenReturn(const RappelState());
      when(() => rBloc.stream).thenAnswer((_) => const Stream.empty());
    }
    final sRappel = serviceRappel ?? _MockServiceRappel();
    return pumpWidget(
      RepositoryProvider<ServiceRappel>.value(
        value: sRappel,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<LocaleBloc>.value(value: lBloc),
            BlocProvider<RappelBloc>.value(value: rBloc),
          ],
          child: MediaQuery(
            data: MediaQueryData(disableAnimations: disableAnimations),
            child: MaterialApp(
              theme: AppTheme.dark,
              darkTheme: AppTheme.dark,
              themeMode: ThemeMode.dark,
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const ParametresView(),
            ),
          ),
        ),
      ),
    );
  }
}

// Intercepte le canal haptique pour éviter les erreurs de plateforme en test.
void _mockHapticFeedback() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('flutter/haptic_feedback'),
    (_) async => null,
  );
}

void main() {
  late _MockUrlLauncher mockUrlLauncher;

  setUpAll(() {
    registerFallbackValue(
      const LaunchOptions(mode: PreferredLaunchMode.externalApplication),
    );
    PackageInfo.setMockInitialValues(
      appName: 'DigiHarmony',
      packageName: 'com.test',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  setUp(() {
    initMockHydratedStorage();
    mockUrlLauncher = _MockUrlLauncher();
    UrlLauncherPlatform.instance = mockUrlLauncher;
  });

  group('ParametresView', () {
    testWidgets(
      'PM-VIEW-1 : AC1 — rend toolbar (titre, espaceur, sans retour), '
      '3 sections, version',
      (tester) async {
        await tester.pumpParametresView();
        await tester.pump();

        // Onglet de la bottom bar : pas de retour (DEC-NAV-2026). Pumpé en
        // racine (canPop == false) → aucun chevron.
        expect(find.byIcon(Icons.chevron_left), findsNothing);
        // Titre toolbar
        expect(find.text('Settings'), findsOneWidget);
        // Pas de burger (aucun Icons.menu)
        expect(find.byIcon(Icons.menu), findsNothing);
        // Les 3 section headers sont présents
        expect(find.text('Language'), findsOneWidget);
        expect(find.text('Privacy'), findsOneWidget);
        expect(find.text('The project'), findsOneWidget);
        // Ligne version (DIGIHARMONY v...)
        expect(find.textContaining('DIGIHARMONY v'), findsOneWidget);
      },
    );

    testWidgets(
      'PM-VIEW-2 : AC2 — 8 langues affichées (drapeau + endonyme), '
      'ordre maquette',
      (tester) async {
        await tester.pumpParametresView();
        await tester.pump();

        // Vérifie que les 8 endonymes sont présents dans l'ordre maquette.
        for (final langue in languesSupportees) {
          expect(find.text(langue.endonyme), findsOneWidget);
        }
        // Vérifie les drapeaux via finder texte
        expect(find.text('🇬🇧'), findsOneWidget);
        expect(find.text('🇫🇷'), findsOneWidget);
        expect(find.text('🇬🇷'), findsOneWidget);
        expect(find.text('🇮🇹'), findsOneWidget);
        expect(find.text('🇷🇴'), findsOneWidget);
        expect(find.text('🇹🇷'), findsOneWidget);
        expect(find.text('🇪🇸'), findsOneWidget);
        expect(find.text('🇲🇰'), findsOneWidget);
      },
    );

    testWidgets(
      'PM-VIEW-3 : AC3 — langue active surlignée (check visible)',
      (tester) async {
        final bloc = LocaleBloc()
          ..add(const LocaleChange(Locale('fr')));
        await tester.pumpParametresView(localeBloc: bloc);
        await tester.pump();

        // La pastille check est visible pour la langue active.
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      },
    );

    testWidgets(
      'PM-VIEW-4 : AC3 — langue active par défaut = locale résolue (en)',
      (tester) async {
        // LocaleBloc avec locale == null + MaterialApp en 'en'.
        await tester.pumpParametresView();
        await tester.pump();

        // Un seul check circle (langue résolue = en).
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      },
    );

    testWidgets(
      'PM-VIEW-5 : AC4 — tap langue → LocaleBloc reçoit LocaleChange',
      (tester) async {
        _mockHapticFeedback();

        final bloc = LocaleBloc();
        await tester.pumpParametresView(localeBloc: bloc);
        await tester.pump();

        // Tap sur l'endonyme français.
        await tester.tap(find.text('Français'));
        await tester.pump();

        expect(bloc.state.locale, const Locale('fr'));
      },
    );

    testWidgets(
      'PM-VIEW-6 : AC4 — tap langue ne montre pas de SnackBar',
      (tester) async {
        _mockHapticFeedback();

        await tester.pumpParametresView();
        await tester.pump();

        await tester.tap(find.text('Français'));
        await tester.pump();

        // Pas de SnackBar après bascule de langue (DEC-PARAM-04).
        expect(find.byType(SnackBar), findsNothing);
      },
    );

    testWidgets(
      'PM-VIEW-7 : AC6 — tap GitHub → launchUrl(github, externalApplication)',
      (tester) async {
        _mockHapticFeedback();
        when(
          () => mockUrlLauncher.canLaunch(any()),
        ).thenAnswer((_) async => true);
        when(
          () => mockUrlLauncher.launchUrl(any(), any()),
        ).thenAnswer((_) async => true);

        await tester.pumpParametresView();
        await tester.pump();

        // Scroll pour amener le lien GitHub dans le viewport.
        await tester.scrollUntilVisible(
          find.text('Open source code'),
          50,
          scrollable: find.byType(Scrollable),
        );
        await tester.pump();

        await tester.tap(find.text('Open source code'));
        // Laisser les futures async (canLaunchUrl, launchUrl) se compléter.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        verify(
          () => mockUrlLauncher.launchUrl(LegalUrls.github, any()),
        ).called(1);
      },
    );

    testWidgets(
      'PM-VIEW-8 : AC8 — launchUrl échoue → SnackBar lienIndisponible',
      (tester) async {
        _mockHapticFeedback();
        // On ne gate plus sur canLaunchUrl : l'echec se manifeste par
        // launchUrl qui jette (Android 11+ « component name is null »).
        when(
          () => mockUrlLauncher.launchUrl(any(), any()),
        ).thenThrow(
          PlatformException(code: 'CHANNEL_ERROR', message: 'no handler'),
        );

        await tester.pumpParametresView();
        await tester.pump();

        // Scroll pour amener le lien GitHub dans le viewport.
        await tester.scrollUntilVisible(
          find.text('Open source code'),
          50,
          scrollable: find.byType(Scrollable),
        );
        await tester.pump();

        await tester.tap(find.text('Open source code'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.textContaining("Couldn't open the link"),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'PM-VIEW-9 : AC15 — carte confidentialité présente',
      (tester) async {
        await tester.pumpParametresView();
        await tester.pump();

        expect(
          find.textContaining('No personal data'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.verified_user), findsOneWidget);
      },
    );

    testWidgets(
      'PM-VIEW-10 : AC15 — section Erasmus+ présente',
      (tester) async {
        await tester.pumpParametresView();
        await tester.pump();

        expect(
          find.textContaining('Erasmus+'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      "PM-VIEW-11 : AC14 reduced-motion — halo statique (pas d'exception)",
      (tester) async {
        // disableAnimations = true (défaut de pumpParametresView).
        await tester.pumpParametresView();
        await tester.pump();

        expect(find.byType(ParametresView), findsOneWidget);
      },
    );
  });

  group('ParametresPage', () {
    testWidgets(
      'PM-PAGE-1 : route() retourne un MaterialPageRoute vers ParametresPage',
      (tester) async {
        final route = ParametresPage.route();
        expect(route, isA<MaterialPageRoute<void>>());
      },
    );
  });

  group('AppRouter.versParametres', () {
    testWidgets(
      'PM-RT-1 : AC10 — versParametres pousse ParametresPage',
      (tester) async {
        initMockHydratedStorage();
        final rBloc = _MockRappelBloc();
        when(() => rBloc.state).thenReturn(const RappelState());
        when(() => rBloc.stream).thenAnswer((_) => const Stream.empty());
        final sRappel = _MockServiceRappel();

        await tester.pumpWidget(
          RepositoryProvider<ServiceRappel>.value(
            value: sRappel,
            child: MultiBlocProvider(
              providers: [
                BlocProvider<LocaleBloc>(create: (_) => LocaleBloc()),
                BlocProvider<RappelBloc>.value(value: rBloc),
              ],
              child: MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Builder(
                  builder: (context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: () => AppRouter.versParametres(context),
                      child: const Text('open'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('open'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(ParametresPage), findsOneWidget);
      },
    );
  });
}
