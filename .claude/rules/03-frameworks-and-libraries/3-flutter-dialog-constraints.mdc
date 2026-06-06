---
description: APPLIQUER ces contraintes LORS de la création de dialogues Flutter
globs: apps/*/lib/pages/**/views/*_dialog.dart, apps/*/lib/pages/**/views/*_modal.dart
alwaysApply: true
---

Contraintes obligatoires pour les dialogues:
- Taille maximum ET minimum définies
- Responsive sur toutes les plateformes
- Scroll automatique si contenu dépasse
- Éviter les dialogues trop grands sur desktop

Structure recommandée:
```dart
Dialog(
  child: ConstrainedBox(
    constraints: const BoxConstraints(
      maxWidth: 600,
      maxHeight: 700,
      minWidth: 300,
      minHeight: 200,
    ),
    child: Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          // En-tête fixe
          HeaderWidget(),
          
          // Contenu scrollable (adaptatif selon le contenu)
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Contenu du dialogue
                ],
              ),
            ),
          ),
          
          // Actions fixes en bas
          ActionsWidget(),
        ],
      ),
    ),
  ),
)
```

Structure alternative pour listes:
```dart
Dialog(
  child: ConstrainedBox(
    constraints: const BoxConstraints(
      maxWidth: 600,
      maxHeight: 700,
      minWidth: 300,
      minHeight: 200,
    ),
    child: Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          // En-tête fixe
          HeaderWidget(),
          
          // Liste avec scroll natif
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              itemBuilder: (context, index) => ItemWidget(),
              separatorBuilder: (context, index) => Divider(),
            ),
          ),
          
          // Actions fixes en bas
          ActionsWidget(),
        ],
      ),
    ),
  ),
)
```

Règles strictes:
- OBLIGATOIRE : ConstrainedBox avec maxWidth ET maxHeight
- OBLIGATOIRE : minWidth ET minHeight pour éviter les dialogues trop petits
- RECOMMANDÉ : Flexible + SingleChildScrollView pour contenu simple
- RECOMMANDÉ : Expanded + ListView pour contenu avec listes
- OBLIGATOIRE : En-tête et actions fixes, contenu scrollable

Contraintes recommandées:
- Desktop : maxWidth: 600, maxHeight: 700
- Mobile : minWidth: 300, minHeight: 200
- Tablette : Adaptatif selon la taille d'écran
- Toujours prévoir un scroll pour le contenu long

Bonnes pratiques:
- Tester sur différentes tailles d'écran
- Utiliser des breakpoints responsives si nécessaire
- Prévoir des marges et paddings appropriés
- Optimiser l'UX avec des tailles adaptées au contenu
- Choisir Flexible vs Expanded selon le type de contenu
