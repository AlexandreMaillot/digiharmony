---
description: APPLIQUER ces méthodes statiques LORS de la création d'un fichier page Flutter
globs: apps/*/lib/pages/**/*_page.dart
alwaysApply: true
---

Méthodes statiques obligatoires:
- Exposer `static MaterialPage<void> page()`
- Exposer `static Route<void> route()`
- Faciliter la navigation et l'intégration
- Centraliser la configuration de la page

Méthode page():
- Retourner une MaterialPage typée
- Définir un name pour la navigation
- Passer l'instance de la page comme child

Méthode route():
- Retourner une MaterialPageRoute typée
- Utiliser un builder pour créer l'instance
- Permettre la navigation impérative

BlocProvider:
- Créer le bloc dans le create du BlocProvider
- Déclencher l'initialisation avec l'opérateur cascade `..add()`
- Injecter les dépendances via context.read<>()
- Appeler le widget view dans le child

Structure du build:
- Retourner le BlocProvider en racine
- Initialiser le bloc avec ses dépendances
- Déclencher l'événement d'initialisation immédiatement
- Déléguer l'UI au widget view correspondant

Exemple type:
```dart
class MaPage extends StatelessWidget {
  const MaPage({super.key});

  static MaterialPage<void> page() {
    return const MaterialPage<void>(
      name: 'MaPage',
      child: MaPage(),
    );
  }

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const MaPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MaPageBloc(
        repository: context.read<MonRepository>(),
      )..add(const MaPageInitialisee()),
      child: const MaPageView(),
    );
  }
}
```
