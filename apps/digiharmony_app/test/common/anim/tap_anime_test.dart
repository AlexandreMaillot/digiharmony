import 'package:digiharmony_app/common/anim/tap_anime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpTapAnime(
  WidgetTester tester, {
  bool disableAnimations = false,
  VoidCallback? onTap,
}) async {
  var tapped = false;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: TapAnime(
              onTap: onTap ?? () => tapped = true,
              child: const Text('tap me'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('TapAnime', () {
    // RM-TA-1 : En reduced-motion, pas d'AnimatedScale.
    testWidgets(
      "RM-TA-1 : reduced-motion → pas d'AnimatedScale",
      (tester) async {
        await pumpTapAnime(tester, disableAnimations: true);
        expect(find.byType(AnimatedScale), findsNothing);
        expect(find.text('tap me'), findsOneWidget);
      },
    );

    // RM-TA-2 : Sans reduced-motion, AnimatedScale présent.
    testWidgets(
      'RM-TA-2 : animations ON → AnimatedScale présent',
      (tester) async {
        await pumpTapAnime(tester);
        expect(find.byType(AnimatedScale), findsOneWidget);
      },
    );

    // RM-TA-3 : En reduced-motion, onTap est déclenché au tap.
    testWidgets(
      'RM-TA-3 : reduced-motion → onTap déclenché',
      (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: TapAnime(
                    onTap: () => tapped = true,
                    child: const Text('tap me'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('tap me'));
        await tester.pump();
        expect(tapped, isTrue);
      },
    );

    // RM-TA-4 : Sans reduced-motion, onTap déclenché + scale revient.
    testWidgets(
      'RM-TA-4 : animations ON → tap déclenche onTap',
      (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(),
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: TapAnime(
                    onTap: () => tapped = true,
                    child: const Text('tap me'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('tap me'));
        await tester.pump(const Duration(milliseconds: 150));
        expect(tapped, isTrue);
      },
    );
  });
}
