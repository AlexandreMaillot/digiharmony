import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Insère une saisie d'humeur dans la base de test avec le [codeEmotion] donné.
///
/// [decalageJours] permet de simuler des saisies sur des jours distincts
/// (pas de contrainte unique violée).
Future<void> _insererHumeur(
  AppDatabase db,
  String codeEmotion, {
  int decalageJours = 0,
}) async {
  final base = DateTime(2026, 1, 1);
  final jour = base.add(Duration(days: decalageJours));
  await db.into(db.entreesHumeur).insert(
    EntreesHumeurCompanion.insert(
      codeEmotion: codeEmotion,
      valence: valencePour(codeEmotion),
      creeLe: jour.add(const Duration(hours: 10)),
      jour: jour,
    ),
  );
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('compterSaisiesNegativesConsecutives', () {
    test('SO-CNT-1 : journal vide → 0', () async {
      expect(await db.compterSaisiesNegativesConsecutives(), 0);
    });

    test('SO-CNT-2 : 7 saisies négatives consécutives → 7', () async {
      for (var i = 0; i < 7; i++) {
        await _insererHumeur(db, 'sad', decalageJours: i);
      }
      expect(await db.compterSaisiesNegativesConsecutives(), 7);
    });

    test('SO-CNT-3 : saisie positive en tête → 0', () async {
      // 6 négatives puis 1 positive (plus récente)
      for (var i = 0; i < 6; i++) {
        await _insererHumeur(db, 'angry', decalageJours: i);
      }
      await _insererHumeur(db, 'happy', decalageJours: 6);
      expect(await db.compterSaisiesNegativesConsecutives(), 0);
    });

    test('SO-CNT-4 : série négative interrompue par une positive plus ancienne',
        () async {
      // j0=positive, j1-j3=négatives (la série en tête = 3)
      await _insererHumeur(db, 'calm', decalageJours: 0);
      for (var i = 1; i <= 3; i++) {
        await _insererHumeur(db, 'nervous', decalageJours: i);
      }
      expect(await db.compterSaisiesNegativesConsecutives(), 3);
    });

    test(
        'SO-CNT-5 : 7 saisies négatives sur jours non consécutifs (jours vides entre) → 7',
        () async {
      // Jours 0, 2, 4, 6, 8, 10, 12 (jours impairs vides)
      for (var i = 0; i < 7; i++) {
        await _insererHumeur(db, 'tired', decalageJours: i * 2);
      }
      expect(await db.compterSaisiesNegativesConsecutives(), 7);
    });

    test('SO-CNT-6 : variantes émotions négatives (sad/angry/nervous/tired)',
        () async {
      final emotions = ['sad', 'angry', 'nervous', 'tired', 'sad', 'angry', 'nervous'];
      for (var i = 0; i < emotions.length; i++) {
        await _insererHumeur(db, emotions[i], decalageJours: i);
      }
      expect(
        await db.compterSaisiesNegativesConsecutives(),
        greaterThanOrEqualTo(7),
      );
    });
  });

  group('aDeclencherSoutien', () {
    test('SO-DEC-1 : journal vide → false', () async {
      expect(await db.aDeclencherSoutien(), isFalse);
    });

    test('SO-DEC-2 : compteur >= 7 → true', () async {
      for (var i = 0; i < 7; i++) {
        await _insererHumeur(db, 'sad', decalageJours: i);
      }
      expect(await db.aDeclencherSoutien(), isTrue);
    });

    test('SO-DEC-3 : compteur < 7 → false', () async {
      for (var i = 0; i < 6; i++) {
        await _insererHumeur(db, 'sad', decalageJours: i);
      }
      expect(await db.aDeclencherSoutien(), isFalse);
    });
  });
}
