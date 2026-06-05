import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Conseils — seed & rotation (conseilDuJour)', () {
    test('TIP-1 : >= 7 conseils seedés', () async {
      final count = await db.conseils.count().getSingle();
      expect(count, greaterThanOrEqualTo(7));
    });

    test('TIP-2 : déterministe pour un même jour', () async {
      final day = DateTime(2026, 6, 5);
      final a = await db.conseilDuJour(day);
      final b = await db.conseilDuJour(day);
      expect(a.cleConseil, b.cleConseil);
    });

    test('TIP-3 : index = joursDepuisEpoch % n', () async {
      final all = await (db.select(
        db.conseils,
      )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
      final day = DateTime(2026, 6, 5);
      final jour = DateTime(day.year, day.month, day.day);
      final jours = jour.difference(DateTime(1970)).inDays;
      final attendu = all[jours % all.length];
      final tip = await db.conseilDuJour(day);
      expect(tip.cleConseil, attendu.cleConseil);
    });

    test('TIP-4 : jours consécutifs -> conseils différents (n>1)', () async {
      final day = DateTime(2026, 6, 5);
      final t1 = await db.conseilDuJour(day);
      final t2 = await db.conseilDuJour(day.add(const Duration(days: 1)));
      expect(t1.cleConseil, isNot(t2.cleConseil));
    });

    test('TIP-5 : cycle modulo n (d et d+n identiques)', () async {
      final all = await db.conseils.count().getSingle();
      final day = DateTime(2026, 6, 5);
      final t1 = await db.conseilDuJour(day);
      final t2 = await db.conseilDuJour(day.add(Duration(days: all)));
      expect(t1.cleConseil, t2.cleConseil);
    });

    test('TIP-6 : stable toute la journée (heure ignorée)', () async {
      final matin = DateTime(2026, 6, 5, 0, 1);
      final soir = DateTime(2026, 6, 5, 23, 59);
      final a = await db.conseilDuJour(matin);
      final b = await db.conseilDuJour(soir);
      expect(a.cleConseil, b.cleConseil);
    });

    test('TIP-7 : seed idempotent (pas de doublon)', () async {
      final before = await db.conseils.count().getSingle();
      // Force un beforeOpen supplémentaire en relisant.
      await db.customSelect('SELECT 1').get();
      final after = await db.conseils.count().getSingle();
      expect(after, before);
    });
  });

  group('observerDerniereHumeurDuJour', () {
    Future<void> insert(String code, int valence, DateTime at) {
      final jour = DateTime(at.year, at.month, at.day);
      return db
          .into(db.entreesHumeur)
          .insert(
            EntreesHumeurCompanion.insert(
              codeEmotion: code,
              valence: valence,
              creeLe: at,
              jour: jour,
            ),
          );
    }

    test('MOOD-1 : base vide -> null', () async {
      expect(await db.observerDerniereHumeurDuJour().first, isNull);
    });

    test('MOOD-2 : entrée du jour -> émet cette entrée', () async {
      final now = DateTime.now();
      await insert('happy', 1, now);
      final row = await db.observerDerniereHumeurDuJour().first;
      expect(row, isNotNull);
      expect(row!.codeEmotion, 'happy');
    });

    test('MOOD-3 : entrée d hier ignorée -> null', () async {
      final hier = DateTime.now().subtract(const Duration(days: 1));
      await insert('sad', -1, hier);
      expect(await db.observerDerniereHumeurDuJour().first, isNull);
    });

    test(
      'MOOD-4 : UPSERT deux fois aujourd hui -> dernière émotion conservée',
      () async {
        // Schéma v2 : unicité par jour → 2 UPSERT successifs = 1 ligne.
        // La deuxième saisie écrase la première.
        await db.enregistrerHumeurDuJour('calm');
        await db.enregistrerHumeurDuJour('angry');
        final row = await db.observerDerniereHumeurDuJour().first;
        expect(row!.codeEmotion, 'angry');
      },
    );

    test('MOOD-5 : réactif (null puis entrée)', () async {
      final stream = db.observerDerniereHumeurDuJour();
      final emissions = <String?>[];
      final sub = stream.listen((row) => emissions.add(row?.codeEmotion));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await insert('dynamic', 1, DateTime.now());
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();
      expect(emissions.first, isNull);
      expect(emissions.last, 'dynamic');
    });
  });
}
