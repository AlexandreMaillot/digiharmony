---
description: APPLIQUER la validation Formz LORS de la création de formulaires Flutter
globs: apps/*/lib/pages/**/models/*_input.dart, apps/*/lib/pages/**/bloc/*_bloc.dart
alwaysApply: true
---

Validation Formz obligatoire:
- Utiliser FormzInput pour chaque champ de formulaire
- Le bloc doit étendre FormzMixin pour la validation globale
- Utiliser bloc.isValid (pas state.isValid) pour vérifier la validité
- Bouton désactivé si tous les champs requis ne sont pas remplis

Structure des modèles FormzInput:
```dart
enum MonChampValidationError { vide }

class MonChampInput extends FormzInput<String, MonChampValidationError> {
  const MonChampInput.pure() : super.pure('');
  const MonChampInput.dirty([String value = '']) : super.dirty(value);

  @override
  MonChampValidationError? validator(String value) {
    return value.isNotEmpty ? null : MonChampValidationError.vide;
  }
}
```

Structure du bloc avec FormzMixin:
```dart
class MonBloc extends Bloc<MonEvent, MonState> with FormzMixin {
  @override
  List<FormzInput<String, dynamic>> get inputs => [
    state.champ1,
    state.champ2,
    // ... autres champs requis
  ];
}
```

Validation des champs:
- Champs pure : Ne pas afficher d'erreur
- Logique : state.field.isPure ? null : (state.field.error != null ? errorMessage : null)
- Erreurs affichées seulement après interaction utilisateur

Bonnes pratiques:
- Créer un enum pour chaque type d'erreur de validation
- Implémenter validator() pour chaque FormzInput
- Utiliser isPure pour distinguer "pas touché" vs "touché mais vide"
- Tester la validation avec des cas limites
