# Règle : Monorepo Melos 7 = pub workspaces

**Melos 7.x s'appuie sur les pub workspaces (Dart 3.6+).** L'ancienne syntaxe
`melos: useRootAsPackage: true` + `melos.yaml` ne suffit pas (`melos bootstrap` échoue avec
« not within a Melos workspace »).

## À appliquer

1. **pubspec racine** :
   ```yaml
   environment:
     sdk: ^3.11.0
   workspace:
     - apps/digiharmony_app
     - packages/core_package
   dev_dependencies:
     melos: ^7.0.0
   melos:
     name: digiharmony
   ```
2. **Chaque package membre** : ajouter `resolution: workspace` et une contrainte SDK compatible (`^3.11.0`).
3. Résoudre avec `dart pub get` à la racine → **un seul `pubspec.lock` racine** (les lock-files par package sont supprimés, c'est normal).
4. `melos bootstrap` fonctionne ensuite.

## Pièges

- **Conflit de versions partagé** : en workspace, la résolution est unique. `core_package`
  tirait `test ^1.31.1` (test_api 0.7.12) vs `flutter_test` qui épingle test_api 0.7.9 (SDK).
  → Ne pas figer `test ^x` dans un package membre ; utiliser `test: any` (laisser le workspace résoudre).
- Ne pas recréer `melos.yaml` : la config vit dans le pubspec racine.
