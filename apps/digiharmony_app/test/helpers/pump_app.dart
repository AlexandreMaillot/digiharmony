import 'package:digiharmony_app/data/local/depot_stats_bien_etre.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/locale/locale_bloc.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:digiharmony_app/voix_off/bloc/voix_off_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

/// Stub de stockage HydratedBloc pour les tests (pas d'I/O disque).
class MockHydratedStorage extends Mock implements Storage {}

/// Fake repository de stats (aucune persistance réelle).
class FakeDepotStatsBienEtre implements DepotStatsBienEtre {
  /// Liste des exercices enregistrés comme terminés.
  final List<String> recorded = <String>[];

  @override
  Future<void> enregistrerSeance(String exerciceId) async {
    recorded.add(exerciceId);
  }

  @override
  Stream<int> observerNombreSeances(String exerciceId) =>
      Stream<int>.value(recorded.where((e) => e == exerciceId).length);
}

extension PumpApp on WidgetTester {
  /// Monte [widget] avec les providers globaux (VoixOff + stats repo),
  /// le thème et les localisations de l'app.
  Future<void> pumpApp(
    Widget widget, {
    DepotStatsBienEtre? statsRepository,
    VoixOffBloc? voiceoverBloc,
    LocaleBloc? localeBloc,
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
            BlocProvider<LocaleBloc>(
              create: (_) => localeBloc ?? LocaleBloc(),
            ),
          ],
          child: BlocBuilder<LocaleBloc, LocaleState>(
            builder: (context, state) {
              return MaterialApp(
                theme: AppTheme.dark,
                locale: state.locale,
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
