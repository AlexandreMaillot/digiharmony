---
page: Mon temps d'écran (ScreenTimePage)
route: /screen-time (ScreenTimePage — écran plein écran, atteint depuis l'Accueil/Home ; chevron retour → parent)
us: []
shared_components: [DigiToolbar, AppBackground, AppTheme]
i18n_keys: [screenTimeTitle, screenTimeTodaySubtitle, screenTimeTodayLabel, screenTimeWeekLabel, screenTimePrivacyNotice, screenTimeNextSection, screenTimeActionBreakTitle, screenTimeActionBreakSubtitle, screenTimeActionNotificationsTitle, screenTimeActionNotificationsSubtitle, screenTimePermissionTitle, screenTimePermissionBody, screenTimePermissionCta, screenTimeUnsupportedTitle, screenTimeUnsupportedBody, screenTimeErrorBody, screenTimeRetryCta, screenTimeDurationHm, screenTimeWeekday1, screenTimeWeekday2, screenTimeWeekday3, screenTimeWeekday4, screenTimeWeekday5, screenTimeWeekday6, screenTimeWeekday7]
shared_components_extracted: [ScreenTimeSummary/DayUsage (core_package, donnée pure immuable), ScreenTimeRepository (app, encapsule le platform channel PACKAGE_USAGE_STATS), ScreenTimeCubit (états loading/permissionRequired/unsupported/loaded/error), ScreenTimeGaugePainter + WeeklyHistogramPainter (CustomPainter)]
tests: aidd_docs/tasks/temps-decran.tests.md (à remplir par Kent en étape 5)
created: 2026-06-05
updated: 2026-06-05
---

# Plan de page — « Mon temps d'écran » (ScreenTimePage)

> Plan auto-suffisant pour éditeur IA. Conforme aux règles `aidd_docs/memory/` +
> `aidd_docs/rules/` de DIGIHARMONY : Flutter, monorepo Melos 7, **client-only,
> zéro collecte, zéro réseau, zéro SDK analytics/tracking/Crashlytics**, vibration via
> `HapticFeedback` uniquement, i18n ARB gen-l10n 8 langues (repli `en`), DM Sans en asset
> local (jamais `google_fonts`).
>
> ⭐ **FEATURE PHARE — point sensible du projet.** C'est le SEUL écran qui exploite la SEULE
> permission autorisée : **`PACKAGE_USAGE_STATS`** (Android `UsageStatsManager`). Lecture du
> temps d'écran **100 % locale sur l'appareil**, calculée à la volée depuis l'OS, **aucun
> stockage Drift**, **aucun envoi réseau**. La bannière « lu sur ton téléphone uniquement,
> rien n'est envoyé » est la **pierre angulaire RGPD-par-absence-de-traitement** et doit
> rester visible et fidèle.
>
> Cet écran **réutilise** les composants partagés `DigiToolbar`, `AppBackground`, `AppTheme`
> créés par `choisis-ta-bulle.md` et étendus par `respiration.md`/`detox.md` (`trailing`,
> `background`, tokens `surface`/`muted`/`primary`/`success`). **Différence clé de fond :** cet
> écran utilise le **fond STANDARD de l'app `#1F2C49`** (PAS le fond bulle `#16213C`).

---

## 1. Contexte de la page

| Élément | Valeur |
| --- | --- |
| Nom | « Mon temps d'écran » — tableau de bord local du temps passé sur le téléphone (aujourd'hui + semaine + répartition 7 jours) |
| Widget page | `ScreenTimePage` (entrée + providers) + `ScreenTimeView` (UI), fichier `lib/screen_time/view/screen_time_page.dart` |
| Route logique | `/screen-time`, écran plein écran, **enfant de l'Accueil/Home**. Le chevron retour ramène au parent (Home) |
| Parent | Accueil / Home (le point d'entrée exact sera branché côté routing Home — non présumé ici) |
| Accès / rôles / auth | **Aucun** — app sans compte, sans identification. Accès libre. La permission n'est PAS un rôle : c'est un accès système spécial (cf. §6) |
| Données affichées | **Temps d'écran AUJOURD'HUI** (jauge), **TOTAL semaine** (texte), **RÉPARTITION par jour** (7 barres lun→dim). Toutes **calculées à la volée depuis l'OS** |
| Source de données | **OS Android** via `UsageStatsManager`, lu par `ScreenTimeRepository` (platform channel). **Aucune** API réseau, **aucune** DB |
| Persistance | **AUCUNE.** Pas de Drift, pas de HydratedBloc pour les stats. Lecture **on-demand** à chaque ouverture/retour. Cohérent zéro collecte : aucun journal de temps d'écran persistant |
| État applicatif | `ScreenTimeCubit` — états `loading` / `permissionRequired` / `unsupported` / `loaded(summary)` / `error`. Re-fetch au retour des réglages (`resume`) |
| États écran | `loading`, `permissionRequired` (invite), `unsupported` (iOS), `loaded` (nominal), `error`. Cf. §5 et §6 |

**Pourquoi AUCUN cache par défaut :** la lecture `UsageStatsManager` est rapide et locale. Un
cache introduirait un stockage de données d'usage → contraire à « zéro collecte / RGPD par absence
de traitement ». **Lecture on-demand uniquement.** Un cache léger ne serait justifié que si un profilage
prouvait une latence perceptible — à ce moment-là seulement, le proposer explicitement comme décision
(non retenu dans ce plan).

---

## 2. User Stories liées

**Aucune US backlog référencée fournie.** Le plan s'appuie sur les **décisions validées par
l'utilisateur** (reportées en §13) qui font office de critères d'acceptation. À rattacher si une US
existe (mettre à jour le champ `us:` de l'en-tête + du registry).

---

## 3. Design — structure visuelle (fidèle à la maquette fournie)

Fond **`#1F2C49`** (fond STANDARD app, PAS `#16213C`) + **halo radial cyan décoratif** en haut
(décoratif → masqué/atténué sous `reduceMotion` si animé ; sinon statique discret).

```
┌──────────────────────────────────────────────┐
│  [‹ 48x48]    Mon temps d'écran     [spacer48]│  ← DigiToolbar (trailing=null)
│                                                │
│            Voici ton temps d'écran aujourd'hui │  ← sous-titre (muted/foreground)
│                                                │
│  ┌──────────── Carte principale (#283A5E) ───┐│
│  │            ╭───────────╮                    ││
│  │          ◜   3h24m      ◝   ← JAUGE         ││  arc gradient cyan→vert
│  │         │   aujourd'hui  │     CIRCULAIRE   ││  r=88, stroke 10
│  │          ╰───────────╯                      ││
│  │  ─────────── séparateur ───────────         ││
│  │  24h10m            ▁▃▂▅▃▆█  L M M J V S D    ││  ← mini histogramme 7j
│  │  cette semaine     (dernier jour surligné)  ││     D = gradient cyan→vert
│  └─────────────────────────────────────────────┘│
│                                                │
│  ┌──🛡──────────────────────────────────────┐  │  ← bannière confidentialité
│  │ Ces données sont lues sur ton téléphone   │  │     fond cyan translucide
│  │ uniquement. Rien n'est envoyé.            │  │     POINT CLÉ RGPD
│  └────────────────────────────────────────────┘ │
│                                                │
│  ET MAINTENANT ?                               │  ← label uppercase
│  ┌──(🌿)─ Faire une pause ───────────────  › ┐ │  → /bubble/detox
│  │       Lance une session Détox maintenant   │ │
│  └────────────────────────────────────────────┘ │
│  ┌──(🔕)─ Couper mes notifications ───────  › ┐ │  → /notifications-guide
│  │       Guide rapide pour réduire les inter… │ │
│  └────────────────────────────────────────────┘ │
└──────────────────────────────────────────────┘
```

**Ordre strict (haut → bas) :** Toolbar → sous-titre → carte principale (jauge + séparateur +
ligne semaine/histogramme) → bannière confidentialité → section « ET MAINTENANT ? » (2 cartes-action).
Ne PAS réordonner.

### Tokens de design (à mapper sur `AppTheme`)

| Token | Valeur | Rôle | Statut `AppTheme` |
| --- | --- | --- | --- |
| `appBackground` | `#1F2C49` | **fond standard app** (cet écran) | à ajouter si absent (distinct de `bubbleBackground #16213C`) |
| `surface` | `#283A5E` | cartes (principale + actions) | déjà posé (detox) |
| `primary` (cyan) | `#3FB8E6` | jauge début, accent action « pause » | déjà posé |
| `success` (vert) | `#A8D24E` | jauge fin, surbrillance dernier jour | déjà posé |
| `foreground` | `#F2F6FB` | texte principal, valeur jauge | déjà posé |
| `muted` | `#A7B6CE` | sous-titres, labels jours, action « muted » | déjà posé |
| accent confidentialité | cyan translucide (`primary` @ ~12 % alpha) | fond bannière shield | dérivé de `primary` |
| radius | 12 / 16 / 24 | rayons cartes | tokens existants |
| police | **DM Sans** (asset local) | toute la typo | déjà câblée (jamais google_fonts) |

> ⚠️ Le token `appBackground #1F2C49` est **distinct** de `bubbleBackground #16213C`. Si `AppTheme`
> ne l'expose pas encore, l'ajouter (ne PAS réutiliser le fond bulle). `AppBackground` doit accepter
> ce background (param `background:` déjà introduit par `respiration.md`).

---

## 4. Arborescence des widgets

```
ScreenTimePage  (lib/screen_time/view/screen_time_page.dart)
└─ BlocProvider<ScreenTimeCubit>(create: ..repository..)..fetch()
   └─ ScreenTimeView
      └─ AppBackground(background: AppTheme.appBackground)   ← #1F2C49 + halo cyan déco
         └─ SafeArea
            └─ Column
               ├─ DigiToolbar(title: l10n.screenTimeTitle, trailing: null, onBack: Navigator.pop)
               └─ Expanded
                  └─ BlocBuilder<ScreenTimeCubit, ScreenTimeState>
                     ├─ loading        → ScreenTimeLoadingView (spinner centré, fond app)
                     ├─ permissionRequired → ScreenTimePermissionView (icône + texte + CTA)
                     ├─ unsupported    → ScreenTimeUnsupportedView (icône + texte info)
                     ├─ error          → ScreenTimeErrorView (texte + bouton « Réessayer »)
                     └─ loaded(summary)→ ScreenTimeLoadedView (SingleChildScrollView)
                                          ├─ ScreenTimeSubtitle (screenTimeTodaySubtitle)
                                          ├─ ScreenTimeSummaryCard
                                          │   ├─ ScreenTimeGauge (CustomPaint: ScreenTimeGaugePainter)
                                          │   │     center: valeur (durée) + screenTimeTodayLabel
                                          │   ├─ Divider
                                          │   └─ Row
                                          │       ├─ WeekTotalLabel (durée + screenTimeWeekLabel)
                                          │       └─ WeeklyHistogram (CustomPaint: WeeklyHistogramPainter)
                                          ├─ PrivacyNoticeBanner (icône shield + screenTimePrivacyNotice)
                                          ├─ NextSectionLabel (screenTimeNextSection, uppercase)
                                          ├─ ScreenTimeActionCard(break)  → /bubble/detox
                                          └─ ScreenTimeActionCard(notifications) → /notifications-guide
```

### Composants réutilisés (registry)

| Composant | Origine | Usage ici |
| --- | --- | --- |
| `DigiToolbar` | choisis-ta-bulle (+ trailing respiration) | toolbar, `trailing: null` (spacer 48px), `onBack` → `Navigator.pop` |
| `AppBackground` | choisis-ta-bulle (+ background respiration) | fond `#1F2C49` + halo cyan déco |
| `AppTheme` | choisis-ta-bulle (+ tokens detox/respiration) | `surface`, `primary`, `success`, `foreground`, `muted` ; **+ `appBackground #1F2C49`** |

### Nouveaux composants (créés par ce plan)

| Composant | Emplacement | Rôle |
| --- | --- | --- |
| `ScreenTimeSummary` / `DayUsage` | **core_package** | données pures immuables (cf. §7) |
| `ScreenTimeRepository` | app `lib/screen_time/data/` | encapsule le platform channel PACKAGE_USAGE_STATS (injectable/mockable) |
| `ScreenTimeCubit` | app `lib/screen_time/cubit/` | états loading/permissionRequired/unsupported/loaded/error |
| `ScreenTimeGaugePainter` | app `lib/screen_time/widgets/` | jauge circulaire arc partiel gradient (CustomPainter) |
| `WeeklyHistogramPainter` | app `lib/screen_time/widgets/` | 7 barres L→D, dernier jour surligné (CustomPainter) |
| `ScreenTimeActionCard` | app `lib/screen_time/widgets/` | carte-action (icône ronde + titre + sous-titre + chevron) |
| `PrivacyNoticeBanner` | app `lib/screen_time/widgets/` | bannière shield (texte i18n statique) |

> 🔁 **Candidat refactor cross-page (non bloquant) :** `ScreenTimeActionCard` (icône ronde + titre +
> sous-titre + chevron + `HapticFeedback`) ressemble fortement à des motifs « ligne d'action » d'autres
> écrans. À promouvoir dans un kit partagé (`lib/wellbeing_shared/` déjà proposé par etirement.md) si un
> 2ᵉ écran en a besoin. Ne PAS extraire prématurément.

---

## 5. Machine d'états — `ScreenTimeCubit`

États (sealed / classes immuables) :

| État | Données | UI |
| --- | --- | --- |
| `ScreenTimeLoading` | — | spinner centré |
| `ScreenTimePermissionRequired` | — | invite + CTA « Autoriser l'accès » |
| `ScreenTimeUnsupported` | — | info « disponible sur Android uniquement » |
| `ScreenTimeLoaded` | `ScreenTimeSummary summary` | jauge + histogramme + bannière + actions |
| `ScreenTimeError` | (message optionnel non affiché brut) | texte générique + « Réessayer » |

### Transitions

```
                         ┌──────── fetch() ────────┐
                         ▼                          │
                    [Loading] ──────────────────────┘
                         │
        ┌────────────────┼─────────────────┬──────────────────┐
        ▼                ▼                  ▼                  ▼
  isAndroid==false   permission NON     permission OK     exception
        │             accordée               │                 │
        ▼                 ▼                  ▼                  ▼
 [Unsupported]    [PermissionRequired]   readUsage()        [Error]
                          │                  │                 │
                  tap CTA « Autoriser »      ▼          tap « Réessayer »
                          │             [Loaded(summary)]      │
                          ▼                                    └──► fetch()
              openUsageAccessSettings()
                          │
                  retour app (resume)
                          │
                          ▼
                   refresh() ──► [Loading] ──► (re-check permission)
```

**Règles de transition :**

- `fetch()` (init + retry + resume) :
  1. Si `!Platform.isAndroid` → `Unsupported` (court-circuit, ne touche jamais le channel).
  2. Sinon `repository.hasUsageAccess()` :
     - `false` → `PermissionRequired`.
     - `true` → `repository.readSummary()` → `Loaded(summary)` ; toute exception → `Error`.
- CTA « Autoriser l'accès » (état `PermissionRequired`) : `HapticFeedback.selectionClick()` puis
  `repository.openUsageAccessSettings()` (ouvre `ACTION_USAGE_ACCESS_SETTINGS`). **Ne change pas l'état
  tout de suite** : l'utilisateur part dans les réglages système.
- **Au retour de l'app** (`AppLifecycleState.resumed`) : `cubit.refresh()` → ré-exécute `fetch()`
  (re-vérifie la permission ; passe à `Loaded` si l'accès vient d'être accordé). Câblé via un
  `WidgetsBindingObserver` dans `ScreenTimeView` (ou `didChangeAppLifecycleState`).
- « Réessayer » (état `Error`) : `fetch()`.

> ℹ️ `PACKAGE_USAGE_STATS` n'est **pas** une permission runtime classique (`permission_handler` ne la
> gère pas). Pas de pop-up système : on **redirige vers les réglages** puis on **re-vérifie au resume**.
> C'est la spécificité centrale de cet écran.

---

## 6. `ScreenTimeRepository` + platform channel PACKAGE_USAGE_STATS

### 6.1 Contrat Dart (interface, app `lib/screen_time/data/screen_time_repository.dart`)

```
abstract class ScreenTimeRepository {
  /// true si l'app a l'accès "Usage Access" (Android). false sinon.
  Future<bool> hasUsageAccess();

  /// Ouvre l'écran système ACTION_USAGE_ACCESS_SETTINGS. Ne retourne rien d'utile.
  Future<void> openUsageAccessSettings();

  /// Lit les stats locales et calcule le résumé (aujourd'hui + semaine + 7 jours).
  /// Lève une exception si lecture impossible (gérée → état Error).
  Future<ScreenTimeSummary> readSummary();
}
```

Implémentation concrète `MethodChannelScreenTimeRepository` (mockable via `mocktail` dans les tests).

### 6.2 Choix technique — MethodChannel maison vs package pub (à VALIDER)

**Recommandation : `MethodChannel` maison.** Justification :

- **Conformité zéro collecte/zéro réseau garantie** : on écrit nous-mêmes le code Kotlin qui lit
  `UsageStatsManager` et renvoie des durées agrégées. Aucune dépendance tierce → **aucun risque** qu'un
  package embarque du tracking/analytics/réseau (interdit par le projet).
- **Surface minimale** : 3 méthodes, pas de fonctionnalités superflues.
- **Pas d'ajout de dépendance** au `pubspec` du membre.

**Alternative signalée (⚠️ À VALIDER, non retenue par défaut) :** un plugin pub de lecture d'usage
**100 % local** type `usage_stats` / `app_usage`. Conforme **uniquement** si audité comme purement
lecteur d'`UsageStatsManager` **sans SDK réseau/analytics**. Différent d'un SDK tracking (interdit).
Si retenu : le **signaler explicitement** au développeur, vérifier ses permissions transitives et son
absence de réseau, et ne l'ajouter qu'après validation. **Par défaut → MethodChannel maison.**

### 6.3 Côté Android (Kotlin) — détail de la permission spéciale

- **AndroidManifest** : déclarer
  `<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" tools:ignore="ProtectedPermissions" />`
  (ajouter `xmlns:tools` au `<manifest>`). **SEULE** permission autorisée du projet. **Ne PAS** ajouter
  `VIBRATE` (vibration via `HapticFeedback`), ni `INTERNET`/réseau/analytics.
- **`hasUsageAccess()`** : via `AppOpsManager.unsafeCheckOpNoThrow(OPSTR_GET_USAGE_STATS, uid, packageName)`
  (`checkOpNoThrow` sur API < 29) → `MODE_ALLOWED`. Ne JAMAIS supposer accordé.
- **`openUsageAccessSettings()`** : `startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))`
  (`FLAG_ACTIVITY_NEW_TASK`). Renvoie l'utilisateur vers le réglage système. Re-vérification au resume.
- **`readSummary()`** :
  - `UsageStatsManager.queryUsageStats(INTERVAL_DAILY, ...)` ou agrégation via `queryAndAggregateUsageStats`
    sur des bornes de jours calendaires.
  - **Aujourd'hui** : somme du temps de foreground depuis minuit local jusqu'à maintenant.
  - **7 derniers jours (lun→dim de la semaine courante, ou 7 jours glissants — figer une convention :
    semaine calendaire lun→dim)** : une `DayUsage` par jour avec sa durée.
  - **Total semaine** : somme des 7 `DayUsage`.
  - Renvoyer une **map/struct sérialisable** (millisecondes par jour + total + aujourd'hui) ; le Dart
    construit `ScreenTimeSummary`. **Aucune écriture disque, aucun envoi.**

### 6.4 Fallback iOS / autres plateformes

- iOS **n'a pas d'API publique** équivalente (Screen Time / `DeviceActivity` = entitlement restreint,
  hors périmètre Erasmus+ client-only). `Platform.isAndroid == false` → état **`Unsupported`** (la feature
  est masquée/expliquée, jamais d'appel channel). Le point d'entrée Home peut aussi masquer l'accès sur
  iOS (décision Home, non présumée ici).

---

## 7. Modèle de données — `core_package` (donnée pure)

`packages/core_package/lib/src/screen_time/screen_time_summary.dart` (exporté via `core_package.dart`) :

```
/// Usage d'un jour de la semaine. Donnée pure, immuable, sans I/O.
class DayUsage {
  final int weekday;        // 1=lundi … 7=dimanche (DateTime.weekday)
  final Duration duration;  // temps d'écran ce jour-là
  // == / hashCode (Equatable ou override) ; const constructor
}

/// Résumé du temps d'écran. Donnée pure, aucune dépendance Flutter/Android.
class ScreenTimeSummary {
  final Duration todayDuration;   // jauge
  final Duration weekTotal;       // texte "cette semaine"
  final List<DayUsage> days;      // 7 entrées, ordonnées lundi→dimanche
  // const + == / hashCode ; invariants: days.length == 7
}
```

- **Aucune logique de plateforme** dans `core_package` (pas de `dart:io`, pas de channel) — pure donnée.
- `weekday` réutilise la convention `DateTime.weekday` (1..7). Le mapping vers les labels courts
  L/M/M/J/V/S/D se fait en UI via i18n (`screenTimeWeekday1..7`).
- **Pas d'agrégat Drift `WellbeingStats`** ici : cet écran **lit l'OS et n'écrit rien** (cohérent DEC-001 :
  Drift réservé au journal d'humeur / exercices terminés). À ne PAS confondre.

---

## 8. Visuels CustomPainter (pas d'asset image, pas de package de charts tiers)

### 8.1 `ScreenTimeGaugePainter`

- Arc de fond (cercle complet, `surface`/`muted` faible alpha) + **arc de progression** partiel,
  `r=88`, `strokeWidth=10`, `StrokeCap.round`.
- **Gradient cyan→vert** (`primary #3FB8E6 → success #A8D24E`) via `SweepGradient`/`LinearGradient` sur
  l'arc actif.
- **Mapping valeur → angle** : choisir une **échelle figée** (ex. plein arc = 8 h de référence ;
  `progress = todayDuration / 8h`, clampé [0,1]). Documenter la référence (non « pourcentage du max
  semaine » pour rester stable au quotidien).
- Centre : `3h24m` (valeur, `foreground`, gros) + `aujourd'hui` (`muted`) — rendus en widgets `Text`
  superposés (`Stack`), pas peints dans le painter.

### 8.2 `WeeklyHistogramPainter`

- 7 barres verticales (lun→dim), hauteur **proportionnelle** à `day.duration / maxJour` (clamp pour
  éviter barre nulle invisible → hauteur min).
- **Dernier jour (aujourd'hui)** en surbrillance **gradient cyan→vert** ; autres jours en `muted`/`surface`.
- Labels courts sous chaque barre via i18n (`screenTimeWeekday1..7`).
- Coins arrondis légers sur les barres ; espacement régulier.

> Les painters reçoivent **uniquement** des valeurs dérivées du `summary` (ratios, durées) + couleurs du
> thème. Pas d'état, pas d'I/O. `shouldRepaint` compare summary + reduceMotion + progress animé.

---

## 9. reduceMotion (accessibilité)

- `MediaQuery.disableAnimations` (ou `AccessibilityFeatures.reduceMotion`) lu en haut de `ScreenTimeView`.
- **Jauge** : si une animation d'apparition (remplissage progressif de l'arc) est prévue → **sous
  reduceMotion, rendu STATIQUE à la valeur finale** (la valeur `3h24m` et l'arc complet restent affichés
  immédiatement). Jamais de perte d'information.
- **Halo radial cyan déco** : si animé (pulsation), **figé/atténué** sous reduceMotion (purement décoratif).
- **Histogramme** : les barres affichent leurs hauteurs finales ; pas d'animation d'entrée sous reduceMotion.
- Règle générale : **décoratif coupé, information conservée**.

---

## 10. Navigation & feedback haptique

| Élément | Action | Cible | Feedback |
| --- | --- | --- | --- |
| Chevron retour (toolbar) | `Navigator.pop` | parent (Home) | — (comportement toolbar standard) |
| Carte « Faire une pause » | navigue | **`/bubble/detox`** (DetoxSetupPage, déjà planifié) | `HapticFeedback.selectionClick()` avant push |
| Carte « Couper mes notifications » | navigue | **`/notifications-guide`** (route logique, écran/guide **à planifier séparément**) | `HapticFeedback.selectionClick()` avant push |
| CTA « Autoriser l'accès » (état permission) | ouvre réglages système | `ACTION_USAGE_ACCESS_SETTINGS` | `HapticFeedback.selectionClick()` avant ouverture |

> ⚠️ **`/notifications-guide` n'est PAS implémenté par ce plan.** On référence une **route logique** par
> nom. Ne PAS présumer son écran. Si l'écran n'existe pas encore au moment de l'implémentation, brancher
> un placeholder de route et le signaler. À planifier dans un fichier dédié (`notifications-guide.md`).

---

## 11. Internationalisation (clés ARB)

Fichiers `lib/l10n/arb/app_*.arb`. **FR + EN remplis**, **placeholders el/it/ro/tr/es/mk** (valeur
provisoire = texte EN, à traduire), repli `en`. Préfixe `screenTime*`.

| Clé | FR | EN |
| --- | --- | --- |
| `screenTimeTitle` | Mon temps d'écran | My screen time |
| `screenTimeTodaySubtitle` | Voici ton temps d'écran aujourd'hui | Here's your screen time today |
| `screenTimeTodayLabel` | aujourd'hui | today |
| `screenTimeWeekLabel` | cette semaine | this week |
| `screenTimePrivacyNotice` | Ces données sont lues sur ton téléphone uniquement. Rien n'est envoyé. | This data is read on your phone only. Nothing is sent. |
| `screenTimeNextSection` | Et maintenant ? | And now? |
| `screenTimeActionBreakTitle` | Faire une pause | Take a break |
| `screenTimeActionBreakSubtitle` | Lance une session Détox maintenant | Start a Detox session now |
| `screenTimeActionNotificationsTitle` | Couper mes notifications | Mute my notifications |
| `screenTimeActionNotificationsSubtitle` | Guide rapide pour réduire les interruptions | Quick guide to reduce interruptions |
| `screenTimePermissionTitle` | Autorise l'accès au temps d'écran | Allow screen time access |
| `screenTimePermissionBody` | Pour afficher ton temps d'écran, autorise DIGIHARMONY à lire l'usage de ton téléphone. Rien n'est envoyé. | To show your screen time, allow DIGIHARMONY to read your phone usage. Nothing is sent. |
| `screenTimePermissionCta` | Autoriser l'accès | Allow access |
| `screenTimeUnsupportedTitle` | Disponible sur Android uniquement | Available on Android only |
| `screenTimeUnsupportedBody` | Cette fonctionnalité utilise une mesure du temps d'écran disponible seulement sur Android. | This feature uses a screen time measure available only on Android. |
| `screenTimeErrorBody` | Impossible de lire ton temps d'écran pour le moment. | Couldn't read your screen time right now. |
| `screenTimeRetryCta` | Réessayer | Retry |
| `screenTimeDurationHm` | {hours}h{minutes}m | {hours}h{minutes}m |
| `screenTimeWeekday1` | L | M |
| `screenTimeWeekday2` | M | T |
| `screenTimeWeekday3` | M | W |
| `screenTimeWeekday4` | J | T |
| `screenTimeWeekday5` | V | F |
| `screenTimeWeekday6` | S | S |
| `screenTimeWeekday7` | D | S |

> Notes :
> - `screenTimeDurationHm` est un **format paramétré** (`placeholders` `hours`/`minutes` typés `int`).
>   Utilisé pour `3h24m`, `24h10m`. Adapter le format par langue si besoin (EN identique pour MVP).
> - Les labels jours sont **mono-lettre** ; les ambiguïtés (FR M/M, EN T/T/S/S) sont assumées (maquette).
>   Si une langue rend l'ambiguïté gênante, autoriser 2 lettres dans sa traduction.
> - Bannière confidentialité = **texte i18n statique**, jamais une valeur dynamique. Pierre angulaire RGPD.

---

## 12. Contraintes RGPD / projet (rappel impératif)

- **Zéro collecte, zéro réseau, zéro stockage** des données d'usage. Lecture **on-demand**, jamais persistée.
- **Aucun SDK** analytics/tracking/Crashlytics. **MethodChannel maison** privilégié (toute dépendance pub
  = à valider + auditer absence de réseau).
- **SEULE permission** : `PACKAGE_USAGE_STATS` (déclarée avec `tools:ignore`, accès via réglages système).
  **Pas** de `VIBRATE` (HapticFeedback), **pas** d'`INTERNET`.
- **Pas de Drift, pas de HydratedBloc** pour les stats (rien à persister).
- **Bannière confidentialité toujours visible** en état `loaded` — argument central du projet.
- DM Sans en **asset local** (jamais `google_fonts`).
- Android release : `minify`/`shrinkResources` restent `false` (R8 strippe les libs natives) — inchangé.

---

## 13. Critères d'acceptation (tiennent lieu d'US — source des tests Kent)

1. **AC-1** Sur Android avec accès accordé : l'écran affiche la jauge (aujourd'hui), le total semaine et
   l'histogramme 7 jours, calculés depuis l'OS.
2. **AC-2** Sur Android **sans** accès : état `permissionRequired` avec CTA ; le CTA ouvre
   `ACTION_USAGE_ACCESS_SETTINGS` et déclenche `HapticFeedback.selectionClick`.
3. **AC-3** Au retour de l'app (resume) après avoir accordé l'accès : re-fetch automatique → passage à `loaded`.
4. **AC-4** Sur une plateforme non-Android (iOS) : état `unsupported`, **aucun** appel au channel.
5. **AC-5** En cas d'exception de lecture : état `error` avec bouton « Réessayer » qui relance `fetch()`.
6. **AC-6** La bannière « lu sur ton téléphone uniquement, rien n'est envoyé » est visible en état `loaded`
   (texte i18n statique).
7. **AC-7** « Faire une pause » navigue vers `/bubble/detox` (+ haptique) ; « Couper mes notifications »
   navigue vers `/notifications-guide` (+ haptique).
8. **AC-8** Sous `reduceMotion`, la jauge et l'histogramme affichent leurs valeurs finales sans animation ;
   aucune information perdue.
9. **AC-9** `ScreenTimeSummary` est une donnée pure de `core_package` (sans `dart:io`/Flutter) ; le repository
   est mockable (mocktail) ; le Cubit ne touche jamais directement la plateforme.
10. **AC-10** Aucune écriture Drift/HydratedBloc des stats ; aucun appel réseau ; manifeste sans permission
    autre que `PACKAGE_USAGE_STATS`.

---

## 14. Découpage fichiers (indicatif, à confirmer par les règles d'architecture)

```
packages/core_package/lib/src/screen_time/screen_time_summary.dart   (ScreenTimeSummary, DayUsage)
packages/core_package/lib/core_package.dart                          (export)

apps/digiharmony_app/lib/screen_time/
├─ view/screen_time_page.dart            (Page + providers + lifecycle observer)
├─ view/screen_time_view.dart            (UI + BlocBuilder par état)
├─ cubit/screen_time_cubit.dart          (Cubit)
├─ cubit/screen_time_state.dart          (états sealed)
├─ data/screen_time_repository.dart      (interface)
├─ data/method_channel_screen_time_repository.dart  (impl. MethodChannel)
└─ widgets/
   ├─ screen_time_gauge.dart + screen_time_gauge_painter.dart
   ├─ weekly_histogram.dart + weekly_histogram_painter.dart
   ├─ screen_time_action_card.dart
   ├─ privacy_notice_banner.dart
   └─ screen_time_state_views.dart       (loading/permission/unsupported/error)

android: MainActivity / plugin Kotlin enregistrant le MethodChannel "digiharmony/screen_time"
         + AndroidManifest (PACKAGE_USAGE_STATS, tools:ignore)

apps/digiharmony_app/lib/l10n/arb/app_*.arb  (clés screenTime*)
```

---

## 15. Points à valider explicitement (signalés, non tranchés unilatéralement)

- ⚠️ **MethodChannel maison vs package pub** de lecture d'usage : recommandation = maison (cf. §6.2).
  Si un package est souhaité, le valider/auditer (absence réseau/analytics) avant ajout.
- ⚠️ **Convention « semaine »** : lun→dim calendaire (retenu) vs 7 jours glissants. À figer côté Kotlin.
- ⚠️ **Échelle de la jauge** : référence fixe (ex. 8 h) retenue pour stabilité. À confirmer.
- ⚠️ **Point d'entrée Home → /screen-time** et masquage sur iOS : décision côté écran Accueil, non présumée.
- ⚠️ **`/notifications-guide`** : écran/guide à planifier séparément (placeholder de route en attendant).
