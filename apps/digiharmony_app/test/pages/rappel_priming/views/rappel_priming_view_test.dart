import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/rappel_priming/views/rappel_priming_view.dart';
import 'package:digiharmony_app/rappel/rappel_bloc.dart';
import 'package:digiharmony_app/services/rappel/service_rappel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockServiceRappel extends Mock implements ServiceRappel {}

class _MockRappelBloc extends Mock implements RappelBloc {}

void main() {
  late _MockServiceRappel serviceRappel;
  late _MockRappelBloc rappelBloc;

  setUp(() {
    serviceRappel = _MockServiceRappel();
    rappelBloc = _MockRappelBloc();
    when(() => rappelBloc.state).thenReturn(const RappelState());
    when(() => rappelBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildSubject() {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ServiceRappel>.value(value: serviceRappel),
        ],
        child: BlocProvider<RappelBloc>.value(
          value: rappelBloc,
          child: const RappelPrimingView(),
        ),
      ),
    );
  }

  testWidgets(
    'ne demande PAS la permission au montage',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      // demanderPermission ne doit pas avoir été appelé au simple montage.
      verifyNever(() => serviceRappel.demanderPermission());
    },
  );

  testWidgets(
    'tap CTA activer + permission accordée → RappelActivationDemandee + pop',
    (tester) async {
      when(() => serviceRappel.demanderPermission())
          .thenAnswer((_) async => true);
      when(
        () => rappelBloc.add(const RappelActivationDemandee()),
      ).thenReturn(null);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Trouver le bouton primaire par son texte (EN fallback).
      final cta = find.text('Enable reminder');
      expect(cta, findsOneWidget);

      await tester.tap(cta);
      await tester.pumpAndSettle();

      verify(() => serviceRappel.demanderPermission()).called(1);
      verify(() => rappelBloc.add(const RappelActivationDemandee())).called(1);
    },
  );

  testWidgets(
    'tap CTA activer + permission refusée → RappelPermissionRefusee',
    (tester) async {
      when(() => serviceRappel.demanderPermission())
          .thenAnswer((_) async => false);
      when(
        () => rappelBloc.add(const RappelPermissionRefusee()),
      ).thenReturn(null);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.tap(find.text('Enable reminder'));
      await tester.pumpAndSettle();

      verify(() => serviceRappel.demanderPermission()).called(1);
      verify(() => rappelBloc.add(const RappelPermissionRefusee())).called(1);
    },
  );

  testWidgets(
    'tap « Plus tard » ne déclenche pas demanderPermission',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.tap(find.text('Maybe later'));
      await tester.pump();

      verifyNever(() => serviceRappel.demanderPermission());
    },
  );
}
