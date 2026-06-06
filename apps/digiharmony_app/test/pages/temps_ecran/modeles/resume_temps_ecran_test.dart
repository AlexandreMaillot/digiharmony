import 'package:digiharmony_app/pages/temps_ecran/modeles/resume_temps_ecran.dart';
import 'package:flutter_test/flutter_test.dart';

UsageAppVue _u(String pkg, int minutes) => UsageAppVue(
  nomApp: pkg,
  packageName: pkg,
  duree: Duration(minutes: minutes),
  fractionDuTotal: 0,
);

void main() {
  group('agregeUsage (AC12)', () {
    test('retourne null si total nul (aucune app avec usage)', () {
      expect(agregeUsage(const []), isNull);
      expect(agregeUsage([_u('a', 0)]), isNull);
    });

    test('total = somme des durées, tri décroissant', () {
      final r = agregeUsage([
        _u('com.a', 10),
        _u('com.b', 30),
        _u('com.c', 20),
      ]);
      expect(r, isNotNull);
      expect(r!.total, const Duration(minutes: 60));
      expect(r.topApps.first.packageName, 'com.b');
      expect(r.topApps.last.packageName, 'com.a');
    });

    test('fractionDuTotal correcte', () {
      final r = agregeUsage([_u('com.a', 25), _u('com.b', 75)])!;
      final b = r.topApps.firstWhere((u) => u.packageName == 'com.b');
      expect(b.fractionDuTotal, closeTo(0.75, 0.0001));
    });

    test('top N + bucket « autres » au-delà de topN', () {
      final usages = [
        for (var i = 0; i < 8; i++) _u('app$i', (8 - i) * 10),
      ];
      final r = agregeUsage(usages, topN: 3)!;
      expect(r.topApps.length, 3);
      // 5 restantes : (50+40+30+20+10) = 150 min.
      expect(r.autres, const Duration(minutes: 150));
    });

    test('pas de bucket autres si <= topN apps', () {
      final r = agregeUsage([_u('a', 10), _u('b', 20)], topN: 3)!;
      expect(r.autres, Duration.zero);
    });
  });

  group('nomLisible (AC12 / DEC-TE-06)', () {
    test('extrait le segment significatif et capitalise', () {
      expect(nomLisible('com.instagram.android'), 'Instagram');
      expect(nomLisible('com.whatsapp'), 'Whatsapp');
    });

    test('ignore segments génériques de tête/queue', () {
      expect(nomLisible('com.google.android'), 'Google');
    });

    test('chaîne vide ou simple inchangée hors capitalisation', () {
      expect(nomLisible(''), '');
      expect(nomLisible('snapchat'), 'Snapchat');
    });
  });
}
