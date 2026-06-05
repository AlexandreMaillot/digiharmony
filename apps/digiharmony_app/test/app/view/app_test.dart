import 'package:digiharmony_app/accueil/accueil_page.dart';
import 'package:digiharmony_app/app/app.dart';
import 'package:digiharmony_app/bienvenue/bienvenue_cubit.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/locale/locale_cubit.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/hydrated_storage.dart';

void main() {
  group('App', () {
    late AppDatabase database;

    setUp(() {
      initMockHydratedStorage();
      database = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    testWidgets('APP-1/APP-2 : thème foncé câblé (AppTheme.dark, dark mode)',
        (tester) async {
      await tester.pumpWidget(App(database: database));
      await tester.pump();
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme, AppTheme.dark);
      expect(app.darkTheme, AppTheme.dark);
      expect(app.themeMode, ThemeMode.dark);
    });

    testWidgets('APP-3 : RepositoryProvider<AppDatabase> accessible',
        (tester) async {
      await tester.pumpWidget(App(database: database));
      await tester.pump();
      final ctx = tester.element(find.byType(AccueilPage));
      expect(ctx.read<AppDatabase>(), same(database));
    });

    testWidgets('APP-4 : LocaleCubit et BienvenueCubit fournis',
        (tester) async {
      await tester.pumpWidget(App(database: database));
      await tester.pump();
      final ctx = tester.element(find.byType(AccueilPage));
      expect(ctx.read<LocaleCubit>(), isA<LocaleCubit>());
      expect(ctx.read<BienvenueCubit>(), isA<BienvenueCubit>());
    });

    testWidgets('APP-5 : LocaleCubit(fr) -> MaterialApp.locale == fr',
        (tester) async {
      final cubit = LocaleCubit()..setLocale(const Locale('fr'));
      await tester.pumpWidget(
        BlocProvider<LocaleCubit>.value(
          value: cubit,
          child: const AppView(),
        ),
      );
      await tester.pump();
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.locale, const Locale('fr'));
    });

    testWidgets('APP-6 : délégués i18n + 8 langues supportées',
        (tester) async {
      await tester.pumpWidget(App(database: database));
      await tester.pump();
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(
        app.localizationsDelegates,
        contains(AppLocalizations.delegate),
      );
      expect(app.supportedLocales.length, 8);
    });
  });
}
