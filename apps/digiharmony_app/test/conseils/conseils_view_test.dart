import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/conseils/args_conseils.dart';
import 'package:digiharmony_app/conseils/view/conseils_page.dart';
import 'package:digiharmony_app/conseils/widgets/carte_conseil.dart';
import 'package:digiharmony_app/langue/langue_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/helpers.dart';

void main() {
  setUp(() {
    final storage = MockHydratedStorage();
    when(() => storage.read(any())).thenReturn(null);
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    when(() => storage.delete(any())).thenAnswer((_) async {});
    when(storage.clear).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  LangueCubit frCubit() => LangueCubit(deviceLocale: const Locale('fr'));

  group('ConseilsView', () {
    testWidgets('renders the first card in catalogue mode', (tester) async {
      await tester.pumpApp(const ConseilsPage(), langueCubit: frCubit());
      await tester.pump();
      expect(find.byType(ConseilsView), findsOneWidget);
      // PageView keeps neighbours alive; at least the active card is present.
      expect(find.byType(CarteConseil), findsWidgets);
      // Title of the first emotion (anger) is shown.
      expect(find.text('Quand tu te sens en colère…'), findsOneWidget);
    });

    testWidgets('opens on the provided initial emotion', (tester) async {
      await tester.pumpApp(
        const ConseilsPage(args: ArgsConseils(idEmotionInitiale: 'fear')),
        langueCubit: frCubit(),
      );
      await tester.pump();
      final expectedIndex = CatalogueConseils.indexDe('fear');
      expect(expectedIndex, 2);
      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.controller!.initialPage, 2);
    });

    testWidgets('repli to first card on unknown initial emotion',
        (tester) async {
      await tester.pumpApp(
        const ConseilsPage(args: ArgsConseils(idEmotionInitiale: 'unknown')),
        langueCubit: frCubit(),
      );
      await tester.pump();
      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.controller!.initialPage, 0);
    });

    testWidgets('previous control is disabled on the first card',
        (tester) async {
      await tester.pumpApp(const ConseilsPage(), langueCubit: frCubit());
      await tester.pump();
      final prev = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'précédent'),
      );
      expect(prev.onPressed, isNull);
    });
  });
}
