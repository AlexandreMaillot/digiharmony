import 'package:flutter/widgets.dart';

/// Quitte un ecran de seance en revenant a l'ecran precedent, si possible.
///
/// Les ecrans de seance utilisent `PopScope(canPop: false)` pour intercepter
/// le retour systeme et demander confirmation. Dans ce cas, `maybePop()`
/// respecte `canPop: false` et NE sort PAS (il re-declenche `onPopInvoked`,
/// d'ou une boucle qui fige l'ecran). On utilise donc `pop()`, qui contourne
/// le `PopScope`, garde par `canPop()` pour rester sans effet quand l'ecran
/// est la racine de navigation (mode previsualisation via `main_development`).
void quitterEcranSeance(BuildContext context) {
  final nav = Navigator.of(context);
  if (nav.canPop()) nav.pop();
}
