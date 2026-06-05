---
description: APPLIQUER cette architecture LORS de la création de TextFields dans des formulaires
globs: apps/*/lib/pages/**/widgets/text_*_input.dart, apps/*/lib/pages/**/widgets/textarea_*_input.dart
alwaysApply: true
---

Architecture obligatoire pour TextFields:

- StatefulWidget avec contrôleur géré dans initState/dispose
- BlocConsumer pour synchronisation bidirectionnelle
- Variable finale pour le contrôleur
- Synchronisation contrôleur ↔ state

Structure obligatoire:

```dart
class MonTextFieldInput extends StatefulWidget {
  @override
  State<MonTextFieldInput> createState() => _MonTextFieldInputState();
}

class _MonTextFieldInputState extends State<MonTextFieldInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<MonBloc>().state.monChamp.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MonBloc, MonState>(
      listener: (context, state) {
        if (_controller.text != state.monChamp.value) {
          _controller.text = state.monChamp.value;
        }
      },
      builder: (context, state) {
        return TextField(
          controller: _controller,
          onChanged: (value) {
            context.read<MonBloc>().add(MonChampModifie(value));
          },
          // ... reste du widget
        );
      },
    );
  }
}
```

Règles strictes:

- JAMAIS initialiser le contrôleur directement dans le TextField
- TOUJOURS utiliser une variable finale pour le contrôleur
- OBLIGATOIRE : initState() pour initialiser, dispose() pour libérer
- OBLIGATOIRE : BlocConsumer (pas BlocBuilder seul)
- OBLIGATOIRE : Synchronisation dans le listener

## Widgets core réutilisables (sans Bloc, pilotés par `valeurInitiale`)

Pour les widgets de `core/widgets/` qui exposent un paramètre `valeurInitiale` (ou `initialValue`) et encapsulent un `TextEditingController`, la synchronisation Bloc ne s'applique pas — c'est le widget parent qui pousse la valeur. Il faut un `didUpdateWidget` sinon le controller garde sa valeur d'origine pour toute la vie du widget, et les préremplissages externes (« Réutiliser trajet », « Changer client », hydratation brouillon) ne prennent jamais effet.

Pattern obligatoire :

```dart
class _MonChampCoreState extends State<MonChampCore> {
  late final TextEditingController _controleur;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controleur = TextEditingController(text: widget.valeurInitiale ?? '');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(MonChampCore oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Resynchronise si le parent pousse une nouvelle valeurInitiale.
    // Garde-fou !_focusNode.hasFocus : ne jamais écraser la saisie de
    // l'utilisateur pendant qu'il tape.
    final nouveau = widget.valeurInitiale ?? '';
    final ancien = oldWidget.valeurInitiale ?? '';
    if (nouveau != ancien &&
        nouveau != _controleur.text &&
        !_focusNode.hasFocus) {
      _controleur.text = nouveau;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controleur.dispose();
    super.dispose();
  }
}
```

Règles :

- OBLIGATOIRE : implémenter `didUpdateWidget` pour tout widget custom exposant `valeurInitiale` + contrôleur interne.
- OBLIGATOIRE : garde `!_focusNode.hasFocus` pour ne pas écraser une saisie en cours.
- OBLIGATOIRE : comparer aussi `nouveau != _controleur.text` pour éviter un setter inutile (coût cursor/selection).
- INTERDIRE : se reposer sur une `key: ValueKey(valeurInitiale)` dans le parent — la re-création forcée du widget perd le focus, annule la position du curseur et relance les overlays.
- INTERDIRE : lire `widget.valeurInitiale` en dehors de `initState` / `didUpdateWidget` comme source de vérité du texte — le controller est la source de vérité.

Bonnes pratiques:

- Vérifier si le texte a changé avant de mettre à jour le contrôleur
- Gérer les erreurs de parsing dans le listener
- Utiliser des constantes pour les propriétés du TextField
- Tester la synchronisation dans les deux sens
