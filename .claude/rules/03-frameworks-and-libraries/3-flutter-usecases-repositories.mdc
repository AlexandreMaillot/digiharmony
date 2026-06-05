---
description: APPLIQUER les patterns d'instanciation des usecases et repositories LORS de la création de pages Flutter avec BLoC pour éviter les erreurs Provider et maintenir une architecture propre
globs: apps/*/lib/pages/**/*_page.dart
alwaysApply: false
---

Instanciation des usecases:
- Ne jamais injecter les usecases via Provider/context
- Instancier les usecases directement dans la page
- Passer les repositories au constructeur des usecases
- Créer les usecases dans le build de la page

Récupération des repositories:
- Récupérer les repositories via context.read<Repository>()
- Stocker les repositories dans des variables finales
- Passer les repositories aux constructeurs des usecases
- Les repositories sont les seules dépendances dans le Provider

Structure de page obligatoire:
- Récupérer les repositories au début du build
- Instancier les usecases avec les repositories
- Passer les usecases au BLoC via le constructeur
- Le BLoC ne doit jamais accéder directement aux repositories

Exemple correct:
```dart
@override
Widget build(BuildContext context) {
  final monRepository = context.read<MonRepository>();
  final autreRepository = context.read<AutreRepository>();

  return BlocProvider(
    create: (context) => MonBloc(
      monUsecase: MonUsecase(repository: monRepository),
      autreUsecase: AutreUsecase(repository: autreRepository),
    )..add(const MonEventInitialise()),
    child: const MonView(),
  );
}
```

Exemples interdits:
- ❌ context.read<MonUsecase>()
- ❌ Provider<MonUsecase> dans main.dart
- ❌ BLoC accédant directement au repository
- ❌ Usecases injectés via MultiProvider

Avantages:
- Pas d'erreur ProviderNotFoundException
- Architecture claire et explicite
- Dépendances visibles et tracées
- Facilite les tests unitaires
- Usecases créés à la demande
