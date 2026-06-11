import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/app/view/app.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/saisie_humeur/bloc/saisie_humeur_bloc.dart';
import 'package:digiharmony_app/pages/saisie_humeur/views/saisie_humeur_view.dart';
import 'package:digiharmony_app/rappel/rappel_bloc.dart';
import 'package:digiharmony_app/services/rappel/service_rappel.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/hydrated_storage.dart';

class _MockSaisieHumeurBloc
    extends MockBloc<SaisieHumeurEvent, SaisieHumeurState>
    implements SaisieHumeurBloc {}

class _MockRappelBloc extends Mock implements RappelBloc {}

class _MockServiceRappel extends Mock implements ServiceRappel {}

/// Harnais avec appNavigatorKey câblé pour tester la sheet d'invitation.
///
/// La SaisieHumeurView est poussée via Navigator.push depuis un Scaffold
/// racine, de sorte que le pop retourne au Scaffold racine et la
/// RappelInvitationSheet peut s'afficher dessus via appNavigatorKey.
Widget _buildHarnais({
  required _MockSaisieHumeurBloc saisieBloc,
  required _MockRappelBloc rappelBloc,
  required _MockServiceRappel serviceRappel,
}) {
  return MediaQuery(
    data: const MediaQueryData(disableAnimations: true),
    child: RepositoryProvider<ServiceRappel>.value(
      value: serviceRappel,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<RappelBloc>.value(value: rappelBloc),
        ],
        child: MaterialApp(
          navigatorKey: appNavigatorKey,
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // Écran racine avec bouton pour naviguer vers SaisieHumeurView.
          home: Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () => unawaited(
                  Navigator.of(ctx).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BlocProvider<SaisieHumeurBloc>.value(
                        value: saisieBloc,
                        child: const SaisieHumeurView(),
                      ),
                    ),
                  ),
                ),
                child: const Text('ouvrir'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const SaisieValidee());
    registerFallbackValue(const RappelInvitationProposee());
  });

  setUp(initMockHydratedStorage);

  group('SaisieHumeurView — invitation rappel (DEC-R-03)', () {
    testWidgets(
      'SHV-INV-1 : 1re saisie réussie (flag false) → '
      'RappelInvitationProposee dispatché + sheet affichée',
      (tester) async {
        final saisieBloc = _MockSaisieHumeurBloc();
        final rappelBloc = _MockRappelBloc();
        final serviceRappel = _MockServiceRappel();
        final ctrl = StreamController<SaisieHumeurState>.broadcast();

        when(() => saisieBloc.state).thenReturn(const SaisieInitiale());
        when(() => saisieBloc.stream).thenAnswer((_) => ctrl.stream);
        // Flag not yet set → should show invitation.
        when(() => rappelBloc.state).thenReturn(const RappelState());
        when(() => rappelBloc.stream).thenAnswer((_) => const Stream.empty());
        when(() => rappelBloc.add(const RappelInvitationProposee()))
            .thenReturn(null);
        when(() => rappelBloc.add(const RappelReplanificationDemandee()))
            .thenReturn(null);

        await tester.pumpWidget(
          _buildHarnais(
            saisieBloc: saisieBloc,
            rappelBloc: rappelBloc,
            serviceRappel: serviceRappel,
          ),
        );

        // Naviguer vers SaisieHumeurView.
        await tester.tap(find.text('ouvrir'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Simuler EnregistrementReussi.
        ctrl.add(const EnregistrementReussi(codeEmotion: 'happy'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Vérifier que le flag one-shot a été posé.
        verify(
          () => rappelBloc.add(const RappelInvitationProposee()),
        ).called(1);

        // Vérifier que la sheet est affichée (via le texte invitation).
        expect(
          find.textContaining('Daily reminder'),
          findsOneWidget,
        );

        await ctrl.close();
      },
    );

    testWidgets(
      'SHV-INV-2 : 2e saisie (flag true) → AUCUNE sheet, '
      'RappelInvitationProposee NON dispatché',
      (tester) async {
        final saisieBloc = _MockSaisieHumeurBloc();
        final rappelBloc = _MockRappelBloc();
        final serviceRappel = _MockServiceRappel();
        final ctrl = StreamController<SaisieHumeurState>.broadcast();

        when(() => saisieBloc.state).thenReturn(const SaisieInitiale());
        when(() => saisieBloc.stream).thenAnswer((_) => ctrl.stream);
        // Flag already set → should NOT show invitation.
        when(() => rappelBloc.state).thenReturn(
          const RappelState(invitationDejaProposee: true),
        );
        when(() => rappelBloc.stream).thenAnswer((_) => const Stream.empty());
        when(() => rappelBloc.add(const RappelReplanificationDemandee()))
            .thenReturn(null);

        await tester.pumpWidget(
          _buildHarnais(
            saisieBloc: saisieBloc,
            rappelBloc: rappelBloc,
            serviceRappel: serviceRappel,
          ),
        );

        // Naviguer vers SaisieHumeurView.
        await tester.tap(find.text('ouvrir'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Simuler EnregistrementReussi.
        ctrl.add(const EnregistrementReussi(codeEmotion: 'happy'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Le flag n'est PAS redispatché.
        verifyNever(
          () => rappelBloc.add(const RappelInvitationProposee()),
        );

        // Aucune sheet d'invitation.
        expect(find.textContaining('Daily reminder'), findsNothing);

        await ctrl.close();
      },
    );
  });
}
