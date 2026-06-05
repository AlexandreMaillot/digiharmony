---
description: APPLIQUER TextFieldTapRegion autour des overlays custom (Overlay.of(context).insert) ouverts depuis un TextField pour éviter la perte de focus qui annule les taps
globs: apps/*/lib/**/champ_*.dart, apps/*/lib/**/*autocomplete*.dart, apps/*/lib/**/*recherche*.dart
alwaysApply: true
---

Principe :

- Un overlay custom ouvert via `Overlay.of(context).insert(OverlayEntry(...))` vit HORS de la hiérarchie tap du `TextField` parent.
- Quand l'utilisateur clique sur un `InkWell` / `GestureDetector` de cet overlay, Flutter détecte un tap « hors TextField » → défocus → listener `FocusNode.addListener` déclenche `_retirerOverlay()` → l'`InkWell` est détaché AVANT que `onTap` ne puisse tirer.
- Résultat : clic sur suggestion ferme l'overlay SANS sélectionner. Bug invisible aux tests widget (le harnais de tests ne simule pas les TapRegion comme en prod).

Règle absolue :

- OBLIGATOIRE : envelopper le contenu interactif de l'overlay dans `TextFieldTapRegion` (PAS `TapRegion` nu).
- `TextFieldTapRegion` groupe automatiquement la région avec le TextField parent (même `groupId: EditableText`) → tapper dedans ne défocus pas le champ.
- INTERDIRE : `FocusNode.addListener` comme seul mécanisme de fermeture — déclenche le bug décrit.
- INTERDIRE : bricolages `_selectionEnCours` + `onPointerDown` + `Timer(200ms)` pour contourner — préférer `TextFieldTapRegion` qui est la solution Flutter idiomatique (utilisée par `RawAutocomplete` / `Autocomplete`).

Exemple interdit :

```dart
// ❌ Overlay SANS TextFieldTapRegion + FocusNode listener qui ferme
_focusNode.addListener(() {
  if (!_focusNode.hasFocus) _retirerOverlay();
});
// ...
OverlayEntry(
  builder: (_) => Material(
    child: InkWell(onTap: _select, ...), // onTap ne tire jamais
  ),
);
```

Exemple correct :

```dart
// ✅ TextFieldTapRegion enveloppe le contenu cliquable de l'overlay
OverlayEntry(
  builder: (_) => Positioned(
    child: CompositedTransformFollower(
      link: _lien,
      child: TextFieldTapRegion(
        child: Material(
          child: InkWell(onTap: _select, ...), // fonctionne
        ),
      ),
    ),
  ),
);
```

Cas d'usage typiques :

- `ChampRechercheClient` → overlay suggestions clients
- `ChampAutocompleteAdresse` → overlay Places autocomplete
- Tout widget `DropdownWithSearch` custom avec `Overlay.of(context)`

Complément :

- Pour fermer l'overlay sur tap extérieur, `TextFieldTapRegion` fournit `onTapOutside` — utilisable sans casser la sélection interne.
- Si l'overlay doit aussi se fermer sur blur clavier (Tab), garder un `FocusNode.addListener` MAIS avec un délai minimal (50-100 ms) pour laisser le tap se propager, ou mieux : utiliser `TextFieldTapRegion.onTapOutside` seul.

Conséquences du non-respect :

- Clics sur items de l'overlay perdus (pas de callback)
- Overlay qui se ferme au moment de cliquer
- Tests unitaires qui passent en CI mais fail en prod (les tests Flutter ne simulent pas la perte de focus pointer up / down comme en app réelle)
- Ajout progressif de workarounds fragiles (`Timer`, `onPointerDown`, flags maison)
