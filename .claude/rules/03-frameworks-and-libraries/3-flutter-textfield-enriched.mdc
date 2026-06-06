---
description: APPLIQUER ces enrichissements LORS de la création de TextFields
globs: apps/*/lib/pages/**/widgets/text_*_input.dart, apps/*/lib/pages/**/widgets/textarea_*_input.dart
alwaysApply: true
---

Enrichissements obligatoires pour TextFields:
- AutofillHints appropriés selon le type de champ
- textCapitalization selon le contenu attendu
- textInputAction pour la navigation entre champs
- Propriétés d'accessibilité

AutofillHints par type de champ:
```dart
// Adresse
autofillHints: const [AutofillHints.streetAddressLine1]

// Nom/Prénom
autofillHints: const [AutofillHints.name]

// Email
autofillHints: const [AutofillHints.email]

// Téléphone
autofillHints: const [AutofillHints.telephoneNumber]

// Code postal
autofillHints: const [AutofillHints.postalCode]

// Ville
autofillHints: const [AutofillHints.addressCity]
```

textCapitalization par type:
```dart
// Noms propres
textCapitalization: TextCapitalization.words

// Phrases complètes
textCapitalization: TextCapitalization.sentences

// Tout en majuscules
textCapitalization: TextCapitalization.characters

// Pas de capitalisation (emails, codes)
textCapitalization: TextCapitalization.none
```

textInputAction par contexte:
```dart
// Champ suivant
textInputAction: TextInputAction.next

// Nouvelle ligne (textarea)
textInputAction: TextInputAction.newline

// Terminer (dernier champ)
textInputAction: TextInputAction.done

// Rechercher
textInputAction: TextInputAction.search
```

Bonnes pratiques:
- Adapter les hints au contexte métier
- Utiliser des constantes pour les valeurs récurrentes
- Tester l'autofill sur différents appareils
- Optimiser l'UX avec la bonne capitalisation
- Prévoir la navigation clavier appropriée
