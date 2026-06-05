---
description: UTILISER le widget Visibility au lieu de if-else LORS de l'affichage conditionnel dans le widget tree pour améliorer les performances et la lisibilité
globs: apps/*/lib/**/*.dart
alwaysApply: true
---

Principe:

- Utiliser `Visibility` pour gérer l'affichage conditionnel de widgets
- Éviter les structures `if-else` dans le widget tree
- Améliorer les performances avec le lazy loading
- Rendre le code plus lisible et maintenable

Règles strictes:

- INTERDIRE `if (condition) widget1 else widget2` dans le children
- OBLIGATOIRE: Utiliser `Visibility` avec `replacement` pour les conditions binaires
- OBLIGATOIRE: Utiliser `Visibility` avec `visible` pour afficher/masquer

Structure obligatoire avec remplacement:

```dart
Visibility(
  visible: condition,
  replacement: WidgetSiConditionFausse(),
  child: WidgetSiConditionVraie(),
)
```

Structure obligatoire sans remplacement:

```dart
Visibility(
  visible: condition,
  child: WidgetSiConditionVraie(),
)
```

Exemples corrects:

```dart
// ✅ Correct - Visibility avec replacement
Visibility(
  visible: user.isLoggedIn,
  replacement: const LoginButton(),
  child: const UserProfile(),
)

// ✅ Correct - Visibility simple
Visibility(
  visible: isLoading,
  child: const CircularProgressIndicator.adaptive(),
)

// ✅ Correct - Visibility avec image
Visibility(
  visible: imageUrl.isNotEmpty,
  replacement: const PlaceholderWidget(),
  child: CachedNetworkImage(imageUrl: imageUrl),
)

// ✅ Correct - Visibility pour bouton
Visibility(
  visible: isCompleted,
  replacement: ElevatedButton(
    onPressed: onComplete,
    child: const Text('Terminer'),
  ),
  child: Text('Terminé le $date'),
)
```

Exemples interdits:

```dart
// ❌ Incorrect - if-else dans children
Column(
  children: [
    if (isLoading)
      const CircularProgressIndicator()
    else
      const Content(),
  ],
)

// ❌ Incorrect - condition ternaire
child: isLoading 
  ? const CircularProgressIndicator()
  : const Content()

// ❌ Incorrect - if sans else dans children
children: [
  if (condition) Widget1(),
  if (!condition) Widget2(),
]

// ❌ Incorrect - multiple if-else
if (state == State.loading)
  LoadingWidget()
else if (state == State.error)
  ErrorWidget()
else
  ContentWidget()
```

Cas spéciaux - Multiple états (utiliser BlocBuilder ou méthode):

```dart
// ✅ Correct - BlocBuilder pour états multiples
BlocBuilder<MyBloc, MyState>(
  builder: (context, state) {
    if (state.status.estEnChargement) {
      return const LoadingWidget();
    }
    if (state.status.estEnErreur) {
      return const ErrorWidget();
    }
    return const ContentWidget();
  },
)

// ✅ Correct - Méthode dédiée pour états multiples
Widget _buildContent() {
  if (status == Status.loading) return const LoadingWidget();
  if (status == Status.error) return const ErrorWidget();
  return const ContentWidget();
}
```

Propriétés utiles de Visibility:

- `visible`: bool - Afficher ou masquer le child
- `replacement`: Widget - Widget affiché si visible est false
- `maintainSize`: bool - Conserver l'espace occupé
- `maintainAnimation`: bool - Maintenir les animations
- `maintainState`: bool - Maintenir l'état du widget

Avantages de Visibility:

- Performance optimisée (lazy loading du child)
- Code plus lisible et structuré
- Facilite le débogage
- Meilleure gestion de l'état
- Évite la reconstruction inutile
- Options avancées (maintainSize, maintainState)

Bonnes pratiques:

- Préférer `Visibility` pour les conditions binaires simples
- Utiliser `BlocBuilder` pour les états multiples complexes
- Créer des méthodes dédiées pour les logiques très complexes
- Toujours nommer les widgets pour améliorer la lisibilité
- Utiliser `const` pour les widgets statiques
- Tester l'affichage avec différentes conditions

Cas d'usage:

- Affichage conditionnel d'images (avec/sans URL)
- Boutons avec états (actif/désactivé visuellement)
- Placeholder pendant chargement
- Contenu utilisateur connecté/déconnecté
- Affichage de messages d'erreur
- Widgets basés sur permissions
