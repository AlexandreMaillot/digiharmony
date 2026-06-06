---
page: Mon temps d'écran
slug: temps-ecran
route: TempsEcranPage (push via AppRouter.versTempsEcran)
feature_dir: apps/digiharmony_app/lib/pages/temps_ecran/
status: proposition_a_valider
github:
us:
  - "US-TE-01 « Consulter mon temps d'écran » → GitHub #12 (milestone Phase 2 🟡 non assigné — milestone inexistant)"
  - "US-TE-02 « Octroyer l'accès aux statistiques d'usage » → GitHub #13 (dépend de #12)"
depends_on:
  - "#3 Fondations (US-FND-01)"
  - "#2 Accueil (US-HOME-01) — point d'entrée placeholderTempsEcran / homeScreenTime"
related:
  - accueil-home.md
  - noter-humeur.md
shared_components:
  - AppTheme
  - AppColors
  - AppRadii
  - AppSpacing
  - AppRouter
  - HaloRespirant
  - ouvrirPlaceholder (common/placeholder_screen.dart)
i18n_keys:
  - tempsEcranTitre
  - tempsEcranSousTitre
  - tempsEcranPermissionTitre
  - tempsEcranPermissionExplication
  - tempsEcranPermissionCta
  - tempsEcranPermissionRassurance
  - tempsEcranChargement
  - tempsEcranTotalAujourdhui
  - tempsEcranAucuneDonnee
  - tempsEcranAucuneDonneeAide
  - tempsEcranTopApps
  - tempsEcranAppAutres
  - tempsEcranErreur
  - tempsEcranReessayer
  - tempsEcranIndisponiblePlateforme
  - tempsEcranMessageBienveillant
  - tempsEcranDonneesLocales
  - tempsEcranDureeHeuresMinutes
  - tempsEcranDureeMinutes
i18n_keys_existantes_reutilisees:
  - homeScreenTime
  - placeholderTempsEcran
tests: aidd_docs/tasks/temps-ecran.tests.md (à remplir en Step 5 par Kent)
created: 2026-06-06
updated: 2026-06-06
---

# Page Plan — « Mon temps d'écran »

> **STATUT : `proposition_a_valider`.** Plan auto-suffisant pour l'éditeur IA. Cible :
> `apps/digiharmony_app/`. App Flutter DIGIHARMONY, public mineur, Erasmus+, **SANS backend
> ni Firebase, ZÉRO collecte**. Les données d'usage récupérées via l'API native **restent
> 100 % sur l'appareil** et **ne sont jamais persistées ni envoyées** (voir §0 + DEC-TE-04).
>
> **Design Banani NON confirmé** (MCP Banani non joignable en mode arrière-plan) et **US non
> encore créées** (Erwin idem). La structure visuelle ci-dessous est dérivée de la mémoire
> projet (design-system « Navy & Halo », ton bienveillant DEC-003) et de l'existant. Les points
> à valider humainement sont regroupés en **§13 « Questions à valider »**. Tout ce qui est
> marqué 🟡 = hypothèse non confirmée.

---

## 0. Garde-fous (FONT LOI — priment sur tout détail divergent ci-dessous)

- **Sans backend, sans Firebase, zéro collecte.** Aucun SDK réseau/analytics/tracking/Crashlytics. La
  lecture du temps d'écran se fait via l'**API native du téléphone**, jamais via une saisie manuelle
  ni un backend.
- **Permission unique** : `PACKAGE_USAGE_STATS` est la **SEULE** permission autorisée dans tout le
  projet (CLAUDE.md fait loi). Elle existe **précisément pour cette page** et est **déjà déclarée**
  dans `android/app/src/main/AndroidManifest.xml` (vérifié, ligne 5, avec `tools:ignore="ProtectedPermissions"`).
  **N'ajoute AUCUNE autre permission**, AUCUN SDK supplémentaire.
- **Permission « spéciale » (pas une runtime permission)** : `PACKAGE_USAGE_STATS` ne s'obtient pas
  via `requestPermissions`. L'utilisateur doit l'accorder manuellement dans les **Réglages système**
  via l'écran `Settings.ACTION_USAGE_ACCESS_SETTINGS`. → La page DOIT décrire le parcours d'octroi
  (état « non accordée » → CTA vers les réglages → retour → état « données affichées »).
- **Données 100 % locales, JAMAIS persistées** (DEC-TE-04) : les agrégats d'usage sont calculés
  **à la volée** à chaque ouverture, affichés, puis **jetés**. Ils **ne vont NI dans Drift NI dans
  HydratedBloc**. Seul un **flag léger** facultatif peut aller dans HydratedBloc (voir DEC-TE-05).
- **Bloc-only** (Cubit interdit, règle `1-bloc-only-no-cubit`) ; transformers explicites ; `State`
  `Equatable` avec enum `status`. Suffixes `Event`/`State` autorisés (dérogation actée).
- **i18n obligatoire** : aucune chaîne FR/EN en dur. Toutes les clés `tempsEcran*` (§8) ajoutées dans
  les 8 ARB, `fr`+`en` réels, repli `en` (TODO) pour `el/it/ro/tr/es/mk`.
- **a11y reduced-motion** : toute animation (halo, apparition de barres) désactivable via
  `MediaQuery.disableAnimations`. Tap 48×48 dp min. Contraste AA.
- **Couleurs via le design system** (`AppColors`/thème) — **aucun hex en dur**. La palette **émotions**
  (`MoodColors`) est **réservée au codage émotionnel** : **interdite ici** (cet écran n'est pas un
  écran d'humeur).
- **Public mineur, ton bienveillant** (DEC-003 + design-system §garde-fous éthiques) : **pas de score
  culpabilisant, pas de FOMO, pas de comparaison/classement, pas de streak, pas d'objectif punitif**.
  Un temps d'écran élevé est présenté **neutrement / avec bienveillance**, jamais comme un échec.
- **Nommage FRANÇAIS** : dossier `lib/pages/temps_ecran/`, classes `TempsEcranPage`/`TempsEcranView`/
  `TempsEcranBloc`/`TempsEcranState`/`TempsEcranEvent`. Structure imposée (règle `0-flutter-pages-structure`) :
  `lib/pages/temps_ecran/{bloc,views,widgets}`. Scaffolding technique reste anglais.
- **Android : `minify`/`shrinkResources = false`** (déjà acté Fondations) — ne rien faire qui suppose
  le contraire.

---

## 1. Contexte & objectif de la page

| Élément | Valeur |
|---|---|
| **But** | Permettre à l'ado de **consulter son temps d'écran du jour** (total + répartition par app), de façon **non culpabilisante**, pour favoriser une prise de conscience douce de son usage du téléphone. |
| **Accès** | Aucune auth (app sans compte). Empilée (`push`) depuis le **lien tertiaire « Mon temps d'écran »** de l'Accueil (`AccueilView`, `TextButton.icon`, clé `homeScreenTime`, icône `Icons.timer_outlined`). Ce lien ouvre aujourd'hui un `ouvrirPlaceholder(context, l10n.placeholderTempsEcran)` (`accueil_view.dart` ~L119-137) → **à recâbler** vers `AppRouter.versTempsEcran(context)` (§9). |
| **Route** | Pas de GoRouter (cohérent `AppRouter`, DEC-FND-07). Nouvelle méthode `AppRouter.versTempsEcran(context)` en **`push`** (retour chevron possible), calquée sur `versSaisieHumeur`. |
| **Retour** | Toolbar : chevron `Icons.chevron_left` → `Navigator.pop`. Toolbar présente (DEC-003 : toolbar partout **sauf** splash/accueil). |
| **Périmètre plateforme** | **V1 = Android d'abord** (DEC-TE-03), cohérent projet (Android prioritaire, architecture.md). iOS = **état dégradé bienveillant** (indisponible explicite, pas de crash). |

---

## 2. Contrainte structurante n°1 — récupération NATIVE du temps d'écran

### 2.1 Source de données = API native (jamais saisie / backend)

- **Android** : statistiques d'usage des apps via `UsageStatsManager`, gardées derrière la permission
  spéciale `PACKAGE_USAGE_STATS`. L'octroi passe par l'écran système `Settings.ACTION_USAGE_ACCESS_SETTINGS`.
- **iOS** : l'API Screen Time (FamilyControls / DeviceActivity) exige un **entitlement Apple spécial**
  (`com.apple.developer.family-controls`) **et** ne donne pas un accès équivalent (pas de lecture
  arbitraire app-par-app sans contexte parental). → **Hors V1.** Sur iOS, la page affiche un **état
  vide bienveillant** « indisponible sur cette plateforme » (DEC-TE-03).

### 2.2 Choix d'implémentation native (DEC-TE-01) — comparatif

| Option | Mécanisme | Réseau / tracking | Maintenance | Verdict |
|---|---|---|---|---|
| **`app_usage: ^4.1.0`** (pub.dev) | `MethodChannel("app_usage.methodChannel")` → `UsageStatsManager.queryUsageStats` côté natif | **Aucun** (vérifié : le package n'a **aucune** dépendance réseau/analytics) | Faible : API minuscule (`getAppUsage(start, end) → List<AppUsageInfo>`) | ✅ **RETENU** |
| `usage_stats` (pub.dev) | idem MethodChannel + helper `checkUsagePermission()` | Aucun | Faible, mais redondant | ❌ doublon |
| MethodChannel **custom** (platform channel maison vers `UsageStatsManager`) | code Kotlin maison | Aucun | **Élevée** (maintenir le code natif, parsing, edge-cases ROM) | ❌ surcoût injustifié |

**Décision DEC-TE-01 : utiliser `app_usage: ^4.1.0`**, qui est **déjà présent dans `pubspec.yaml`**
(vérifié) et **déjà acté dans `architecture.md`** (« Temps d'écran : `app_usage` Android best-effort »).
Justification : zéro dépendance réseau/tracking (conforme zéro-collecte), maintenance minimale (le
package encapsule le `MethodChannel` vers `UsageStatsManager`), pas de code natif maison à maintenir,
compatible sans backend ni Firebase. **Aucune nouvelle dépendance à ajouter.**

> ⚠️ **Limite connue de `app_usage` (à intégrer au design, DEC-TE-02)** : la classe `AppUsage`
> n'expose **PAS** de méthode pour (a) **vérifier** si la permission est accordée, ni (b) **ouvrir**
> l'écran système des réglages. Son seul point d'API est `getAppUsage(DateTime start, DateTime end)`,
> qui retourne une **liste vide** quand la permission n'est pas accordée (et `[]` sur iOS).
> → Le plan gère ces deux manques (vérif permission + ouverture réglages) **sans nouvelle dépendance**,
> via un **MethodChannel minimal maison côté natif** OU une heuristique (voir §2.3 + DEC-TE-02).

### 2.3 Détection de permission & ouverture des réglages (DEC-TE-02)

Comme `app_usage` ne couvre ni la vérification de permission ni l'ouverture des réglages, deux
approches sont possibles. ✅ **TRANCHÉ (2026-06-06) : option (A) retenue** — l'utilisateur accepte
le code Kotlin natif maison. Q-TE-2 résolue.

> ✅ **Principe d'octroi validé par l'utilisateur (2026-06-06)** : **jamais** de demande d'accès
> natif « à froid ». On affiche d'ABORD un écran d'explication UX soigné (`_VuePermission`, §5.2) qui
> dit **pourquoi** l'accès est utile et rassure sur la confidentialité ; **seul** le tap sur son CTA
> déclenche l'accès natif (`ouvrirReglagesAcces()` → écran système `ACTION_USAGE_ACCESS_SETTINGS`).
> Aucun appel natif n'est fait avant cette action explicite de l'utilisateur (hormis le `aLAcces()`
> de lecture de statut, silencieux et sans pop-up).

- **(A) — RECOMMANDÉ : MethodChannel maison minimal `digiharmony/usage_access`** (un seul channel,
  deux méthodes), **sans dépendance pub** :
  - `Future<bool> aLAcces()` → côté Kotlin : `AppOpsManager.unsafeCheckOpNoThrow(OPSTR_GET_USAGE_STATS, uid, packageName) == MODE_ALLOWED` (fallback `checkOpNoThrow` < API 29).
  - `Future<void> ouvrirReglagesAcces()` → côté Kotlin : `startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).addFlags(FLAG_ACTIVITY_NEW_TASK))`.
  - **Pas de nouvelle permission** (`PACKAGE_USAGE_STATS` suffit ; `ACTION_USAGE_ACCESS_SETTINGS`
    est un simple `Intent`). Code natif minuscule dans `MainActivity` (ou un petit `UsageAccessPlugin`).
  - Avantage : déterministe, pas de faux négatif.
- **(B) — Sans aucun code natif (heuristique) :** considérer « permission absente » lorsque
  `getAppUsage` retourne **liste vide** sur une fenêtre qui devrait contenir de l'usage (ex. dernières
  24 h). CTA « ouvrir les réglages » via le package `url_launcher` (déjà présent) avec un schéma
  d'intent Android (`android-app://...` / `app-settings:` — **fragile**). ❌ **Non recommandé** : `[]`
  est ambigu (peut signifier « aucune donnée » légitime), et l'ouverture de l'écran *Usage Access*
  précis via `url_launcher` n'est pas garantie selon ROM. Documenté pour traçabilité, mais **(A) prime**.

> **Garde-fou** : quelle que soit l'option, **aucune** permission supplémentaire au manifeste, **aucun**
> SDK tiers réseau. L'option (A) n'ajoute **que** du code Kotlin local + un `MethodChannel`.

---

## 3. Données affichées & sources

| Donnée | Source | Mode | Persistance |
|---|---|---|---|
| Accès accordé ? (`PACKAGE_USAGE_STATS`) | MethodChannel `digiharmony/usage_access.aLAcces()` (option A) | Lecture native | **Non persisté** (re-vérifié à chaque ouverture) |
| Usage par app sur la fenêtre « aujourd'hui » | `AppUsage().getAppUsage(minuit, now)` → `List<AppUsageInfo>` | Lecture native | **Non persisté** (DEC-TE-04) |
| Total agrégé du jour | **Dérivé** : somme des `usage` de tous les `AppUsageInfo` | Calcul à la volée | **Non persisté** |
| Top apps (répartition) | **Dérivé** : tri desc par `usage`, top N (ex. 5) + bucket « Autres » | Calcul à la volée | **Non persisté** |
| Plateforme (Android/iOS) | `Theme`/`Platform.isAndroid` (déjà utilisé par `app_usage`) | Lecture | — |

- **DEC-TE-04 (zéro collecte)** : les `AppUsageInfo` et tous les agrégats sont **éphémères** —
  calculés à l'ouverture, rendus, puis **jetés** quand on quitte l'écran. **Aucune écriture Drift,
  aucune écriture HydratedBloc** des données d'usage. Justification : zéro-collecte par absence de
  traitement persistant ; pas d'historisation V1 (pas de tendance/graphe multi-jours en V1).
- **DEC-TE-05 (couche de persistance — flag léger seulement)** : si l'on souhaite éviter de remontrer
  l'écran d'onboarding permission à chaque fois, un **flag booléen léger** `tempsEcranOnboardingVu`
  PEUT aller dans **HydratedBloc** (état léger persistant — comme les flags onboarding/tuto, cf.
  architecture.md). **Ce flag NE contient AUCUNE donnée d'usage.** En V1, ce flag est **optionnel** :
  l'écran re-vérifie de toute façon l'accès réel à chaque ouverture (la permission peut être révoquée
  côté système). 🟡 À confirmer (Q-TE-4). **Décision par défaut V1 : ne pas introduire le flag**
  (re-vérification systématique = source de vérité = l'OS), pour rester minimal.

> **Pourquoi PAS Drift ?** Drift = journal/agrégats **relationnels réactifs** qu'on veut **historiser**
> (humeur, conseils). Le temps d'écran V1 n'est **pas historisé** (snapshot du jour, jeté à la sortie)
> et **ne doit pas** créer de base de données d'usage (zéro-collecte). → Drift = **interdit ici** en V1.
> Si une US future demande des **tendances sur 7 jours**, ce sera une décision séparée (et il faudra
> alors arbitrer Drift vs recalcul natif sur fenêtre étendue — voir §13 Q-TE-5). Hors V1.

### 3.1 ViewModels légers (pas de logique dans la vue)

```
ResumeTempsEcran {
  Duration total;                    // somme des usages du jour
  List<UsageAppVue> topApps;         // top N triées desc
  Duration autres;                   // somme des apps hors top N (bucket)
}

UsageAppVue {
  String nomApp;                     // AppUsageInfo.appName (best-effort ; voir §3.2)
  String packageName;                // AppUsageInfo.packageName
  Duration duree;                    // AppUsageInfo.usage
  double fractionDuTotal;            // duree / total (0..1) — pour la barre proportionnelle
}
```

### 3.2 Limite « nom d'app » (DEC-TE-06)

`AppUsageInfo.appName` du package = **dernier segment du package name** (ex. `com.instagram.android`
→ `android`), **pas** le libellé humain de l'app. C'est une limite connue du package.
- **V1 (DEC-TE-06)** : afficher `packageName` de façon **lisible** (heuristique d'affichage côté UI :
  prendre l'avant-dernier segment significatif, ex. `instagram`, capitalisé). Ne **pas** prétendre à
  un nom marketing exact. **Pas d'icône d'app** (nécessiterait un accès natif supplémentaire ; hors V1).
- 🟡 Si un vrai libellé + icône sont exigés par le design → nécessite un MethodChannel natif étendu
  (`PackageManager.getApplicationLabel` / `getApplicationIcon`). **Hors V1**, à acter via US dédiée (Q-TE-3).

---

## 4. Bloc / Event / State

**Pattern** : `flutter_bloc` (Bloc-only), lints `bloc_lint`. State `Equatable` + enum `status`
(convention `accueil`/`saisie_humeur`). Transformers explicites (`bloc_concurrency` déjà présent).

### 4.1 Dépendance injectée — `ServiceTempsEcran` (façade testable)

Pour isoler la plateforme (et permettre les tests sans `MethodChannel` réel), introduire une **façade**
`ServiceTempsEcran` injectée dans le Bloc (mockable via `mocktail`) :

```
abstract interface class ServiceTempsEcran {
  /// True si l'app a l'accès aux statistiques d'usage (Android). False sinon / iOS.
  Future<bool> aLAcces();

  /// Ouvre l'écran système Settings.ACTION_USAGE_ACCESS_SETTINGS (Android).
  Future<void> ouvrirReglagesAcces();

  /// Usage du jour [minuit, now]. Liste vide si pas d'accès / iOS / aucune donnée.
  Future<List<UsageAppVue>> usageDuJour();

  /// True si la plateforme supporte la lecture (Android), false sinon (iOS, etc.).
  bool get plateformeSupportee;
}
```

Implémentation concrète `ServiceTempsEcranAndroid` (ou `ServiceTempsEcranImpl`) :
- `aLAcces()` / `ouvrirReglagesAcces()` → MethodChannel `digiharmony/usage_access` (option A, DEC-TE-02).
- `usageDuJour()` → `AppUsage().getAppUsage(DateTime(y,m,d), DateTime.now())`, map vers `UsageAppVue`,
  tri desc, filtre `usage > 0`.
- `plateformeSupportee` → `Platform.isAndroid` (via `dart:io`, déjà utilisé par `app_usage`).

> Injection : `RepositoryProvider<ServiceTempsEcran>` fourni au moment du `push` (calqué sur la façon
> dont `versSaisieHumeur` transmet `AppDatabase` à travers la frontière de route, `app_router.dart`).
> Voir §9.

### 4.2 Events — `TempsEcranEvent` (sealed)

| Event | Déclenché par | Transformer | Charge |
|---|---|---|---|
| `TempsEcranDemarre` | `initState` / ouverture de la page | `restartable()` | — |
| `TempsEcranPermissionDemandee` | tap CTA « Activer l'accès » | `droppable()` | — |
| `TempsEcranRevenuAuPremierPlan` | retour de l'écran réglages système (`AppLifecycleState.resumed`) | `restartable()` | — |
| `TempsEcranReessaye` | tap « Réessayer » (état erreur) | `restartable()` | — |

### 4.3 State — `TempsEcranState` (Equatable + enum `status`)

```
enum TempsEcranStatus {
  initial,
  chargement,        // lecture native en cours
  permissionRequise, // Android, accès non accordé
  pret,              // données affichées
  vide,              // accès OK mais aucune donnée (fenêtre sans usage)
  indisponible,      // plateforme non supportée (iOS) — état dégradé bienveillant
  erreur,            // exception MethodChannel / parsing
}

class TempsEcranState extends Equatable {
  final TempsEcranStatus status;
  final ResumeTempsEcran? resume;   // non-null seulement en `pret`
  final String? messageErreur;      // facultatif (debug local ; UI affiche clé i18n générique)
  ...
}
```

### 4.4 Logique

- `TempsEcranDemarre` :
  1. Si `!service.plateformeSupportee` → `status: indisponible` (iOS). **Stop.**
  2. `status: chargement`.
  3. `aLAcces()` → si `false` → `status: permissionRequise`. **Stop.**
  4. `usageDuJour()` → agréger en `ResumeTempsEcran` (total, top N, bucket « Autres »).
     - liste vide → `status: vide`.
     - sinon → `status: pret(resume)`.
  5. Exception → `status: erreur`.
- `TempsEcranPermissionDemandee` (droppable) → `await service.ouvrirReglagesAcces()`. Ne change pas
  l'état directement (l'utilisateur part dans les réglages système ; le retour est géré par le cycle
  de vie, point suivant).
- `TempsEcranRevenuAuPremierPlan` (restartable) → relance la séquence de `TempsEcranDemarre`
  (re-vérifie l'accès : l'utilisateur a pu accorder OU refuser dans les réglages). C'est ce qui fait
  basculer `permissionRequise → pret/vide` **sans refresh manuel**.
  > **Câblage cycle de vie** : la **View** observe `AppLifecycleState.resumed` (via
  > `WidgetsBindingObserver` ou `AppLifecycleListener`) et `add(TempsEcranRevenuAuPremierPlan())`.
  > Le Bloc ne porte pas de listener de cycle de vie (testabilité).
- `TempsEcranReessaye` (restartable) → idem `TempsEcranDemarre` (depuis l'état `erreur`).
- **Agrégation top N** (helper pur testable, ex. `ResumeTempsEcran agregeUsage(List<UsageAppVue>, {int topN = 5})`) :
  trier desc par `duree`, prendre les `topN` premières, sommer le reste dans `autres`, calculer
  `fractionDuTotal` de chaque app sur le `total`. Si `total == 0` → liste vide → état `vide`.

---

## 5. Vue(s) — structure visuelle (🟡 design Banani non confirmé)

> **Aucun hex en dur** : toutes les teintes = `AppColors`/`Theme.of(context)`. **`MoodColors` interdit
> ici.** Les barres de répartition utilisent `AppColors.primary` / `AppColors.primaryLight` /
> `AppColors.accentGold` (chrome), **pas** de couleurs d'émotion. Espacements `AppSpacing`, rayons `AppRadii`.

### 5.1 `TempsEcranView` — squelette commun

```
Scaffold
 ├─ AppBar (toolbar DEC-003)
 │   ├─ leading : IconButton chevron-left (Icons.chevron_left) → Navigator.pop
 │   ├─ title  : logo (logo_digiharmony_square.png, hauteur réduite) centré  (cohérent saisie_humeur)
 │   └─ actions: IconButton menu (Icons.menu) → ouvrirPlaceholder (V1, cohérent app)
 └─ Stack
     ├─ HaloRespirant (décor de fond, réutilisé common/widgets/halo_respirant.dart ; a11y-aware)
     └─ SafeArea > Padding(AppSpacing.lg) > BlocBuilder<TempsEcranBloc, TempsEcranState>
          switch (state.status) {
            chargement        -> _VueChargement()
            permissionRequise -> _VuePermission()
            pret              -> _VueResume(resume)
            vide              -> _VueVide()
            indisponible      -> _VueIndisponible()
            erreur            -> _VueErreur()
            initial           -> SizedBox.shrink()  // transitoire (1 frame)
          }
```

Footer commun (sous le contenu, dans tous les états « informationnels ») :
`Text(tempsEcranDonneesLocales)` centré, `bodySmall`, `AppColors.textMuted`
(« Ces données restent sur ton appareil et ne sont jamais envoyées. »).

### 5.2 `_VuePermission` (Android, accès non accordé) — **parcours d'octroi**

- Icône bienveillante (`Icons.lock_clock` ou `Icons.timelapse`), `AppColors.primary`.
- Titre `tempsEcranPermissionTitre` (« Pour voir ton temps d'écran »).
- Explication `tempsEcranPermissionExplication` : explique **pourquoi** l'accès système est nécessaire
  **et** rassure sur la confidentialité (« on lit ces stats **uniquement sur ton téléphone**, rien
  n'est envoyé »). Ton bienveillant, **non culpabilisant**.
- CTA `ElevatedButton` `tempsEcranPermissionCta` (« Activer l'accès dans les réglages ») →
  `add(TempsEcranPermissionDemandee())` (+ `HapticFeedback.lightImpact()` côté View).
- Ligne rassurance `tempsEcranPermissionRassurance` (`bodySmall`, `textMuted`).
- **Parcours complet** : tap CTA → écran système `ACTION_USAGE_ACCESS_SETTINGS` → l'utilisateur
  active → revient dans l'app → `AppLifecycleState.resumed` → `TempsEcranRevenuAuPremierPlan` →
  re-vérif → bascule vers `pret`/`vide`. **Aucun refresh manuel requis.**

### 5.3 `_VueResume` (état nominal — données affichées)

- En-tête : `tempsEcranTotalAujourdhui` + **total formaté** (`tempsEcranDureeHeuresMinutes` ICU, ex.
  « 3 h 12 min »). Présentation **neutre** : pas de jauge « objectif dépassé », pas de rouge d'alerte,
  pas d'emoji triste.
- Message bienveillant `tempsEcranMessageBienveillant` (`bodyMedium`, `textMuted`) : ex. « Prendre
  conscience de son temps d'écran, c'est déjà prendre soin de soi. » (**jamais** « tu passes trop de
  temps… »).
- Section `tempsEcranTopApps` : liste des `topApps` (widget `_LigneApp`) :
  - nom lisible (DEC-TE-06) + durée (`tempsEcranDureeHeuresMinutes`/`tempsEcranDureeMinutes`) +
    **barre de proportion** (`LinearProgressIndicator` ou `FractionallySizedBox`) `value: fractionDuTotal`,
    couleur `AppColors.primary` sur piste `AppColors.surface`.
  - ligne « Autres » (`tempsEcranAppAutres`) pour le bucket résiduel, si `autres > 0`.
  - a11y : `Semantics(label: "<app> : <durée>")`. Pas de classement « pire app » culpabilisant —
    c'est une **répartition factuelle**, présentée sobrement.

### 5.4 `_VueVide` (accès OK mais aucune donnée)

- Icône douce (`Icons.hourglass_empty`). `tempsEcranAucuneDonnee` (« Pas encore de données pour
  aujourd'hui ») + aide `tempsEcranAucuneDonneeAide` (« Reviens un peu plus tard dans la journée. »).
- Pas de bouton agressif. Optionnel : lien discret « Réessayer » (`tempsEcranReessayer`).

### 5.5 `_VueIndisponible` (iOS / plateforme non supportée — DEC-TE-03)

- `tempsEcranIndisponiblePlateforme` (« Le temps d'écran n'est disponible que sur Android pour le
  moment. »). Ton neutre, pas d'erreur. Footer données-locales conservé.

### 5.6 `_VueChargement`

- Skeleton neutre / `CircularProgressIndicator` discret + `tempsEcranChargement` (« Lecture en
  cours… »). Pas de spinner agressif (public mineur). a11y : pas d'animation bloquante.

### 5.7 `_VueErreur`

- `tempsEcranErreur` (« Impossible de lire le temps d'écran pour l'instant. ») + bouton
  `tempsEcranReessayer` → `add(TempsEcranReessaye())`. **Jamais de crash** ; log silencieux local
  (zéro remontée réseau).

---

## 6. États de la page (synthèse)

| État | Déclencheur | Rendu |
|---|---|---|
| **initial** | 1ʳᵉ frame avant `TempsEcranDemarre` | `SizedBox.shrink` (transitoire) |
| **chargement** | lecture native en cours | `_VueChargement` |
| **permissionRequise** | Android + `aLAcces() == false` | `_VuePermission` (parcours d'octroi §5.2) |
| **pret** | accès OK + au moins une app avec usage > 0 | `_VueResume` |
| **vide** | accès OK + aucune donnée sur la fenêtre | `_VueVide` |
| **indisponible** | `!plateformeSupportee` (iOS) | `_VueIndisponible` |
| **erreur** | exception MethodChannel / parsing | `_VueErreur` + Réessayer |

- Transition **permissionRequise → pret/vide** : **réactive** au retour des réglages système
  (`AppLifecycleState.resumed` → `TempsEcranRevenuAuPremierPlan`). Aucun refresh manuel.

---

## 7. Navigation

- **Entrée** : `AppRouter.versTempsEcran(context)` (nouvelle méthode, `push`).
- **Sortie** : chevron toolbar → `Navigator.pop`. Bouton menu (actions) → `ouvrirPlaceholder` (V1).
- Pas de GoRouter (DEC-FND-07).

`app_router.dart` à ajouter (calqué sur `versSaisieHumeur`, qui transmet une dépendance à travers la
frontière de route) :

```dart
/// Ouvre l'écran « Mon temps d'écran » (empilé, retour possible).
///
/// Le [ServiceTempsEcran] est fourni au sous-arbre (frontière de route),
/// comme `versSaisieHumeur` le fait pour `AppDatabase`.
static Future<void> versTempsEcran(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => RepositoryProvider<ServiceTempsEcran>(
        create: (_) => ServiceTempsEcranImpl(),
        child: const TempsEcranPage(),
      ),
    ),
  );
}
```

> Alternative : fournir `ServiceTempsEcran` au-dessus de `MaterialApp` (bootstrap) si d'autres écrans
> en ont besoin plus tard. V1 = local à la route (mince, pas d'autre consommateur). 🟡 Q-TE-6.

---

## 8. i18n (clés ARB — 8 langues, repli `en`)

> Ajouter dans **les 8** `lib/l10n/arb/app_<lang>.arb` (template `app_en.arb`), `fr`+`en` réels,
> repli `en` (TODO traduction) pour `el/it/ro/tr/es/mk`. Puis `flutter gen-l10n`.
> **Réutiliser** `homeScreenTime` (libellé du lien Accueil) — ne pas le recréer.
> Le titre de page peut réutiliser `homeScreenTime` ou la nouvelle `tempsEcranTitre` (cohérence : §13 Q-TE-7).

| Clé | FR (référence) | EN |
|---|---|---|
| `tempsEcranTitre` | « Mon temps d'écran » | "My screen time" |
| `tempsEcranSousTitre` | « Un aperçu doux de ton usage du téléphone. » | "A gentle look at your phone use." |
| `tempsEcranPermissionTitre` | « Pour voir ton temps d'écran » | "To see your screen time" |
| `tempsEcranPermissionExplication` | « DigiHarmony a besoin d'accéder aux statistiques d'usage de ton téléphone. Ces données sont lues uniquement sur ton appareil et ne sont jamais envoyées. » | "DigiHarmony needs access to your phone's usage statistics. This data is read only on your device and is never sent anywhere." |
| `tempsEcranPermissionCta` | « Activer l'accès dans les réglages » | "Enable access in settings" |
| `tempsEcranPermissionRassurance` | « Tu peux retirer cet accès à tout moment dans les réglages. » | "You can revoke this access anytime in settings." |
| `tempsEcranChargement` | « Lecture en cours… » | "Reading…" |
| `tempsEcranTotalAujourdhui` | « Aujourd'hui » | "Today" |
| `tempsEcranAucuneDonnee` | « Pas encore de données pour aujourd'hui » | "No data for today yet" |
| `tempsEcranAucuneDonneeAide` | « Reviens un peu plus tard dans la journée. » | "Check back a little later today." |
| `tempsEcranTopApps` | « Tes applications » | "Your apps" |
| `tempsEcranAppAutres` | « Autres » | "Others" |
| `tempsEcranErreur` | « Impossible de lire le temps d'écran pour l'instant. » | "Can't read screen time right now." |
| `tempsEcranReessayer` | « Réessayer » | "Try again" |
| `tempsEcranIndisponiblePlateforme` | « Le temps d'écran n'est disponible que sur Android pour le moment. » | "Screen time is only available on Android for now." |
| `tempsEcranMessageBienveillant` | « Prendre conscience de son temps d'écran, c'est déjà prendre soin de soi. » | "Noticing your screen time is already taking care of yourself." |
| `tempsEcranDonneesLocales` | « Ces données restent sur ton appareil et ne sont jamais envoyées. » | "This data stays on your device and is never sent." |
| `tempsEcranDureeHeuresMinutes` | « {heures} h {minutes} min » | "{heures} h {minutes} min" |
| `tempsEcranDureeMinutes` | « {minutes} min » | "{minutes} min" |

- `tempsEcranDureeHeuresMinutes` / `tempsEcranDureeMinutes` : **ICU** avec placeholders `heures`/
  `minutes` (type `int`). Le formatage (séparer h/min) se fait côté Dart (helper pur `formaterDuree`),
  l'ARB ne porte que le gabarit. Choix h+min vs min seul selon `duree >= 1h`.
- Ton de **tous** les libellés : bienveillant, **jamais** culpabilisant (garde-fou §0).

---

## 9. Fichiers à créer / modifier

> **Fourni par Fondations / existant (NE PAS recréer)** : `theme.dart`, `app_router.dart`,
> `common/placeholder_screen.dart` (`ouvrirPlaceholder`), `common/widgets/halo_respirant.dart`,
> `l10n/`. Permission `PACKAGE_USAGE_STATS` **déjà au manifeste**. Dépendance `app_usage` **déjà au pubspec**.

**Créer (propre à `temps_ecran`)** :
- `lib/pages/temps_ecran/views/temps_ecran_page.dart` (`TempsEcranPage` + `route()` ; fournit `TempsEcranBloc`).
- `lib/pages/temps_ecran/views/temps_ecran_view.dart` (`TempsEcranView` : toolbar + switch d'états + observer cycle de vie).
- `lib/pages/temps_ecran/bloc/temps_ecran_bloc.dart` / `temps_ecran_event.dart` / `temps_ecran_state.dart`.
- `lib/pages/temps_ecran/services/service_temps_ecran.dart` (interface `ServiceTempsEcran` + impl `ServiceTempsEcranImpl` ; MethodChannel `digiharmony/usage_access` + `AppUsage`).
- `lib/pages/temps_ecran/modeles/resume_temps_ecran.dart` (`ResumeTempsEcran`, `UsageAppVue`, helpers purs `agregeUsage`, `formaterDuree`, `nomLisible`).
- `lib/pages/temps_ecran/widgets/vue_permission.dart`, `vue_resume.dart`, `ligne_app.dart`, `vue_etat_message.dart` (vide/indispo/erreur factorisées).

**Modifier** :
- `lib/app/routing/app_router.dart` : **+** `versTempsEcran(context)` (append-only, §7).
- `lib/pages/accueil/views/accueil_view.dart` : recâbler le `TextButton.icon` (~L119-137) :
  `onPressed: () => ouvrirPlaceholder(context, l10n.placeholderTempsEcran)` → `AppRouter.versTempsEcran(context)`.
  > ⚠️ **Dépendance d'intégration (Accueil #2)** : fichier du Lot Accueil. Recâbler **après** merge
  > Accueil, ou patch d'intégration append-only coordonné (cf. DEC-SH-010 pour le précédent). 1 ligne.
- `android/app/src/main/AndroidManifest.xml` : **AUCUNE modif** (permission déjà présente). Si option
  (A) retenue (DEC-TE-02), ajouter le code Kotlin du `MethodChannel` dans `MainActivity` (ou un petit
  `UsageAccessPlugin`) — **pas** de permission ni de dépendance ajoutée.
- 8 × `lib/l10n/arb/app_<lang>.arb` : clés §8, puis `flutter gen-l10n`.
- `aidd_docs/tasks/_registry.md` : ligne `temps-ecran` (§12).

> **N'ajouter AUCUNE dépendance pub** (`app_usage`, `url_launcher` déjà présents). **Pas de codegen
> Drift** (aucune modif de schéma — le temps d'écran ne touche pas Drift, DEC-TE-04).

---

## 10. Conformité contraintes projet (garde-fous)

- ✅ Zéro backend / Firebase / SDK réseau / analytics / Crashlytics. Données d'usage **éphémères**, locales, jamais envoyées (DEC-TE-04).
- ✅ **Permission unique** `PACKAGE_USAGE_STATS` (déjà au manifeste) ; **aucune** autre permission, **aucune** dépendance pub ajoutée.
- ✅ Permission « spéciale » gérée correctement (octroi via `ACTION_USAGE_ACCESS_SETTINGS`, pas runtime — DEC-TE-02 + §5.2).
- ✅ **Pas de Drift, pas de HydratedBloc** pour les données d'usage (DEC-TE-04) ; flag léger optionnel non retenu V1 (DEC-TE-05).
- ✅ Bloc-only, transformers explicites, `State` `Equatable` + enum `status`.
- ✅ i18n 8 langues, repli `en`, aucune chaîne en dur.
- ✅ a11y : `MediaQuery.disableAnimations` (halo + apparitions), tap 48×48, `Semantics` sur les lignes d'app.
- ✅ Couleurs via `AppColors`/thème (jamais hex en dur) ; `MoodColors` **interdit** (pas un écran d'humeur).
- ✅ Ton bienveillant : pas de score/objectif/FOMO/comparaison/streak (DEC-003 + design-system éthique).
- ✅ Vibration via `HapticFeedback` (pas de permission `VIBRATE`).
- ✅ Android `minify`/`shrinkResources = false`.
- ✅ V1 Android-first ; iOS = état dégradé bienveillant (pas de crash, DEC-TE-03).

---

## 11. User Stories (dépendance — À CRÉER via Erwin)

> **Aucune US n'existe** pour cette page (Erwin non joignable en arrière-plan ; à créer et valider).

- **US-TE-01 « Consulter mon temps d'écran »** (milestone **Phase 2** 🟡), couvrant : lien Accueil →
  page, lecture native Android, total du jour + répartition top apps, ton bienveillant, états
  pret/vide/erreur/indisponible, a11y, i18n 8 langues.
- **US-TE-02 « Octroyer l'accès aux statistiques d'usage »**, couvrant : état permission requise,
  CTA vers `ACTION_USAGE_ACCESS_SETTINGS`, retour réactif au premier plan, rassurance confidentialité.

**Critères d'acceptation à inscrire (source des tests Kent — Step 5)** :
- AC1 : Android, accès **non accordé** → `_VuePermission` avec CTA réglages (pas de crash, pas de données).
- AC2 : tap CTA → ouvre `ACTION_USAGE_ACCESS_SETTINGS` (vérifiable : `ServiceTempsEcran.ouvrirReglagesAcces` appelé).
- AC3 : retour au premier plan après octroi → re-vérif → bascule vers `pret`/`vide` **sans refresh manuel**.
- AC4 : Android, accès accordé + usage présent → `_VueResume` : **total** correct + **top apps** triées desc + bucket « Autres ».
- AC5 : accès accordé mais **aucune** donnée → `_VueVide` (message bienveillant, pas d'erreur).
- AC6 : **iOS / plateforme non supportée** → `_VueIndisponible` (état dégradé, pas de crash).
- AC7 : exception native → `_VueErreur` + « Réessayer » fonctionnel.
- AC8 : **zéro persistance** : aucune écriture Drift / HydratedBloc des données d'usage (vérifier qu'aucune table/clé n'est touchée).
- AC9 : **ton non culpabilisant** : aucun libellé d'objectif/score/alerte rouge ; footer « données locales » présent.
- AC10 : `disableAnimations == true` → halo statique, écran lisible.
- AC11 : libellés traduits 8 langues (repli `en`) ; wordmark « DigiHarmony » non traduit.
- AC12 : `formaterDuree`/`agregeUsage`/`nomLisible` déterministes (helpers purs testés isolément).

---

## 12. Registry & coordination

- Ajouter dans `aidd_docs/tasks/_registry.md` :
  `| [temps-ecran.md](./temps-ecran.md) | Mon temps d'écran (page empilée, lecture native Android) | US-TE-01/02 (à créer) | Phase 2 | Fondations (#3), Accueil (#2) | temps-ecran.tests.md ⏳ | proposition_a_valider |`
- **Composants consommés** : `AppTheme`/`AppColors`/`AppRadii`/`AppSpacing`, `AppRouter`,
  `HaloRespirant`, `ouvrirPlaceholder`. **Introduit ici (réutilisable)** : `ServiceTempsEcran`
  (façade plateforme), helpers `formaterDuree`/`agregeUsage`.
- **Coordination** : recâblage `accueil_view.dart` = append-only sur 1 ligne, à faire après merge
  Accueil (#2) — même pattern que DEC-SH-010 (noter-humeur). **Pas de collision Drift** (aucune modif schéma).

---

## 13. Questions à valider (🟡 hypothèses non confirmées — à trancher avec l'utilisateur)

> Banani (design) et Erwin (US) **non joignables en mode arrière-plan** → ces points sont des
> **hypothèses raisonnables** dérivées de la mémoire projet, à confirmer avant implémentation.

- **Q-TE-1 (design Banani)** : la maquette exacte de « Mon temps d'écran » n'a pas été récupérée. La
  structure §5 (permission / résumé total + top apps avec barres / vide / indispo / erreur) est une
  proposition. → **Récupérer le design Banani** et ajuster la composition (présence/forme du graphe,
  période affichée, présence d'icônes d'app).
- ✅ **Q-TE-2 — RÉSOLUE (2026-06-06) : option (A) acceptée.** Code Kotlin natif maison
  (MethodChannel `digiharmony/usage_access`, sans dépendance ni permission supplémentaire) validé par
  l'utilisateur. De plus, **principe d'octroi confirmé** : écran d'explication UX soigné AVANT toute
  demande native ; seul le CTA déclenche l'accès natif (cf. encart DEC-TE-02 + §5.2).
- **Q-TE-3 (noms/icônes d'app, DEC-TE-06)** : V1 affiche un nom **lisibilisé** depuis le package name
  (pas de libellé marketing ni d'icône). OK pour V1 ? Sinon → MethodChannel étendu
  (`PackageManager.getApplicationLabel/Icon`), **hors V1**, US dédiée.
- **Q-TE-4 (flag onboarding, DEC-TE-05)** : par défaut V1 = **pas** de flag HydratedBloc (re-vérif
  systématique de l'accès réel). Confirmer, ou demander un flag « onboarding permission vu » (léger,
  **sans** données d'usage).
- **Q-TE-5 (historisation / tendances)** : V1 = **snapshot du jour uniquement**, **pas** d'historique
  multi-jours, **pas** de Drift (zéro-collecte). Une vue « 7 derniers jours » serait une **US séparée**
  avec décision de persistance dédiée. Confirmer que c'est hors V1.
- **Q-TE-6 (portée du provider `ServiceTempsEcran`)** : V1 = fourni **local à la route**. Le remonter
  au bootstrap si d'autres écrans en ont besoin. OK local V1 ?
- **Q-TE-7 (titre de page)** : réutiliser `homeScreenTime` (« Mon temps d'écran », déjà existante) en
  titre, ou utiliser la nouvelle `tempsEcranTitre` ? (les deux ont la même valeur FR). Recommandation :
  réutiliser `homeScreenTime` pour le **lien Accueil** et la cohérence, `tempsEcranTitre` pour le **titre
  in-page** si une nuance est voulue. À harmoniser.
- ✅ **Q-TE-8 — RÉSOLUE (2026-06-06)** : fenêtre = **« aujourd'hui »** `[minuit local, now]`
  (jour calendaire, remise à zéro à 00:00), confirmée par l'utilisateur. Option « 24 h glissantes »
  écartée. `app_usage` agrège sur l'intervalle demandé.
- **Q-TE-9 (milestone)** : Phase 1 (avec le reste) ou Phase 2 ? Supposé **Phase 2** (le placeholder
  Accueil suggère une livraison ultérieure). À confirmer pour le registre.

---

## 14. Décisions tranchées (DEC-TE)

| ID | Décision |
|---|---|
| DEC-TE-01 | Implémentation native via **`app_usage: ^4.1.0`** (déjà au pubspec, acté architecture.md). Pas de MethodChannel maison pour la **lecture** d'usage, pas d'autre package. Zéro réseau/tracking. |
| DEC-TE-02 | Détection de permission + ouverture des réglages **non fournies** par `app_usage` → **option (A)** : MethodChannel maison minimal `digiharmony/usage_access` (`aLAcces`, `ouvrirReglagesAcces`), **sans** dépendance ni permission supplémentaire. (Option B heuristique documentée mais rejetée.) ✅ **Tranché (2026-06-06)** : option (A) acceptée + écran d'explication préalable au CTA d'accès natif. |
| DEC-TE-03 | **V1 Android-first** ; iOS (Screen Time = entitlement spécial, accès non équivalent) = **état dégradé bienveillant** `indisponible`, pas de crash. |
| DEC-TE-04 | **Zéro persistance des données d'usage** : agrégats calculés à la volée, affichés, jetés. **Ni Drift ni HydratedBloc.** Pas d'historisation V1. |
| DEC-TE-05 | Couche de persistance : seul un **flag léger** (onboarding permission) pourrait aller dans **HydratedBloc** (jamais Drift, jamais de données d'usage). **Non retenu en V1** (re-vérif système = source de vérité). 🟡 Q-TE-4. |
| DEC-TE-06 | Noms d'app = **lisibilisation du package name** (limite `AppUsageInfo.appName`). Pas d'icône d'app en V1. Libellé/icône exacts = MethodChannel étendu, **hors V1**. 🟡 Q-TE-3. |
| DEC-TE-07 | Permission accordée/refusée détectée au **retour au premier plan** (`AppLifecycleState.resumed` → event) → bascule d'état **réactive**, sans refresh manuel. |
| DEC-TE-08 | Façade `ServiceTempsEcran` injectée (mockable `mocktail`) pour isoler la plateforme et tester le Bloc sans `MethodChannel`. |
| DEC-TE-09 | Présentation **non culpabilisante** : pas de score/objectif/jauge d'alerte/comparaison/streak ; message bienveillant + footer « données locales ». |
| DEC-TE-10 | Navigation `AppRouter.versTempsEcran` en `push` (DEC-FND-07, pas de GoRouter). Recâblage du lien Accueil = dépendance d'intégration append-only (#2). |
| DEC-TE-11 | Fenêtre temporelle V1 = **« aujourd'hui »** `[minuit local, now]` (jour calendaire). ✅ **Tranché (2026-06-06)** — Q-TE-8 confirmée, 24 h glissantes écartées. |

---

## 15. Auto-challenge (points signalés)

- ✅ **`app_usage` ne vérifie pas la permission** (vérifié dans le source : seul `getAppUsage` existe,
  retourne `[]` sans accès). → **résolu** par DEC-TE-02 option (A), acceptée (2026-06-06) : `aLAcces()`
  natif déterministe lève l'ambiguïté `permissionRequise` vs `vide`.
- ⚠️ **`AppUsageInfo.appName` = dernier segment du package** (pas le vrai libellé) → DEC-TE-06, à
  assumer en V1 (Q-TE-3).
- ⚠️ **iOS réellement déclaré** dans le projet (dossier `ios/` présent) → l'état `indisponible` n'est
  pas théorique : il **doit** être implémenté pour ne pas crasher sur un build iOS.
- ⚠️ **Tests widget + halo animé** : `HaloRespirant` (boucle `flutter_animate`) → ne **jamais**
  `pumpAndSettle()` (piège connu testing.md) ; wrapper `MediaQuery(disableAnimations: true)`.
- ⚠️ **Cycle de vie en test** : simuler `AppLifecycleState.resumed` pour AC3 (via
  `tester.binding.handleAppLifecycleStateChanged` / `WidgetsBinding`).
- 🟡 **Design + US non confirmés** : tout le §13 reste ouvert ; ce plan est `proposition_a_valider`.
- 🔁 **Réutilisations** : `HaloRespirant`, `ouvrirPlaceholder`, toolbar (calquée `saisie_humeur`),
  pattern d'injection de dépendance à travers la route (calqué `versSaisieHumeur`). Pas de duplication.
