---
page: Conseils (AdvicePage)
route: /advice (carrousel de conseils par émotion — atteint depuis Journal/Home)
us: []
shared_components: [DigiToolbar, AppBackground, AppTheme]
i18n_keys: [adviceTitle, adviceEmotionLabel, adviceDoSectionLabel, adviceAvoidSectionLabel, adviceTryBreathing, advicePrev, adviceNext, adviceApply, adviceAppliedConfirmation, adviceCardTitleAnger, adviceCardTitleSadness, adviceCardTitleFear, adviceCardTitleStress, adviceCardTitleLoneliness, adviceDoAnger1, adviceDoAnger2, adviceDoAnger3, adviceAvoidAnger1, adviceAvoidAnger2, adviceDoSadness1, adviceDoSadness2, adviceDoSadness3, adviceAvoidSadness1, adviceAvoidSadness2, adviceDoFear1, adviceDoFear2, adviceDoFear3, adviceAvoidFear1, adviceAvoidFear2, adviceDoStress1, adviceDoStress2, adviceDoStress3, adviceAvoidStress1, adviceAvoidStress2, adviceDoLoneliness1, adviceDoLoneliness2, adviceDoLoneliness3, adviceAvoidLoneliness1, adviceAvoidLoneliness2]
shared_components_extracted: [EmotionAdvice/AdviceCatalog (core_package — catalogue statique = SOURCE DE VÉRITÉ), NegativeEmotion enum (core_package), AppTheme tokens couleurs émotions (angerRed/sadnessBlue/fearViolet/stressOrange/lonelinessTeal)]
tests: aidd_docs/tasks/conseils.tests.md (à remplir par Kent en étape 5)
created: 2026-06-05
updated: 2026-06-05
---

# Plan de page — « Conseils » (AdvicePage)

> Plan auto-suffisant pour éditeur IA. Conforme aux règles `aidd_docs/memory/` +
> `aidd_docs/rules/` de DIGIHARMONY : Flutter, monorepo Melos 7, **client-only,
> zéro collecte, zéro réseau, zéro SDK analytics/tracking**, aucune permission
> au-delà de `PACKAGE_USAGE_STATS`, vibration via `HapticFeedback` uniquement,
> pas de backend ni Firebase, i18n ARB gen-l10n 8 langues (repli `en`),
> **DM Sans en asset local (PAS `google_fonts`)**, **icônes Material only**,
> aucun asset image (cartes empilées via `Stack`).
>
> Carrousel de **5 cartes de conseils, une par émotion négative**. Réutilise les
> briques partagées `DigiToolbar`, `AppBackground`, `AppTheme` créées par les
> plans bulles. CTA « Essayer la respiration » → **`/bubble/breathing`**
> (`BreathingPage`, déjà planifié dans `respiration.md`).

---

## 0. Réconciliation architecture — OÙ VIVENT LES CONSEILS ? (décision justifiée)

Le memory bank crée une ambiguïté à lever explicitement :

- `architecture.md` / `project-brief.md` : **Drift** stocke « journal d'humeur,
  **conseils**, agrégats » ; **DEC-001/DEC-002** : le journal va dans Drift
  (relationnel, réactif `watch()`), l'état léger persistant dans HydratedBloc,
  et le **super-conseil** (7 émotions négatives consécutives) est **DÉRIVÉ de
  Drift, jamais dupliqué**.

Il faut distinguer **deux choses qui portent le même mot « conseil »** :

| Notion | Nature | Où elle vit |
| --- | --- | --- |
| **Catalogue de conseils** (contenu fixe par émotion : titres, listes à-faire / à-éviter) | **Donnée de référence FIXE**, identique pour tous, jamais éditée par l'utilisateur, traduite en 8 langues | **Statique dans `core_package`** (clés i18n) — **SOURCE DE VÉRITÉ UNIQUE** |
| **Faits liés aux conseils** (un conseil *a été appliqué*, le *super-conseil* a été déclenché) | **Données comportementales/agrégats**, datées, requêtables, dérivées du journal | **Drift** (DEC-001), quand le journal sera planifié |

**DÉCISION RETENUE (à respecter par l'éditeur IA) :**

1. **Le CATALOGUE de conseils est un catalogue statique `const` dans
   `core_package`** (`AdviceCatalog.all`), portant des **clés i18n** (jamais du
   texte en dur). C'est la **source de vérité unique**. Justification : contenu
   de référence figé, multilingue, sans état — exactement le même pattern que
   `BubbleCategory.all`, `StretchRoutine.defaultRoutine`, `DetoxAmbiance` déjà
   en place dans `core_package`. Le mettre en Drift créerait une **duplication
   de la vérité** (violation directe de la règle « ne pas dupliquer la vérité »
   de DEC-001/DEC-002) et imposerait du codegen + des migrations pour de la
   donnée morte.

2. **SI** une feature future exige que le catalogue soit interrogeable en SQL
   (jointures avec le journal, agrégats « conseil le plus consulté », etc.),
   alors on **SEED** ce catalogue dans Drift **au 1er lancement, à partir de la
   source statique `core_package`**. Le seed est une **projection en lecture
   seule** ; la **source de vérité reste le catalogue statique**. On ne **JAMAIS**
   édite le contenu côté Drift, on **re-seed** depuis `core_package`. → Ce seed
   **n'est PAS implémenté par ce plan** (pas de besoin SQL ici) ; il est
   documenté comme point d'extension §11.

3. **Ce que cet écran ne fait PAS** (et qu'il ne doit pas faire) : aucune
   écriture Drift, aucune dérivation du super-conseil, aucune lecture du
   journal. L'écran est **autonome** et lit **uniquement** `AdviceCatalog.all`.

---

## 1. Contexte de la page

| Élément | Valeur |
| --- | --- |
| Nom | « Conseils » — carrousel de cartes de conseils, **une carte par émotion négative** |
| Widget page | `AdvicePage` (entrée + providers) + `AdviceView` (UI), fichier `lib/advice/view/advice_page.dart` |
| Route logique | `advice`, conceptuellement `/advice` — écran autonome plein écran |
| Parent | **Journal d'humeur / Home** (pas encore planifié) → chevron retour ramène au parent **par nom de route** (ne pas présumer le widget parent) |
| Accès / rôles / auth | **Aucun** — app sans compte, sans identification, sans permission. Accès libre |
| Données affichées | Pour la carte courante : couleur émotion, titre, liste à-faire (3), liste à-éviter (2), exercice associé. **Toutes dérivées de `AdviceCatalog.all` (statique, en mémoire)** |
| Persistance | **AUCUNE.** Lecture seule d'un catalogue `const`. Pas de Drift, pas de HydratedBloc sur cet écran |
| État applicatif | **`AdvicePageController` (`PageController`)** pour le carrousel + index courant local. **Pas de Bloc requis** (état purement UI/navigation, pas d'état métier mutable persistant — cf. §13) |
| Contrat d'entrée | `AdviceArgs { String? initialEmotionId }` — **optionnel** : ouvre directement sur l'émotion donnée (utilisé plus tard par le Journal). `null` ⇒ ouvre sur la 1ʳᵉ carte (mode catalogue) |
| États écran | (a) **nominal** (carte affichée), (b) **navigation entre cartes** (prev/next/swipe/dots synchronisés). **Pas d'empty ni d'error** (catalogue statique non vide). Repli défini §8 pour `initialEmotionId` inconnu |

**Mode par défaut = CATALOGUE** (toutes les émotions négatives, librement
parcourues, écran autonome). Le mode **CONTEXTUEL** (filtré sur l'émotion du
jour saisie dans le journal) n'est **pas** implémenté ici : il se ramène au mode
catalogue + `initialEmotionId` (voir §7 et §11).

---

## 2. User Stories liées

**Aucune US backlog référencée fournie.** Le plan s'appuie sur les **décisions /
défauts validés par l'utilisateur** (reportés en §13) qui font office de
critères d'acceptation. À rattacher si une US existe (mettre à jour le champ
`us:` de l'en-tête + du registry).

Critères d'acceptation dérivés des décisions (source des tests Kent) :

- **AC-1** : Le carrousel affiche **5 cartes, une par émotion négative**
  (`NegativeEmotion.values`), dans l'ordre du catalogue.
- **AC-2** : Chaque carte affiche : barre d'accent couleur émotion, label
  « ÉMOTION », titre, **3** items « À FAIRE » (puce check, cercle couleur
  émotion), **2** items « À ÉVITER » (puce x, cercle gris), CTA « Essayer la
  respiration » (fond couleur émotion).
- **AC-3** : Navigation **prev/next** (chevrons), **swipe horizontal** et **dots**
  sont **synchronisés** (même `PageController`).
- **AC-4** : Le **dot actif** est une **barre allongée rouge** (`#E5392B`,
  cf. design) ; les autres sont des points.
- **AC-5** : `HapticFeedback.selectionClick()` sur **chaque** changement de carte
  (prev, next, swipe), sur **« Essayer la respiration »** et sur **« J'applique
  ce conseil »**.
- **AC-6** : **« Essayer la respiration »** navigue vers **`/bubble/breathing`**
  (`BreathingPage`). L'émotion courante PEUT être passée en contexte
  (optionnel, non requis — cf. §6).
- **AC-7** : **« J'applique ce conseil »** : `HapticFeedback` + **confirmation
  brève** (SnackBar/feedback) puis **retour à l'écran précédent**. **Aucune
  écriture Drift** (point d'extension documenté §11).
- **AC-8** : Le **chevron retour** ramène au **parent par nom de route** (ne
  présume pas le widget parent).
- **AC-9** : `initialEmotionId` fourni ⇒ le carrousel **ouvre sur cette carte** ;
  `initialEmotionId` `null` ou **inconnu** ⇒ ouvre sur la **1ʳᵉ carte** (repli
  catalogue, §8).
- **AC-10** : Tout texte visible provient de l'**ARB** (gen-l10n), **aucune
  chaîne en dur**.
- **AC-11** : Si `reduceMotion` actif → animations **décoratives**
  (swipe-hint, clouds, particules, emotion-glow) **désactivées** ; la
  **navigation, l'affichage, les dots restent fonctionnels**.
- **AC-12** : **Zéro réseau / zéro collecte / aucun asset image** : cartes
  empilées via `Stack`, aucune permission au-delà de `PACKAGE_USAGE_STATS`.

---

## 3. Design (capturé depuis le HTML/CSS fourni) → mapping widgets

Écran mobile, fond bulle `#16213C`, halo radial rouge central léger,
**3 particules flottantes** (décoratives). Structure haut → bas :

### Toolbar (haut)
| Élément design | Widget | Comportement |
| --- | --- | --- |
| Bouton retour (chevron-left, 48×48) | `DigiToolbar.onBack` | §6 — retour parent par nom de route |
| Titre centré « Conseils » (bold) | `DigiToolbar.title` = `l10n.adviceTitle` | DM Sans bold |
| **PAS de bouton à droite** (spacer 48px) | `DigiToolbar` **sans `trailing`**, `showMenu = false` | équilibre visuel (spacer auto, cf. code `DigiToolbar`) |

### Indicateur de cartes (dots)
| Élément design | Widget | Donnée |
| --- | --- | --- |
| 5 points, l'actif = **barre allongée rouge `#E5392B`** | `_AdviceDots(current, total)` | `current = pageIndex`, `total = NegativeEmotion.values.length`. **Couleur barre active = couleur de l'émotion courante** (le design montre rouge car carte « colère » active ; généraliser à la couleur émotion) |

### Carte centrale (swipeable) — `_AdviceCard`
Cartes suivantes en **« peek »** derrière (`bg-card-peek`) → rendues via `Stack`
+ `PageView` (`viewportFraction < 1` pour laisser voir les cartes voisines).

| Élément design | Widget | Donnée (par carte) |
| --- | --- | --- |
| Barre d'accent haute, couleur émotion | `Container` (4px, `advice.color`) | `EmotionAdvice.color` |
| Label « ÉMOTION » + icône heart (couleur émotion) | `Row` : `Icon(Icons.favorite, color: advice.color)` + `Text(l10n.adviceEmotionLabel)` | label = `adviceEmotionLabel` (« Émotion ») |
| Titre « Quand tu te sens en colère… » | `Text` | `l10n` résolu depuis `advice.titleKey` (§9) |
| Section « À FAIRE » (3 items, puce **check** dans cercle **couleur émotion**) | `_AdviceList(items, accent: advice.color, icon: Icons.check)` | 3 clés `advice.doKeys` |
| Section « À ÉVITER » (2 items, puce **x** dans cercle **gris**) | `_AdviceList(items, accent: AppTheme.muted, icon: Icons.close)` | 2 clés `advice.avoidKeys` |
| CTA carte « Essayer la respiration » (fond couleur émotion, icône **wind**) | `_TryBreathingButton(color: advice.color)` icône `Icons.air` | `l10n.adviceTryBreathing` → §6 |

> Labels de sections « À FAIRE » / « À ÉVITER » = clés `adviceDoSectionLabel` /
> `adviceAvoidSectionLabel`.

### Contrôles carrousel (sous la carte)
| Élément design | Widget | Comportement |
| --- | --- | --- |
| « précédent » (chevron-left) | `_CarouselNavButton(Icons.chevron_left, label: l10n.advicePrev)` | `controller.previousPage(...)` + `HapticFeedback.selectionClick()`. **Désactivé** sur la 1ʳᵉ carte |
| séparateur | `_Separator` (trait `AppTheme.muted`) | décoratif |
| « suivant » (chevron-right) | `_CarouselNavButton(Icons.chevron_right, label: l10n.adviceNext)` | `controller.nextPage(...)` + `HapticFeedback.selectionClick()`. **Désactivé** sur la dernière carte |

### CTA bas (large)
| Élément design | Widget | Comportement |
| --- | --- | --- |
| « J'applique ce conseil » (fond cyan `#3FB8E6`, icône **check**) | `_ApplyButton` icône `Icons.check`, fond `AppTheme.primary` | §6 — feedback + retour. `l10n.adviceApply` |

### Tokens design → `AppTheme`
| Token | Valeur | Source |
| --- | --- | --- |
| `background` (fond bulle) | `#16213C` | `AppTheme.bubbleBackground` (existant) |
| `surface` (cartes) | `#283A5E` | `AppTheme.surface` (existant) |
| `foreground` | `#F2F6FB` | `AppTheme.foreground` (existant) |
| `muted` (puce « à éviter » grise) | `#A7B6CE` | `AppTheme.muted` (existant) |
| cyan (CTA bas) | `#3FB8E6` | `AppTheme.primary` (existant) |
| vert | `#A8D24E` | `AppTheme.success` (existant) |
| jaune | `#F0C84A` | `AppTheme.sensesAccent` (existant) |
| **couleur émotion colère** | `#E5392B` | **NOUVEAU** → `AppTheme.angerRed` |
| **couleurs des 4 autres émotions** | voir §5 | **NOUVEAUX** tokens (cf. §5) |
| Police | `DM Sans` | asset local (existant) |
| radius | 12 / 16 / 24 | `AppTheme.radiusSmall`(12) / **16 à ajouter** ou réutiliser `radiusMedium`(20) / `radiusLarge`(24) |

> ⚠️ Le design cite `radius 12/16/24`. `AppTheme` expose `radiusSmall=12`,
> `radiusMedium=20`, `radiusLarge=24`. **Décision** : réutiliser
> `radiusSmall`(12) et `radiusLarge`(24) ; pour le 16, ajouter
> `AppTheme.radiusCard = 16` **ou** utiliser `radiusMedium` si la tolérance
> visuelle est acceptable. Recommandé : ajouter `radiusCard = 16` pour fidélité.

### Icônes (Material only, zéro dépendance ajoutée)
| Design (lucide) | Material |
| --- | --- |
| `chevron-left` / `chevron-right` | `Icons.chevron_left` / `Icons.chevron_right` |
| `heart` | `Icons.favorite` |
| `check` (puce à-faire + CTA bas) | `Icons.check` |
| `x` (puce à-éviter) | `Icons.close` |
| `wind` (CTA respiration) | `Icons.air` |

---

## 4. Structure widgets (arborescence)

```
AdvicePage(args: AdviceArgs?)                         // lib/advice/view/advice_page.dart
└─ AppBackground(background: AppTheme.bubbleBackground) // fond bulle #16213C + halos
   └─ AdviceView                                       // gère PageController + index courant (StatefulWidget)
      └─ Scaffold(backgroundColor: transparent, extendBodyBehindAppBar: true)
         ├─ DigiToolbar(title: l10n.adviceTitle, onBack: _onBack)   // PAS de trailing
         └─ Column
            ├─ _AdviceDots(current, total)             // dots, actif = barre couleur émotion
            ├─ Expanded
            │  └─ Stack                                 // peek des cartes voisines
            │     ├─ (cartes peek en arrière-plan, décoratif, coupé si reduceMotion)
            │     └─ PageView.builder(controller, viewportFraction: ~0.86)
            │        └─ _AdviceCard(advice: AdviceCatalog.all[index])
            │           ├─ _AccentBar(color: advice.color)
            │           ├─ _EmotionLabel(icon: favorite, color, text: adviceEmotionLabel)
            │           ├─ _CardTitle(l10n[advice.titleKey])
            │           ├─ _AdviceList(advice.doKeys,   accent: advice.color,  icon: check)
            │           ├─ _AdviceList(advice.avoidKeys, accent: muted,         icon: close)
            │           └─ _TryBreathingButton(color: advice.color) → /bubble/breathing
            ├─ _CarouselControls(controller, index, total)  // prev | sep | next
            └─ _ApplyButton → feedback + pop()           // « J'applique ce conseil »
```

> `AdviceView` est **`StatefulWidget`** : il possède le `PageController`, l'index
> courant (`_index`), gère `dispose()` du controller et l'init via
> `initialEmotionId`. Aucune dépendance Bloc/Cubit (cf. §13).

---

## 5. Modèle `core_package` — catalogue (SOURCE DE VÉRITÉ)

Fichier : `packages/core_package/lib/src/advice/advice_catalog.dart`
Export à ajouter dans `packages/core_package/lib/core_package.dart`.

### Enum émotions négatives
```dart
/// Identifiants stables des emotions negatives du carrousel de conseils.
/// Ordre = ordre d'affichage des cartes.
enum NegativeEmotion { anger, sadness, fear, stress, loneliness }
```

### Modèle `EmotionAdvice`
Suit **exactement** le pattern `StretchSegment` / `BubbleCategory` déjà en place
(donnée pure immuable, `Equatable`, **clés i18n**, jamais de texte en dur ;
`Color` autorisé comme pour `BubbleCategory`).

```dart
class EmotionAdvice extends Equatable {
  const EmotionAdvice({
    required this.id,
    required this.color,
    required this.titleKey,
    required this.doKeys,      // List<String> longueur 3
    required this.avoidKeys,   // List<String> longueur 2
    required this.exercise,    // exercice associe (defaut respiration)
  });

  final NegativeEmotion id;
  final Color color;           // couleur d'accent de l'emotion
  final String titleKey;       // cle ARB du titre « Quand tu te sens... »
  final List<String> doKeys;   // 3 cles ARB « a faire »
  final List<String> avoidKeys;// 2 cles ARB « a eviter »
  final AdviceExercise exercise;

  @override
  List<Object?> get props => [id, color, titleKey, doKeys, avoidKeys, exercise];
}

/// Exercice proposé par une carte (extensible). V1 : respiration uniquement.
enum AdviceExercise { breathing }
```

### Catalogue `const` (les 5 cartes)
```dart
abstract final class AdviceCatalog {
  static const List<EmotionAdvice> all = <EmotionAdvice>[
    EmotionAdvice(
      id: NegativeEmotion.anger,
      color: Color(0xFFE5392B),                 // = AppTheme.angerRed
      titleKey: 'adviceCardTitleAnger',
      doKeys: ['adviceDoAnger1','adviceDoAnger2','adviceDoAnger3'],
      avoidKeys: ['adviceAvoidAnger1','adviceAvoidAnger2'],
      exercise: AdviceExercise.breathing,
    ),
    EmotionAdvice(
      id: NegativeEmotion.sadness,
      color: Color(0xFF3FB8E6),                 // bleu = AppTheme.sadnessBlue
      titleKey: 'adviceCardTitleSadness',
      doKeys: ['adviceDoSadness1','adviceDoSadness2','adviceDoSadness3'],
      avoidKeys: ['adviceAvoidSadness1','adviceAvoidSadness2'],
      exercise: AdviceExercise.breathing,
    ),
    EmotionAdvice(
      id: NegativeEmotion.fear,
      color: Color(0xFF9B7BE8),                 // violet = AppTheme.fearViolet
      titleKey: 'adviceCardTitleFear',
      doKeys: ['adviceDoFear1','adviceDoFear2','adviceDoFear3'],
      avoidKeys: ['adviceAvoidFear1','adviceAvoidFear2'],
      exercise: AdviceExercise.breathing,
    ),
    EmotionAdvice(
      id: NegativeEmotion.stress,
      color: Color(0xFFF0C84A),                 // jaune = AppTheme.stressAmber (= sensesAccent)
      titleKey: 'adviceCardTitleStress',
      doKeys: ['adviceDoStress1','adviceDoStress2','adviceDoStress3'],
      avoidKeys: ['adviceAvoidStress1','adviceAvoidStress2'],
      exercise: AdviceExercise.breathing,
    ),
    EmotionAdvice(
      id: NegativeEmotion.loneliness,
      color: Color(0xFFA8D24E),                 // vert = AppTheme.lonelinessGreen (= success)
      titleKey: 'adviceCardTitleLoneliness',
      doKeys: ['adviceDoLoneliness1','adviceDoLoneliness2','adviceDoLoneliness3'],
      avoidKeys: ['adviceAvoidLoneliness1','adviceAvoidLoneliness2'],
      exercise: AdviceExercise.breathing,
    ),
  ];

  /// Recherche par id (mode initialEmotionId). null si introuvable.
  static EmotionAdvice? byId(String? rawId) { /* values.firstWhereOrNull */ }

  /// Index d'une emotion dans `all` (sync PageController). -1 si introuvable.
  static int indexOf(String? rawId) { /* ... */ }
}
```

> **Couleurs émotions (chaque émotion a SA couleur).** Le design ne donne que le
> rouge colère `#E5392B`. Les 4 autres réutilisent des tokens **déjà présents**
> dans `AppTheme` (cyan, jaune `sensesAccent`, vert `success`, violet `#9B7BE8`
> déjà utilisé pour la bulle « senses ») afin de **ne pas inventer de palette**.
> **À valider visuellement** par le designer : ces affectations sont des
> **valeurs par défaut cohérentes avec la charte existante**, pas une exigence
> du mockup. Les ajouter à `AppTheme` sous des **alias sémantiques** (§voir
> tokens ci-dessous) pour que le catalogue reste lisible.

### Tokens couleurs à ajouter dans `AppTheme`
```dart
static const Color angerRed       = Color(0xFFE5392B); // NOUVEAU (du mockup)
static const Color sadnessBlue    = primary;           // alias #3FB8E6
static const Color fearViolet     = Color(0xFF9B7BE8); // réutilise la teinte "senses"
static const Color stressAmber    = sensesAccent;      // alias #F0C84A
static const Color lonelinessGreen= success;           // alias #A8D24E
```

> Source de vérité couleur = **soit** les constantes `AppTheme` **soit** le
> catalogue `core_package`. **Décision** : le **catalogue `core_package` porte
> la `Color`** (comme `BubbleCategory`), et `AppTheme.angerRed` existe pour
> l'UI partagée (dot actif, etc.). Garder les deux **synchronisés** ; ne pas
> diverger.

---

## 6. Actions & navigation (exhaustif)

| Élément | Déclencheur | Comportement | Feedback | Conditions |
| --- | --- | --- | --- | --- |
| **Chevron retour** | tap | `Navigator.maybePop()` (retour parent **par nom de route**, non présumé) | — | toujours visible |
| **Swipe horizontal** | geste PageView | change la carte ; met à jour `_index` + dots | `HapticFeedback.selectionClick()` sur `onPageChanged` | — |
| **« précédent »** | tap | `controller.previousPage(duration: 250ms, curve: easeOut)` | `selectionClick` | **désactivé** (grisé, `onPressed: null`) si `_index == 0` |
| **« suivant »** | tap | `controller.nextPage(...)` | `selectionClick` | **désactivé** si `_index == total-1` |
| **« Essayer la respiration »** (CTA carte) | tap | `Navigator.pushNamed('/bubble/breathing')` → `BreathingPage`. **Optionnel** : passer `arguments` portant l'émotion courante (contexte non requis par BreathingPage) | `selectionClick` | présent sur chaque carte |
| **« J'applique ce conseil »** (CTA bas) | tap | `HapticFeedback.selectionClick()` → `ScaffoldMessenger.showSnackBar(l10n.adviceAppliedConfirmation)` (ou petite confirmation animée `cta-in`) → `Navigator.maybePop()` | SnackBar de confirmation | **HOOK** journal/super-conseil §11 — **action simple et découplée** (callback/route), **aucune** écriture Drift ici |

> **Découplage du CTA « J'applique »** : le bouton appelle un callback
> `onApply` (défaut = feedback + `pop`). Quand le Journal sera planifié, on
> injectera un `onApply` qui marque le conseil comme appliqué (écriture Drift)
> **sans modifier cet écran**. Documenté §11.

> **Navigation `/bubble/breathing`** : référencer `BreathingPage` **par nom de
> route** (la table de routes n'est pas encore centralisée — cf. registry,
> routing par nom à brancher). Ne pas instancier `BreathingPage` en dur si une
> route nommée existe.

---

## 7. Contrat d'entrée `initialEmotionId` (mode catalogue vs contextuel)

```dart
class AdviceArgs {
  const AdviceArgs({this.initialEmotionId});
  /// Id d'emotion (NegativeEmotion.name) sur laquelle ouvrir le carrousel.
  /// null  => mode CATALOGUE pur, ouverture sur la 1re carte.
  /// fourni => ouverture directe sur la carte correspondante.
  final String? initialEmotionId;
}
```

- **Mode CATALOGUE (défaut, implémenté ici)** : `initialEmotionId == null` →
  `PageController(initialPage: 0)`. Toutes les émotions parcourables.
- **Mode CONTEXTUEL (préparé, utilisé plus tard par le Journal)** :
  `initialEmotionId` fourni → `initialPage = AdviceCatalog.indexOf(id)`.
  L'utilisateur **peut toujours** parcourir les autres cartes (pas de filtrage
  dur — le design est un carrousel complet).
- **Repli (AC-9 / §8)** : `initialEmotionId` **inconnu** (`indexOf == -1`) →
  ouverture sur la **1ʳᵉ carte** (mode catalogue), aucun crash, aucun écran vide.

---

## 8. États écran

| État | Condition | Rendu |
| --- | --- | --- |
| **Nominal** | toujours (catalogue non vide) | carte courante + dots + contrôles + CTA bas |
| **Navigation** | swipe / prev / next | transition `PageView`, dots resync, haptique |
| **initialEmotionId inconnu** | `indexOf(id) == -1` | **repli** → 1ʳᵉ carte (mode catalogue). Pas d'erreur affichée |
| ~~Empty~~ | **N/A** | catalogue `const` toujours non vide |
| ~~Error~~ | **N/A** | aucune source faillible (pas de réseau, pas de Drift, pas d'I/O) |

> **Garde-fou défensif** (test Kent) : si jamais `AdviceCatalog.all` était vide
> (régression), l'écran ne doit pas crasher (clamp d'index, `Expanded` vide
> toléré). Mais ce n'est **pas** un état métier prévu.

---

## 9. Internationalisation (clés ARB — gen-l10n, 8 langues)

Fichiers : `apps/digiharmony_app/lib/l10n/arb/app_<lang>.arb` (8 langues).
**FR + EN remplis**, **placeholders el/it/ro/tr/es/mk** (recopier l'EN en
attendant traduction — repli `en`). Préfixe **`advice*`**.

### Clés transverses
| Clé | FR | EN |
| --- | --- | --- |
| `adviceTitle` | « Conseils » | "Advice" |
| `adviceEmotionLabel` | « Émotion » | "Emotion" |
| `adviceDoSectionLabel` | « À faire » | "Do" |
| `adviceAvoidSectionLabel` | « À éviter » | "Avoid" |
| `adviceTryBreathing` | « Essayer la respiration » | "Try breathing" |
| `advicePrev` | « précédent » | "previous" |
| `adviceNext` | « suivant » | "next" |
| `adviceApply` | « J'applique ce conseil » | "I'll apply this advice" |
| `adviceAppliedConfirmation` | « Bien joué, prends soin de toi 💙 » | "Well done, take care of yourself" |

### Clés par émotion (structurées par `emotionId`)
Pattern : `adviceCardTitle{Emotion}`, `adviceDo{Emotion}{1..3}`,
`adviceAvoid{Emotion}{1..2}`. Exemple **colère** (du mockup) :

| Clé | FR | EN |
| --- | --- | --- |
| `adviceCardTitleAnger` | « Quand tu te sens en colère… » | "When you feel angry…" |
| `adviceDoAnger1` | « Fais une pause avant de répondre » | "Take a break before replying" |
| `adviceDoAnger2` | « Respire profondément 3 fois » | "Breathe deeply 3 times" |
| `adviceDoAnger3` | « Écris ce que tu ressens — sans envoyer » | "Write what you feel — without sending" |
| `adviceAvoidAnger1` | « Ne poste pas à chaud » | "Don't post in the heat of the moment" |
| `adviceAvoidAnger2` | « Évite les confrontations en ligne » | "Avoid online confrontations" |

> Les 4 autres émotions (`sadness`, `fear`, `stress`, `loneliness`) suivent le
> **même schéma de clés** (`adviceCardTitleSadness`, `adviceDoSadness1..3`,
> `adviceAvoidSadness1..2`, etc.). **Contenu FR/EN à rédiger** par le PO/designer
> (ton bienveillant, public mineur). Les clés sont **déclarées** dans l'en-tête
> `i18n_keys:` et dans `core_package` (catalogue) ; le **texte** est rempli ARB.

> **Pas de placeholders ICU** ici (aucun nombre/variable injecté dans ces
> chaînes) → entrées ARB simples + bloc `@`-metadata vide.

---

## 10. Composants réutilisés / étendus

| Composant | Statut | Note |
| --- | --- | --- |
| `DigiToolbar` | **RÉUTILISÉ tel quel** | `title` + `onBack`, **sans `trailing`**, `showMenu=false` (spacer 48px auto à droite — exactement le design « pas de bouton à droite ») |
| `AppBackground` | **RÉUTILISÉ tel quel** | `background: AppTheme.bubbleBackground` (#16213C, défaut). Halos décoratifs déjà statiques (reduceMotion-safe par construction) |
| `AppTheme` | **ÉTENDU** | ajouter `angerRed` (#E5392B) + alias émotions (§5) + éventuel `radiusCard=16` |
| `EmotionAdvice`/`AdviceCatalog`/`NegativeEmotion` | **NOUVEAU** `core_package` | catalogue statique, source de vérité (§5) |

> **Pas de réutilisation du kit `lib/wellbeing_shared/`** (CelebrationLayout,
> RestartButton, ExitSessionDialog, AudioHint) : cet écran n'a ni séance
> minutée, ni célébration, ni voix off, ni dialog de sortie. Ne pas l'importer.

---

## 11. Points d'extension (documentés, NON implémentés ici)

1. **Hook « J'applique ce conseil » → Journal/super-conseil.** Le CTA bas est le
   **point naturel** pour marquer un conseil comme appliqué. Quand le Journal
   sera planifié : injecter un `onApply(EmotionAdvice)` qui écrit l'événement en
   **Drift** (jamais HydratedBloc). Cet écran reste inchangé (callback découplé).

2. **Super-conseil (7 émotions négatives consécutives, DEC-001/DEC-002).** **Non
   implémenté ici.** Articulation future : un **conseil spécial** pourrait être
   **injecté en tête de carrousel** (carte index 0) **uniquement** quand le
   compteur dérivé de Drift atteint 7. Ce compteur est **DÉRIVÉ de Drift, jamais
   dupliqué**. L'injection se ferait via un paramètre `List<EmotionAdvice>`
   passé à `AdviceView` (défaut = `AdviceCatalog.all`), sans toucher au
   catalogue source. Aucune logique Drift dans ce plan.

3. **Mode contextuel piloté par le Journal.** Le Journal ouvrira
   `AdvicePage(AdviceArgs(initialEmotionId: emotionDuJour))` — déjà supporté par
   le contrat d'entrée §7.

4. **Seed Drift du catalogue.** Si une feature SQL l'exige (§0.2) : seed
   lecture-seule depuis `AdviceCatalog.all` au 1er lancement, source de vérité
   = statique. Non requis ici.

---

## 12. Animations & reduceMotion

Animations CSS du mockup → `flutter_animate` (aucun package tiers, aucun asset) :

| Anim CSS | Cible Flutter | Catégorie | reduceMotion |
| --- | --- | --- | --- |
| `card-enter` | entrée de la carte courante (fade+slide léger) | semi-fonctionnelle | **réduite** (fade court conservé, slide coupé) |
| `swipe-hint` | indice de swipe sur la 1ʳᵉ ouverture | **décorative** | **désactivée** |
| `bg-card-peek` | cartes empilées derrière (Stack) | **décorative** | **désactivée** (cartes voisines rendues statiques, sans pulsation) |
| `cloud-l` / `cloud-r` | nuages colorés dans la carte | **décorative** | **désactivée** |
| `emotion-glow` | halo de la carte (couleur émotion) | **décorative** | **désactivée** (glow statique léger toléré) |
| `ptcl` | 3 particules flottantes | **décorative** | **désactivée** |
| `cta-in` | apparition CTA bas | **décorative** | **désactivée** |

> Détection : `MediaQuery.maybeOf(context)?.disableAnimations ?? false`. Quand
> actif : la **navigation (prev/next/swipe), les dots, l'affichage des cartes et
> les listes** restent **pleinement fonctionnels** (AC-11). Seul le décoratif
> tombe.

---

## 13. Décision état : pourquoi PAS de Bloc ici

La règle `coding-assertions` impose `bloc`/`flutter_bloc` **dès qu'il y a de
l'état applicatif métier mutable / persistant** (cf. `BreathingBloc`,
`SensesBloc`…). **Ici, ce n'est pas le cas** :

- Aucune donnée métier mutable : le catalogue est `const`.
- Aucun timer, aucune machine d'états métier (contrairement à Breathing/Stretch).
- Aucune persistance (ni Drift ni HydratedBloc sur cet écran).
- Le seul état est **l'index de page courant** = **état UI pur** de navigation
  → `PageController` + `setState` dans `AdviceView` (`StatefulWidget`).

→ **Pas de `AdviceBloc`.** Introduire un Bloc ici serait du sur-engineering sans
état métier à gérer. **Si** le hook journal/super-conseil §11 ajoute plus tard
de l'état métier (catalogue dérivé de Drift, carte super-conseil conditionnelle),
**alors** un `AdviceCubit` deviendra justifié — à ce moment-là, pas avant.

> ⚠️ **Point à valider** avec l'équipe : ce projet utilise `bloc_lint`. Vérifier
> qu'aucune règle de lint n'impose un Bloc par page. Si c'est le cas, encapsuler
> l'index dans un `AdviceCubit` minimal (un seul champ `int index`). Le reste du
> plan est inchangé.

---

## 14. Contraintes projet dures (rappel — invariants)

- Flutter, monorepo Melos 7 (`apps/digiharmony_app` + `packages/core_package`).
- **Client-only, zéro collecte** : AUCUN SDK réseau/analytics/tracking/Crashlytics.
- **Aucune permission** au-delà de `PACKAGE_USAGE_STATS` (cet écran n'en demande
  aucune).
- Vibration via **`HapticFeedback` uniquement** (pas de permission `VIBRATE`).
- Pas de backend ni Firebase.
- **DM Sans en asset local** (PAS `google_fonts`).
- **Icônes Material only** ; **aucun asset image** (cartes via `Stack`).
- **Conseils = donnée de référence fixe** : catalogue statique `core_package`
  (source de vérité), seed Drift seulement si l'architecture l'impose — **jamais
  dupliqué**.
- i18n gen-l10n / ARB 8 langues, repli `en`, **aucune chaîne en dur**.

---

## 15. Fichiers à créer / modifier

**Créer :**
- `packages/core_package/lib/src/advice/advice_catalog.dart` (modèle + catalogue)
- `apps/digiharmony_app/lib/advice/view/advice_page.dart` (`AdvicePage` + `AdviceView`)
- `apps/digiharmony_app/lib/advice/widgets/advice_card.dart` (`_AdviceCard`, `_AdviceList`, `_AccentBar`, `_EmotionLabel`, `_TryBreathingButton`)
- `apps/digiharmony_app/lib/advice/widgets/advice_dots.dart` (`_AdviceDots`)
- `apps/digiharmony_app/lib/advice/widgets/carousel_controls.dart` (`_CarouselControls`, `_ApplyButton`)
- `apps/digiharmony_app/lib/advice/advice.dart` (barrel)

**Modifier :**
- `packages/core_package/lib/core_package.dart` (export `advice_catalog.dart`)
- `apps/digiharmony_app/lib/theme/app_theme.dart` (tokens couleurs émotions + `angerRed` + éventuel `radiusCard`)
- `apps/digiharmony_app/lib/l10n/arb/app_*.arb` (8 fichiers — clés §9 ; FR/EN remplis)
- Table de routes (quand centralisée) : enregistrer `/advice` → `AdvicePage` et
  brancher l'entrée depuis Journal/Home (par nom de route).

---

## 16. Definition of Done

- [ ] `AdviceCatalog.all` = 5 `EmotionAdvice` (une par `NegativeEmotion`), clés i18n, couleurs.
- [ ] Carrousel `PageView` + dots + prev/next **synchronisés** ; dot actif = barre couleur émotion.
- [ ] `initialEmotionId` ouvre la bonne carte ; repli 1ʳᵉ carte si inconnu/null.
- [ ] « Essayer la respiration » → `/bubble/breathing` ; « J'applique » → feedback + pop, **0 Drift**.
- [ ] `HapticFeedback.selectionClick` sur nav carte + 2 CTA.
- [ ] `reduceMotion` coupe le décoratif, garde la nav/affichage.
- [ ] Tous textes via ARB (FR/EN remplis, placeholders 6 langues, repli en).
- [ ] `flutter analyze` clean (`very_good_analysis` + `bloc_lint`).
- [ ] Tests Kent (étape 5) verts — voir `aidd_docs/tasks/conseils.tests.md`.
