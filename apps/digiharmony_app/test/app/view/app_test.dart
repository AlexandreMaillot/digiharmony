import 'package:digiharmony_app/app/app.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/locale/locale_bloc.dart';
import 'package:digiharmony_app/pages/bienvenue/bloc/bienvenue_bloc.dart';
import 'package:digiharmony_app/pages/demarrage/views/demarrage_view.dart';
import 'package:digiharmony_app/pages/soutien/bloc/soutien_bloc.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/hydrated_storage.dart';

class _MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  group('App', () {
    late _MockAppDatabase database;

    setUpAll(() {
      registerFallbackValue(DateTime(2026));
    });

    setUp(() {
      initMockHydratedStorage();
      database = _MockAppDatabase();
      when(() => database.conseilDuJour(any())).thenAnswer(
        (_) async => const Conseil(
        id: 1,
        cleConseil: 'tipDay01',
        typeCarte: 'rappel',
        accentChrome: 'primary',
        ordre: 1,
      ),
      );
      when(
        () => database.observerDerniereHumeurDuJour(),
      ).thenAnswer((_) => const Stream<EntreeHumeur?>.empty());
      when(
        () => database.compterSaisiesNegativesConsecutives(),
      ).thenAnswer((_) async => 0);
      TestWidgetsFlutterBinding
          .instance
          .platformDispatcher
          .accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
        disableAnimations: true,
      );
    });

    tearDown(() {
      TestWidgetsFlutterBinding.instance.platformDispatcher
          .clearAccessibilityFeaturesTestValue();
    });

    testWidgets('APP-1/APP-2 : thème foncé câblé (AppTheme.dark, dark mode)', (
      tester,
    ) async {
      await tester.pumpWidget(App(database: database));
      await tester.pump();
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme, AppTheme.dark);
      expect(app.darkTheme, AppTheme.dark);
      expect(app.themeMode, ThemeMode.dark);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('APP-3 : RepositoryProvider<AppDatabase> accessible', (
      tester,
    ) async {
      await tester.pumpWidget(App(database: database));
      await tester.pump();
      final ctx = tester.element(find.byType(DemarrageView));
      expect(ctx.read<AppDatabase>(), same(database));
      // Vide le timer du délai minimal pour ne pas laisser de Timer pendant.
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('APP-4 : LocaleBloc et BienvenueBloc fournis', (
      tester,
    ) async {
      await tester.pumpWidget(App(database: database));
      await tester.pump();
      final ctx = tester.element(find.byType(DemarrageView));
      expect(ctx.read<LocaleBloc>(), isA<LocaleBloc>());
      expect(ctx.read<BienvenueBloc>(), isA<BienvenueBloc>());
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets(
      'APP-5 : LocaleBloc(LocaleChange(fr)) -> MaterialApp.locale == fr',
      (tester) async {
        final bloc = LocaleBloc()..add(const LocaleChange(Locale('fr')));
        await tester.pumpWidget(
          MultiRepositoryProvider(
            providers: [
              RepositoryProvider<AppDatabase>.value(value: database),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider<LocaleBloc>.value(value: bloc),
                BlocProvider<BienvenueBloc>(create: (_) => BienvenueBloc()),
                BlocProvider<SoutienBloc>(create: (_) => SoutienBloc()),
              ],
              child: const AppView(),
            ),
          ),
        );
        await tester.pump();
        final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(app.locale, const Locale('fr'));
        // Vide le timer du délai minimal (DemarragePage est le home).
        await tester.pump(const Duration(seconds: 3));
      },
    );

    testWidgets('APP-6 : délégués i18n + 8 langues supportées', (tester) async {
      await tester.pumpWidget(App(database: database));
      await tester.pump();
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(
        app.localizationsDelegates,
        contains(AppLocalizations.delegate),
      );
      expect(app.supportedLocales.length, 8);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets(
      'APP-7 : suit la langue du téléphone si supportée, sinon repli anglais',
      (tester) async {
        await tester.pumpWidget(App(database: database));
        await tester.pump();
        final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
        final resolve = app.localeListResolutionCallback;
        expect(resolve, isNotNull);

        // Langue du téléphone supportée -> on la suit.
        expect(
          resolve!([const Locale('es')], app.supportedLocales),
          const Locale('es'),
        );
        // Langue du téléphone non supportée -> repli ANGLAIS (pas 'el', 1er
        // de la liste en ordre alphabétique).
        expect(
          resolve([const Locale('de')], app.supportedLocales),
          const Locale('en'),
        );
        // Préférences multiples : 1re supportée gagne.
        expect(
          resolve(
            [const Locale('de'), const Locale('fr')],
            app.supportedLocales,
          ),
          const Locale('fr'),
        );
        // Aucune préférence (null) -> repli anglais.
        expect(resolve(null, app.supportedLocales), const Locale('en'));
        await tester.pump(const Duration(seconds: 3));
      },
    );
  });
}
