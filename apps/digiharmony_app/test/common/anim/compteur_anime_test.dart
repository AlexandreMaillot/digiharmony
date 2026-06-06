import 'package:digiharmony_app/common/anim/compteur_anime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CompteurAnimeInt', () {
    // RM-CI-1 : En reduced-motion, valeur finale affichée directement.
    testWidgets(
      'RM-CI-1 : reduced-motion → valeur finale immédiate',
      (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: MaterialApp(
              home: Scaffold(
                body: CompteurAnimeInt(
                  valeur: 42,
                  builder: (_, v) => Text('$v'),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Valeur finale visible directement.
        expect(find.text('42'), findsOneWidget);
      },
    );

    // RM-CI-2 : Sans reduced-motion, animation démarre à 0.
    testWidgets(
      'RM-CI-2 : animations ON → count-up sans hang',
      (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(),
            child: MaterialApp(
              home: Scaffold(
                body: CompteurAnimeInt(
                  valeur: 10,
                  builder: (_, v) => Text('$v'),
                ),
              ),
            ),
          ),
        );
        await tester.pump(Duration.zero);
        // Après la durée de l'animation, valeur finale atteinte.
        await tester.pump(const Duration(milliseconds: 700));
        expect(find.text('10'), findsOneWidget);
      },
    );
  });

  group('CompteurAnimeDuree', () {
    // RM-CD-1 : En reduced-motion, durée finale affichée directement.
    testWidgets(
      'RM-CD-1 : reduced-motion → durée finale immédiate',
      (tester) async {
        const duree = Duration(hours: 1, minutes: 30);

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: MaterialApp(
              home: Scaffold(
                body: CompteurAnimeDuree(
                  duree: duree,
                  builder: (_, d) => Text('${d.inMinutes}min'),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // 90 minutes affichées directement.
        expect(find.text('90min'), findsOneWidget);
      },
    );

    // RM-CD-2 : Sans reduced-motion, animation count-up sans hang.
    testWidgets(
      'RM-CD-2 : animations ON → durée finale atteinte',
      (tester) async {
        const duree = Duration(minutes: 5);

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(),
            child: MaterialApp(
              home: Scaffold(
                body: CompteurAnimeDuree(
                  duree: duree,
                  builder: (_, d) => Text('${d.inSeconds}s'),
                ),
              ),
            ),
          ),
        );
        await tester.pump(Duration.zero);
        await tester.pump(const Duration(milliseconds: 700));

        // 300s (5min) atteints après l'animation.
        expect(find.text('300s'), findsOneWidget);
      },
    );
  });
}
