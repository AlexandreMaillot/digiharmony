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
/// Clé = `Locale.languageCode`.
///
/// ⚠️ Aucun numéro/URL réel hardcodé (DEC-SO-007).
/// L'entrée 'fr' est un EXEMPLE MANIFESTEMENT FACTICE destiné à rendre le
/// bouton d'appel visible en préview/recette. Elle ne doit JAMAIS être
/// présentée à des utilisateurs finaux en production.
///
/// Le bloc ligne d'écoute utilise l'entrée 'fr' comme fallback si la locale
/// courante n'a pas d'entrée propre ; il se masque uniquement si l'entrée
/// 'fr' elle-même est absente.
///
// TODO(partenaires): Remplacer l'exemple 'fr' par les ressources validées
//   par les partenaires du projet (un numéro par pays, public mineur,
//   Erasmus+). Supprimer ou remplacer cette entrée avant la mise en
//   production.
const Map<String, RessourceLigneEcoute>
tableRessources = <String, RessourceLigneEcoute>{
  // EXEMPLE FACTICE — à valider et remplacer par les partenaires.
  // Le numéro '0000000000' est manifestement fictif (aucun service ne répond).
  // Libellé explicitement marqué « exemple — à valider » pour éviter toute
  // confusion lors des tests et de la recette.
  'fr': RessourceLigneEcoute(
    nom: "Ligne d'écoute (exemple — à valider)",
    cible: '0000000000',
    type: TypeRessourceEcoute.telephone,
    disponibilite: 'Exemple — à valider',
  ),
};
