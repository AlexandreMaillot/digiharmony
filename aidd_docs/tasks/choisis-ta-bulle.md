---
page: Choisis ta bulle (Bubbles)
route: /bubbles (BubblesPage)
us: []
shared_components: [DigiToolbar, BubbleCard, AppBackground]
i18n_keys: [bubblesTitle, bubblesSubtitle, bubblesRespirationLabel, bubblesRespirationHint, bubblesRespirationDuration, bubblesSensesLabel, bubblesSensesHint, bubblesSensesDuration, bubblesStretchLabel, bubblesStretchHint, bubblesStretchDuration, bubblesDetoxLabel, bubblesDetoxHint, bubblesDetoxDuration, bubblesOfflineHint, bubblesToolbarBack]
tests: aidd_docs/tasks/choisis-ta-bulle.tests.md (à remplir par Kent en étape 5)
created: 2026-06-05
updated: 2026-06-05
---

# Plan de page — « Choisis ta bulle » (BubblesPage)

> Plan auto-suffisant pour éditeur IA. Conforme aux règles `.claude/rules/` et
> `aidd_docs/memory/` de DIGIHARMONY : Flutter, monorepo Melos 7, client-only,
> **zéro collecte, zéro réseau, zéro SDK analytics**, vibration via `HapticFeedback`
> uniquement, i18n ARB gen-l10n 8 langues (repli `en`).

---

## 1. Contexte de la page

| Élément | Valeur |
| --- | --- |
| Nom | « Choisis ta bulle » — écran de sélection d'une catégorie d'exercice |
| Widget page | `BubblesPage` (entrée) + `BubblesView` (UI), fichier `lib/bubbles/view/bubbles_page.dart` |
| Route logique | `/bubbles` (référence interne `BubblesPage`) |
| Parent | Écran d'accueil / Home → **on y arrive depuis un parent** : le chevron retour est conservé (`Navigator.maybePop`) |
| Accès / rôles / auth | **Aucun** — app sans compte, sans identification, sans permission. Accès libre |
| Données | **Statiques en dur** (4 bulles), modèle dans `core_package`. Aucune lecture Drift, aucun HydratedBloc, aucune collecte |
| État applicatif | **Aucun Bloc/Cubit nécessaire** : page purement présentationnelle sans état mutable (cf. §6). `StatelessWidget` |
| États écran | **État nominal uniquement** — pas d'empty, pas de loading, pas d'error (données const en mémoire) |

**Raison du « pas de Bloc » :** la règle `coding-assertions` impose le state via `bloc`/`flutter_bloc`
*uniquement quand il y a de l'état applicatif*. Ici la liste est `const`, immuable, sans I/O ni
`watch()` Drift. Introduire un Cubit serait du sur-engineering. Si une évolution future rend la
liste dynamique (lecture Drift, favoris), créer alors `BubblesCubit` exposant `List<BubbleCategory>`.

---

## 2. User Stories liées

**Aucune US référencée fournie.** Le plan s'appuie sur les **décisions validées par l'utilisateur**
(reportées en §11) qui font office de critères d'acceptation. À rattacher ultérieurement si une US
backlog existe (mettre à jour le champ `us:` de l'en-tête et du registry).

Critères d'acceptation dérivés des décisions (source des tests Kent) :
- AC-1 : 4 bulles affichées (Respiration, Les sens, Étirement, Détox), chacune fonctionnelle.
- AC-2 : tap sur une bulle → `HapticFeedback.selectionClick()` **puis** navigation vers l'écran dédié de la catégorie.
- AC-3 : toolbar = bouton retour (chevron-left) + logo centré **uniquement** (pas de hamburger).
- AC-4 : chevron retour → revient au parent.
- AC-5 : tout texte visible provient de l'ARB (gen-l10n), aucune chaîne en dur.
- AC-6 : si `reduceMotion` actif → animations float/shimmer désactivées ou réduites.
- AC-7 : données 100% statiques, aucune lecture Drift / aucune écriture / aucune collecte.

---

## 3. Design (capturé) → mapping widgets

Fond bleu nuit `#1F2C49` + 2 halos radiaux décoratifs. Toolbar (retour + logo centré).
Titre + sous-titre. Grille 2×2 organique de 4 bulles flottantes (float + anneau shimmer rotatif),
chacune : icône, label, badge durée, hint sous le cercle. Footer : « Tap pour commencer — tout se passe hors ligne ».

### Tokens design (à centraliser, cf. §8)
| Token | Valeur |
| --- | --- |
| `background` (bleu nuit) | `#1F2C49` |
| `primary` | `#3FB8E6` |
| `accent` | `#F5C842` |
| `foreground` | `#F2F6FB` |
| Police | `DM Sans` |
| Radius | 12 / 20 / 24 |
| Couleurs bulles | Respiration cyan `#3FB8E6` · Les sens violet · Étirement vert · Détox vert clair |

### Icônes (Material par défaut, pas de package tiers — zéro dépendance ajoutée)
| Bulle | Icône design (lucide) | Équivalent Material proposé |
| --- | --- | --- |
| Respiration | `wind` | `Icons.air` |
| Les sens | `eye` | `Icons.visibility_outlined` |
| Étirement | `activity` | `Icons.self_improvement` (ou `Icons.accessibility_new`) |
| Détox | `leaf` | `Icons.eco_outlined` |

> Les icônes sont portées par le **modèle** `BubbleCategory.icon` (`IconData`) pour rester data-driven.
> Aucun asset image requis pour ces 4 bulles.

---

## 4. Arbre de widgets

```
BubblesPage (StatelessWidget)              // lib/bubbles/view/bubbles_page.dart
└─ BubblesView (StatelessWidget)
   └─ Scaffold (extendBodyBehindAppBar: true, backgroundColor: bubbles bg)
      ├─ appBar: DigiToolbar(                // composant partagé (cf. §7)
      │     onBack: () => Navigator.maybePop(context),
      │     showMenu: false,                 // ← hamburger RETIRÉ
      │   )
      └─ body: AppBackground(                // halos radiaux décoratifs (composant partagé §7)
            child: SafeArea(
              child: Column(
                ├─ _BubblesHeader            // titre + sous-titre
                │    ├─ Text(l10n.bubblesTitle)      // DM Sans, foreground
                │    └─ Text(l10n.bubblesSubtitle)
                ├─ Expanded(
                │    child: _BubblesGrid(categories: BubbleCategory.all)
                │      └─ GridView/Wrap 2×2 « organique » (offsets verticaux alternés)
                │         └─ BubbleCard(category) × 4      // composant réutilisable §7
                │            └─ Semantics(button:true, label: «<label>, <durée>, <hint>»)
                │               └─ GestureDetector/InkWell(onTap: _onBubbleTap)
                │                  └─ Stack
                │                     ├─ _ShimmerRing       // anneau shimmer rotatif (animé)
                │                     ├─ CircleAvatar/Container (cercle + Icon)
                │                     ├─ _DurationBadge(category.duration)  // badge accent
                │                     ├─ Text(category.label)
                │                     └─ Text(category.hint)  // hint sous le cercle
                └─ _OfflineFooter
                     └─ Text(l10n.bubblesOfflineHint)
              )
            )
          )
```

### Comportement du tap (`_onBubbleTap`)
```dart
Future<void> _onBubbleTap(BuildContext context, BubbleCategory category) async {
  await HapticFeedback.selectionClick();        // feedback AVANT navigation (AC-2)
  if (!context.mounted) return;
  Navigator.of(context).push(category.route(context));   // cf. §5
}
```

---

## 5. Navigation / Routes

Tap sur chaque bulle → écran dédié de la catégorie. **Ces écrans sont créés en parallèle par
d'autres agents** : on les référence par un **nom de route logique** sans présumer de leur
implémentation interne (constructeur, providers internes).

| Bulle | Route logique cible | Page cible (référence) |
| --- | --- | --- |
| Respiration | `breathing` | `BreathingPage` |
| Les sens | `senses` | `SensesPage` |
| Étirement | `stretch` | `StretchPage` |
| Détox | `detox` | `DetoxPage` (player audio `just_audio`) |

### Stratégie de découplage (résilience à l'implémentation tierce)
Le modèle `BubbleCategory` ne référence **pas** directement les classes de pages (qui peuvent ne pas
encore exister / changer de signature). On introduit une **table de routing injectée** côté app :

```dart
// lib/bubbles/bubbles_routes.dart  (côté app, pas core_package)
typedef BubbleRouteBuilder = Route<void> Function();

const Map<BubbleCategoryId, BubbleRouteBuilder Function()> _routeRegistry = {...};
// Au runtime : MaterialPageRoute(builder: (_) => const BreathingPage()), etc.
```
- `BubbleCategory` (dans `core_package`) porte un **`BubbleCategoryId`** (enum) — donnée pure, sans dépendance Flutter UI.
- Le mapping `id → Route` vit **dans l'app** (`lib/bubbles/`), où les pages dédiées seront importées.
- Tant qu'une page dédiée n'est pas livrée, son builder reste un **TODO compilable** (référence par nom) ; remplacer par `const XxxPage()` dès livraison. Les 4 bulles restent **fonctionnelles** (pas de placeholder visuel), seul le builder est à brancher.

> Navigation via `Navigator` (Material) — cohérent avec le scaffold VGC actuel (`home:` direct,
> pas encore de router déclaratif). Si un router (`go_router`/flow_builder) est introduit ailleurs,
> adapter le registry pour produire des routes nommées.

---

## 6. Pas d'état applicatif (justifié)

- Aucun `Bloc`/`Cubit` créé : page sans état mutable, données `const`.
- Aucun accès **Drift** (interdit ici : pas de journal, pas d'agrégat).
- Aucun **HydratedBloc** (la langue reste gérée globalement par le `LocaleCubit` existant au-dessus du `MaterialApp`).
- `reduceMotion` est lu via `MediaQuery.of(context).disableAnimations` (pas un état applicatif).

---

## 7. Modèle de données — `core_package`

Fichier : `packages/core_package/lib/src/bubbles/bubble_category.dart`
Export : ajouter `export 'src/bubbles/bubble_category.dart';` dans `lib/core_package.dart`.

```dart
import 'package:flutter/widgets.dart'; // pour IconData/Color (widgets, pas material)

/// Identifiant stable d'une catégorie de bulle (sert au routing côté app).
enum BubbleCategoryId { respiration, senses, stretch, detox }

/// Donnée statique, immuable, d'une bulle « apaisante ».
/// Aucune persistance, aucune collecte : liste const en mémoire.
@immutable
class BubbleCategory {
  const BubbleCategory({
    required this.id,
    required this.icon,
    required this.color,
  });

  final BubbleCategoryId id;
  final IconData icon;
  final Color color;

  /// Les 4 bulles, ordre = ordre d'affichage de la grille 2×2.
  static const List<BubbleCategory> all = <BubbleCategory>[
    BubbleCategory(id: BubbleCategoryId.respiration, icon: Icons.air,                 color: Color(0xFF3FB8E6)),
    BubbleCategory(id: BubbleCategoryId.senses,      icon: Icons.visibility_outlined, color: Color(0xFF9B7BE8)),
    BubbleCategory(id: BubbleCategoryId.stretch,     icon: Icons.self_improvement,    color: Color(0xFF5FC98A)),
    BubbleCategory(id: BubbleCategoryId.detox,       icon: Icons.eco_outlined,        color: Color(0xFF8FE08F)),
  ];
}
```

> **Texte = i10n côté app**, pas dans le modèle. Le label/hint/durée sont résolus par
> `BubbleCategoryId` → clé ARB dans une extension côté app (mapping en §9), pour respecter
> « toute chaîne UI passe par l'ARB » et garder `core_package` sans dépendance l10n de l'app.
>
> ⚠️ `Icons`/`Color` viennent de `package:flutter/widgets.dart`. Si l'on veut `core_package`
> 100% sans Flutter, alternative : stocker `iconCodePoint`/`colorValue` (int) et reconstruire
> côté app. **Choix retenu** : `IconData`/`Color` directs (plus simple, `flutter/widgets` est
> acceptable dans un package modèle d'app Flutter). Le test unitaire valide la longueur 4 et l'unicité des `id`.

---

## 8. Composants réutilisables candidats (vs registry)

Aucun plan existant dans `aidd_docs/tasks/` (premier plan du projet → registry créé). Composants
extraits car réutilisés par les écrans dédiés (breathing/senses/stretch/detox) qui partagent la même charte :

| Composant | Fichier proposé | Rôle | Réutilisation |
| --- | --- | --- | --- |
| `DigiToolbar` | `lib/widgets/digi_toolbar.dart` | AppBar custom : retour (chevron-left) + logo centré, param `showMenu` (false ici) | Tous les écrans à toolbar |
| `AppBackground` | `lib/widgets/app_background.dart` | Fond bleu nuit `#1F2C49` + 2 halos radiaux décoratifs | Tous les écrans « bulles » |
| `BubbleCard` | `lib/bubbles/widgets/bubble_card.dart` | Cercle animé (icône + label + badge durée + hint + shimmer ring) | Spécifique bubbles, candidat partage si réutilisé |
| `BubbleTheme`/`AppTheme` | `lib/theme/app_theme.dart` | Tokens couleurs/radius + police DM Sans | Tout le thème app |

> **DM Sans** : déclarer la police dans `pubspec.yaml` (`flutter > fonts`) + déposer l'asset, ou
> via `google_fonts` **non listé** dans les deps → **ne pas ajouter de dépendance réseau**
> (`google_fonts` télécharge en ligne = viole zéro-réseau). **Décision** : embarquer DM Sans en
> **asset local** (`assets/fonts/DMSans-*.ttf`) et le déclarer dans `pubspec.yaml`. Aucune deps ajoutée.

---

## 9. Internationalisation (ARB / gen-l10n)

Système détecté : **gen-l10n / ARB**, dir `lib/l10n/arb`, template `app_en.arb`, 8 langues
`en/fr/el/it/ro/tr/es/mk`, repli `en`. Helper `context.l10n` (extension existante).

### Clés à créer (préfixe `bubbles*`)
| Clé ARB | EN | FR |
| --- | --- | --- |
| `bubblesTitle` | "Bubbles to soothe you" | "Des bulles pour t'apaiser" |
| `bubblesSubtitle` | "Choose based on how you feel" | "Choisis selon comment tu te sens" |
| `bubblesRespirationLabel` | "Breathing" | "Respiration" |
| `bubblesRespirationHint` | "when you're stressed or angry" | "quand tu es stressé ou en colère" |
| `bubblesRespirationDuration` | "1–2 min" | "1–2 min" |
| `bubblesSensesLabel` | "Senses" | "Les sens" |
| `bubblesSensesHint` | "when anxiety rises" | "quand l'anxiété monte" |
| `bubblesSensesDuration` | "~3 min" | "~3 min" |
| `bubblesStretchLabel` | "Stretching" | "Étirement" |
| `bubblesStretchHint` | "when your body is tense" | "quand ton corps est tendu" |
| `bubblesStretchDuration` | "1 min" | "1 min" |
| `bubblesDetoxLabel` | "Detox" | "Détox" |
| `bubblesDetoxHint` | "when you really want to disconnect" | "quand tu veux vraiment décrocher" |
| `bubblesDetoxDuration` | "you choose" | "tu choisis" |
| `bubblesOfflineHint` | "Tap to begin — everything happens offline" | "Tap pour commencer — tout se passe hors ligne" |
| `bubblesToolbarBack` | "Back" | "Retour" (label a11y du bouton retour) |

### Fichiers cibles
- `app_en.arb` : valeurs EN ci-dessus **+ bloc `@bubblesXxx`** avec `description` (template = obligatoire).
- `app_fr.arb` : valeurs FR.
- `app_el.arb`, `app_it.arb`, `app_ro.arb`, `app_tr.arb`, `app_es.arb`, `app_mk.arb` :
  **placeholders = copie de la valeur EN** (repli `en`), à marquer pour **relecture native ultérieure**
  (el/ro/tr/mk = relecture locuteur natif requise, cf. coding-assertions).
- Régénérer : `flutter gen-l10n` (puis vérifier `flutter analyze`).

### Résolution label/hint/durée par `BubbleCategoryId` (côté app)
```dart
// lib/bubbles/bubble_l10n.dart
extension BubbleCategoryL10n on BubbleCategory {
  String label(AppLocalizations l) => switch (id) {
    BubbleCategoryId.respiration => l.bubblesRespirationLabel,
    BubbleCategoryId.senses      => l.bubblesSensesLabel,
    BubbleCategoryId.stretch     => l.bubblesStretchLabel,
    BubbleCategoryId.detox       => l.bubblesDetoxLabel,
  };
  String hint(AppLocalizations l) => switch (id) { ... };      // bubblesXxxHint
  String duration(AppLocalizations l) => switch (id) { ... };  // bubblesXxxDuration
}
```

---

## 10. Animations (flutter_animate) + accessibilité

`flutter_animate: ^4.5.2` est **déjà en dépendance** (pas encore utilisé ailleurs → 1ère utilisation).

| Animation | Cible | Effet `flutter_animate` |
| --- | --- | --- |
| **Float** | chaque `BubbleCard` (cercle) | `.animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: -8, duration: 2200.ms, curve: Curves.easeInOut)` — déphasage par index pour effet « organique » |
| **Shimmer ring** | anneau autour du cercle | `.animate(onPlay: (c) => c.repeat()).rotate(duration: 6.s)` + `.shimmer()` |
| **Halos** | `AppBackground` | léger `.fadeIn` à l'entrée, statiques ensuite |

### Respect `reduceMotion` (AC-6) — OBLIGATOIRE
```dart
final reduceMotion = MediaQuery.of(context).disableAnimations; // pilote iOS/Android
```
- Si `reduceMotion == true` → **ne pas** lancer `repeat()` (float/shimmer/rotate désactivés) ;
  afficher l'état statique (cercle posé, anneau fixe). Optionnel : un `fadeIn` unique court toléré.
- Encapsuler la logique dans `BubbleCard` : `effects` conditionnels selon `reduceMotion`.
- Test Kent : avec `MediaQueryData(disableAnimations: true)`, vérifier qu'aucune animation en boucle n'est active (pas de `pump` infini) et que la carte reste tappable.

---

## 11. États de la page

| État | Présent ? | Détail |
| --- | --- | --- |
| Nominal | ✅ | 4 bulles affichées, animées (ou statiques si reduceMotion) |
| Loading | ❌ | Données `const`, aucun I/O |
| Empty | ❌ | Liste toujours = 4 (garantie par le test d'unicité/longueur) |
| Error | ❌ | Aucune source faillible (pas de Drift, pas de réseau) |

Feedback utilisateur : **`HapticFeedback.selectionClick()`** au tap (avant navigation). Aucune
popup/confirmation/snackbar — navigation directe vers l'écran dédié.

---

## 12. Contraintes projet (rappel, à respecter à 100%)

- ✅ **Zéro collecte / zéro réseau** : aucun SDK analytics/tracking/réseau ; pas de `google_fonts` (réseau) → DM Sans en asset local.
- ✅ **Vibration via `HapticFeedback`** uniquement (pas de permission `VIBRATE`, pas de package vibration).
- ✅ **Pas de Drift / pas de HydratedBloc** sur cette page (données statiques).
- ✅ **i18n ARB obligatoire** : aucune chaîne en dur, 8 langues, repli `en`.
- ✅ **Lints** `very_good_analysis` + `bloc_lint` stricts (0 warning/info) — `const` partout où possible.
- ✅ **Naming** : fichiers snake_case, widgets PascalCase.
- ✅ **Monorepo** : modèle dans `core_package`, UI dans `apps/digiharmony_app`.
- ✅ Aucune nouvelle dépendance pub (réutilise `flutter_animate`, Material icons, `HapticFeedback`).

---

## 13. Fichiers à créer / modifier

**core_package**
- `packages/core_package/lib/src/bubbles/bubble_category.dart` (modèle + enum + liste `all`).
- `packages/core_package/lib/core_package.dart` (ajouter l'export).

**app**
- `apps/digiharmony_app/lib/bubbles/view/bubbles_page.dart` (`BubblesPage` + `BubblesView` + sous-widgets header/grid/footer).
- `apps/digiharmony_app/lib/bubbles/widgets/bubble_card.dart` (`BubbleCard` + shimmer ring + float, gestion reduceMotion).
- `apps/digiharmony_app/lib/bubbles/bubbles_routes.dart` (mapping `BubbleCategoryId` → `Route`).
- `apps/digiharmony_app/lib/bubbles/bubble_l10n.dart` (extension label/hint/duration).
- `apps/digiharmony_app/lib/bubbles/bubbles.dart` (barrel export).
- `apps/digiharmony_app/lib/widgets/digi_toolbar.dart` (composant partagé).
- `apps/digiharmony_app/lib/widgets/app_background.dart` (composant partagé).
- `apps/digiharmony_app/lib/theme/app_theme.dart` (tokens couleurs/radius/DM Sans).
- `apps/digiharmony_app/lib/l10n/arb/app_*.arb` (×8 : ajouter clés `bubbles*`).
- `apps/digiharmony_app/pubspec.yaml` (déclarer la police DM Sans + asset fonts).
- Brancher l'entrée : remplacer (ou router vers) `home:` selon l'intégration Home (hors scope de cette page, mais `BubblesPage` doit être atteignable depuis le parent Home).

**Génération**
- `flutter gen-l10n` après ajout ARB.
- `flutter analyze --fatal-infos` (0 info/warning) + `dart format`.

---

## 14. Critères de complétude (Definition of Done)

- [ ] 4 bulles rendues, ordre = Respiration, Les sens, Étirement, Détox.
- [ ] Toolbar = retour + logo centré, **sans hamburger**.
- [ ] Chevron retour → `Navigator.maybePop` (revient au parent).
- [ ] Tap → `HapticFeedback.selectionClick()` puis navigation vers la page dédiée correspondante.
- [ ] Tous textes via ARB `bubbles*`, FR+EN remplis, 6 autres langues = repli EN (TODO relecture native).
- [ ] Float + shimmer actifs ; désactivés/réduits si `reduceMotion`.
- [ ] Aucune deps ajoutée, aucun réseau, aucune permission, aucun Drift/HydratedBloc.
- [ ] Lints stricts verts, `gen-l10n` OK.
- [ ] Tests unitaires/widget générés par Kent (étape 5) verts.
