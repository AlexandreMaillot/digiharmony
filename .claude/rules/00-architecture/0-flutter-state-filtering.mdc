---
description: APPLIQUER cette architecture LORS de l'implémentation de recherche ou filtrage avec Bloc
globs: apps/*/lib/**/*_state.dart, apps/*/lib/**/*_bloc.dart
alwaysApply: false
---

Principe fondamental:
- Placer la logique de filtrage dans le state, pas dans le bloc
- Utiliser des getters calculés pour les données filtrées
- Stocker uniquement les données complètes dans le state
- Le bloc ne fait que mettre à jour les critères

Structure du state:
- Conserver les données complètes (ex: `donneesCompletes`)
- Stocker les critères de recherche (ex: `termeRecherche`)
- Créer un getter calculé pour les données filtrées
- Ne jamais dupliquer les données dans le state

Implémentation du getter:
- Vérifier si les critères sont vides
- Appliquer le filtrage sur les données complètes
- Retourner une nouvelle liste filtrée
- Normaliser les termes de recherche (trim, toLowerCase)

Responsabilité du bloc:
- Charger les données complètes via le repository
- Mettre à jour uniquement les critères de recherche
- Ne pas implémenter de logique de filtrage
- Émettre des états avec les nouveaux critères

Stratégie de filtrage local:
- Filtrer côté client, pas via API
- Charger toutes les données une fois
- Le bouton actualiser recharge depuis le repository
- Le filtrage est automatique via le getter calculé
