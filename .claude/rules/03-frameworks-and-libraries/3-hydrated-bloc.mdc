---
description: APPLIQUER l'initialisation appropriée de HydratedBloc LORS de la configuration du stockage selon la plateforme cible (Web vs Mobile/Desktop)
globs: apps/*/lib/main_*.dart
alwaysApply: true
---

Principe:
- Initialiser HydratedBloc.storage avant l'utilisation de blocs hydratés
- Utiliser une approche différente selon la plateforme cible
- Web : HydratedStorageDirectory.web
- Mobile/Desktop : getApplicationDocumentsDirectory()

Initialisation pour Web:
```dart
import 'package:hydrated_bloc/hydrated_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory.web,
  );
  
  // ... reste de l'initialisation
}
```

Initialisation pour Mobile/Desktop:
```dart
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      await getApplicationDocumentsDirectory().then((value) => value.path),
    ),
  );
  
  // ... reste de l'initialisation
}
```

Imports obligatoires:

Pour Web uniquement:
```dart
import 'package:hydrated_bloc/hydrated_bloc.dart';
```

Pour Mobile/Desktop:
```dart
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
```

Règles strictes:
- OBLIGATOIRE: Appeler WidgetsFlutterBinding.ensureInitialized() avant l'initialisation
- OBLIGATOIRE: Initialiser HydratedBloc.storage avant tout bloc hydraté
- INTERDIRE: Utiliser getApplicationDocumentsDirectory() pour Web
- INTERDIRE: Utiliser HydratedStorageDirectory.web pour Mobile/Desktop

Exemples corrects:

Web:
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory.web,
  );
  
  await bootstrap(() => const App());
}
```

Mobile/Desktop:
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      await getApplicationDocumentsDirectory().then((value) => value.path),
    ),
  );
  
  await bootstrap(() => const App());
}
```

Exemples interdits:

❌ Web avec getApplicationDocumentsDirectory:
```dart
// NE PAS FAIRE pour Web
HydratedBloc.storage = await HydratedStorage.build(
  storageDirectory: HydratedStorageDirectory(
    await getApplicationDocumentsDirectory().then((value) => value.path),
  ),
);
```

❌ Mobile avec HydratedStorageDirectory.web:
```dart
// NE PAS FAIRE pour Mobile/Desktop
HydratedBloc.storage = await HydratedStorage.build(
  storageDirectory: HydratedStorageDirectory.web,
);
```

❌ Sans WidgetsFlutterBinding:
```dart
// INCORRECT - manque ensureInitialized
Future<void> main() async {
  HydratedBloc.storage = await HydratedStorage.build(...);
}
```

Bonnes pratiques:
- Initialiser au tout début de la fonction main()
- Vérifier la plateforme cible avant de choisir l'approche
- Utiliser path_provider uniquement pour Mobile/Desktop
- Gérer les erreurs potentielles d'initialisation
- Tester sur toutes les plateformes cibles

Détection de plateforme (optionnelle):
```dart
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory.web,
    );
  } else {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(
        await getApplicationDocumentsDirectory().then((value) => value.path),
      ),
    );
  }
  
  await bootstrap(() => const App());
}
```

Avantages:
- Compatibilité multi-plateforme garantie
- Stockage persistant optimal pour chaque plateforme
- Évite les erreurs de runtime
- Performance optimale selon la plateforme
