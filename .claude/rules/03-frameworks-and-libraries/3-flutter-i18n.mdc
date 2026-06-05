---
description: APPLIQUER l'internationalisation LORS de l'affichage de texte dans Flutter
globs: apps/*/lib/**/*_view.dart, apps/*/lib/**/*_page.dart
alwaysApply: true
---

Règle absolue:
- INTERDIRE tout texte en dur dans le code
- Tout texte visible doit passer par l10n
- Aucune exception, même pour le debug
- Utiliser des clés descriptives et explicites

Fichiers de traduction:
- Ajouter les clés dans `lib/l10n/arb/app_fr.arb`
- Ajouter les clés dans `lib/l10n/arb/app_en.arb`
- Maintenir la cohérence entre les fichiers
- Documenter chaque clé avec @description

Format des entrées ARB:
- Clé en camelCase
- Valeur traduite appropriée
- Métadonnées avec @cle
- Description obligatoire de l'usage

Génération des fichiers:
- Exécuter `flutter gen-l10n` après modification
- Vérifier la génération sans erreur
- Commit les fichiers générés
- Tester les traductions

Utilisation dans le code:
- Accéder via `context.l10n.maCle`
- Utiliser dans les widgets Text, labels, etc.
- Passer comme paramètres aux widgets
- Supporter les placeholders avec paramètres

Nommage des clés:
- Préfixer par le contexte (bouton, erreur, titre, message)
- Suffixer par le type (Label, Message, Titre, Hint)
- Être descriptif et unique
- Éviter les abréviations

Exemple complet:
```json
{
  "boutonValider": "Valider",
  "@boutonValider": {
    "description": "Label du bouton de validation du formulaire"
  },
  "erreurChargementMessage": "Impossible de charger les données.",
  "@erreurChargementMessage": {
    "description": "Message d'erreur lors du chargement des données"
  }
}
```

Utilisation:
```dart
Text(context.l10n.boutonValider)
TextField(labelText: context.l10n.champNomLabel)
```
