---
description: APPLIQUER bloc_concurrency LORS de la gestion des events dans les blocs
globs: apps/*/lib/**/*_bloc.dart
alwaysApply: true
---

Principe:
- Utiliser bloc_concurrency pour optimiser la gestion des events
- Choisir l'event transformer approprié selon le type d'event

Event transformers disponibles:
- `concurrent` : traiter les events en parallèle
- `sequential` : traiter les events séquentiellement  
- `droppable` : ignorer les nouveaux events pendant le traitement
- `restartable` : traiter seulement le dernier event et annuler les précédents

Règles de sélection:

Events de recherche/filtrage:
- Utiliser `restartable` pour éviter les recherches obsolètes
- Exemple: recherche dans un champ de texte

Events de chargement/actualisation:
- Utiliser `restartable` pour éviter les appels API multiples
- Exemple: refresh, chargement initial

Events de modification d'état:
- Utiliser `sequential` pour maintenir l'ordre
- Exemple: modification de paramètres, navigation

Events critiques:
- Utiliser `droppable` pour éviter les conflits
- Exemple: sauvegarde, suppression

Events indépendants:
- Utiliser `concurrent` pour optimiser les performances
- Exemple: chargements parallèles de données différentes

Import obligatoire:
```dart
import 'package:bloc_concurrency/bloc_concurrency.dart';
```

Exemple d'utilisation:
```dart
class MonBloc extends Bloc<MonEvent, MonState> {
  MonBloc() : super(const MonStateInitial()) {
    // Event de recherche - restartable
    on<MonEventRecherche>(
      _onRecherche,
      transformer: restartable(),
    );
    
    // Event de chargement - restartable  
    on<MonEventChargement>(
      _onChargement,
      transformer: restartable(),
    );
    
    // Event de modification - sequential
    on<MonEventModification>(
      _onModification,
      transformer: sequential(),
    );
    
    // Event critique - droppable
    on<MonEventSauvegarde>(
      _onSauvegarde,
      transformer: droppable(),
    );
  }
}
```

Bonnes pratiques:
- Analyser le comportement souhaité pour chaque event
- Éviter concurrent() pour les events qui modifient l'état
- Préférer restartable() pour les events de recherche
- Documenter le choix de transformer dans les commentaires
