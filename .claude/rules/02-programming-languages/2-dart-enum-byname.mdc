---
description: UTILISER la méthode byName() native LORS de la conversion d'un String en Enum au lieu de créer des switch ou mappings manuels
globs: **/*.dart
alwaysApply: true
---

Principe:

- Utiliser la méthode `.byName()` native de Dart pour convertir String en Enum
- Éviter les switch ou mappings manuels qui dupliquent la logique
- Gérer les erreurs avec try-catch pour les valeurs invalides
- Toujours définir une valeur par défaut en cas d'erreur

Règles strictes:

- INTERDIRE les switch pour convertir String en Enum
- INTERDIRE les Map<String, Enum> pour faire la conversion
- OBLIGATOIRE: Utiliser `EnumName.values.byName(stringValue)`
- OBLIGATOIRE: Gérer `ArgumentError` avec try-catch
- OBLIGATOIRE: Retourner une valeur par défaut appropriée

Structure type:

```dart
static MonEnum parseMonEnum(String valeur) {
  try {
    return MonEnum.values.byName(valeur);
  } on ArgumentError {
    return MonEnum.valeurParDefaut;
  }
}
```

Exemples corrects:

```dart
static StatutAffaire parseStatut(String statut) {
  try {
    return StatutAffaire.values.byName(statut);
  } on ArgumentError {
    return StatutAffaire.initial;
  }
}

static Priorite parsePriorite(String priorite) {
  try {
    return Priorite.values.byName(priorite);
  } on ArgumentError {
    return Priorite.normale;
  }
}
```

Exemples interdits:

```dart
// ❌ Switch manuel
static MonEnum parseEnum(String valeur) {
  switch (valeur) {
    case 'valeur1':
      return MonEnum.valeur1;
    case 'valeur2':
      return MonEnum.valeur2;
    default:
      return MonEnum.valeurParDefaut;
  }
}

// ❌ Map manuel
static final Map<String, MonEnum> _enumMap = {
  'valeur1': MonEnum.valeur1,
  'valeur2': MonEnum.valeur2,
};

static MonEnum parseEnum(String valeur) {
  return _enumMap[valeur] ?? MonEnum.valeurParDefaut;
}
```

Cas spéciaux:

- Si le format du string diffère des noms d'enum, normaliser avant `.byName()`
- Exemple: `valeur.toLowerCase().trim()` avant conversion
- Documenter pourquoi une valeur par défaut spécifique est choisie

Avantages:

- Code plus court et maintenable
- Pas de duplication de logique
- Utilise les capacités natives de Dart
- Moins d'erreurs de maintenance
- Ajout automatique de nouvelles valeurs d'enum
