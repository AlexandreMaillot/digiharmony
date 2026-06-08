import 'package:core_package/core_package.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategorieBulle', () {
    test('exposes exactly 4 categories with unique ids', () {
      expect(CategorieBulle.all.length, 4);
      final ids = CategorieBulle.all.map((c) => c.id).toSet();
      expect(ids.length, 4);
    });

    test('order is respiration, senses, stretch, detox', () {
      expect(
        CategorieBulle.all.map((c) => c.id).toList(),
        <IdCategorieBulle>[
          IdCategorieBulle.respiration,
          IdCategorieBulle.senses,
          IdCategorieBulle.stretch,
          IdCategorieBulle.detox,
        ],
      );
    });
  });

  group('SeanceRespiration', () {
    test('quatreDeuxSix cadence is 4-2-6 x 5', () {
      const s = SeanceRespiration.quatreDeuxSix;
      expect(s.inhale, const Duration(seconds: 4));
      expect(s.hold, const Duration(seconds: 2));
      expect(s.exhale, const Duration(seconds: 6));
      expect(s.totalCycles, 5);
      expect(s.durationOf(PhaseRespiration.exhale), const Duration(seconds: 6));
    });
  });

  group('ExerciceAncrage', () {
    test('5-4-3-2-1 has 5 ordered steps with decreasing counts', () {
      const e = ExerciceAncrage.cinqQuatreTroisDeuxUn;
      expect(e.totalSteps, 5);
      expect(e.steps.map((s) => s.count).toList(), <int>[5, 4, 3, 2, 1]);
      expect(e.steps.first.sense, SensAncrage.see);
      expect(e.steps.last.sense, SensAncrage.taste);
    });
  });

  group('RoutineEtirement', () {
    test('default routine has 4 segments and correct cumulative bounds', () {
      const r = RoutineEtirement.routineParDefaut;
      expect(r.totalSegments, 4);
      expect(r.totalDuration, const Duration(seconds: 60));
      expect(r.startOf(1), const Duration(seconds: 10));
      expect(r.endOf(1), const Duration(seconds: 30));
    });
  });

  group('AmbianceDetox / DureeDetox', () {
    test('4 ambiances, unique ids, default is sea', () {
      expect(AmbianceDetox.all.length, 4);
      expect(AmbianceDetox.all.map((a) => a.id).toSet().length, 4);
      expect(AmbianceDetox.idParDefaut, IdAmbianceDetox.sea);
      expect(AmbianceDetox.parId(IdAmbianceDetox.sea).id, IdAmbianceDetox.sea);
    });

    test('durations are 5/10/15 with exactly one default (15)', () {
      expect(
        DureeDetox.all.map((d) => d.minutes).toList(),
        <int>[5, 10, 15],
      );
      expect(DureeDetox.all.where((d) => d.isDefault).length, 1);
      expect(DureeDetox.minutesParDefaut, 15);
    });
  });

  group('SeanceDetox', () {
    test('audioAsset resolves from ambianceId', () {
      const session = SeanceDetox(
        ambianceId: IdAmbianceDetox.forest,
        total: Duration(minutes: 15),
      );
      expect(session.audioAsset, 'assets/audio/detox/foret.mp3');
    });
  });
}
