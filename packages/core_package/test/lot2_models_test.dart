import 'package:core_package/core_package.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CatalogueConseils', () {
    test('exposes 5 advices, one per EmotionNegative, in order', () {
      expect(CatalogueConseils.all.length, 5);
      expect(
        CatalogueConseils.all.map((c) => c.id).toList(),
        EmotionNegative.values,
      );
    });

    test('each advice has 3 do keys and 2 avoid keys', () {
      for (final conseil in CatalogueConseils.all) {
        expect(conseil.doKeys.length, 3, reason: conseil.id.name);
        expect(conseil.avoidKeys.length, 2, reason: conseil.id.name);
      }
    });

    test('anger uses the mockup red color', () {
      final anger = CatalogueConseils.all.first;
      expect(anger.id, EmotionNegative.anger);
      expect(anger.color.toARGB32(), 0xFFE5392B);
    });

    test('parId / indexDe resolve known ids and repli on unknown', () {
      expect(CatalogueConseils.parId('fear')?.id, EmotionNegative.fear);
      expect(CatalogueConseils.indexDe('stress'), 3);
      expect(CatalogueConseils.parId('unknown'), isNull);
      expect(CatalogueConseils.indexDe('unknown'), -1);
      expect(CatalogueConseils.indexDe(null), -1);
    });
  });

  group('CatalogueGuideNotifications', () {
    test('android and ios sets each have 5 ordered steps', () {
      for (final p in PlateformeGuide.values) {
        final steps = CatalogueGuideNotifications.etapesPour(p);
        expect(steps.length, 5, reason: p.name);
        expect(
          steps.map((s) => s.index).toList(),
          <int>[1, 2, 3, 4, 5],
          reason: p.name,
        );
      }
    });

    test('ios bodies use the Ios suffix keys', () {
      expect(
        CatalogueGuideNotifications.iosSteps.first.bodyKey,
        'notifGuideStep1BodyIos',
      );
      expect(
        CatalogueGuideNotifications.androidSteps.first.bodyKey,
        'notifGuideStep1Body',
      );
    });
  });

  group('kLanguesSupportees', () {
    test('lists the 8 project locales in order', () {
      expect(
        kLanguesSupportees.map((l) => l.code).toList(),
        <String>['en', 'fr', 'el', 'it', 'ro', 'tr', 'es', 'mk'],
      );
    });

    test('autonyms are non-empty and not translated placeholders', () {
      for (final langue in kLanguesSupportees) {
        expect(langue.autonym.isNotEmpty, isTrue);
        expect(langue.flag.isNotEmpty, isTrue);
      }
    });
  });

  group('ResumeTempsEcran', () {
    test('value equality on summary and days', () {
      const a = ResumeTempsEcran(
        todayDuration: Duration(hours: 3),
        weekTotal: Duration(hours: 21),
        days: <UsageJour>[
          UsageJour(weekday: 1, duration: Duration(hours: 3)),
        ],
      );
      const b = ResumeTempsEcran(
        todayDuration: Duration(hours: 3),
        weekTotal: Duration(hours: 21),
        days: <UsageJour>[
          UsageJour(weekday: 1, duration: Duration(hours: 3)),
        ],
      );
      expect(a, b);
    });
  });
}
