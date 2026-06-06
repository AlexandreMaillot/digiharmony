/// Type d'ouverture de la ressource d'écoute.
enum TypeRessourceEcoute {
  /// Appel téléphonique via scheme `tel:`.
  telephone,

  /// Lien web via scheme `https:`.
  lien,
}

/// Ressource d'écoute associée à une locale (donnée statique embarquée).
///
/// ⚠️ PLACEHOLDERS — numéros/URL à remplir par les partenaires du projet.
/// Table vide par défaut : aucun numéro réel hardcodé (DEC-SO-007).
class RessourceLigneEcoute {
  /// Crée une ressource d'écoute.
  const RessourceLigneEcoute({
    required this.nom,
    required this.cible,
    required this.type,
    required this.disponibilite,
  });

  /// Nom affiché de la ligne d'écoute.
  final String nom;

  /// Cible : numéro brut (tel) ou URL (https). Placeholder partenaires.
  final String cible;

  /// Mode d'ouverture de la ressource.
  final TypeRessourceEcoute type;

  /// Libellé de disponibilité (ex. « 24h/24, 7j/7 »). Placeholder partenaires.
  final String disponibilite;
}

/// Table statique locale → ressource d'écoute.
///
/// **VIDE par défaut** — les ressources validées seront fournies par les
/// partenaires du projet (public mineur, Erasmus+).
/// Clé = `Locale.languageCode`.
///
/// ⚠️ Aucun numéro/URL réel hardcodé (DEC-SO-007).
/// Le bloc ligne d'écoute est masqué quand la locale est absente de cette map.
///
// TODO(partenaires): Remplir les ressources par pays après validation.
const Map<String, RessourceLigneEcoute> tableRessources =
    <String, RessourceLigneEcoute>{};
