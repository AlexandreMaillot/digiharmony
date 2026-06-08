import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/pages/conseils/modeles/carte_conseil.dart';

/// Référence Unix epoch pour le calcul `joursDepuisEpoch` (DEC-CO-03).
final _epoch = DateTime(1970);

/// Compose le deck de cartes de manière DÉTERMINISTE (DEC-CO-03..06).
///
/// Helper PUR : reçoit les données déjà lues, sans accès à Drift.
/// Testable isolément — seule entrée du résultat = (humeur, corpus, jour, n).
///
/// Règles de composition (DEC-CO-06) :
///   1. Si [humeurDuJour] != null ET le corpus contient une carte émotion
///      pour ce code → carte émotion EN TÊTE.
///   2. Portion générique = rotation déterministe de [n] cartes parmi celles
///      dont le `typeCarte` != 'emotion' (rappels + conseils pratiques),
///      offset = joursDepuisEpoch % nbGeneriques.
///   3. La carte émotion en tête est exclue de la portion générique (pas de
///      doublon par cleContenu).
///
/// Garantie : retourne au moins [n] cartes (≥ 1) même si le corpus est court.
/// Si le corpus générique est vide → fallback : une seule CarteRappel
/// 'tipDay01'.
List<CarteConseil> composerDeck({
  required EntreeHumeur? humeurDuJour,
  required List<Conseil> corpus,
  required DateTime jour,
  int n = 4,
}) {
  // Séparation corpus : génériques (rappel + conseil) / émotions.
  final generiques =
      corpus.where((c) => c.typeCarte != 'emotion').toList();
  final emotions =
      corpus.where((c) => c.typeCarte == 'emotion').toList();

  final deck = <CarteConseil>[];

  // ── Étape 1 : carte émotion contextuelle (optionnelle) ─────────────────
  CarteEmotion? carteEmotionAjoutee;
  if (humeurDuJour != null) {
    final code = humeurDuJour.codeEmotion;
    final rowEmotion = _trouverEmotion(emotions, code);
    if (rowEmotion != null) {
      carteEmotionAjoutee = CarteEmotion(
        cleContenu: rowEmotion.cleConseil,
        codeEmotion: code,
      );
      deck.add(carteEmotionAjoutee);
    } else if (valencePour(code) < 0) {
      // Repli : émotion négative sans carte dédiée → premier générique
      // de réconfort (sinon aucune carte contextuelle, deck 100 % générique).
      // V1 : pas de carte réconfort générique dédiée — on laisse passer sans
      // ajout (cohérent DEC-CO-06 «repli optionnel V1»).
    }
  }

  // ── Étape 2 : portion générique (rotation déterministe) ────────────────
  if (generiques.isEmpty) {
    // Fallback : corpus vide → une carte rappel minimale (jamais de crash).
    if (deck.isEmpty) {
      deck.add(const CarteRappel(
        cleContenu: 'tipDay01',
        accentChrome: 'primary',
      ));
    }
    return deck;
  }

  final jourNormalise = DateTime(jour.year, jour.month, jour.day);
  final joursDepuisEpoch = jourNormalise.difference(_epoch).inDays;
  final offset = joursDepuisEpoch % generiques.length;

  final exclues = carteEmotionAjoutee != null
      ? {carteEmotionAjoutee.cleContenu}
      : <String>{};

  // Rotation circulaire à partir de offset, N cartes max, sans doublon.
  var ajoutees = 0;
  final nb = generiques.length;
  for (var i = 0; i < nb && ajoutees < n; i++) {
    final row = generiques[(offset + i) % nb];
    if (exclues.contains(row.cleConseil)) continue;
    deck.add(_carteDepuisRow(row));
    ajoutees++;
  }

  return deck;
}

/// Trouve la carte émotion pour un [codeEmotion] dans la liste [emotions].
Conseil? _trouverEmotion(List<Conseil> emotions, String codeEmotion) {
  for (final e in emotions) {
    if (e.codeEmotion == codeEmotion) return e;
  }
  return null;
}

/// Convertit une ligne [Conseil] Drift en [CarteConseil] typé.
CarteConseil _carteDepuisRow(Conseil row) {
  return switch (row.typeCarte) {
    'emotion' => CarteEmotion(
        cleContenu: row.cleConseil,
        codeEmotion: row.codeEmotion ?? 'happy',
      ),
    'rappel' => CarteRappel(
        cleContenu: row.cleConseil,
        accentChrome: row.accentChrome,
      ),
    _ => CarteConseilPratique(
        cleContenu: row.cleConseil,
        accentChrome: row.accentChrome,
      ),
  };
}
