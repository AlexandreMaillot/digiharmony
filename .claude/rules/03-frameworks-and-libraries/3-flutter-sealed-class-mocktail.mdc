---
description: En Dart 3+ `sealed class` ne peut pas être implémentée par `Fake` cross-library — `class _MockX extends Fake implements MaSealed {}` plante en compile error. Pour `mocktail` `registerFallbackValue`, utiliser une **valeur réelle** d'une sous-classe sealed plutôt qu'un Fake. Pattern aussi valide pour `bloc_test` qui exige `registerFallbackValue` pour les events / states sealed.
globs: apps/**/test/**/*.dart, apps/**/integration_test/**/*.dart
alwaysApply: false
---
- **Anti-pattern** (compile error Dart 3) :
  ```dart
  class _FakeAuthEtat extends Fake implements AuthEtat {}  // ❌ AuthEtat est sealed
  void main() {
    setUpAll(() => registerFallbackValue(_FakeAuthEtat()));
  }
  ```
  Erreur : `The class 'AuthEtat' can't be implemented outside of its library because it's a sealed class.`
- **Correct** : utiliser une sous-classe sealed réelle comme valeur de fallback :
  ```dart
  void main() {
    setUpAll(() {
      registerFallbackValue(const AuthDeconnecte());           // sous-classe sealed
      registerFallbackValue(const SaisieTelephone());           // état initial bloc
      registerFallbackValue(const HydraterDepuisBrouillon());  // event sealed
    });
  }
  ```
  La valeur sert juste de fallback quand `mocktail` doit générer une valeur lors d'un `any()` non typé. La sous-classe doit être instantiable `const` si possible (sinon `factory` simple).
- **bloc_test** : `whenListen(bloc, Stream<EtatX>.empty(), initialState: <UneSousClasseX>())` exige aussi un état réel non-Fake.
- **Restriction explicite** : la rule sealed ne permet que les sous-classes définies dans le **même fichier ou la même `library`**. Les Fake d'un autre package / fichier sont refusés.
- Cas vécu projet (2026-05-08, modal signin OTP step 1 tests) : tests `etape_saisie_telephone_test.dart` exigent `registerFallbackValue` sur `EvenementAuthModalSignin` (sealed). Solution : `registerFallbackValue(const HydraterDepuisBrouillon())`.
