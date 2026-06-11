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

    test('TIP-3 : index = joursDepuisEpoch % n (génériques)', () async {
      // conseilDuJour tourne sur les génériques (type_carte != 'emotion')
      // ordonnés par ordre/id — même ensemble que composerDeck (DEC-CO-11).
      final generiques = await db.cartesGeneriquesOrdonnees();
      final day = DateTime(2026, 6, 5);
      final jour = DateTime(day.year, day.month, day.day);
      final jours = jour.difference(DateTime(1970)).inDays;
      final attendu = generiques[jours % generiques.length];
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
      // Le cycle est basé sur le nombre de génériques, pas le total.
      final generiques = await db.cartesGeneriquesOrdonnees();
      final day = DateTime(2026, 6, 5);
      final t1 = await db.conseilDuJour(day);
      final t2 = await db.conseilDuJour(
        day.add(Duration(days: generiques.length)),
      );
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

  group('observerEntreesDeLaSemaine', () {
    Future<void> insertAvecJour(
      String code,
      int valence,
      DateTime at,
    ) {
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

    // SEMAINE-1 : entrée lundi incluse, entrée lundi suivant exclue.
    test('SEMAINE-1 : borne lundi incluse, lundi+7j exclue', () async {
      // Lundi 2026-06-01 00:00.
      final lundi = DateTime(2026, 6);
      // Entrée au lundi (borne basse incluse).
      await insertAvecJour('happy', 1, lundi);
      // Entrée au lundi suivant (borne haute exclue).
      final lundiSuivant = DateTime(2026, 6, 8);
      await insertAvecJour('sad', -1, lundiSuivant);

      final ref = DateTime(2026, 6, 3); // mercredi de la même semaine
      final entries = await db.observerEntreesDeLaSemaine(ref).first;
      expect(entries.length, 1);
      expect(entries.first.codeEmotion, 'happy');
    });

    // SEMAINE-2 : semaine sans entrée → liste vide.
    test('SEMAINE-2 : semaine vide → liste vide', () async {
      final ref = DateTime(2026, 6, 3);
      final entries = await db.observerEntreesDeLaSemaine(ref).first;
      expect(entries, isEmpty);
    });

    // SEMAINE-3 : tri ASC par creeLe.
    test('SEMAINE-3 : tri creeLe ASC', () async {
      final lundi = DateTime(2026, 6);
      final mercredi = DateTime(2026, 6, 3);
      await insertAvecJour('calm', 1, mercredi);
      await insertAvecJour('angry', -1, lundi);
      final entries = await db.observerEntreesDeLaSemaine(lundi).first;
      expect(entries.first.codeEmotion, 'angry');
      expect(entries.last.codeEmotion, 'calm');
    });

    // SEMAINE-4 : réactif — nouvelle entrée → ré-émission.
    test('SEMAINE-4 : réactif (nouvelles entrées)', () async {
      final ref = DateTime(2026, 6, 3);
      final emissions = <int>[];
      final sub = db
          .observerEntreesDeLaSemaine(ref)
          .listen((list) => emissions.add(list.length));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await insertAvecJour('happy', 1, ref);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();
      expect(emissions.first, 0);
      expect(emissions.last, 1);
    });
  });

  group('observerEntreesDuMois', () {
    Future<void> insertAvecJour(
      String code,
      int valence,
      DateTime at,
    ) {
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

    // MOIS-1 : entrée 1er du mois incluse, 1er mois suivant exclue.
    test('MOIS-1 : borne 1er inclus, 1er mois suivant exclue', () async {
      final premierJuin = DateTime(2026, 6);
      final premierJuillet = DateTime(2026, 7);
      await insertAvecJour('happy', 1, premierJuin);
      await insertAvecJour('sad', -1, premierJuillet);

      final ref = DateTime(2026, 6, 15);
      final entries = await db.observerEntreesDuMois(ref).first;
      expect(entries.length, 1);
      expect(entries.first.codeEmotion, 'happy');
    });

    // MOIS-2 : mois sans entrée → liste vide.
    test('MOIS-2 : mois vide → liste vide', () async {
      final ref = DateTime(2026, 5, 15);
      final entries = await db.observerEntreesDuMois(ref).first;
      expect(entries, isEmpty);
    });

    // MOIS-3 : réactif — nouvelle entrée → ré-émission.
    test('MOIS-3 : réactif (nouvelle entrée dans le mois)', () async {
      final ref = DateTime(2026, 6, 10);
      final emissions = <int>[];
      final sub = db
          .observerEntreesDuMois(ref)
          .listen((list) => emissions.add(list.length));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await insertAvecJour('calm', 1, ref);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();
      expect(emissions.first, 0);
      expect(emissions.last, 1);
    });

    // MOIS-4 : gestion fin d'année (décembre → borne janvier n+1).
    test("MOIS-4 : décembre borné sur janvier de l'année suivante", () async {
      final deuxDecembre = DateTime(2026, 12, 2);
      await insertAvecJour('dynamic', 1, deuxDecembre);
      // Entrée au 1er janvier 2027 (borne haute exclue).
      await insertAvecJour('tired', -1, DateTime(2027));
      final ref = DateTime(2026, 12, 15);
      final entries = await db.observerEntreesDuMois(ref).first;
      expect(entries.length, 1);
      expect(entries.first.codeEmotion, 'dynamic');
    });
  });

  group('humeurDuJourEstNotee', () {
    Future<void> insertAvecJour(
      String code,
      int valence,
      DateTime at,
    ) {
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

    // DJNOTEE-1 : jour avec entrée → true.
    test('DJNOTEE-1 : jour avec entrée → true', () async {
      final jour = DateTime(2026, 6, 10, 14, 30);
      await insertAvecJour('happy', 1, jour);
      expect(
        await db.humeurDuJourEstNotee(jour: DateTime(2026, 6, 10)),
        isTrue,
      );
    });

    // DJNOTEE-2 : jour sans entrée → false.
    test('DJNOTEE-2 : jour sans entrée → false', () async {
      expect(
        await db.humeurDuJourEstNotee(jour: DateTime(2026, 6, 11)),
        isFalse,
      );
    });

    // DJNOTEE-3 : entrée exactement à minuit → incluse (borne basse incluse).
    test('DJNOTEE-3 : entrée à minuit incluse (borne basse)', () async {
      final minuit = DateTime(2026, 6, 12);
      await insertAvecJour('calm', 0, minuit);
      expect(
        await db.humeurDuJourEstNotee(jour: DateTime(2026, 6, 12)),
        isTrue,
      );
    });

    // DJNOTEE-4 : entrée à minuit+1j → exclue (borne haute exclue).
    test('DJNOTEE-4 : entrée à minuit+1j exclue (borne haute)', () async {
      final minuitPlusUn = DateTime(2026, 6, 13); // minuit du jour suivant
      await insertAvecJour('sad', -1, minuitPlusUn);
      // La requête pour le 12 ne doit pas trouver l'entrée du 13 à minuit.
      expect(
        await db.humeurDuJourEstNotee(jour: DateTime(2026, 6, 12)),
        isFalse,
      );
    });
  });
}
