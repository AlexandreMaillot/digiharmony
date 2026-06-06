---
description: APPLIQUER les bonnes pratiques Dart LORS de l’écriture de code Dart
globs: **/*.dart,**/*/.dart
alwaysApply: false
---

Types stricts :

- Taper explicitement chaque valeur
- Ne jamais utiliser `var` ou `unknown`
- Éviter `as` pour la conversion de type
- Utiliser des gardes de type pour les assertions
- Employer les génériques pour les fonctions réutilisables

Interfaces et types :

- Utiliser `abstract` pour les objets extensibles

Nullabilité :

- Éviter `null` et `undefined` dans les retours

Énumérations :

- Utiliser les enums constantes si besoin
- Définir explicitement les valeurs des enums

Lint & Gestion d’erreur :

- Gérer les erreurs comme `unknown` ou `Error`

Génériques :

- Utiliser des noms de paramètres de type descriptifs

Fonctions asynchrone :

- Toujours mettre le async pour une fonction Future

Const :

- Toujours utiliser const lorsque c'est possible

Modèles / entités :

- Tous les modèles ont toJson() et fromJson() (via json_serializable).
- Un constructeur empty() pour les états initiaux.
- Utilisation systématique de copyWith() (généré ou manuel).
- Égalité via Equatable.
- Nom de classe aligné sur le fichier (ex : article_model.dart → ArticleModel).
- Toujours créer un builder avec le PatternBuilder
- Le builder doit être en dessous de la classe principale
