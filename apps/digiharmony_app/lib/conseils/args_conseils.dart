/// Contrat d'entree OPTIONNEL de l'ecran Conseils.
///
/// - `idEmotionInitiale == null` => mode CATALOGUE pur (1re carte).
/// - fourni => ouvre directement sur la carte de l'emotion (mode contextuel
///   futur Journal).
/// - inconnu => repli sur la 1re carte (aucun crash).
class ArgsConseils {
  /// {@macro args_conseils}
  const ArgsConseils({this.idEmotionInitiale});

  /// Id d'emotion (`EmotionNegative.name`) sur laquelle ouvrir le carrousel.
  final String? idEmotionInitiale;
}
