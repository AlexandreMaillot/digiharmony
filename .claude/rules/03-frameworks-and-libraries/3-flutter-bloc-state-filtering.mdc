---
description: APPLIQUER cette architecture LORS de l'implémentation de recherche avec flutter_bloc
globs: apps/*/lib/**/*_state.dart
alwaysApply: true
---

Architecture du state:
- Stocker uniquement les données complètes
- Ajouter les critères de recherche comme propriétés
- Créer un getter calculé pour les données filtrées
- Ne jamais dupliquer les données

Getter calculé obligatoire:
- Nommer le getter de manière explicite (donneesFiltrees, itineraires)
- Vérifier si les critères sont vides en premier
- Normaliser les termes de recherche (trim, toLowerCase)
- Retourner une liste filtrée immutable

Logique de filtrage dans le getter:
- Implémenter le where sur les données complètes
- Combiner plusieurs critères si nécessaire
- Utiliser contains pour la recherche textuelle
- Retourner toList() pour créer une nouvelle instance

Responsabilité du bloc:
- Charger les données via le repository
- Mettre à jour les critères de recherche uniquement
- Émettre de nouveaux états avec copyWith
- Ne jamais implémenter de logique de filtrage

Événements de recherche:
- Créer un événement pour modification de recherche
- Passer le nouveau terme en paramètre
- Émettre le state avec le terme mis à jour
- Le filtrage est automatique via le getter

Structure type du state:
```dart
final class MaPageState extends Equatable {
  const MaPageState({
    this.donneesCompletes = const [],
    this.termeRecherche = '',
    this.status = MaPageStatus.initial,
  });

  final List<MesData> donneesCompletes;
  final String termeRecherche;
  final MaPageStatus status;

  List<MesData> get donneesFiltrees {
    if (termeRecherche.trim().isEmpty) {
      return donneesCompletes;
    }
    
    final termeNormalise = termeRecherche.trim().toLowerCase();
    
    return donneesCompletes.where((item) {
      return item.nom.toLowerCase().contains(termeNormalise);
    }).toList();
  }

  @override
  List<Object> get props => [donneesCompletes, termeRecherche, status];
}
```

Gestion du bloc:
```dart
void _onRechercheModifiee(
  MaPageRechercheModifiee event,
  Emitter<MaPageState> emit,
) {
  emit(state.copyWith(termeRecherche: event.terme));
}
```

Utilisation dans la vue:
- Utiliser `state.donneesFiltrees` dans le BlocBuilder
- Ne jamais accéder à `state.donneesCompletes` directement
- Le filtrage est réactif et automatique
- Pas de logique de filtrage dans la vue

Avantages de cette approche:
- Séparation des responsabilités claire
- Tests simplifiés et ciblés
- Pas de duplication de données en mémoire
- Filtrage automatique à chaque changement de critère
