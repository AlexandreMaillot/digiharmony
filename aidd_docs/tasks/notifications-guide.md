---
page: Couper mes notifications (NotificationGuidePage)
route: /notifications-guide (NotificationGuidePage — écran plein écran, atteint depuis « Mon temps d'écran » /screen-time ; chevron retour → parent par nom de route)
us: []
shared_components: [DigiToolbar, AppBackground, AppTheme]
i18n_keys: [notifGuideBrand, notifGuideTitle, notifGuideSubtitle, notifGuideStep1Title, notifGuideStep1Body, notifGuideStep2Title, notifGuideStep2Body, notifGuideStep3Title, notifGuideStep3Body, notifGuideStep4Title, notifGuideStep4Body, notifGuideStep5Title, notifGuideStep5Body, notifGuideStep1TitleIos, notifGuideStep1BodyIos, notifGuideStep2TitleIos, notifGuideStep2BodyIos, notifGuideStep3TitleIos, notifGuideStep3BodyIos, notifGuideStep4TitleIos, notifGuideStep4BodyIos, notifGuideStep5TitleIos, notifGuideStep5BodyIos, notifGuideTip, notifGuideOtherPhone, notifGuideMenuTooltip, notifGuideBackLabel]
shared_components_extracted: [NotificationGuideStep (core_package, donnée pure immuable — index + clés i18n titre/description + IconData), NotificationGuideCatalog (core_package, 2 jeux statiques android/ios), NotificationGuidePlatform (enum android/ios), GuideStepCard (app, widget carte étape), GuideTipBanner (app, bandeau conseil), DigiBrandHeader OU DigiToolbar mode brand (app, toolbar à logo — voir §4)]
tests: aidd_docs/tasks/notifications-guide.tests.md (à remplir par Kent en étape 5)
created: 2026-06-05
updated: 2026-06-05
---

# Plan de page — « Couper mes notifications » (NotificationGuidePage)

> Plan auto-suffisant pour éditeur IA. Conforme aux règles `aidd_docs/memory/` de
> DIGIHARMONY : Flutter, monorepo Melos 7 (`apps/digiharmony_app` + `packages/core_package`),
> **client-only, zéro collecte, zéro réseau, zéro SDK analytics/tracking/Crashlytics**,
> **aucune permission**, vibration via `HapticFeedback` uniquement, i18n ARB gen-l10n 8 langues
> (`en/fr/el/it/ro/tr/es/mk`, repli `en`), DM Sans en asset local (jamais `google_fonts`),
> icônes **Material only**, logo en **asset local** (jamais `cached_network_image`/réseau).
>
> 🟢 **Écran 100 % STATIQUE — le plus simple du backlog.** C'est un **tutoriel** : 5 étapes
> numérotées pour désactiver/regrouper les notifications côté OS. **Aucune** donnée Drift,
> **aucun** HydratedBloc, **aucune** permission, **aucun** audio, **aucun** réseau, **aucune**
> persistance. Le seul état dynamique est la **plateforme affichée** (Android / iOS) — un état
> **local non persistant**.
>
> Cet écran **réutilise** les composants partagés `DigiToolbar`, `AppBackground`, `AppTheme`.
> Il est la **cible navigation** de la carte « Couper mes notifications » de
> `temps-decran.md` (route `/notifications-guide`, jusqu'ici un placeholder).

---

## 1. Contexte de la page

| Élément | Valeur |
| --- | --- |
| Nom | « Couper mes notifications » — guide statique 5 étapes pour réduire les notifications |
| Widget page | `NotificationGuidePage` (entrée + état local plateforme) + `NotificationGuideView` (UI), fichier `lib/notifications_guide/view/notification_guide_page.dart` |
| Route logique | `/notifications-guide`, écran plein écran. **Cible déjà référencée** par `temps-decran.md` |
| Parent | « Mon temps d'écran » (`/screen-time`) **ou** Accueil/Home selon le point d'entrée. **Référence par nom de route, NON présumée.** Retour = `Navigator.pop` (revient au parent réel quel qu'il soit) |
| Accès / rôles / auth | **Aucun** — app sans compte. Accès libre |
| Données affichées | **Liste STATIQUE de 5 étapes** numérotées (pastille + icône + titre + description) + un **bandeau conseil** + un **sous-titre**. Variante par plateforme (android/ios) |
| Source de données | **`NotificationGuideCatalog`** (listes statiques figées dans `core_package`). **Aucune** I/O, **aucune** API, **aucune** DB, **aucun** channel |
| Persistance | **AUCUNE.** Pas de Drift, pas de HydratedBloc. La plateforme affichée est un **état local non persistant** (réinitialisé à chaque ouverture sur la plateforme courante) |
| État applicatif | État local **plateforme affichée** (`android` / `ios`). Implémentation au choix (cf. §5) : `StatefulWidget` minimal **OU** `NotificationGuideCubit` léger **NON** `HydratedCubit`. Recommandation par défaut : **`StatefulWidget`** (suffit, zéro dépendance bloc pour un simple toggle) |
| États écran | **`nominal`** (liste affichée pour la plateforme courante) + **bascule plateforme** (affiche l'autre jeu). **Pas** d'`empty`/`error`/`loading` (contenu statique) |

**Pourquoi pas de Cubit/Bloc obligatoire :** un simple basculement entre 2 listes constantes ne
justifie pas un Bloc. Un `StatefulWidget` avec un champ `NotificationGuidePlatform _platform` est
suffisant et plus léger. **Si** l'architecture projet impose un Cubit pour toute vue à état (à
vérifier dans les règles), alors un `NotificationGuideCubit` non persistant convient — mais **jamais
`HydratedCubit`** (rien à persister, cohérent zéro collecte). Choix signalé en §15.

---

## 2. User Stories liées

**Aucune US backlog référencée fournie.** Le plan s'appuie sur le design fourni + les **défauts
validés par l'utilisateur** (reportés en §13 comme critères d'acceptation, source des tests Kent).
À rattacher si une US existe (mettre à jour le champ `us:` de l'en-tête + du registry).

---

## 3. Design — structure visuelle (fidèle au HTML/CSS fourni)

Fond **`#1F2C49`** = **fond STANDARD app**. ⚠️ **Correction registry/parent :** dans le code réel,
ce token existe déjà dans `AppTheme` sous le nom **`hubBackground` (`#1F2C49`)** — il ne faut **PAS**
créer de token `appBackground`, ni réutiliser le fond bulle `bubbleBackground #16213C`. (Le plan
`temps-decran.md` parlait d'un token `appBackground` « à ajouter » : il est en fait **déjà là** sous
`hubBackground`. Voir §3 tokens et §15.)

Halo radial cyan décoratif fourni par `AppBackground` (déjà 2 halos statiques, compatibles
`reduceMotion` par construction).

```
┌──────────────────────────────────────────────┐
│ [‹ 48]    [▣ DigiHarmony]          [≡ menu]   │  ← Toolbar mode BRAND (logo+label centre, menu droite)
│                                                │
│        Moins de notifications, plus de calme.  │  ← sous-titre (muted/foreground)
│                                                │
│  ┌──── carte étape (#283A5E, radius 12) ─────┐ │
│  │ (①cyan) ⚙   Ouvre les Réglages            │ │  ← pastille n° + icône + titre bold
│  │            Repère l'icône engrenage sur…   │ │     + description (muted)
│  └────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────┐ │
│  │ (②cyan) 🔔  Appuie sur "Notifications"     │ │
│  │            Fais défiler jusqu'à la section… │ │
│  └────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────┐ │
│  │ (③cyan) 📱  Choisis une app distrayante     │ │
│  │            Sélectionne une app qui…         │ │
│  └────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────┐ │
│  │ (④cyan) 🔕  Désactive ou regroupe           │ │
│  │            Désactive les notifications ou…  │ │
│  └────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────┐ │
│  │ (⑤cyan) ✓   Répète pour chaque app          │ │
│  │            Prends 2–3 minutes pour…         │ │
│  └────────────────────────────────────────────┘ │
│                                                │
│  ┌──☀──────────────────────────────────────┐  │  ← bandeau conseil
│  │ Chaque notification en moins, c'est une   │  │     icône sun jaune #F0C84A
│  │ interruption de moins. Prends ton temps.  │  │     fond cyan translucide
│  └────────────────────────────────────────────┘ │
│                                                │
│            Voir pour un autre téléphone         │  ← lien bas centré (muted) → bascule plateforme
└──────────────────────────────────────────────┘
```

**Ordre strict (haut → bas) :** Toolbar brand+menu → sous-titre → **liste des 5 cartes étapes
(dans l'ordre 1→5)** → bandeau conseil → lien de bascule plateforme. **Ne PAS réordonner.**
Le contenu défile (`SingleChildScrollView`/`ListView`).

### Tokens de design (mappés sur `AppTheme` — état réel du code)

| Token maquette | Valeur | Rôle | Statut `AppTheme` réel |
| --- | --- | --- | --- |
| fond app | `#1F2C49` | fond standard de l'écran | **déjà présent = `AppTheme.hubBackground`** (NE PAS créer `appBackground`) |
| `surface` | `#283A5E` | cartes étapes | déjà présent (`AppTheme.surface`) |
| `primary` (cyan) | `#3FB8E6` | pastilles n°, label brand, fond translucide bandeau/conseil | déjà présent (`AppTheme.primary`) |
| accent jaune | `#F0C84A` | icône sun du bandeau conseil | déjà présent (`AppTheme.sensesAccent` = `#F0C84A`) |
| `foreground` | `#F2F6FB` | titres d'étape, valeurs | déjà présent (`AppTheme.foreground`) |
| `muted` | `#A7B6CE` | sous-titre, descriptions, lien bas | déjà présent (`AppTheme.muted`) |
| fond bandeau conseil | cyan translucide (`primary` @ ~12 % alpha) | fond du bandeau | dérivé de `primary.withValues(alpha: 0.12)` |
| radius | 8 / 12 | rayons cartes / pastilles | `AppTheme.radiusSmall` (12) ; logo 8 via `BorderRadius.circular(8)` |
| police | **DM Sans** (asset local) | toute la typo | `AppTheme.fontFamily` (repli système gracieux si `.ttf` absent) |

> ⚠️ **Le token jaune de la maquette est `#F0C84A`** → mapper sur **`AppTheme.sensesAccent`**
> (exactement `#F0C84A`), **PAS** sur `AppTheme.accent` (`#F5C842`, jaune du hub, valeur différente).

---

## 4. Arborescence des widgets

```
NotificationGuidePage  (lib/notifications_guide/view/notification_guide_page.dart)
└─ (état local plateforme : StatefulWidget _platform = plateforme courante)   ← cf. §5
   └─ NotificationGuideView(platform, onTogglePlatform)
      └─ AppBackground(background: AppTheme.hubBackground)        ← #1F2C49 + halos cyan déco
         └─ SafeArea
            └─ Column
               ├─ DigiBrandHeader( ou DigiToolbar(mode brand) )   ← cf. 4.bis
               │     • leading  : chevron_left → Navigator.maybePop(context)
               │     • center   : logo (asset local + fallback) + label « DigiHarmony »
               │     • trailing : IconButton(Icons.menu) → no-op TODO (§10)
               └─ Expanded
                  └─ SingleChildScrollView (ou ListView)
                     ├─ GuideSubtitle (l10n.notifGuideSubtitle)
                     ├─ ...steps.map((step) => GuideStepCard(step))   ← 5 cartes, ordre index 1→5
                     │     GuideStepCard :
                     │       Row( pastille(numéro), Icon(step.icon),
                     │            Column( Text(title bold), Text(body muted) ) )
                     ├─ GuideTipBanner(icon: Icons.wb_sunny color: sensesAccent,
                     │                 text: l10n.notifGuideTip)
                     └─ OtherPhoneLink( l10n.notifGuideOtherPhone, onTap: onTogglePlatform )
```

Où `steps = NotificationGuideCatalog.stepsFor(platform)` (résolu via i18n en UI, cf. §7).

### 4.bis Toolbar « mode brand » — décision d'implémentation

Le `DigiToolbar` **actuel** (`lib/widgets/digi_toolbar.dart`) expose : `title` (String centré),
`onBack`, `trailing`, `showMenu` (réserve un espace 48px à droite), `backLabel`. Il **n'a pas** de
mode « titre = logo+label », ni de bouton menu actif. Deux options, **par préférence de propreté** :

- **✅ Option A (recommandée) — widget dédié `DigiBrandHeader`** (app `lib/notifications_guide/widgets/`
  ou `lib/widgets/` si réutilisable). Header `Row` à 3 zones : leading chevron (réutilise le même
  rendu que `DigiToolbar`), centre = `Row(logo 32×32 radius 8 + label « DigiHarmony » cyan uppercase
  letterSpacing)`, trailing = `IconButton(Icons.menu)`. **Avantage :** ne touche pas à `DigiToolbar`
  (zéro risque de régression sur les 7 écrans qui l'utilisent), header spécifique app-shell isolé.
- ⚠️ Option B — **étendre `DigiToolbar`** avec un mode brand (ex. `Widget? titleWidget` qui, s'il est
  fourni, remplace le `Text(title)` centré ; le `trailing` existant porte le bouton menu). Compatible
  rétro (params optionnels), **mais** modifie un composant partagé → re-tester les écrans existants.
  À ne faire que si le header brand doit être réutilisé ailleurs (probable avec l'écran Home/app-shell).

> **Défaut retenu : Option A (`DigiBrandHeader`)** pour ne pas risquer `DigiToolbar`. Si l'écran Home
> introduit le même app-shell, **promouvoir** `DigiBrandHeader` en composant partagé à ce moment-là
> (signalé au registry, non bloquant). Le développeur peut basculer sur l'option B s'il préfère
> centraliser dès maintenant — **signalé**, non tranché unilatéralement.

### Logo DigiHarmony — asset local + fallback gracieux (impératif zéro réseau)

- Les `img` Banani pointent vers **Firebase Storage** = **export maquette uniquement**. En Flutter,
  **asset local obligatoire**, **jamais** `cached_network_image`/`Image.network` (réseau interdit).
- Emplacement attendu : `assets/images/logo.png` (ou `logo.webp`), déclaré dans `pubspec.yaml`
  (`flutter: assets:`). **⚠️ Aucun dossier `assets/images/` n'existe encore** et aucune section
  `assets:` n'est déclarée dans `pubspec.yaml` → l'implémentation doit **créer** l'asset + la
  déclaration, OU s'appuyer sur le fallback ci-dessous.
- **Fallback gracieux si l'asset est absent** : afficher un **placeholder neutre** (carré `surface`
  radius 8 32×32 avec une `Icon` Material discrète, ex. `Icons.spa`/`Icons.self_improvement`) **ou
  le label texte seul** « DigiHarmony ». Le rendu ne doit **jamais** crasher ni tenter un accès
  réseau. Implémentation type : `Image.asset(..., errorBuilder: (_, __, ___) => _LogoFallback())`.

### Composants réutilisés (registry)

| Composant | Origine | Usage ici |
| --- | --- | --- |
| `AppBackground` | choisis-ta-bulle (+ `background` respiration) | fond `AppTheme.hubBackground` (#1F2C49) + halos cyan déco statiques |
| `AppTheme` | choisis-ta-bulle (+ tokens detox/senses) | `hubBackground`, `surface`, `primary`, `sensesAccent` (#F0C84A), `foreground`, `muted`, `radiusSmall` — **aucun nouveau token requis** |
| `DigiToolbar` | choisis-ta-bulle | **rendu du chevron retour réutilisé** ; le mode brand est porté par `DigiBrandHeader` (Option A) ou par extension (Option B) |

### Nouveaux composants (créés par ce plan)

| Composant | Emplacement | Rôle |
| --- | --- | --- |
| `NotificationGuidePlatform` | **core_package** `lib/src/notifications_guide/` | enum `{ android, ios }` |
| `NotificationGuideStep` | **core_package** | donnée pure immuable (index, `titleKey`, `bodyKey`, `IconData icon`) — cf. §7 |
| `NotificationGuideCatalog` | **core_package** | 2 jeux statiques figés (`androidSteps`, `iosSteps`) + `stepsFor(platform)` |
| `DigiBrandHeader` | app `lib/notifications_guide/widgets/` (ou `lib/widgets/`) | toolbar app-shell : chevron + logo+label centre + menu (Option A) |
| `GuideStepCard` | app `lib/notifications_guide/widgets/` | carte étape (pastille n° + icône + titre + description) |
| `GuideTipBanner` | app `lib/notifications_guide/widgets/` | bandeau conseil (icône sun jaune + texte, fond cyan translucide) |
| `OtherPhoneLink` | app `lib/notifications_guide/widgets/` | lien bas centré atténué + `HapticFeedback.selectionClick` |

> 🔁 **Candidats refactor cross-page (non bloquants) :** `DigiBrandHeader` (app-shell) et `GuideStepCard`
> (motif « pastille numérotée + icône + titre + body ») pourront migrer vers un kit partagé
> (`lib/wellbeing_shared/` déjà proposé par `etirement.md`/`temps-decran.md`) si un 2ᵉ écran en a besoin.
> **Ne PAS extraire prématurément.**

---

## 5. État local « plateforme affichée » (non persistant)

Le **seul** comportement dynamique de l'écran. Modélisé comme un **petit état local NON persistant**.

```
NotificationGuidePlatform _platform   // initial = plateforme courante (cf. règle ci-dessous)

stepsFor(_platform) = NotificationGuideCatalog.androidSteps | iosSteps

onTogglePlatform():
  HapticFeedback.selectionClick()
  _platform = (_platform == android) ? ios : android   // setState (ou emit)
```

### Détermination de la plateforme initiale

- Par défaut, afficher le jeu correspondant à la **plateforme courante** :
  `Platform.isIOS ? NotificationGuidePlatform.ios : NotificationGuidePlatform.android`.
- ⚠️ `dart:io` `Platform` **ne fonctionne pas sur le web** (hors périmètre projet : app Android-first,
  pas de cible web), donc usage acceptable. Si une garde est souhaitée, encapsuler dans un getter
  testable (injectable) pour permettre un mock en test (par défaut : lecture directe `Platform.isIOS`).
- Le lien « Voir pour un autre téléphone » **bascule vers l'autre jeu** (android ↔ ios). L'état n'est
  **pas** persisté : à la réouverture, on repart de la plateforme courante.

### Implémentation recommandée

- **Défaut : `StatefulWidget`** (`NotificationGuidePage` porte `_platform`, `setState` au toggle).
  Aucune dépendance bloc, aucun fichier `*_state.dart`. Le plus simple et le plus propre ici.
- **Alternative (si règle archi impose un Cubit pour toute vue à état) :** `NotificationGuideCubit`
  (NON `HydratedCubit`) avec état `NotificationGuideState(platform)` et `togglePlatform()`. Testable
  via `bloc_test`. **Jamais** `HydratedBloc` (rien à persister — cohérent zéro collecte). Choix
  signalé en §15.

### Machine d'états (bascule plateforme)

```
        ┌──────────────────────────────────────────┐
        ▼                                            │
 [Affiche Android] ── tap « Voir pour un autre » ──► [Affiche iOS]
        ▲                                            │
        └──────── tap « Voir pour un autre » ────────┘
```

Deux états symétriques. Chaque transition : `HapticFeedback.selectionClick()` puis rebuild de la
liste avec l'autre jeu d'étapes. Aucune autre transition (pas de loading/error).

> Pour un composant à état, un **state machine** est joint ci-dessus (équivalent
> `aidd:03:components_behavior`) : 2 nœuds, 1 transition réflexive bidirectionnelle, déclencheur =
> tap lien, effet = haptique + swap de liste. Kent testera les **2 sens** de la bascule.

---

## 6. (sans objet) — pas de repository / channel / réseau / permission

Cet écran **n'a aucune** couche données dynamique : pas de `Repository`, pas de `MethodChannel`, pas
de permission, pas d'audio, pas de réseau, pas de Drift, pas de HydratedBloc. **À ne PAS introduire.**
Toute la donnée est statique (`NotificationGuideCatalog`, §7) ; tout le texte est i18n (§11).

---

## 7. Modèle de données — `core_package` (donnée pure, listes statiques figées)

`packages/core_package/lib/src/notifications_guide/notification_guide_catalog.dart`
(exporté via `core_package.dart`). Style **identique** aux modèles existants (`Equatable`, clés i18n,
`static const` figé — cf. `StretchRoutine`/`GroundingExercise`).

```
/// Plateforme dont on affiche les étapes de réglages.
enum NotificationGuidePlatform { android, ios }

/// Une étape du guide « Couper mes notifications ». Donnée pure, immuable,
/// SANS I/O. Les libellés sont des CLES i18n (résolues côté app), jamais du
/// texte en dur. L'icône est un IconData Material (const).
class NotificationGuideStep extends Equatable {
  const NotificationGuideStep({
    required this.index,     // 1..5 (numéro de pastille affiché)
    required this.titleKey,  // clé ARB du titre
    required this.bodyKey,   // clé ARB de la description
    required this.icon,      // IconData Material (const)
  });

  final int index;
  final String titleKey;
  final String bodyKey;
  final IconData icon;

  @override
  List<Object?> get props => <Object?>[index, titleKey, bodyKey, icon];
}

/// Catalogue figé V1 : 2 jeux d'étapes (Android / iOS).
abstract final class NotificationGuideCatalog {
  static const List<NotificationGuideStep> androidSteps = <NotificationGuideStep>[
    NotificationGuideStep(index: 1, titleKey: 'notifGuideStep1Title', bodyKey: 'notifGuideStep1Body', icon: Icons.settings),
    NotificationGuideStep(index: 2, titleKey: 'notifGuideStep2Title', bodyKey: 'notifGuideStep2Body', icon: Icons.notifications),
    NotificationGuideStep(index: 3, titleKey: 'notifGuideStep3Title', bodyKey: 'notifGuideStep3Body', icon: Icons.phone_android),
    NotificationGuideStep(index: 4, titleKey: 'notifGuideStep4Title', bodyKey: 'notifGuideStep4Body', icon: Icons.notifications_off),
    NotificationGuideStep(index: 5, titleKey: 'notifGuideStep5Title', bodyKey: 'notifGuideStep5Body', icon: Icons.check_circle),
  ];

  static const List<NotificationGuideStep> iosSteps = <NotificationGuideStep>[
    NotificationGuideStep(index: 1, titleKey: 'notifGuideStep1TitleIos', bodyKey: 'notifGuideStep1BodyIos', icon: Icons.settings),
    NotificationGuideStep(index: 2, titleKey: 'notifGuideStep2TitleIos', bodyKey: 'notifGuideStep2BodyIos', icon: Icons.notifications),
    NotificationGuideStep(index: 3, titleKey: 'notifGuideStep3TitleIos', bodyKey: 'notifGuideStep3BodyIos', icon: Icons.phone_iphone),
    NotificationGuideStep(index: 4, titleKey: 'notifGuideStep4TitleIos', bodyKey: 'notifGuideStep4BodyIos', icon: Icons.notifications_off),
    NotificationGuideStep(index: 5, titleKey: 'notifGuideStep5TitleIos', bodyKey: 'notifGuideStep5BodyIos', icon: Icons.check_circle),
  ];

  static List<NotificationGuideStep> stepsFor(NotificationGuidePlatform p) =>
      p == NotificationGuidePlatform.ios ? iosSteps : androidSteps;
}
```

> Décisions de modèle :
> - **2 variantes android/ios privilégiées** (défaut demandé) : les chemins de réglages diffèrent
>   réellement (« Réglages › Notifications › [app] › désactiver/Résumé programmé » vs Android
>   « Paramètres › Notifications › [app] › désactiver/Résumé »). Justifie 2 jeux de clés i18n.
>   **Alternative non retenue :** une seule liste générique — possible si on accepte des libellés
>   volontairement neutres, mais on perd la fidélité par plateforme. **Défaut = 2 variantes.**
> - `IconData` dans `core_package` : acceptable, `Icons.*` sont des `const IconData` (Material), pas
>   d'asset, pas de réseau. Reste **donnée pure** (pas de widget). L'icône `phone_iphone` est utilisée
>   pour iOS (au lieu de `phone_android`) pour la fidélité, le reste des icônes est commun.
> - **Aucun Drift** ici (cohérent DEC-001 : Drift réservé au journal d'humeur / exercices terminés).

---

## 8. Widgets de présentation (Material only, pas d'asset hors logo, pas de package tiers)

### 8.1 `GuideStepCard`
- Conteneur `surface` (`#283A5E`), `BorderRadius.circular(AppTheme.radiusSmall)` (12), padding interne.
- `Row` : **pastille ronde numérotée** (cercle `primary`/cyan, `Text(step.index)` en `foreground`/fond
  contrasté) → **icône** `Icon(step.icon, color: primary)` → `Column(crossAxisStart)` : `Text(title,
  bold, foreground)` + `Text(body, muted)`.
- Espacement vertical régulier entre cartes (la maquette empile 5 cartes). Pas d'interaction (cartes
  non cliquables — purement informatives).

### 8.2 `GuideTipBanner`
- Fond **cyan translucide** (`AppTheme.primary.withValues(alpha: 0.12)`), radius 12, padding.
- `Row` : `Icon(Icons.wb_sunny, color: AppTheme.sensesAccent)` (jaune `#F0C84A`) + `Text(tip, foreground/muted)`.

### 8.3 `OtherPhoneLink`
- `Text(l10n.notifGuideOtherPhone, color: AppTheme.muted)` centré, atténué, soulignement léger
  optionnel. Enveloppé dans un `InkWell`/`GestureDetector` (zone tap confortable) → `onTogglePlatform`.

### 8.4 `DigiBrandHeader` (cf. §4.bis)
- `Row` 3 zones (leading chevron / centre logo+label / trailing menu). Le centre :
  `Row(mainAxisSize.min)` = logo (`Image.asset` 32×32 radius 8 + `errorBuilder` fallback) + `SizedBox`
  + `Text(l10n.notifGuideBrand /* « DigiHarmony » */, color: primary, letterSpacing, uppercase via
  style/`.toUpperCase()`)`.

---

## 9. reduceMotion (accessibilité)

- Contenu **statique** (cartes, bandeau, texte) → **aucune animation lourde** par défaut. `AppBackground`
  est déjà sans boucle d'animation (halos statiques) → compatible `reduceMotion` par construction.
- **Si** une apparition échelonnée des cartes est ajoutée (ex. `flutter_animate` fade/slide en cascade) :
  la **neutraliser sous `reduceMotion`** (`MediaQuery.disableAnimations` / `AccessibilityFeatures.reduceMotion`
  lu en haut de `NotificationGuideView`) → afficher les cartes **immédiatement, à leur état final**.
- Règle générale du projet : **décoratif coupé, information conservée**. Aucune information (étapes,
  conseil, lien) ne doit dépendre d'une animation.

---

## 10. Navigation & feedback haptique

| Élément | Action | Cible | Feedback |
| --- | --- | --- | --- |
| Chevron retour (header) | `Navigator.maybePop(context)` | **parent réel** (« Mon temps d'écran » `/screen-time` ou Home selon point d'entrée — par nom de route, **non présumé**) | — (rendu chevron standard) |
| Bouton menu (hamburger) | **no-op TODO** | — | — (cf. ci-dessous) |
| Lien « Voir pour un autre téléphone » | bascule plateforme | swap android ↔ ios (même écran) | **`HapticFeedback.selectionClick()`** avant swap |

> **Bouton menu (hamburger) — HORS-SCOPE de cet écran.** Le menu global de l'app sera défini avec
> l'écran **Accueil/Home/app-shell**. Ici : **poser le bouton** (`IconButton(Icons.menu)`, `tooltip:
> l10n.notifGuideMenuTooltip`) avec une action **`onPressed` no-op + commentaire `// TODO(home): menu
> global app-shell — défini avec l'écran Home`**. **Ne pas plomber le plan.**
> *Alternative signalée :* le **retirer** entièrement de cet écran si on préfère ne pas exposer un
> bouton inerte. **Défaut retenu : le poser en TODO no-op** (fidélité maquette). Le développeur tranche.

> ⚠️ Le **retour** ne présume pas du parent : `Navigator.maybePop` revient à l'écran qui a poussé
> `/notifications-guide` (réellement `/screen-time` aujourd'hui via la carte de `temps-decran.md`).
> Le branchement de route concret (table de routes) reste à câbler côté app shell — **signalé**.

---

## 11. Internationalisation (clés ARB)

Fichiers `lib/l10n/arb/app_*.arb` (8 langues existantes). **FR + EN remplis**, **placeholders
el/it/ro/tr/es/mk** (valeur provisoire = texte EN, à traduire), repli `en`. Préfixe `notifGuide*`.
Suffixe **`Ios`** pour les variantes iOS (les titres d'icône restent communs ; seuls les **chemins de
réglages** diffèrent dans les bodies, et certains titres).

### 11.1 Toolbar / sous-titre / commun

| Clé | FR | EN |
| --- | --- | --- |
| `notifGuideBrand` | DigiHarmony | DigiHarmony |
| `notifGuideTitle` | Couper mes notifications | Mute my notifications |
| `notifGuideSubtitle` | Moins de notifications, plus de calme. | Fewer notifications, more calm. |
| `notifGuideTip` | Chaque notification en moins, c'est une interruption de moins. Prends ton temps. | Each notification removed is one less interruption. Take your time. |
| `notifGuideOtherPhone` | Voir pour un autre téléphone | See for another phone |
| `notifGuideMenuTooltip` | Menu | Menu |
| `notifGuideBackLabel` | Retour | Back |

### 11.2 Étapes — variante **Android** (jeu par défaut)

| Clé | FR | EN |
| --- | --- | --- |
| `notifGuideStep1Title` | Ouvre les Réglages | Open Settings |
| `notifGuideStep1Body` | Repère l'icône engrenage sur ton écran d'accueil ou dans ta bibliothèque d'apps. | Find the gear icon on your home screen or in your app library. |
| `notifGuideStep2Title` | Appuie sur "Notifications" | Tap "Notifications" |
| `notifGuideStep2Body` | Fais défiler jusqu'à la section "Notifications" et appuie dessus. | Scroll to the "Notifications" section and tap it. |
| `notifGuideStep3Title` | Choisis une app distrayante | Pick a distracting app |
| `notifGuideStep3Body` | Sélectionne une app qui t'interrompt souvent — réseaux sociaux, messageries, jeux. | Choose an app that interrupts you often — social media, messaging, games. |
| `notifGuideStep4Title` | Désactive ou regroupe | Turn off or group |
| `notifGuideStep4Body` | Désactive les notifications ou active "Résumé programmé" pour les recevoir une seule fois par jour. | Turn notifications off, or enable "Scheduled summary" to get them once a day. |
| `notifGuideStep5Title` | Répète pour chaque app | Repeat for each app |
| `notifGuideStep5Body` | Prends 2–3 minutes pour passer les apps une par une. Chaque silence compte. | Take 2–3 minutes to go through your apps one by one. Every bit of quiet counts. |

### 11.3 Étapes — variante **iOS** (suffixe `Ios`)

| Clé | FR | EN |
| --- | --- | --- |
| `notifGuideStep1TitleIos` | Ouvre les Réglages | Open Settings |
| `notifGuideStep1BodyIos` | Repère l'icône grise « Réglages » sur ton écran d'accueil ou via la recherche. | Find the grey "Settings" icon on your home screen or via search. |
| `notifGuideStep2TitleIos` | Appuie sur "Notifications" | Tap "Notifications" |
| `notifGuideStep2BodyIos` | Dans Réglages, ouvre la section "Notifications". | In Settings, open the "Notifications" section. |
| `notifGuideStep3TitleIos` | Choisis une app distrayante | Pick a distracting app |
| `notifGuideStep3BodyIos` | Sélectionne une app qui t'interrompt souvent — réseaux sociaux, messageries, jeux. | Choose an app that interrupts you often — social media, messaging, games. |
| `notifGuideStep4TitleIos` | Désactive ou programme | Turn off or schedule |
| `notifGuideStep4BodyIos` | Désactive "Autoriser les notifications" ou utilise le "Résumé programmé" pour les regrouper. | Turn off "Allow Notifications", or use "Scheduled Summary" to group them. |
| `notifGuideStep5TitleIos` | Répète pour chaque app | Repeat for each app |
| `notifGuideStep5BodyIos` | Prends 2–3 minutes pour passer les apps une par une. Chaque silence compte. | Take 2–3 minutes to go through your apps one by one. Every bit of quiet counts. |

> Notes :
> - Les **deux jeux** existent comme clés distinctes (suffixe `Ios`) pour découpler les chemins de
>   réglages. Plusieurs libellés sont volontairement **identiques** FR/EN entre Android/iOS (étapes 3 et 5)
>   — on les duplique quand même pour garder un jeu cohérent et indépendant par plateforme.
> - Aucune valeur dynamique injectée (pas de placeholders paramétrés ici) → clés simples.
> - Penser à remplir les 6 ARB restants (el/it/ro/tr/es/mk) avec la valeur EN provisoire (repli `en`
>   garantit l'absence de clé manquante au runtime), à traduire ensuite.

---

## 12. Contraintes RGPD / projet (rappel impératif)

- **Zéro collecte, zéro réseau, zéro stockage.** Écran **purement statique** + 1 état UI local non
  persistant. Aucune lecture OS, aucune permission, aucun audio.
- **Aucun SDK** réseau/analytics/tracking/Crashlytics. **Logo en asset local** (jamais
  `cached_network_image`/`Image.network` — les URLs Banani/Firebase Storage ne servent **que** d'export
  maquette).
- **Aucune permission** ajoutée au manifeste pour cet écran (ni `VIBRATE` → `HapticFeedback`, ni
  `INTERNET`). N'altère pas le manifeste.
- **Pas de Drift, pas de HydratedBloc** (rien à persister, y compris la plateforme affichée).
- **Icônes Material only** (`settings`, `notifications`, `phone_android`/`phone_iphone`,
  `notifications_off`, `check_circle`, `wb_sunny`, `menu`, `chevron_left`). Pas d'asset image hors logo.
- DM Sans en **asset local** via `AppTheme.fontFamily` (repli système gracieux si `.ttf` absent ;
  **jamais** `google_fonts`).
- Android release : `minify`/`shrinkResources` restent `false` — inchangé (cet écran n'y touche pas).

---

## 13. Critères d'acceptation (tiennent lieu d'US — source des tests Kent)

1. **AC-1** L'écran affiche, dans l'ordre : header brand (logo+label « DigiHarmony »), sous-titre
   « Moins de notifications, plus de calme. », **5 cartes d'étapes numérotées 1→5** (pastille + icône +
   titre + description), le bandeau conseil (icône sun jaune `#F0C84A`), puis le lien « Voir pour un
   autre téléphone ».
2. **AC-2** Sur Android (plateforme courante), le jeu d'étapes **Android** est affiché par défaut ;
   sur iOS, le jeu **iOS** est affiché par défaut.
3. **AC-3** Le lien « Voir pour un autre téléphone » **bascule** vers l'autre jeu d'étapes (android ↔
   ios) et **re-bascule** au tap suivant (les deux sens fonctionnent), avec
   `HapticFeedback.selectionClick` à chaque bascule.
4. **AC-4** Le chevron retour exécute `Navigator.maybePop` (revient au parent réel, non présumé).
5. **AC-5** Le bouton menu est présent mais **inerte** (no-op TODO) — aucune navigation/erreur au tap.
   *(Si l'option « retirer le menu » est choisie, cette AC devient : le menu n'est pas affiché.)*
6. **AC-6** **Tous les textes** proviennent de l'ARB (clés `notifGuide*`) — aucun texte en dur dans les
   widgets ; les variantes iOS utilisent les clés à suffixe `Ios`.
7. **AC-7** `NotificationGuideStep` / `NotificationGuideCatalog` sont des **données pures** de
   `core_package` (Equatable, `static const`, clés i18n, `IconData` Material) — **sans** `dart:io`,
   **sans** widget, **sans** I/O. `stepsFor(android)` et `stepsFor(ios)` renvoient chacun 5 étapes
   ordonnées par `index` 1→5.
8. **AC-8** Le fond de l'écran est `AppTheme.hubBackground` (#1F2C49), **pas** `bubbleBackground`
   (#16213C). L'icône du bandeau conseil utilise `AppTheme.sensesAccent` (#F0C84A).
9. **AC-9** Le logo est un **asset local** ; en l'absence de l'asset, un **fallback gracieux**
   (placeholder ou label seul) s'affiche **sans crash ni accès réseau**.
10. **AC-10** **Aucune** persistance (Drift/HydratedBloc), **aucun** appel réseau, **aucune** permission,
    **aucun** audio, **aucun** `cached_network_image`. La plateforme affichée n'est pas persistée
    (réouverture → plateforme courante).
11. **AC-11** Sous `reduceMotion`, si une apparition échelonnée est implémentée, elle est neutralisée :
    les 5 cartes + le bandeau + le lien sont affichés immédiatement à leur état final (aucune info perdue).

---

## 14. Découpage fichiers (indicatif, à confirmer par les règles d'architecture)

```
packages/core_package/lib/src/notifications_guide/notification_guide_catalog.dart
    (NotificationGuidePlatform, NotificationGuideStep, NotificationGuideCatalog)
packages/core_package/lib/core_package.dart        (+ export ci-dessus)

apps/digiharmony_app/lib/notifications_guide/
├─ view/notification_guide_page.dart     (Page : état local _platform + plateforme initiale)
├─ view/notification_guide_view.dart     (UI : header + sous-titre + liste + bandeau + lien)
└─ widgets/
   ├─ digi_brand_header.dart             (Option A : chevron + logo+label + menu no-op)  ← ou extension DigiToolbar
   ├─ guide_step_card.dart               (pastille n° + icône + titre + body)
   ├─ guide_tip_banner.dart              (icône sun jaune + texte, fond cyan translucide)
   └─ other_phone_link.dart              (lien bas + HapticFeedback.selectionClick)
   [ widgets/_logo_fallback.dart si fallback isolé ]

apps/digiharmony_app/assets/images/logo.png        (À DÉPOSER ; sinon fallback)
apps/digiharmony_app/pubspec.yaml                  (+ déclaration flutter: assets: [assets/images/] — À CRÉER)
apps/digiharmony_app/lib/l10n/arb/app_*.arb        (clés notifGuide* ; FR+EN remplis, 6 autres en repli EN)

routing app-shell : brancher /notifications-guide (table de routes — câblage côté Home/screen-time)
```

---

## 15. Points à valider explicitement (signalés, non tranchés unilatéralement)

- ⚠️ **Token de fond :** le code réel expose **`AppTheme.hubBackground` (#1F2C49)** = fond standard app.
  Le plan parent `temps-decran.md` parlait d'un token `appBackground` « à ajouter » : **inutile**, il
  existe déjà sous `hubBackground`. **Défaut retenu : utiliser `hubBackground`.** (Si une renommage
  `hubBackground → appBackground` est souhaité pour clarté sémantique, c'est un refactor cross-page
  séparé, non bloquant — à coordonner avec `temps-decran.md`.)
- ⚠️ **Toolbar brand :** Option A `DigiBrandHeader` dédié (recommandé, ne touche pas `DigiToolbar`) vs
  Option B extension de `DigiToolbar` (`titleWidget`). **Défaut : Option A.** Promouvoir en partagé si
  l'écran Home réutilise l'app-shell.
- ⚠️ **Bouton menu :** poser en **no-op TODO** (défaut, fidélité maquette) vs le retirer. **Défaut : le
  poser.** Action définie avec l'écran Home.
- ⚠️ **État plateforme :** `StatefulWidget` (défaut, le plus simple) vs `Cubit` léger non persistant (si
  règle archi l'impose). **Jamais `HydratedBloc`.**
- ⚠️ **1 liste générique vs 2 variantes android/ios :** **défaut = 2 variantes** (fidélité des chemins de
  réglages). 1 liste générique possible si on accepte des libellés neutres — non retenu.
- ⚠️ **Plateforme initiale via `Platform.isIOS` :** lecture directe `dart:io` (OK Android/iOS, pas web —
  hors périmètre). Encapsuler dans un getter injectable si on veut la mocker en test (recommandé pour
  tester les 2 jeux par défaut sans dépendre de la plateforme de test).
- ⚠️ **Asset logo `assets/images/logo.png` :** à déposer + déclarer dans `pubspec.yaml` (aucune section
  `assets:` n'existe aujourd'hui). En attendant : **fallback gracieux** obligatoire (placeholder/label).
- ⚠️ **Câblage de route `/notifications-guide` :** table de routes à brancher côté app-shell/Home (la
  carte de `temps-decran.md` pousse cette route — aujourd'hui placeholder). À confirmer au moment de
  l'intégration.
```
