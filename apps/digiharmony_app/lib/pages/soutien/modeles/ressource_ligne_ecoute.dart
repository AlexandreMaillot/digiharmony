/// Type d'ouverture de la ressource d'écoute.
enum TypeRessourceEcoute {
  /// Appel téléphonique via scheme `tel:`.
  telephone,

  /// Lien web via scheme `https:`.
  lien,
}

/// Ressource d'écoute associée à une locale (donnée statique embarquée).
///
/// Contient uniquement les données (cible, type).
/// Les libellés UI (titre, disponibilité) sont gérés par l'i18n (ARB).
///
/// L'entrée 'fr' contient le 3114 (numéro FR approuvé).
/// Les autres locales utilisent le fallback 'fr' — données partenaires
/// à valider avant déploiement hors France (DEC-SO-007).
class RessourceLigneEcoute {
  /// Crée une ressource d'écoute.
  const RessourceLigneEcoute({
    required this.cible,
    required this.type,
  });

  /// Cible : numéro brut (tel) ou URL (https).
  final String cible;

  /// Mode d'ouverture de la ressource.
  final TypeRessourceEcoute type;
}

/// Table statique locale → ressource d'écoute.
///
/// Clé = `Locale.languageCode`.
///
/// L'entrée 'fr' utilise le 3114 (Numéro national de prévention du suicide,
/// France), validé par les partenaires du projet pour la locale FR.
///
/// Le bloc ligne d'écoute utilise l'entrée 'fr' comme fallback si la locale
/// courante n'a pas d'entrée propre ; il se masque uniquement si l'entrée
/// 'fr' elle-même est absente.
///
// TODO(partenaires): 3114 = numéro FR (France-only). Ajouter un numéro VALIDÉ
//   par pays/locale ; le fallback FR ci-dessous est temporaire et ne fonctionne
//   qu'en France.
const Map<String, RessourceLigneEcoute>
tableRessources = <String, RessourceLigneEcoute>{
  // 3114 = Numéro national de prévention du suicide (FR), approuvé partenaires.
  // Utilisé comme fallback pour toutes les locales sans entrée propre.
  'fr': RessourceLigneEcoute(
    cible: '3114',
    type: TypeRessourceEcoute.telephone,
  ),
};
