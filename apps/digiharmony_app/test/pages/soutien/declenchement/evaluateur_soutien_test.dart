import 'package:digiharmony_app/pages/soutien/declenchement/evaluateur_soutien.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EvaluateurSoutien.doitDeclencher', () {
    test('SO-EVAL-1 : compteur < 7 → false (dejaMontre false)', () {
      expect(
        EvaluateurSoutien.doitDeclencher(
          compteurNegativesConsecutives: 6,
          dejaMontrePourEpisodeEnCours: false,
        ),
        isFalse,
      );
    });

    test('SO-EVAL-2 : compteur < 7 → false (dejaMontre true)', () {
      expect(
        EvaluateurSoutien.doitDeclencher(
          compteurNegativesConsecutives: 0,
          dejaMontrePourEpisodeEnCours: true,
        ),
        isFalse,
      );
    });

    test('SO-EVAL-3 : compteur == 7 et dejaMontre false → true', () {
      expect(
        EvaluateurSoutien.doitDeclencher(
          compteurNegativesConsecutives: 7,
          dejaMontrePourEpisodeEnCours: false,
        ),
        isTrue,
      );
    });

    test('SO-EVAL-4 : compteur > 7 et dejaMontre false → true', () {
      expect(
        EvaluateurSoutien.doitDeclencher(
          compteurNegativesConsecutives: 10,
          dejaMontrePourEpisodeEnCours: false,
        ),
        isTrue,
      );
    });

    test('SO-EVAL-5 : compteur >= 7 et dejaMontre true → false (une fois par épisode)',
        () {
      expect(
        EvaluateurSoutien.doitDeclencher(
          compteurNegativesConsecutives: 7,
          dejaMontrePourEpisodeEnCours: true,
        ),
        isFalse,
      );
    });

    test('SO-EVAL-6 : seuil exposé = 7', () {
      expect(EvaluateurSoutien.seuil, equals(7));
    });
  });
}
