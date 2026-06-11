import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/parametres/widgets/section_rappel.dart';
import 'package:digiharmony_app/rappel/rappel_bloc.dart';
import 'package:digiharmony_app/services/rappel/service_rappel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRappelBloc extends Mock implements RappelBloc {}

class _MockServiceRappel extends Mock implements ServiceRappel {}

void main() {
  late _MockRappelBloc rappelBloc;
  late _MockServiceRappel serviceRappel;

  setUp(() {
    rappelBloc = _MockRappelBloc();
    serviceRappel = _MockServiceRappel();
    when(() => rappelBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildSubject({RappelState state = const RappelState()}) {
    when(() => rappelBloc.state).thenReturn(state);
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<ServiceRappel>.value(value: serviceRappel),
          ],
          child: BlocProvider<RappelBloc>.value(
            value: rappelBloc,
            child: const SectionRappel(),
          ),
        ),
      ),
    );
  }

  testWidgets(
    "affiche le toggle dans l'état désactivé par défaut",
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Le switch doit être présent
      expect(find.byType(SwitchListTile), findsOneWidget);

      // Le sélecteur d'heure est masqué quand actif=false
      expect(find.byIcon(Icons.access_time_outlined), findsNothing);
    },
  );

  testWidgets(
    "affiche le sélecteur d'heure quand actif=true",
    (tester) async {
      await tester.pumpWidget(
        buildSubject(
          state: const RappelState(actif: true),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.access_time_outlined), findsOneWidget);
    },
  );

  testWidgets(
    'toggle ON → navigue vers la page priming (pas de permission directe)',
    (tester) async {
      when(() => rappelBloc.state).thenReturn(const RappelState());
      when(
        () => rappelBloc.add(const RappelDesactive()),
      ).thenReturn(null);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Activer le toggle
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      // La permission ne doit pas avoir été demandée directement
      verifyNever(() => serviceRappel.demanderPermission());
    },
  );

  testWidgets(
    'toggle OFF → dispatch RappelDesactive',
    (tester) async {
      when(
        () => rappelBloc.add(const RappelDesactive()),
      ).thenReturn(null);

      await tester.pumpWidget(
        buildSubject(
          state: const RappelState(actif: true),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();

      verify(() => rappelBloc.add(const RappelDesactive())).called(1);
    },
  );

  testWidgets(
    'affiche le message de permission refusée quand permissionRefusee=true',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(
          state: const RappelState(permissionRefusee: true),
        ),
      );
      await tester.pump();

      // Le message doit être présent
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    },
  );
}
