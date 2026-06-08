import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests de comportement UPSERT et annulation (DEC-SH-001/007).
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> countEntrees() async {
    final all = await db.select(db.entreesHumeur).get();
    return all.length;
  }

  group('enregistrerHumeurDuJour', () {
    // UPSERT-1 : première saisie → retourne null.
    test(
      'UPSERT-1 : première saisie → ancienne = null',
      () async {
        final ancienne = await db.enregistrerHumeurDuJour('happy');
        expect(ancienne, isNull);
      },
    );

    // UPSERT-2 : écrasement → retourne l'ancienne, 1 seule ligne.
    test(
      'UPSERT-2 : ré-saisie le même jour → retourne ancienne + 1 ligne',
      () async {
        await db.enregistrerHumeurDuJour('happy');
        final ancienne = await db.enregistrerHumeurDuJour('calm');

        expect(ancienne, isNotNull);
        expect(ancienne!.codeEmotion, 'happy');
        expect(await countEntrees(), 1);
      },
    );

    // UPSERT-3 : valence écrite correctement.
    test(
      'UPSERT-3 : valence écrite = valencePour(codeEmotion)',
      () async {
        await db.enregistrerHumeurDuJour('sad');
        final entree = await db.observerDerniereHumeurDuJour().first;
        expect(entree?.valence, lessThan(0));
      },
    );

    // UPSERT-4 : réactivité watch() après UPSERT.
    test(
      'UPSERT-4 : observerDerniereHumeurDuJour émet après UPSERT',
      () async {
        final stream = db.observerDerniereHumeurDuJour();
        final emissions = <String?>[];
        final sub = stream.listen(
          (row) => emissions.add(row?.codeEmotion),
        );

        await Future<void>.delayed(const Duration(milliseconds: 30));
        await db.enregistrerHumeurDuJour('dynamic');
        await Future<void>.delayed(const Duration(milliseconds: 30));

        await sub.cancel();
        expect(emissions.first, isNull);
        expect(emissions.last, 'dynamic');
      },
    );
  });

  group('annulerDerniereSaisie', () {
    // UNDO-1 : annulation avec ancienne → restaure.
    test(
      'UNDO-1 : ancienneEntree != null → restaure l ancienne émotion',
      () async {
        await db.enregistrerHumeurDuJour('happy');
        final ancienne = await db.enregistrerHumeurDuJour('calm');

        await db.annulerDerniereSaisie(ancienneEntree: ancienne);

        final derniere = await db.observerDerniereHumeurDuJour().first;
        expect(derniere?.codeEmotion, 'happy');
        expect(await countEntrees(), 1);
      },
    );

    // UNDO-2 : annulation sans ancienne → supprime.
    test(
      'UNDO-2 : ancienneEntree == null → supprime l entrée du jour',
      () async {
        await db.enregistrerHumeurDuJour('tired');
        await db.annulerDerniereSaisie();

        expect(await countEntrees(), 0);
      },
    );
  });
}
