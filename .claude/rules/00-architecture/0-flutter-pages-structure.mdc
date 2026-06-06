---
description: APPLIQUER cette structure de dossiers LORS de la création d'une nouvelle page Flutter
globs: apps/*/lib/pages/**
alwaysApply: false
---

Structure obligatoire:
- Placer les pages dans le dossier `pages/` (avec un "s")
- Créer un dossier par page avec la structure définie
- Organiser en `bloc/` et `views/`

Dossier bloc:
- Créer un sous-dossier `{nom_page}_bloc/` (suffixe `_bloc/` sans `_page_`, conforme au pattern repo récent — lignes_navette, navettes_detail, prestations_tarifs)
- Contient `{nom_page}_bloc.dart`, `{nom_page}_event.dart`, `{nom_page}_state.dart`
- Optionnel : fichiers `part of` complémentaires `{nom_page}_helpers.dart`, `{nom_page}_handlers.dart` pour respecter la limite 300 lignes par fichier (`1-clean-code.mdc`)

Dossier views:
- Contient `{nom_page}_page.dart` et `{nom_page}_view.dart`
- Le fichier page expose les méthodes statiques
- Le fichier view contient le Scaffold et l'UI

Exemple de structure:
```
pages/
  liste_itineraires/
    bloc/
      liste_itineraires_bloc/
        liste_itineraires_bloc.dart        # constructeur + bindings on<E>
        liste_itineraires_event.dart       # part of
        liste_itineraires_state.dart       # part of
        liste_itineraires_handlers.dart    # part of, optionnel
        liste_itineraires_helpers.dart     # part of, optionnel
    views/
      liste_itineraires_page.dart
      liste_itineraires_view.dart
    widgets/                               # optionnel
      ...
```

Nommage:
- Utiliser le pluriel pour le dossier si pertinent
- Préfixer les fichiers bloc avec le nom complet de la page
- Suffixer avec `_page` et `_view` selon le type
- Pour les `part of` du bloc : utiliser le préfixe `{nom_page}_` (pas `{nom_page}_page_`)

Note historique : la convention initiale du projet utilisait `{nom_page}_page_bloc/{nom_page}_page_bloc.dart`. À partir de 2026-04-29 (lignes_navette), le pattern actuel `{nom_page}_bloc/` (sans `_page_`) a été retenu pour réduire le bruit. Toutes les pages livrées récemment suivent ce pattern.
