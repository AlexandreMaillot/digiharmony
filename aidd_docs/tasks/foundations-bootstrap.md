---
page: Fondations / Bootstrap (infrastructure transverse)
route: N/A (pas un écran — socle technique)
us: [US-FND-01]
github: "#3"
milestone: Phase 1
shared_components: [AppTheme, AppColors, MoodColors, AppSpacing, AppRadii, AppDatabase, LocaleCubit, OnboardingCubit, AppRouter, OnboardingPlaceholder, HomePlaceholder]
i18n_keys: []
tests: aidd_docs/tasks/foundations-bootstrap.tests.md
created: 2026-06-05
updated: 2026-06-05
status: valide
depends_on: []
consumed_by: [splash-screen.md (US-1.1), accueil-home.md (US-HOME-01)]
---

## ✅ Décisions de validation (2026-06-05) — FONT FOI (priment sur tout détail divergent ci-dessous)

- **Émotions = 7 canoniques** (DEC-003 / `design-system.md`) : `happy/calm/dynamic/sad/angry/nervous/tired`. `MoodColors` (déjà 7 clés) fait référence. Clés i18n : `moodHappy/moodCalm/moodDynamic/moodSad/moodAngry/moodNervous/moodTired`.
- **Logo carré** : `assets/images/logo_digiharmony_square.png` (969×969, recadrage centré) pour le **splash natif** et l'**icône de lanceur**. `logo_digiharmony.png` (rectangulaire) reste dispo pour usages illustration. `logo_eu_funding.png` = footer.
- **Icône de lanceur** : `flutter_launcher_icons` en **dev_dependency** (build-time, zéro runtime/réseau), source `logo_digiharmony_square.png`, fond adaptatif `#16213C`.
- **i18n V1** : `fr` + `en` traduits réellement ; `el/it/ro/tr/es/mk` = **repli `en`** avec `TODO` de traduction (qualité Erasmus+ ultérieure). Ne pas bloquer le build.
- **Conseils** : seed **placeholder** ~7 conseils bienveillants génériques (fr+en) pour faire tourner la rotation déterministe ; contenu éditorial réel plus tard.
- **Nommage FRANÇAIS des features** : racine domaine FR + suffixes Flutter standard. **Onboarding → Bienvenue** : `OnboardingCubit` → `BienvenueCubit`, `isOnboardingCompleted()` → `estBienvenueVue()`, clé HydratedBloc `bienvenue`, placeholder `BienvenuePage` (`lib/bienvenue/`). **Home → Accueil** : placeholder `AccueilPage` (`lib/accueil/`), route `/accueil`. **Splash → Demarrage** (`lib/demarrage/`). Scaffolding technique (`AppTheme`/`AppColors`/`MoodColors`/`AppDatabase`/`AppRouter`/`LocaleCubit`/`bootstrap`) reste en anglais.
- **Couche de données en FRANÇAIS** (convention projet) : tables/colonnes/DAO/entités/méthodes Drift en français. Tables : `EntreesHumeur` (SQL `entrees_humeur`, ligne `EntreeHumeur`) et `Conseils` (ligne `Conseil`). Colonnes `EntreesHumeur` : `id`, `codeEmotion` (`code_emotion`), `valence`, `creeLe` (`cree_le`). Colonnes `Conseils` : `id`, `cleConseil` (`cle_conseil`). Méthodes : `observerDerniereHumeurDuJour()`, `conseilDuJour(DateTime jour)`. DAO en français.
- **`EntreesHumeur`** : schéma **minimal provisoire** (`id`, `codeEmotion`, `valence`, `creeLe`), lecture seule pour l'état A/B ; étendu par l'US « Noter mon humeur ».
- **Git/Kaio** : implémentation orchestrée par **Kaio**, branche depuis `alexandre`, **une PR par lot** (Fondations → Splash → Accueil) vers `main`.

# Page Plan — Fondations / Bootstrap (à implémenter EN PREMIER)

> **Plan d'infrastructure transverse, PAS un écran.** Décision validée : extraire un socle
> Fondations dédié, implémenté **avant** Splash (US #1) et Accueil (US-HOME-01), pour éviter que
> ces deux plans recréent chacun le thème, l'init storage, la base Drift, le routing et le splash natif.
> Banani NON sollicité (consigne). Cible : `apps/digiharmony_app/`.
>
> Contraintes projet (CLAUDE.md + memory bank) : public mineur, Erasmus+, **SANS backend / SANS
> Firebase / ZÉRO collecte**. Aucun SDK réseau / analytics / tracking / Crashlytics. Aucune permission
> au-delà de `PACKAGE_USAGE_STATS`. Monorepo Melos 7 (pub workspaces). Mode **foncé uniquement** (DEC-003).

---

## 0. État réel du codebase (vérifié 2026-06-05)

- `lib/app/view/app.dart` → `MaterialApp` brut VGV : `ThemeData` Material par défaut, `home: const CounterPage()`,
  délégués i18n déjà câblés (`AppLocalizations.localizationsDelegates` / `supportedLocales`). **Pas** de thème
  DIGIHARMONY appliqué, **pas** de `LocaleCubit`, **pas** de Providers de dépendances.
- `lib/bootstrap.dart` → `bootstrap()` installe `Bloc.observer = AppBlocObserver()` et `FlutterError.onError`,
  puis `runApp(await builder())`. **Aucune** init `HydratedBloc.storage`, **aucune** ouverture Drift
  (commentaire « Add cross-flavor configuration here »).
- `lib/theme/theme.dart` → **DÉJÀ CRÉÉ et complet** : `AppColors`, `MoodColors`, `AppSpacing`, `AppRadii`,
  `AppTheme.dark` (Material 3, `fontFamily = 'DMSans'`, `scaffoldBackgroundColor = AppColors.background`).
  `AppColors.signatureGradient = [#3FB8E6, #A8D24E, #F0C84A]`. **Ce thème n'est PAS encore câblé** dans `MaterialApp`.
- `lib/l10n/arb/` → 8 fichiers (`en/fr/el/it/ro/tr/es/mk`), template `app_en.arb`, **seule clé** `counterAppBarTitle`.
- `pubspec.yaml` → présents : `bloc`, `flutter_bloc`, `drift ^2.33.0` (+ `drift_dev` dev), `hydrated_bloc ^11.0.0`,
  `flutter_animate ^4.5.2`, `path_provider ^2.1.5`, `path ^1.9.1`, `sqlite3_flutter_libs ^0.6.0+eol`,
  `flow_builder ^0.1.0`, `intl ^0.20.2`. **`assets/` PAS déclaré** sous `flutter:`. **Aucune** section `fonts:`.
  `flutter_native_splash` **absent** (à ajouter en dev_dependency).
- `assets/images/`, `assets/fonts/`, `assets/audio/`, `assets/video/` **existent mais sont VIDES**
  (logos et `.ttf` pas encore fournis → fallback non bloquant obligatoire, voir §2 et §3).
- `aidd_docs/tasks/_registry.md` → **n'existe pas** (à créer, §13).

> **Conséquence** : ce plan crée le socle minimal au strict nécessaire pour Splash + Accueil, sans déborder
> sur l'écran « Noter mon humeur » (écriture du journal = hors périmètre, table préparée en lecture seule).

---

## 1. THÈME — câbler `theme.dart` dans `MaterialApp` (mode foncé uniquement)

> Le thème central **existe déjà** dans `lib/theme/theme.dart`. Ce plan **ne le recrée pas** : il le **câble**.

- **Action** : dans `lib/app/view/app.dart`, remplacer le `ThemeData(...)` brut par :
  - `theme: AppTheme.dark`
  - `darkTheme: AppTheme.dark` (cohérence)
  - `themeMode: ThemeMode.dark` (**mode foncé uniquement** — DEC-003 ; ne jamais exposer de thème clair).
- **Import** : `package:digiharmony_app/theme/theme.dart`.
- **RÈGLE absolue (DEC-FND-01)** : **aucune couleur hex en dur** ailleurs que `lib/theme/theme.dart`.
  Tout écran consomme `AppColors` / `MoodColors` / `Theme.of(context)`. Splash et Accueil sont mis à jour
  en conséquence (voir leurs plans respectifs).
- **Tokens disponibles** (rappel, source `theme.dart` + `aidd_docs/memory/design-system.md`) :
  - `AppColors.background = #1F2C49`, `AppColors.backgroundDeep = #16213C` (splash/immersif),
    `AppColors.surface = #283A5E`, `AppColors.primary = #3FB8E6`, `AppColors.primaryLight = #8FD8F0`,
    `AppColors.accentGold = #E0B24A`, `AppColors.text = #F2F6FB`, `AppColors.textMuted = #A7B6CE`.
  - `AppColors.signatureGradient = [#3FB8E6 (cyan), #A8D24E (lime), #F0C84A (or)]` —
    **valeurs CANONIQUES du dégradé signature**, réservées aux moments de marque (splash, halo).
  - `MoodColors` (7 émotions) : **réservées au codage émotionnel** (journal/saisie/stats), jamais au chrome.
  - `AppSpacing` (4/8/16/24/32), `AppRadii` (`button = 12`, `card = 24`, + `buttonRadius`/`cardRadius`).
- **Garde-fou DEC-003** : aucun streak / badge / point / classement / FOMO / mascotte. Le thème reste
  apaisant, non anxiogène.

---

## 2. POLICE — vendoriser DM Sans (asset bundlé, ZÉRO réseau)

> **Interdit : `google_fonts`** (réseau). DM Sans doit être **bundlé** localement. `AppTheme.fontFamily = 'DMSans'`
> est déjà référencé par `theme.dart` ; il faut **déclarer** cette family au pubspec et fournir les `.ttf`.

- **Déclarer la family `'DMSans'`** dans `pubspec.yaml`, section `flutter: fonts:` (voir §10 pour le bloc exact).
- **Fichiers `.ttf` attendus** sous `assets/fonts/` (à fournir par l'utilisateur — dossier actuellement vide) :
  - `assets/fonts/DMSans-Regular.ttf` (weight 400)
  - `assets/fonts/DMSans-Medium.ttf` (weight 500)
  - `assets/fonts/DMSans-Bold.ttf` (weight 700)
- **Fallback NON bloquant (DEC-FND-02)** : tant que les `.ttf` sont absents, Flutter retombe automatiquement
  sur la police système (commentaire déjà présent dans l'en-tête de `theme.dart`). **Ne pas bloquer le build.**
  Marquer un **TODO asset** : « fournir les 3 `.ttf` DM Sans dans `assets/fonts/` ».
- Pas de licence à intégrer côté SDK ; DM Sans est OFL — joindre le fichier de licence dans le repo si exigé
  par la conformité Erasmus+ (hors périmètre code).

---

## 3. ASSETS — déclarer `assets/images/` au pubspec

- **Déclarer** `assets/images/` (ou les fichiers nommés) dans `pubspec.yaml`, section `flutter: assets:` (§10).
- **Fichiers fournis par l'utilisateur** (dossier `assets/images/` actuellement vide) :
  - `assets/images/logo_digiharmony.png` (logo de marque — utilisé par Splash + header Accueil + splash natif §4)
  - `assets/images/logo_eu_funding.png` (financement UE — footer Splash, image porteuse du texte, **pas** d'i18n)
- **Fallback NON bloquant (DEC-FND-03)** : si un PNG manque, l'`Image.asset` lèvera à l'exécution. Recommandation :
  les écrans consommateurs (Splash/Accueil) utilisent `Image.asset(..., errorBuilder:)` pour afficher un
  placeholder neutre plutôt que crasher. Marquer un **TODO asset** pour les 2 logos.
- Déclarer **uniquement** `assets/images/` ici (audio/video existent mais hors périmètre Fondations).

---

## 4. SPLASH NATIF RÉEL (Android + iOS) — « le vrai splash natif de l'app »

> Demande explicite : configurer le **vrai splash natif** affiché par l'OS **avant** que Flutter démarre,
> pour garantir la **continuité visuelle** (pas de flash blanc) avant que l'écran Flutter `SplashPage`
> (plan splash-screen.md) prenne le relais.

- **Approche recommandée (DEC-FND-04)** : package **`flutter_native_splash` en `dev_dependencies`**.
  - C'est un outil **build-time uniquement** : il **génère les assets natifs** (drawables Android,
    `LaunchScreen` iOS) à partir d'une config. **Aucun SDK runtime, aucun code réseau** → **compatible
    zéro-collecte** et conforme « aucun SDK réseau/analytics ». Il ne s'exécute jamais sur l'appareil.
  - À ajouter sous `dev_dependencies:` (PAS `dependencies:`). Voir §10.
- **Config** (fichier `flutter_native_splash.yaml` à la racine de `apps/digiharmony_app/`, ou section
  `flutter_native_splash:` dans `pubspec.yaml`) :
  ```yaml
  flutter_native_splash:
    color: "#16213C"            # AppColors.backgroundDeep (fond profond splash)
    image: assets/images/logo_digiharmony.png
    android_12:
      color: "#16213C"
      image: assets/images/logo_digiharmony.png   # icône splash Android 12+ (taille contrainte par l'OS)
    ios: true
    android: true
    fullscreen: false
  ```
- **Commande de génération** (à lancer depuis `apps/digiharmony_app/`, **une seule fois** et à re-lancer si
  le logo/couleur changent) :
  ```
  dart run flutter_native_splash:create
  ```
- **Couleur de fond = `#16213C`** (= `AppColors.backgroundDeep`). C'est volontairement le fond **profond**
  du splash, pas `AppColors.background`, pour la continuité avec l'écran Flutter `SplashPage`.
- **Continuité visuelle** : splash natif (`#16213C` + logo) → `SplashPage` Flutter (`#16213C` + logo animé) →
  navigation. Aucun flash blanc.
- **3 flavors** : `flutter_native_splash` écrit dans les ressources natives partagées ; vérifier que les
  3 flavors (`development`/`staging`/`production`) rendent bien le splash (les `styles.xml`/`LaunchScreen`
  par flavor peuvent diverger — à valider après génération).
- **Garde-fou R8** : ne PAS activer `minify`/`shrinkResources` (CLAUDE.md) — sans rapport direct avec le splash
  natif mais rappelé car on touche au natif Android.

> **Alternative manuelle** (si l'on refusait toute dépendance, même dev) : éditer à la main
> `android/app/src/main/res/values/styles.xml` (+ `values-night`) et `ios/Runner/.../LaunchScreen.storyboard`.
> **Non retenue** ici : plus fragile, à répéter par flavor, et `flutter_native_splash` étant build-time pur,
> il ne viole aucune contrainte zéro-collecte. (DEC-FND-04.)

---

## 5. INIT BOOTSTRAP — séquencer `bootstrap.dart`

> Ordre **critique** : `HydratedBloc.storage` doit être affecté **AVANT** `runApp` et **avant** tout bloc
> hydraté (`LocaleCubit`, `OnboardingCubit`). Sinon ces cubits lèvent à la construction.

Séquence cible dans `lib/bootstrap.dart`, **avant** `runApp(await builder())` :

1. `WidgetsFlutterBinding.ensureInitialized();`
2. **HydratedBloc storage** :
   ```dart
   final dir = await getApplicationDocumentsDirectory(); // path_provider (présent)
   HydratedBloc.storage = await HydratedStorage.build(
     storageDirectory: HydratedStorageDirectory(dir.path),
   );
   ```
   - **Signature VÉRIFIÉE sur `hydrated_bloc 11.0.0`** (source pub-cache) :
     `static Future<HydratedStorage> build({required HydratedStorageDirectory storageDirectory})`,
     et `HydratedStorageDirectory(String path)`. **Flag levé / confirmé** — pas besoin de `HydratedStorageDirectory.web` (mobile only).
3. **Ouverture base Drift** (instance unique) : `final db = AppDatabase();` (voir §6 — ouverture paresseuse
   via `LazyDatabase` + `path_provider`). L'ouverture réelle de la connexion peut être paresseuse ; le
   **warm-up mesuré** (latence perçue) reste piloté par le `SplashBloc` (plan splash-screen.md), pas ici.
4. Conserver `Bloc.observer = const AppBlocObserver();` et `FlutterError.onError` déjà en place.
5. **Fournir les dépendances** : `bootstrap()` (ou `App`) expose l'instance `AppDatabase` et les cubits via
   `MultiRepositoryProvider` / `MultiBlocProvider` au-dessus de `MaterialApp` (voir §7 et §8).
   - Recommandation : `bootstrap()` construit `db` puis `builder()` retourne `App(database: db)`, qui place
     `RepositoryProvider<AppDatabase>.value(value: db)` + `BlocProvider(create: (_) => LocaleCubit())` +
     `BlocProvider(create: (_) => OnboardingCubit())` au-dessus de `MaterialApp`.

> **DEC-FND-05** : l'init storage est faite **une fois** dans `bootstrap.dart` (partagée par les 3 entrypoints
> `main_<flavor>.dart`). Le Splash ne ré-initialise rien — il **mesure** seulement la latence d'ouverture/warm-up Drift.

---

## 6. DRIFT — base minimale + tables `mood_entries` (lecture) et `conseils` (seed + rotation)

> Base **n'existe pas** encore. Ce plan la crée au strict nécessaire pour Accueil (lecture). L'écriture du
> journal (« Noter mon humeur ») est **hors périmètre** ; le schéma `mood_entries` est conçu pour anticiper
> l'écriture sans la faire ici.

- **Fichier** : `lib/data/local/app_database.dart` (+ codegen `app_database.g.dart`).
- **Ouverture** : `LazyDatabase` + `NativeDatabase` sur
  `p.join((await getApplicationDocumentsDirectory()).path, 'digiharmony.sqlite')` (`path` + `path_provider`,
  tous deux présents). Instance **unique** fournie via `RepositoryProvider<AppDatabase>`.

### 6.1 Table `MoodEntries` (lecture seule pour l'état A/B de l'Accueil)
- `id` INTEGER autoincrement PK
- `moodCode` TEXT NOT NULL — code stable (aligné `MoodColors.byKey` : `happy|calm|dynamic|sad|angry|nervous|tired`).
  > NB : `MoodColors` expose **7** émotions ; le plan Accueil actuel liste 6 libellés
  > (`happy/calm/neutral/sad/angry/anxious`). **Incohérence à arbitrer** (voir §11) — le schéma stocke un code
  > libre, donc non bloquant pour Fondations, mais à figer avec l'US « Noter mon humeur ».
- `valence` INTEGER NOT NULL — ≥0 positive/neutre, <0 négative ; sert au **futur** compteur « 7 émotions
  négatives consécutives », **dérivé** de Drift (DEC-001), jamais dupliqué dans HydratedBloc.
- `createdAt` DATETIME NOT NULL — horodatage local.
- **Schéma à figer définitivement avec l'US « Noter mon humeur »** (DEC-FND-06) — ici on n'écrit jamais cette table.

### 6.2 Table `Conseils` (dataset local seedé, rotation quotidienne déterministe)
- `id` INTEGER autoincrement PK
- `tipKey` TEXT NOT NULL — clé i18n du conseil (ex. `tipDay01`). Le **texte traduit** vit dans les ARB
  (multilingue sans dupliquer 8 langues en SQLite).
- **Seed** dans `MigrationStrategy.onCreate` (+ check idempotent si table vide) : ≥ 7 entrées `tipDay01..tipDay07`.

### 6.3 Requêtes read-only (DAO)
- `Stream<MoodEntryRow?> watchLastMoodToday()` : dernière entrée du jour
  (`createdAt ∈ [minuit aujourd'hui, minuit demain)`, tri `createdAt DESC LIMIT 1`, NULL si aucune). Réactif (`watch()`).
- `Future<ConseilRow> tipOfTheDay(DateTime day)` : conseil **déterministe** par date —
  `index = joursDepuisEpoch % nbConseils`, `joursDepuisEpoch = DateTime(d.year,d.month,d.day).difference(DateTime(1970,1,1)).inDays`.
  1 conseil/jour, stable la journée, sans aléatoire ni stockage d'état.

### 6.4 Garde-fous
- **Codegen obligatoire** : `dart run build_runner build --delete-conflicting-outputs` **avant** les tests.
- **Android** : `minify`/`shrinkResources` restent **`false`** (R8 strippe sqlite3/Drift natif). Ne rien
  changer côté Gradle.
- **DEC-001/002** : le journal vit **uniquement** dans Drift ; l'état A/B est **dérivé** via `watch()`, jamais
  copié dans HydratedBloc.

---

## 7. LOCALECUBIT — bascule de langue live (HydratedBloc)

- **Fichier** : `lib/locale/locale_cubit.dart`.
- `LocaleCubit extends HydratedCubit<Locale?>` :
  - état = `Locale?` (NULL = suivre la langue système) — défaut `null`.
  - `toJson`/`fromJson` sérialisent le `languageCode` (clé HydratedBloc dédiée).
  - méthodes : `setLocale(Locale)`, `useSystem()` (remet `null`).
- **8 langues** : `en/fr/el/it/ro/tr/es/mk`, **repli `en`** (DEC-002). La liste vient déjà de
  `AppLocalizations.supportedLocales`.
- **Câblage** : `BlocProvider(create: (_) => LocaleCubit())` **au-dessus** de `MaterialApp`, et
  `MaterialApp(locale: context.watch<LocaleCubit>().state, ...)` pour la bascule **live**.
- **Garde-fou DEC-001/002** : `LocaleCubit` = état **léger** persistant uniquement (langue). **Jamais** le journal.
- L'init storage (§5) doit précéder la construction de ce cubit (sinon `HydratedCubit` lève).

---

## 8. ROUTING minimal — Splash → Onboarding/Home

> Routing **minimal** suffisant pour que le Splash route via `Navigator.pushReplacement` selon le flag
> onboarding. Pas de `flow_builder` requis pour la Phase 1 (DEC-FND-07) — `flow_builder` reste au pubspec
> pour un usage ultérieur (parcours onboarding multi-étapes), non câblé ici.

- **OnboardingCubit** (`lib/onboarding/onboarding_cubit.dart`) : `HydratedCubit<bool>`, état = `isOnboardingCompleted`,
  **défaut `false`**, clé HydratedBloc `'onboarding'`. Expose `complete()` (passe à `true`, écrit par la future US
  Onboarding). Contrat lu par le Splash : `isOnboardingCompleted == true ? Home : Onboarding`. (DEC-FND-08, aligne DEC-S-010.)
- **Placeholders** (`lib/common/placeholder_screen.dart` ou dédiés) :
  - `OnboardingPlaceholder` — Scaffold neutre « Bientôt disponible » (remplacé par l'US Onboarding).
  - `HomePlaceholder` — **provisoire** : sera remplacé par `HomePage` réel dès que le plan Accueil est implémenté.
    Tant qu'Accueil n'est pas livré, le Splash route vers ce placeholder ; une fois Accueil livré, la cible
    « home » du routeur pointe sur `HomePage`.
- **AppRouter / helpers** (`lib/app/routing/app_router.dart`) : exposer des helpers
  `AppRouter.toOnboarding(context)` / `AppRouter.toHome(context)` encapsulant
  `Navigator.of(context).pushReplacement(MaterialPageRoute(builder: ...))`, pour que Splash et futurs écrans
  partagent une seule définition des cibles (évite la divergence de routes).
- **MaterialApp.home** : reste piloté par le **plan Splash** (`home: const SplashPage()`). Fondations fournit
  seulement les **cibles** et helpers, pas le `home`.

---

## 9. FLUTTER_ANIMATE — règle d'usage homogène (incohérence tranchée)

> **Incohérence historique** : le plan Splash interdisait `flutter_animate` (« aucune dépendance ajoutée »)
> alors qu'Accueil l'utilisait. Or `flutter_animate ^4.5.2` est **DÉJÀ au pubspec** → ce **n'est PAS une
> dépendance ajoutée**. L'argument « zéro dépendance » est donc sans objet.

- **DEC-FND-09 (règle actée)** : **`flutter_animate` est AUTORISÉ et privilégié** pour les animations
  déclaratives, de façon **homogène** sur Splash **et** Accueil (et écrans futurs). Il est déjà présent,
  purement local (aucun réseau), et réduit le boilerplate d'`AnimationController`.
- **Conséquence pour Splash** : la contrainte « Flutter pur / `AnimationController` obligatoire » est **levée**.
  Le Splash peut utiliser `flutter_animate` (halo, ondes, fade-in titre, dots). Voir mise à jour du plan splash.
- **Accessibilité (transverse)** : tous les écrans respectent `MediaQuery.of(context).disableAnimations` —
  si `true`, **désactiver les boucles** (`flutter_animate` : ne pas appliquer les effets en boucle, rendre l'état
  de repos statique) tout en gardant l'écran lisible. (Aligné DEC-S-005 / DEC-HOME-07.)

---

## 10. pubspec.yaml — modifications exactes (Fondations)

> **Aucune dépendance runtime ajoutée.** Seul ajout : `flutter_native_splash` en **dev_dependency** (build-time pur).

### 10.1 `dev_dependencies` — ajouter
```yaml
dev_dependencies:
  # ...existant...
  flutter_native_splash: ^2.4.4   # build-time uniquement (génère assets natifs), AUCUN SDK runtime/réseau
```
> Vérifier la dernière version compatible Flutter `^3.41.0` au moment de l'implémentation (le flag de version
> est indicatif). C'est le **seul** ajout au pubspec.

### 10.2 `flutter:` — assets + fonts
```yaml
flutter:
  generate: true
  uses-material-design: true
  assets:
    - assets/images/
  fonts:
    - family: DMSans
      fonts:
        - asset: assets/fonts/DMSans-Regular.ttf
        - asset: assets/fonts/DMSans-Medium.ttf
          weight: 500
        - asset: assets/fonts/DMSans-Bold.ttf
          weight: 700
```
- Déclarer `assets/images/` (dossier) suffit pour les 2 logos. Ne PAS déclarer `audio/`/`video/` (hors périmètre).
- La family **`DMSans`** doit correspondre **exactement** à `AppTheme.fontFamily` (`theme.dart`).
- Fallback : si les `.ttf` sont absents, Flutter émet un warning au build mais retombe sur la police système
  (DEC-FND-02) — non bloquant.

### 10.3 Config splash natif
- Ajouter le bloc `flutter_native_splash:` (§4) soit dans `pubspec.yaml`, soit dans
  `flutter_native_splash.yaml` à la racine de `apps/digiharmony_app/`.

---

## 11. Fichiers à créer / modifier (récap)

**Créer** :
- `lib/data/local/app_database.dart` (+ `app_database.g.dart` via codegen) — tables `MoodEntries` (lecture),
  `Conseils` (seed + rotation), DAO read-only.
- `lib/locale/locale_cubit.dart` — `LocaleCubit` (HydratedCubit, 8 langues, repli `en`).
- `lib/onboarding/onboarding_cubit.dart` — `OnboardingCubit` (HydratedCubit<bool>, clé `'onboarding'`).
- `lib/app/routing/app_router.dart` — helpers `toOnboarding` / `toHome` (`pushReplacement`).
- `lib/common/placeholder_screen.dart` — `PlaceholderScreen({required String titre})` générique +
  `OnboardingPlaceholder` / `HomePlaceholder` (ou 2 wrappers minces).
- `flutter_native_splash.yaml` (ou section pubspec) — config splash natif.
- **(fournis par l'utilisateur)** : `assets/images/logo_digiharmony.png`, `assets/images/logo_eu_funding.png`,
  `assets/fonts/DMSans-{Regular,Medium,Bold}.ttf`.

**Modifier** :
- `lib/bootstrap.dart` — init `HydratedBloc.storage` (avant `runApp`) + ouverture `AppDatabase` + fourniture deps (§5).
- `lib/app/view/app.dart` — `theme/darkTheme: AppTheme.dark`, `themeMode: ThemeMode.dark`,
  `MultiRepositoryProvider`/`MultiBlocProvider` (DB + `LocaleCubit` + `OnboardingCubit`),
  `locale: <LocaleCubit.state>`. (Le `home:` reste défini par le plan Splash.)
- `pubspec.yaml` — `dev_dependencies` (`flutter_native_splash`), `flutter: assets:` + `fonts:` (§10).
- `aidd_docs/tasks/_registry.md` — créer + entrées Fondations / Splash / Accueil (§13).

> **Ne PAS modifier** : `lib/theme/theme.dart` (déjà complet — câblage uniquement). Gradle `minify`/`shrinkResources`
> (rester `false`). Les délégués i18n de `app.dart` (déjà bons).
> **Codegen Drift** : `dart run build_runner build --delete-conflicting-outputs` **avant** `flutter test`.

---

## 12. User Story (dépendance — À CRÉER via Erwin)

> Fondations est un socle technique ; il mérite une US de traçabilité (Phase 1) dont **dépendent** US-1.1 (Splash)
> et US-HOME-01 (Accueil).

- **US-FND-01 « Fondations / Bootstrap »** (milestone Phase 1), couvrant : câblage thème foncé, vendorisation
  DM Sans, déclaration assets, splash natif `#16213C`, init HydratedBloc.storage + Drift dans `bootstrap`,
  base Drift (`mood_entries` lecture / `conseils` seed+rotation), `LocaleCubit` 8 langues, `OnboardingCubit`,
  routing minimal + placeholders.
- Critères d'acceptation (source des tests Kent — Step 5) :
  - AC1 : au lancement, le thème foncé `AppTheme.dark` est appliqué ; aucune couleur hex en dur hors `theme.dart`.
  - AC2 : `HydratedBloc.storage` est initialisé **avant** tout cubit hydraté (pas d'exception au démarrage).
  - AC3 : la base Drift s'ouvre ; `tipOfTheDay(d)` est **déterministe** (même `d` → même conseil) ; le seed
    contient ≥ 7 conseils.
  - AC4 : `watchLastMoodToday()` émet `null` si aucune entrée du jour, sinon la dernière entrée du jour.
  - AC5 : `LocaleCubit.setLocale(fr)` bascule la langue **live** ; persiste après redémarrage ; repli `en`.
  - AC6 : `OnboardingCubit` défaut `false`, `complete()` → `true`, persiste.
  - AC7 : helpers de routing remplacent l'écran courant (`pushReplacement`) vers Onboarding/Home selon le flag.
  - AC8 : `flutter_native_splash` génère un splash `#16213C` + logo (Android + iOS) — pas de flash blanc.

---

## 13. Registry & coordination

- `aidd_docs/tasks/_registry.md` **n'existe pas** → **à créer** avec :
  ```
  - Fondations / Bootstrap: N/A (socle technique) — US-FND-01 — foundations-bootstrap.md
  - Splash Screen: "/" — US-1.1 (#1) — splash-screen.md
  - Accueil (Home): /home (placeholder) — US-HOME-01 — accueil-home.md
  ```
- **Composants partagés introduits ici** (réutilisés par Splash, Accueil et écrans futurs — ne pas dupliquer) :
  `AppTheme`/`AppColors`/`MoodColors`/`AppSpacing`/`AppRadii` (déjà dans `theme.dart`), `AppDatabase` (Drift),
  `LocaleCubit`, `OnboardingCubit`, `AppRouter`, `PlaceholderScreen`/`OnboardingPlaceholder`/`HomePlaceholder`.
- **Ordre d'implémentation imposé** : **Fondations EN PREMIER**, puis Splash (US-1.1), puis Accueil (US-HOME-01).
  Splash et Accueil **consomment** ce socle (ne le recréent pas).

---

## 14. Décisions tranchées (DEC-FND)

| ID | Décision |
| --- | --- |
| DEC-FND-01 | Thème `AppTheme.dark` câblé dans `MaterialApp` (mode foncé seul, `themeMode: ThemeMode.dark`). Aucune couleur hex en dur hors `theme.dart`. |
| DEC-FND-02 | DM Sans bundlé (family `DMSans`, pas `google_fonts`). Fallback police système non bloquant si `.ttf` absents (TODO asset). |
| DEC-FND-03 | `assets/images/` déclaré ; 2 logos fournis par l'utilisateur ; fallback `errorBuilder` côté écrans (TODO asset). |
| DEC-FND-04 | Splash natif via `flutter_native_splash` en **dev_dependency** (build-time pur, zéro runtime/réseau) ; fond `#16213C` ; commande `dart run flutter_native_splash:create`. Manuel = alternative non retenue. |
| DEC-FND-05 | `HydratedBloc.storage` initialisé dans `bootstrap.dart` **avant** `runApp` (signature `hydrated_bloc 11` vérifiée). Splash ne fait que mesurer la latence Drift. |
| DEC-FND-06 | Schéma `MoodEntries` préparé en lecture ; figé définitivement avec l'US « Noter mon humeur ». Journal = Drift only (DEC-001/002). |
| DEC-FND-07 | Routing minimal `pushReplacement` ; `flow_builder` non câblé en Phase 1 (réservé onboarding multi-étapes futur). |
| DEC-FND-08 | `OnboardingCubit` HydratedBloc clé `'onboarding'`, défaut `false` (aligne DEC-S-010). |
| DEC-FND-09 | `flutter_animate` AUTORISÉ et homogène (Splash + Accueil) — déjà au pubspec, donc pas une dépendance ajoutée ; lève l'ancienne contrainte « Flutter pur » du splash. a11y `disableAnimations` respecté partout. |

---

## 15. Points à challenger / confirmer (self-challenge)

1. **`proposition_a_valider`** : US-FND-01 à créer/valider par Erwin (critères AC ci-dessus = base).
2. **Incohérence codes d'émotion** : `MoodColors` = 7 clés (`happy/calm/dynamic/sad/angry/nervous/tired`) vs
   plan Accueil = 6 libellés (`happy/calm/neutral/sad/angry/anxious`). À **arbitrer** avec l'US « Noter mon
   humeur » avant de figer `mood_entries`/les libellés i18n. **Non bloquant** pour Fondations (code stocké libre).
3. **Version `flutter_native_splash`** : confirmer la dernière compatible Flutter `^3.41.0` à l'implémentation.
4. **Android 12+** : le splash natif Android 12 contraint la taille/forme de l'icône — vérifier le rendu réel
   du logo sur API 31+ après `:create`.
5. **3 flavors** : valider le splash natif sur `development`/`staging`/`production` (ressources natives partagées).
6. **`.ttf` & logos absents** : fournis par l'utilisateur ; fallback non bloquant en attendant (TODO assets).
7. **Helpers routing vs flow_builder** : confirmer qu'on n'introduit pas `flow_builder` maintenant (DEC-FND-07).

---

## 16. Plan de tests (préparation Step 5 — Kent)

Cas déduits (sources US-FND-01 + §) à présenter avant écriture :
- `LocaleCubit` : défaut `null` (système) ; `setLocale(fr)` → état `fr` ; round-trip `toJson/fromJson` (AC5).
- `OnboardingCubit` : défaut `false` ; `complete()` → `true` ; round-trip persistance (AC6).
- Drift `tipOfTheDay(d)` : déterministe (même `d` → même `tipKey`) ; seed ≥ 7 conseils (AC3).
- Drift `watchLastMoodToday()` : `null` si aucune entrée du jour ; dernière entrée du jour sinon ; entrée d'hier ignorée (AC4).
- `app.dart` (widget) : thème appliqué = `AppTheme.dark`, `themeMode: ThemeMode.dark` ; providers présents (AC1).
- `AppRouter` : `toHome`/`toOnboarding` font un `pushReplacement` (AC7) — test de navigation.
- (Non testable en unitaire) splash natif `flutter_native_splash` (AC8) → vérification manuelle build.

> Réutiliser **uniquement** les packages de test présents : `bloc_test`, `mocktail`, `flutter_test`.
> **Aucune** nouvelle dépendance de test. Pour Drift, base en mémoire (`NativeDatabase.memory()`).

---

## 17. Estimation

- Câblage thème + app.dart (providers, themeMode, locale) : ~2 h.
- bootstrap (storage + Drift open + deps) : ~2 h.
- Base Drift (2 tables + DAO + seed + codegen) : ~4 h.
- `LocaleCubit` + `OnboardingCubit` + routing + placeholders : ~3 h.
- pubspec (assets/fonts/dev_dep) + splash natif (config + `:create` + vérif flavors) : ~2,5 h.
- Tests Kent : ~3 h.
- **Total** : ~16,5 h.
</content>
</invoke>
