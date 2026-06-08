---
page: Splash Screen
route: "/" (écran de démarrage, route initiale de l'app)
us: [US-1.1]
github: "#1"
milestone: Phase 1
shared_components: [AppTheme, AppColors, AppDatabase, AppRouter]
i18n_keys: [splashTagline]
tests: aidd_docs/tasks/splash-screen.tests.md
created: 2026-06-05
updated: 2026-06-05
status: valide
depends_on: [foundations-bootstrap.md (US-FND-01)]
---

## ✅ Décisions de validation (2026-06-05) — FONT FOI

- **Nommage FRANÇAIS** : cet écran s'appelle **Demarrage** (Splash → Demarrage). Dossier `lib/demarrage/`, classes `DemarragePage`/`DemarrageView`/`DemarrageBloc`/`DemarrageEvent`/`DemarrageState`, fichiers `demarrage_*.dart`. Route `/` inchangée. Scaffolding (`AppTheme`/`AppDatabase`/`AppRouter`) reste anglais.
- **Logo central 110×110** : utiliser `assets/images/logo_digiharmony_square.png` (carré 969×969), affiché en `BoxFit.cover`/`contain` dans le cadre 110×110 radius 22.
- **Splash natif** (fourni par Fondations) : `flutter_native_splash`, fond `#16213C` (`AppColors.backgroundDeep`), logo carré — continuité visuelle avant `SplashPage`.
- **Tagline** : `splashTagline` traduite `fr`+`en` réellement, repli `en` pour les 6 autres langues (TODO). `DIGIHARMONY` jamais traduit.
- Délai min **injectable** (`SplashDemarre(dureeMinimale)`) ; reduced-motion → boucles off + délai ~0,8 s.

## ✅ Décision produit (2026-06-05) — FONT FOI — ONBOARDING ABANDONNÉ

- **L'onboarding (écran Bienvenue) est abandonné** : le Demarrage route **toujours directement vers l'Accueil**, quelle que soit l'historique d'utilisation (1re ouverture ou non).
- **`DemarrageBloc`** n'a plus de dépendance sur `BienvenueBloc`. Il ne lit plus aucun flag d'onboarding. État simplifié : `DemarrageInitial` → `DemarrageEnCours` → `DemarragePret` | `DemarrageErreur` (les deux terminent vers l'Accueil).
- **`BienvenueBloc` et `BienvenuePage`** restent dans le codebase à l'état **DORMANT** : fournis globalement par `App` (au cas où une future US les réactive), mais plus consommés par le Demarrage.
- **`AppRouter.versBienvenue`** reste présent (dormant) dans `AppRouter` — ne pas le supprimer.
- **En cas d'erreur Drift** : le Demarrage route quand même vers l'Accueil (tolérance d'erreur §7 maintenue).

# Page Plan — Splash Screen (US-1.1)

> Plan régénéré à partir de la spécification validée (Banani NON re-récupéré, conformément à la consigne).
> Contexte : Flutter DIGIHARMONY, public mineur, Erasmus+, **sans backend / sans Firebase / zéro collecte**.
> Monorepo Melos 7, code dans `apps/digiharmony_app/`.
>
> **DÉPENDANCE : `foundations-bootstrap.md` (US-FND-01), à implémenter EN PREMIER.** Le thème, l'init
> `HydratedBloc.storage`, l'ouverture Drift, le `LocaleCubit`, le `OnboardingCubit`, le routing/placeholders et
> le **splash natif** sont fournis par les Fondations et **NE sont PAS refaits ici**. Ce plan ne couvre que
> l'écran Flutter `SplashPage` + `SplashBloc` + animations + la mesure de durée d'init.

---

## 1. Contexte & rôle de la page

- **But** : premier écran affiché au lancement. Marque l'identité visuelle DIGIHARMONY, masque le temps d'initialisation locale (storage HydratedBloc + ouverture base Drift), puis route vers Onboarding (1re ouverture) ou Home.
- **Accès** : route initiale, aucune authentification (l'app n'a ni compte ni backend).
- **Route** : écran racine présenté par `MaterialApp.home` au démarrage. Pas besoin de `flow_builder` pour cette US (DEC archi) — routage par `Navigator.pushReplacement`.
- **Hors périmètre de cette US** : Onboarding et Home sont des **placeholders** (écrans vides minimaux), à remplacer par leurs US dédiées.

### Périmètre vs Fondations (qui fait quoi)
> Le socle technique est **entièrement délégué** au plan `foundations-bootstrap.md`. Ne PAS le recréer ici.

| Sujet | Où c'est traité |
| --- | --- |
| Thème `AppTheme.dark` câblé dans `MaterialApp` | **Fondations** (§1) — Splash ne fait que **consommer** `AppColors` |
| Init `HydratedBloc.storage` dans `bootstrap.dart` | **Fondations** (§5) — Splash mesure seulement la latence Drift |
| Ouverture base Drift (`AppDatabase`) | **Fondations** (§6) — Splash reçoit l'instance via `RepositoryProvider` et **mesure** son warm-up |
| `LocaleCubit` (8 langues) | **Fondations** (§7) — la tagline est localisée via gen-l10n |
| `OnboardingCubit` (flag `'onboarding'`) | **Fondations** (§8) — Splash **lit** `isOnboardingCompleted` |
| Routing / `OnboardingPlaceholder` / `HomePlaceholder` / `AppRouter` | **Fondations** (§8) — Splash **appelle** les helpers |
| Splash **natif** Android/iOS (`#16213C` + logo) | **Fondations** (§4, `flutter_native_splash`) — assure la continuité AVANT `SplashPage` |
| Déclaration assets/fonts au pubspec | **Fondations** (§10) |

**Reste à la charge de CE plan (US-1.1)** : `home: const SplashPage()` dans `app.dart`, l'écran Flutter
`SplashPage`/`SplashView`, le `SplashBloc` + state machine, les animations, et la **mesure de la durée d'init**
(`max(init, délai)`).

### État actuel du code (vérifié 2026-06-05)
- `apps/digiharmony_app/lib/app/view/app.dart` → `MaterialApp` brut VGV, `home: const CounterPage()` (sera
  remplacé par `home: const SplashPage()` une fois Fondations câblées). Thème/Locale/providers = posés par Fondations.
- `apps/digiharmony_app/lib/bootstrap.dart` → init storage/Drift posée par **Fondations** (§5).
- `apps/digiharmony_app/lib/theme/theme.dart` → **DÉJÀ créé** ; `AppColors.signatureGradient = [#3FB8E6, #A8D24E, #F0C84A]`.
- `apps/digiharmony_app/lib/l10n/arb/app_en.arb` → seulement `counterAppBarTitle`. 8 fichiers ARB présents.
- `CounterPage` toujours référencée (à retirer du `home`).

---

## 2. User Story liée

- **US-1.1 — Splash Screen** (GitHub #1, milestone Phase 1).
  - Critères d'acceptation déduits/attendus (à confirmer/compléter par Erwin si la US est incomplète) :
    - AC-1 : au lancement, le splash s'affiche sur fond `AppColors.backgroundDeep` (`#16213C`), logo, titre, barre signature (dégradé `AppColors.signatureGradient` = `#3FB8E6 → #A8D24E → #F0C84A`), tagline localisée, dots de chargement, footer logo UE.
    - AC-2 : le splash reste affiché jusqu'à ce que l'init locale soit prête (warm-up Drift ; le storage HydratedBloc est déjà prêt via Fondations §5), avec une durée minimale perçue d'environ 2 à 2,5 s.
    - AC-3 : à la fin, l'app route automatiquement vers Onboarding si `OnboardingCubit.isOnboardingCompleted` est faux (1re ouverture), sinon vers Home, via les helpers `AppRouter` (Fondations §8).
    - AC-4 : les animations utilisent `flutter_animate` (déjà au pubspec — DEC-FND-09), de façon homogène avec l'Accueil.
    - AC-5 : pas de flash blanc au démarrage — assuré par le **splash natif** `#16213C` (Fondations §4, `flutter_native_splash`).
    - AC-6 : si l'utilisateur a activé « réduire les animations » (OS), les boucles d'animation sont désactivées et le délai minimal est réduit (DEC-S-005).
    - AC-7 : la tagline est traduite dans les 8 langues ; le titre DIGIHARMONY n'est PAS traduit.

> ⚠️ Si la US #1 n'a pas de critères d'acceptation formels, les faire valider/écrire par Erwin avant d'enchaîner sur l'implémentation.

---

## 3. Spécification visuelle (maquette validée)

Fond `AppColors.backgroundDeep` (`#16213C`) plein écran. Contenu vertical centré (`Column`, `MainAxisAlignment.center` pour le bloc central, footer en bas).

> **Couleurs : aucune valeur hex en dur (DEC-FND-01).** Tout vient de `AppColors` (`lib/theme/theme.dart`).

### Structure (de haut en bas)
1. **Espaceur barre de statut** (`SafeArea` / padding top).
2. **Bloc marque central** :
   - `Stack` 280×280 centré :
     - **Halo dégradé radial « respirant »** (scale + opacité animés en boucle).
     - **3 anneaux d'ondes concentriques** : diamètres 150 / 190 / 230 px, opacités décroissantes, animation d'expansion/pulse en boucle.
     - **Logo** : `assets/images/logo_digiharmony.png`, 110×110, `BorderRadius` 22, légère respiration (scale) en boucle.
   - **Titre** : `DIGIHARMONY` — 28 px, `FontWeight.bold`, letter-spacing large, couleur `AppColors.text`, **NON traduit** (texte littéral). Fade-in déclenché **après** l'apparition du logo.
   - **Barre dégradée signature** : 88×3 px, dégradé horizontal = `AppColors.signatureGradient` **= `#3FB8E6` (cyan) → `#A8D24E` (lime) → `#F0C84A` (or)** (valeurs **canoniques** du thème, **DEC-S-008** corrigé — l'ancien vert `0xFF4FD1A1` était inventé et est **supprimé**).
   - **Tagline** : « Bien-être numérique · Erasmus+ », couleur `AppColors.textMuted` (`#A7B6CE`), **clé i18n `splashTagline`** (8 langues).
3. **3 loading dots** : le central plus gros ; animation de pulsation séquentielle.
4. **Footer** :
   - séparé du contenu par une **bordure fine** (filet horizontal).
   - **logo** `assets/images/logo_eu_funding.png`, largeur ~120 px. **Pas de clé i18n** (image porteuse du texte « Financé par l'Union européenne »).

### Palette (références au thème central — AUCUN hex en dur)
| Rôle | Token (`lib/theme/theme.dart`) | Valeur |
| --- | --- | --- |
| Fond | `AppColors.backgroundDeep` | `#16213C` |
| Signature (dégradé complet) | `AppColors.signatureGradient` | `#3FB8E6` → `#A8D24E` → `#F0C84A` |
| Tagline | `AppColors.textMuted` | `#A7B6CE` |
| Titre | `AppColors.text` | `#F2F6FB` |

> **DEC-FND-01 / DEC-HOME-06** : le design system **existe déjà** (`lib/theme/theme.dart`). Le module splash
> **ne crée AUCUNE constante de couleur locale** (pas de `splash_colors.dart`) : il consomme `AppColors`.
> Le dégradé signature est **déjà** la source de vérité `AppColors.signatureGradient` (valeurs canoniques).

---

## 4. Animations (`flutter_animate` — homogène avec l'Accueil)

> **Contrainte « Flutter pur » LEVÉE (DEC-FND-09).** `flutter_animate ^4.5.2` est **déjà au pubspec** : ce n'est
> donc pas une dépendance ajoutée, et l'argument « zéro dépendance » est sans objet. Le splash utilise
> `flutter_animate` de façon **homogène** avec l'Accueil. Un `AnimationController` manuel reste acceptable pour
> les boucles fines (halo/ondes) si l'implémenteur le juge plus lisible, mais `flutter_animate` est privilégié.

| Animation | Type | Détail |
| --- | --- | --- |
| Halo respirant | boucle | `AnimationController` `repeat(reverse: true)`, scale ~0.9↔1.1 + opacité ~0.4↔0.8 |
| Ondes concentriques | boucle | expansion/pulse des 3 anneaux, opacité décroissante par anneau |
| Respiration logo | boucle | scale léger ~0.97↔1.03 |
| Fade-in titre | one-shot | déclenché après apparition du logo (delay), opacité 0→1 |
| Loading dots | boucle | pulsation séquentielle des 3 dots |

### Reduced motion — DEC-S-005
- Lecture via `MediaQuery.of(context).disableAnimations` (équivalent `MediaQueryData.disableAnimations`).
- Si **vrai** :
  - **désactiver les boucles** d'animation (halo/ondes/logo/dots affichés dans un état statique « repos »),
  - **réduire le délai minimum** à ~800 ms (juste de quoi éviter un flash),
  - **navigation dès que l'init est prête** (le `max(init, 2,5s)` est remplacé par `max(init, 0,8s)`).
- Le fade-in titre peut être remplacé par un affichage immédiat.

> ⚠️ `disableAnimations` dépend d'un `MediaQuery` → le lire dans le `build`/`didChangeDependencies` de la `View`, pas dans le `Bloc`. La **durée minimale effective** est donc passée du widget au Bloc (paramètre d'event), ou le Bloc expose deux seuils et la View choisit. Voir §6.

---

## 5. Données, init & sources

- **Aucune donnée réseau.** Tout est local.
- **Init mesurée par le splash** (entre dans le `max(init, ~2,5s)`) :
  1. `HydratedBloc.storage` : **déjà initialisé par Fondations dans `bootstrap()`** avant `runApp` (Fondations §5).
     Le splash ne l'initialise PAS et n'a pas à le vérifier (garanti prêt). L'init mesurée côté Splash = **warm-up Drift**.
  2. **Warm-up de la base Drift** : `AppDatabase` est **fourni par Fondations** (instance unique via `RepositoryProvider`,
     Fondations §6). Le `SplashBloc` déclenche une 1re requête (ex. `tipOfTheDay`/un `select` léger) pour forcer
     l'ouverture paresseuse et **mesure** sa complétion. C'est l'opération asynchrone attendue.
- **Flag onboarding (DEC-FND-08, aligne DEC-S-010)** :
  - **fourni par Fondations** : `OnboardingCubit` (`HydratedCubit<bool>`, clé `'onboarding'`, défaut `false`).
  - Le Splash **lit** `context.read<OnboardingCubit>().state` (= `isOnboardingCompleted`) au moment de router.
  - La future US Onboarding écrira `true` via `OnboardingCubit.complete()`.

---

## 6. Architecture & comportement (Bloc + state machine)

Pattern projet : **Bloc/Cubit + flutter_bloc**, persistance via HydratedBloc/Drift (jamais mélanger — voir CLAUDE.md DEC-001/002).

### Découpage
- `lib/splash/` :
  - `bloc/splash_bloc.dart`, `splash_event.dart`, `splash_state.dart`
  - `view/splash_page.dart` (fournit le Bloc) + `view/splash_view.dart` (UI + animations)
  - `widgets/` : `brand_halo.dart`, `wave_rings.dart`, `loading_dots.dart`, `signature_bar.dart` (composants privés du module)
  - **Pas de `splash_colors.dart`** : les couleurs viennent de `AppColors` (Fondations / `theme.dart`).

### State machine du SplashBloc (composant à comportement — `aidd:03:components_behavior`)

States (sealed) :
- `SplashInitial` — état de départ, rien lancé.
- `SplashEnCours` — init en cours (Drift en ouverture) + chrono du délai minimal démarré.
- `SplashPretPourOnboarding` — init terminée, délai écoulé, `isOnboardingCompleted == false`.
- `SplashPretPourHome` — init terminée, délai écoulé, `isOnboardingCompleted == true`.
- `SplashErreur(message)` — échec d'init (ex. ouverture Drift échoue). Stratégie : **on route quand même** (l'app doit démarrer), mais on logge l'erreur ; comportement par défaut = aller vers Onboarding/Home selon le flag, en réessayant l'ouverture Drift plus tard. (À confirmer : tolérance d'erreur acceptable car zéro collecte / pas de réseau.)

Events :
- `SplashDemarre(dureeMinimale)` — déclenché par la View au `initState`, passe la durée minimale **calculée selon reduced motion** (~2,5 s normal / ~0,8 s si `disableAnimations`).
- `SplashInitTerminee` — interne (émis quand Drift est ouvert).
- `SplashDelaiEcoule` — interne (émis quand le timer minimal expire).

Transitions :
```
SplashInitial
  --SplashDemarre(d)--> SplashEnCours
        |  (lance en parallèle : ouverture Drift  +  Future.delayed(d))
        |
   [Drift ouvert]            [timer d écoulé]
        \                     /
         v                   v
      attend que LES DEUX soient finis (max(init, d))
                 |
        lit isOnboardingCompleted()
            /                 \
         false               true
          v                    v
 SplashPretPourOnboarding   SplashPretPourHome

(si ouverture Drift échoue) --> SplashErreur --> route quand même (selon flag)
```

> Implémentation conseillée : dans `SplashEnCours`, lancer `Future.wait([ouvertureDrift, Future.delayed(d)])` puis lire le flag. La logique `max(init, d)` est donc un simple `Future.wait`.

### Navigation (via les helpers `AppRouter` de Fondations §8)
- Effectuée par la **View** via `BlocListener`, en appelant les helpers **fournis par Fondations**
  (`OnboardingPlaceholder`/`HomePlaceholder` et `AppRouter` ne sont PAS définis ici) :
  - `SplashPretPourOnboarding` → `AppRouter.toOnboarding(context)`
  - `SplashPretPourHome` → `AppRouter.toHome(context)`
  - `SplashErreur` → même routage que le flag (récupéré dans l'état d'erreur) + log.
- Les helpers encapsulent `Navigator.pushReplacement` (pas de retour vers le splash). **Pas de `flow_builder`**
  pour cette US (DEC-FND-07).

---

## 7. États de la page

| État | Rendu |
| --- | --- |
| Nominal (chargement) | Splash complet animé, dots actifs. |
| Reduced motion | Splash statique (pas de boucles), délai ~800 ms. |
| Erreur d'init Drift | Affichage identique (l'utilisateur ne voit pas l'erreur), routage quand même. Log dev. |
| Prêt | Transition `pushReplacement` vers Onboarding/Home. |

Pas d'état « vide » (écran purement transitoire). Pas d'interaction utilisateur (aucun bouton). Pas de gestion back (écran racine).

---

## 8. Infrastructure — DÉLÉGUÉE à Fondations (NE PAS refaire ici)

> Tout le socle ci-dessous est traité par `foundations-bootstrap.md` (US-FND-01), **à implémenter EN PREMIER**.
> Ce plan ne fait que **consommer**. Ces points restent listés pour la traçabilité de la dépendance.

| Sujet | Statut | Référence |
| --- | --- | --- |
| `HydratedBloc.storage` dans `bootstrap.dart` (signature `hydrated_bloc 11` **vérifiée**) | **Fondations** | Fondations §5, DEC-FND-05 |
| Câblage `AppTheme.dark` + `themeMode: ThemeMode.dark` dans `MaterialApp` | **Fondations** | Fondations §1, DEC-FND-01 |
| `LocaleCubit` (8 langues, repli `en`) au-dessus de `MaterialApp` | **Fondations** | Fondations §7 |
| `OnboardingCubit` (flag `'onboarding'`) | **Fondations** | Fondations §8 |
| Routing minimal + `OnboardingPlaceholder`/`HomePlaceholder` + `AppRouter` | **Fondations** | Fondations §8 |
| Ouverture base Drift + fourniture `AppDatabase` via `RepositoryProvider` | **Fondations** | Fondations §6 |
| Déclaration assets (`assets/images/`) + fonts (`DMSans`) au pubspec | **Fondations** | Fondations §10 |
| Splash **natif** Android/iOS `#16213C` + logo (`flutter_native_splash`, anti-flash blanc) | **Fondations** | Fondations §4, DEC-FND-04 |

### Reste à la charge de CE plan (US-1.1)
- **`app.dart`** : `home: const SplashPage()` (remplace `CounterPage`). Le reste de `app.dart` (thème, providers,
  locale) est posé par Fondations — ne pas le dupliquer, juste ajouter le `home`.
- **`SplashPage`** : fournit le `SplashBloc` (qui reçoit `AppDatabase` et lit `OnboardingCubit`) au-dessus de `SplashView`.
- Aucune autre modif d'infra : **aucune dépendance ajoutée** par ce plan (interdits réseau/analytics/Crashlytics inchangés).

---

## 9. Internationalisation

- Système détecté : **gen-l10n / ARB**, 8 langues (`en` repli).
- **1 seule clé à créer** : `splashTagline`.
  - Cible : les 8 fichiers `apps/digiharmony_app/lib/l10n/arb/app_*.arb`.
  - `app_en.arb` (référence + metadata) :
    ```json
    "splashTagline": "Digital well-being · Erasmus+",
    "@splashTagline": {
      "description": "Tagline shown on the splash screen, below the brand signature bar"
    }
    ```
  - `app_fr.arb` : `"splashTagline": "Bien-être numérique · Erasmus+"`
  - Les 6 autres (`el/it/ro/tr/es/mk`) : traductions à fournir (placeholder = texte EN si traduction non dispo, à compléter). À faire traduire avant release.
- **Titre DIGIHARMONY** : littéral, **pas** de clé i18n.
- **Logo footer UE** : image, **pas** de clé i18n.
- Lancer `flutter gen-l10n` après ajout.

---

## 10. Décisions tranchées (DEC-S)

| ID | Décision |
| --- | --- |
| DEC-S-005 | Reduced motion : si `MediaQuery.disableAnimations`, désactiver les boucles ET réduire le délai min à ~800 ms ; naviguer dès init prête. |
| DEC-S-008 | **CORRIGÉ** : dégradé barre signature = `AppColors.signatureGradient` (valeurs canoniques `#3FB8E6 → #A8D24E → #F0C84A`). L'ancien vert inventé `0xFF4FD1A1` est **supprimé**. |
| DEC-S-010 | Flag onboarding lu via `OnboardingCubit` (Fondations §8, défaut `false`, clé `'onboarding'`). |
| DEC-S-ARCHI-1 | **Délégué à Fondations** : `HydratedBloc.storage` initialisé dans `bootstrap()` avant tout bloc hydraté (DEC-FND-05). |
| DEC-S-ARCHI-2 | Warm-up Drift **mesuré** par le `SplashBloc` (instance `AppDatabase` fournie par Fondations §6), entre dans `max(init, ~2,5s)` via `Future.wait`. |
| DEC-S-ARCHI-3 | Routage via helpers `AppRouter` (`pushReplacement`) fournis par Fondations §8 ; pas de `flow_builder` (DEC-FND-07). |
| DEC-S-ANIM-1 | **REVU** : `flutter_animate` AUTORISÉ et homogène avec l'Accueil (DEC-FND-09) — déjà au pubspec, donc pas une dépendance ajoutée. L'ancienne contrainte « Flutter pur » est levée. |

---

## 11. Points à challenger / à confirmer (self-challenge)

1. **`proposition_a_valider`** : la US #1 doit avoir des critères d'acceptation formels (Erwin) — actuellement déduits.
2. **Dépendance Fondations** : ce plan **présuppose** que `foundations-bootstrap.md` (US-FND-01) est implémenté
   en premier (thème, storage, Drift, `OnboardingCubit`, `AppRouter`, splash natif). À séquencer avant l'US-1.1.
3. **Tolérance d'erreur Drift** (`SplashErreur`) : router quand même est-il acceptable ? (recommandé oui, car app locale).
4. **`disableAnimations` lu côté View** : la durée minimale doit transiter vers le Bloc (event paramétré) — confirmer ce découpage View↔Bloc.
5. **Traductions ARB** des 6 langues hors en/fr : à fournir avant release (placeholder EN en attendant).
6. ~~API `hydrated_bloc`~~ : **résolu** — signature `HydratedStorage.build({required HydratedStorageDirectory storageDirectory})` vérifiée sur `11.0.0` (traité par Fondations §5).
7. ~~Placeholders / splash natif manuel~~ : **résolus par Fondations** (§8 placeholders + `AppRouter` ; §4 splash natif `flutter_native_splash`).

---

## 12. Plan de tests (préparation Step 5 — Kent)

Cas déduits (sources US + états du plan) à présenter avant écriture :
- SplashBloc : `SplashDemarre` → `SplashEnCours` (source : §6).
- `max(init, délai)` : init rapide < délai → navigation après le délai (source : AC-2).
- init lente > délai → navigation après init (source : AC-2).
- flag `false` → `SplashPretPourOnboarding` (source : AC-3, DEC-S-010).
- flag `true` → `SplashPretPourHome` (source : AC-3).
- reduced motion : délai réduit ~800 ms (source : DEC-S-005, AC-6).
- erreur ouverture Drift → `SplashErreur` puis routage (source : §7).
- Widget : présence logo, titre `DIGIHARMONY`, tagline localisée, barre signature, footer logo UE (source : §3).
- Widget reduced motion : pas de boucles d'animation actives (source : DEC-S-005).

> Réutiliser les packages de test déjà présents : `bloc_test`, `mocktail`, `flutter_test`. **Aucune** nouvelle dépendance de test.

---

## 13. Estimation

> Infra (bootstrap storage, thème, Drift, `LocaleCubit`/`OnboardingCubit`, routing/placeholders, splash natif,
> pubspec assets/fonts) = **comptée dans le plan Fondations** (~16,5 h), pas ici.

- `app.dart` (`home: SplashPage`) + `SplashPage` (fourniture Bloc) : ~0,5 h.
- `SplashBloc` + state machine (lit `OnboardingCubit`, mesure warm-up Drift) : ~2,5 h.
- UI + animations `flutter_animate` (halo/ondes/dots/signature/fade-in) + a11y `disableAnimations` : ~5 h.
- i18n (1 clé `splashTagline` × 8 ARB) + gen-l10n : ~1 h.
- Tests Kent : ~3 h.
- **Total US-1.1 (hors Fondations)** : ~12 h.
