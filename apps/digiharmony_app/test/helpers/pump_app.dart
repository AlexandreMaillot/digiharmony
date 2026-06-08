import 'package:digiharmony_app/database/depot_stats_bien_etre.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/langue/langue_cubit.dart';
import 'package:digiharmony_app/theme/theme_application.dart';
import 'package:digiharmony_app/voix_off/bloc/voix_off_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

/// Stub de stockage HydratedBloc pour les tests (pas d'I/O disque).
class MockHydratedStorage extends Mock implements Storage {}

/// Fake repository de stats (aucune persistance reelle).
class FakeDepotStatsBienEtre implements DepotStatsBienEtre {
  /// Liste des exercices enregistres comme termines.
  final List<String> recorded = <String>[];

  @override
  Future<void> recordCompletedSession(String exerciseId) async {
    recorded.add(exerciseId);
  }

  @override
  Stream<int> watchCompletedCount(String exerciseId) =>
      Stream<int>.value(recorded.where((e) => e == exerciseId).length);
}

extension PumpApp on WidgetTester {
  /// Monte [widget] avec les providers globaux (VoixOff + stats repo),
  /// le theme et les localisations de l'app.
  Future<void> pumpApp(
    Widget widget, {
    DepotStatsBienEtre? statsRepository,
    VoixOffBloc? voiceoverBloc,
    LangueCubit? langueCubit,
  }) {
    final storage = MockHydratedStorage();
    when(() => storage.read(any())).thenReturn(null);
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    when(() => storage.delete(any())).thenAnswer((_) async {});
    when(storage.clear).thenAnswer((_) async {});
    HydratedBloc.storage = storage;

    return pumpWidget(
      RepositoryProvider<DepotStatsBienEtre>.value(
        value: statsRepository ?? FakeDepotStatsBienEtre(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<VoixOffBloc>(
              create: (_) => voiceoverBloc ?? VoixOffBloc(),
            ),
            BlocProvider<LangueCubit>(
              create: (_) => langueCubit ?? LangueCubit(),
            ),
          ],
          child: BlocBuilder<LangueCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp(
                theme: ThemeApplication.themeData,
                locale: locale,
                localizationsDelegates:
                    AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: widget,
              );
            },
          ),
        ),
      ),
    );
  }
}
