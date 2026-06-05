import 'package:bloc_test/bloc_test.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/demarrage/bloc/demarrage_bloc.dart';
import 'package:digiharmony_app/pages/demarrage/views/demarrage_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDemarrageBloc extends MockBloc<DemarrageEvent, DemarrageState>
    implements DemarrageBloc {}

void main() {
  late _MockDemarrageBloc bloc;

  setUpAll(() {
    registerFallbackValue(const DemarrageDemarre(dureeMinimale: Duration.zero));
  });

  setUp(() {
    bloc = _MockDemarrageBloc();
    when(() => bloc.state).thenReturn(const DemarrageInitial());
    whenListen<DemarrageState>(
      bloc,
      const Stream.empty(),
      initialState: const DemarrageInitial(),
    );
  });

  Widget wrap({required bool reduced}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: BlocProvider<DemarrageBloc>.value(
          value: bloc,
          child: const DemarrageView(),
        ),
      ),
    );
  }

  DemarrageDemarre capturerEvent() {
    final captured = verify(() => bloc.add(captureAny())).captured;
    return captured.last as DemarrageDemarre;
  }

  testWidgets('RM-3 : reduced motion -> DemarrageDemarre(0,8s)', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(reduced: true));
    await tester.pump();
    expect(capturerEvent().dureeMinimale, dureeMinimaleReduite);
  });

  testWidgets('RM-4 : mode normal -> DemarrageDemarre(2,5s)', (tester) async {
    await tester.pumpWidget(wrap(reduced: false));
    await tester.pump();
    expect(capturerEvent().dureeMinimale, dureeMinimaleNormale);
    // Démonte la vue (dispose les boucles) puis vide les timers de delay.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
