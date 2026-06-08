---
page: Accueil (Home)
route: /home (placeholder, routing custom non encore en place)
us: [US-HOME-01]
github: "#2"
shared_components: [AppTheme, AppColors, MoodColors, AppRadii, AppDatabase, LocaleCubit, AppRouter, PlaceholderScreen, BreathingHalo, FloatingParticles]
i18n_keys: [homeBrandName, homeGreeting, homeGreetingSubtitle, heroMoodQuestion, heroMoodInvite, heroLogMoodCta, heroSeeJournal, heroMoodTodayPrefix, heroMoodLoggedAt, homeToolBubble, homeToolDailyTip, homePauseCta, homeScreenTime, moodHappy, moodCalm, moodDynamic, moodSad, moodAngry, moodNervous, moodTired]
created: 2026-06-05
updated: 2026-06-05
tests: aidd_docs/tasks/accueil-home.tests.md
status: valide
depends_on: [foundations-bootstrap.md (US-FND-01)]
---

## ✅ Décisions de validation (2026-06-05) — FONT FOI (priment sur tout détail divergent ci-dessous)

- **Nommage FRANÇAIS** : Home → **Accueil**. Dossier `lib/accueil/`, classes `AccueilPage`/`AccueilView`/`AccueilBloc`/`AccueilState`/`AccueilEvent`, fichiers `accueil_*.dart`. Route `/accueil`. Widgets de domaine en français (ex. `HaloRespirant`, `ParticulesFlottantes`, `CarteHumeur`). Scaffolding (`AppTheme`/`AppDatabase`/`AppRouter`/`LocaleCubit`) reste anglais ; data layer en français (`observerDerniereHumeurDuJour()`, `conseilDuJour()`).
- **Émotions = 7 canoniques** (DEC-003) : `happy/calm/dynamic/sad/angry/nervous/tired`. Les clés `moodNeutral`/`moodAnxious` du corps sont **remplacées** par `moodDynamic`/`moodNervous`/`moodTired` (set complet : `moodHappy/moodCalm/moodDynamic/moodSad/moodAngry/moodNervous/moodTired`). Couleurs via `MoodColors.byKey`.
- **Logo header 40×40** : `assets/images/logo_digiharmony_square.png` (carré).
- **i18n V1** : `fr`+`en` réels, repli `en` (TODO) pour `el/it/ro/tr/es/mk`. Wordmark `DigiHarmony` non traduit.
- **Conseil du jour** : table Drift seedée placeholder (~7, fr+en), rotation déterministe par date (fournie par Fondations).
- Toutes les cibles de navigation = **placeholders** V1 ; pas de toolbar haute sur l'Accueil (DEC-003).

# Page Plan — Écran « Accueil » (Home)

> Plan auto-suffisant pour l'éditeur IA. Cible : `apps/digiharmony_app/`. App Flutter DIGIHARMONY,
> public mineur, Erasmus+, **SANS backend ni Firebase, ZÉRO collecte**. Persistance 100 % locale
> (Drift + HydratedBloc). Périmètre = **écran Accueil uniquement** (option A) : toutes les cibles
> de navigation non encore créées sont des **stubs/placeholders**.
>
> **DÉPENDANCE : `foundations-bootstrap.md` (US-FND-01), à implémenter EN PREMIER.** Le thème
> (`AppTheme.dark` câblé, `AppColors`/`MoodColors`/`AppRadii`), la base **Drift** (`AppDatabase`,
> tables `mood_entries`/`conseils`, DAO read-only, seed), l'init `HydratedBloc.storage`, le `LocaleCubit`,
> le routing/`PlaceholderScreen`/`AppRouter` et la **déclaration des assets/fonts** au pubspec sont **fournis
> par les Fondations** et **NE sont PAS recréés ici**. L'Accueil ne conserve que sa **couche de LECTURE** Drift
> (humeur du jour pour l'état A/B) et son UI/Bloc propres.

---

## 0. État du codebase au moment du plan (vérifié)

- Scaffold Very Good CLI brut : `App` (`lib/app/view/app.dart`) avec `home: const CounterPage()`, délégués i18n câblés.
- `lib/theme/theme.dart` **DÉJÀ CRÉÉ** : `AppColors`, `MoodColors`, `AppSpacing`, `AppRadii`, `AppTheme.dark`
  (Material 3, `fontFamily = 'DMSans'`). **Pas encore câblé** dans `MaterialApp` → **câblage = Fondations §1**.
- **Posé par Fondations (PAS par ce plan)** : base Drift (`AppDatabase`), wiring `HydratedBloc.storage`,
  `LocaleCubit`, routing custom + `PlaceholderScreen`, déclaration `assets:`/`fonts:` au pubspec.
- `assets/images/` et `assets/fonts/` existent mais **vides** (logos + `.ttf` fournis par l'utilisateur).
  `aidd_docs/tasks/_registry.md` **n'existe pas** (créé par Fondations §13).
- Dépendances présentes : `drift ^2.33.0` (+ `drift_dev`), `hydrated_bloc ^11.0.0`, `flutter_animate ^4.5.2`,
  `path_provider ^2.1.5`, `path ^1.9.1`, `sqlite3_flutter_libs`, `flow_builder ^0.1.0`, `bloc_test`/`mocktail` (dev).
- ARB existants : seule clé `counterAppBarTitle`. 8 langues (`en/fr/el/it/ro/tr/es/mk`), template `app_en.arb`.

**Conséquence** : ce plan **consomme** les fondations (thème + base Drift + Locale + routing déjà posés) et
n'ajoute que la **couche de LECTURE** « humeur du jour » (état A/B) et l'UI/Bloc Accueil, sans déborder sur
l'écran « Noter mon humeur » (écriture du journal hors périmètre).

---

## 1. Contexte & objectif de la page

- **But** : écran d'accueil quotidien. Accueille l'utilisateur, propose en un coup d'œil de noter son
  humeur (ou la rappelle si déjà notée), et offre des points d'entrée vers les outils (bulle, conseil,
  pause respiration, temps d'écran, réglages).
- **Accès** : écran racine post-Splash. Pas d'authentification (zéro compte, zéro collecte). Pas de rôles.
- **Route** : conceptuellement `/home`. Le routing custom n'existe pas encore → en V1, `App.home` pointe
  directement sur `HomePage`. La navigation vers les cibles se fait via `Navigator.push` vers des
  **placeholders** (voir §6).

---

## 2. Données affichées & sources

| Donnée | Source | Mode |
| --- | --- | --- |
| Humeur du jour (existe ? laquelle ? heure de la dernière entrée du jour) | **Drift** (`AppDatabase` fourni par Fondations), table `mood_entries`, via `watch()` | LECTURE seule (read-only) |
| Conseil du jour | **Drift**, table `conseils` (seedée par Fondations), rotation déterministe par date | LECTURE seule |
| Langue active | `LocaleCubit` **fourni par Fondations §7** (HydratedBloc) | — |

- **DEC-001/002 (memory bank)** : le journal d'humeur vit dans **Drift uniquement**, JAMAIS dans
  HydratedBloc. L'état A/B est **dérivé** de Drift via `watch()`, jamais dupliqué dans un état persistant léger.
- L'écran ne fait **aucune écriture** de journal. L'écriture appartient à l'écran « Noter mon humeur » (hors périmètre).

### 2.1 Schéma Drift — DÉFINI par Fondations ; Accueil consomme la LECTURE

> **La base Drift, les tables `MoodEntries`/`Conseils`, le seed et le DAO read-only sont créés par
> `foundations-bootstrap.md` §6.** Ce plan **ne recrée rien** : il **consomme** l'instance `AppDatabase`
> fournie via `RepositoryProvider` (Fondations §5/§6) et appelle ses requêtes de lecture.

Rappel (source = Fondations §6, non redéfini ici) :
- Table `MoodEntries` : `id` PK / `moodCode` TEXT / `valence` INT / `createdAt` DATETIME — **lecture seule** pour l'Accueil.
  > ⚠️ **Incohérence à arbitrer** (signalée dans Fondations §15.2) : `MoodColors` expose 7 clés
  > (`happy/calm/dynamic/sad/angry/nervous/tired`) alors que ce plan liste 6 libellés
  > (`happy/calm/neutral/sad/angry/anxious`). À figer avec l'US « Noter mon humeur ». Non bloquant pour l'Accueil (lecture).
- Table `Conseils` : `id` PK / `tipKey` TEXT — seedée (≥ 7 entrées) par Fondations.
- DAO consommé par l'Accueil :
  - `Stream<MoodEntryRow?> watchLastMoodToday()` : dernière entrée du jour (`[minuit, minuit+1j)`, tri `createdAt DESC LIMIT 1`, NULL si aucune).
  - `Future<ConseilRow> tipOfTheDay(DateTime day)` : conseil **déterministe** par date (§2.2).
- **L'Accueil n'écrit JAMAIS** `mood_entries` (écriture = écran « Noter mon humeur », hors périmètre).

> **Garde-fou build Android** (rappel, géré par Fondations) : `minify`/`shrinkResources` restent `false`.

### 2.2 Conseil du jour — rotation déterministe (Q3)

- Distinct de « Choisis ta bulle » (qui est un outil interactif, ici simple stub).
- Index déterministe : `index = joursDepuisEpoch % nombreDeConseils`, où
  `joursDepuisEpoch = DateTime(now.year, now.month, now.day).difference(DateTime(1970,1,1)).inDays`.
  → 1 conseil par jour, stable toute la journée, sans aléatoire, sans stockage d'état.
- Le **texte** affiché vient de l'ARB via la `tipKey` du conseil sélectionné (multilingue, repli `en`).

---

## 3. Thème (Q6) — FOURNI par Fondations ; Accueil consomme `AppColors`/`AppRadii`

> **Le thème central existe déjà** (`lib/theme/theme.dart`) et est **câblé par Fondations §1**
> (`theme/darkTheme: AppTheme.dark`, `themeMode: ThemeMode.dark`, mode foncé seul). Ce plan **ne crée
> AUCUN `app_theme.dart`** et **n'écrit AUCUNE couleur hex en dur** (DEC-FND-01). Il consomme les tokens.

Tokens consommés par l'Accueil (source `theme.dart`, ne pas redéclarer) :
- Fond écran : `AppColors.background` (`#1F2C49`) via `scaffoldBackgroundColor` du thème (déjà appliqué).
- Surfaces (cartes) : `AppColors.surface` (`#283A5E`) via `CardThemeData` du thème.
- Accent primaire (CTA, wordmark, icônes actives) : `AppColors.primary` (`#3FB8E6`).
- Accent or (highlights fins) : `AppColors.accentGold` (`#E0B24A`).
- Texte / texte atténué : `AppColors.text` (`#F2F6FB`) / `AppColors.textMuted` (`#A7B6CE`).
- Dégradé de marque (si halo/décor) : `AppColors.signatureGradient` (`#3FB8E6 → #A8D24E → #F0C84A`) — réservé marque.
- **Émotions** (emoji/pastille HeroCard état B) : `MoodColors.byKey[moodCode]` — **réservé au codage émotionnel**.
- Rayons : `AppRadii.button` (12) / `AppRadii.card` (24) + `buttonRadius`/`cardRadius`.
  > **Correction vs version précédente** : il n'existe **pas** d'échelle `sm/md/lg/xl` ni de `r10` dans `theme.dart`.
  > Les cartes/bulles utilisent `AppRadii.card` (24), les boutons `AppRadii.button` (12). Pour le logo header
  > (coins arrondis ~10), utiliser une valeur explicite locale au widget logo (cas décoratif), sans introduire
  > de couleur hex. Espacement = `AppSpacing` (4/8/16/24/32).
- Police **DM Sans** : déclarée au pubspec par **Fondations §2/§10** (family `DMSans` = `AppTheme.fontFamily`),
  fallback police système non bloquant si `.ttf` absents.
- **Câblage `app.dart`** : fait par **Fondations** (thème + providers + locale). Pour l'Accueil, il reste
  uniquement à pointer le `home` réel : remplacer le `HomePlaceholder` de Fondations par `home: const HomePage()`
  (et retirer `CounterPage`).

---

## 4. Structure visuelle (fidèle à la maquette validée — NE PAS réordonner)

`HomePage` → `Scaffold` (fond = `AppColors.background` via le thème, ne pas le surcharger en dur) → corps
scrollable (`SingleChildScrollView` ou `CustomScrollView`), avec **décor animé en fond** (Stack) :

> **Couleurs : aucun hex en dur (DEC-FND-01).** Toutes les teintes ci-dessous = `AppColors`/`MoodColors`/`Theme.of(context)`.

1. **Décor animé (fond, Stack arrière-plan)** :
   - `BreathingHalo` : halo respirant (scale/opacity en boucle, `flutter_animate` — DEC-FND-09) ; teintes = `AppColors.signatureGradient` / `AppColors.primary`.
   - `FloatingParticles` : 3 particules flottantes + icônes float (teintes `AppColors.primaryLight`/`accentGold`).
   - `flutter_animate` (déjà présent, autorisé DEC-FND-09). **a11y** : si `MediaQuery.disableAnimations == true`,
     rendre statique (pas de boucle) tout en gardant l'écran lisible.

2. **Header** (Row) :
   - Gauche : logo `assets/images/logo_digiharmony.png` (40×40, coins ~10) + wordmark
     **« DigiHarmony »** (`AppColors.primary`, **uppercase**, **NON traduit** → constante `homeBrandName`).
   - Droite : `IconButton` Réglages (icône `settings`) → push **placeholder Réglages** (§6).

3. **Greeting** (Column, animation slide-in) :
   - Titre « Bonjour 👋 » (26px) — **fixe**, pas de variation selon l'heure (Q4) → `homeGreeting`.
   - Sous-titre « Comment tu te sens aujourd'hui ? » → `homeGreetingSubtitle`.

4. **HeroCard** (Card arrondie `lg`/`xl`, 2 états pilotés par Drift — §5) :
   - **État A** (aucune entrée aujourd'hui) : icône `book-heart`, titre `heroMoodQuestion`,
     CTA principal « Noter mon humeur » (icône `plus-circle`, `heroLogMoodCta`) + lien
     « Voir mon journal » (`heroSeeJournal`).
   - **État B** (humeur déjà notée aujourd'hui) : emoji de l'humeur + `heroMoodTodayPrefix`
     (« Aujourd'hui tu te sens ») + **libellé de l'humeur** + `heroMoodLoggedAt` (« Humeur notée à {heure} »,
     ICU, heure = heure de la **dernière** entrée du jour) + CTA « Voir mon journal » (`heroSeeJournal`).

5. **Grille 2 tuiles** (Row de 2 cards égales) :
   - « Choisis ta bulle » (icône `sparkles`, `homeToolBubble`) → placeholder bulle (§6).
   - « Conseil du jour » (icône `lightbulb`, `homeToolDailyTip`) → affiche/ouvre le conseil du jour (§2.2 ; V1 = placeholder/affichage, voir §6).

6. **Pilule « Faire une pause »** (`homePauseCta`, icône `leaf`, animation *breathing*) → placeholder pause (§6).
   - a11y : respiration désactivée si `disableAnimations`.

7. **Lien tertiaire « Mon temps d'écran »** (`homeScreenTime`, icône `timer`) en bas → placeholder temps d'écran (§6).

> Les icônes `book-heart`, `plus-circle`, `sparkles`, `lightbulb`, `leaf`, `timer`, `settings`
> sont à mapper sur des `Icons` Material équivalentes (ex. `Icons.menu_book`/`Icons.favorite`,
> `Icons.add_circle_outline`, `Icons.auto_awesome`, `Icons.lightbulb_outline`, `Icons.eco`,
> `Icons.timer_outlined`, `Icons.settings`). Pas de dépendance d'icônes externe (zéro SDK superflu).

---

## 5. États de la page

| État | Déclencheur | Rendu |
| --- | --- | --- |
| **Chargement** | Première frame avant le premier event du stream Drift | HeroCard en skeleton/placeholder neutre (pas de spinner agressif, public mineur) ; reste de l'écran rendu |
| **Nominal A** | `watchLastMoodToday()` émet `null` (aucune entrée du jour) | HeroCard **État A** |
| **Nominal B** | `watchLastMoodToday()` émet une entrée | HeroCard **État B** (emoji + libellé + heure dernière entrée) |
| **Erreur Drift** | Exception ouverture/lecture base | Fallback gracieux = afficher **État A** (invite à noter) + log silencieux (zéro collecte, pas de remontée réseau). Ne jamais crasher l'écran. |

- Transition A → B **réactive** : dès qu'une entrée du jour apparaît dans Drift (écrite par le futur
  écran « Noter mon humeur »), `watch()` re-émet et la HeroCard bascule sans rechargement manuel.
- Pas d'« empty state » global : l'écran a toujours du contenu (greeting + outils).

---

## 6. Actions & navigation (V1 = STUBS / placeholders — Q1)

> Toutes les cibles sont des **placeholders** en V1. Le plan **définit les points d'entrée** mais
> chaque cible mène à un écran neutre. Le widget générique `PlaceholderScreen({required String titre})`
> (Scaffold + titre + « Bientôt disponible ») est **fourni par Fondations §8/§11** — l'Accueil le **réutilise**
> pour ses 7 destinations (ne pas le recréer).

| Élément | Geste | Cible (V1) | Feedback |
| --- | --- | --- | --- |
| Bouton Réglages (header) | tap | `PlaceholderScreen(Réglages)` | push standard |
| CTA « Noter mon humeur » (État A) | tap | `PlaceholderScreen(Noter mon humeur)` | push ; au retour, le stream Drift pilotera A/B (pas de refresh manuel) |
| Lien « Voir mon journal » (A et B) | tap | `PlaceholderScreen(Mon journal)` | push |
| Tuile « Choisis ta bulle » | tap | `PlaceholderScreen(Choisis ta bulle)` | push |
| Tuile « Conseil du jour » | tap | `PlaceholderScreen(Conseil du jour)` (le **texte** du conseil du jour est déjà calculé/affichable côté Accueil ; V1 = affichage dans la tuile et/ou ouverture placeholder) | push |
| Pilule « Faire une pause » | tap | `PlaceholderScreen(Faire une pause)` | push |
| Lien « Mon temps d'écran » | tap | `PlaceholderScreen(Mon temps d'écran)` | push |

- Tous les gestes déclenchent un `HapticFeedback.lightImpact()` (vibration sans permission `VIBRATE`,
  conforme contrainte projet). Pas de SDK tiers.
- Aucune cible ne nécessite de paramètre en V1 (les placeholders sont sans état).

---

## 7. Gestion d'état (BLoC)

**Pattern** : `flutter_bloc`, lints `bloc_lint`. Le journal restant dans Drift, l'état Home est mince.

- **`HomeBloc`** (`lib/home/bloc/home_bloc.dart`) :
  - **Events** :
    - `HomeStarted` (restartable) → abonne `watchLastMoodToday()` + résout `tipOfTheDay(now)`.
  - **State** (sealed/`equatable`) — recommandé en variantes :
    - `HomeLoading`
    - `HomeReady({ MoodTodayView? humeurDuJour, DailyTipView conseil })`
      - `humeurDuJour == null` → rendu État A ; non-null → rendu État B.
    - `HomeError` → l'UI rend l'État A en fallback (§5).
  - L'event écoute le stream Drift via `emit.forEach` / `await for` (réactif). Heure formatée côté UI
    (locale-aware) à partir du `createdAt` de la dernière entrée.
- **ViewModels légers** (pas de logique métier dans la vue) :
  - `MoodTodayView { String moodCode; String emoji; DateTime loggedAt; }` (le **libellé** se résout via
    i18n d'après `moodCode` ; l'**emoji** est mappé en dur depuis `moodCode`).
  - `DailyTipView { String tipKey; }` (texte résolu via i18n).
- **LocaleCubit** : **fourni par Fondations §7** (HydratedBloc, 8 langues, repli `en`), déjà câblé au-dessus
  de `MaterialApp`. L'Accueil le **consomme** (i18n live) ; ne **pas** y mettre l'humeur (DEC-001/002).
- Pas de débounce nécessaire (pas de saisie sur cet écran).

---

## 8. i18n (clés ARB — 8 langues, repli `en`)

> Ajouter dans **les 8** fichiers `lib/l10n/arb/app_<lang>.arb`, template = `app_en.arb`. Puis `flutter gen-l10n`.
> `homeBrandName` = constante NON traduite (même valeur « DigiHarmony » partout, déclarée pour cohérence d'accès).

| Clé | FR (référence) | Notes |
| --- | --- | --- |
| `homeBrandName` | « DigiHarmony » | constante, identique dans toutes les langues |
| `homeGreeting` | « Bonjour 👋 » | fixe (Q4) |
| `homeGreetingSubtitle` | « Comment tu te sens aujourd'hui ? » | |
| `heroMoodQuestion` | « Comment te sens-tu aujourd'hui ? » | titre HeroCard État A |
| `heroMoodInvite` | (invite secondaire État A, ex. « Prends un instant pour toi. ») | |
| `heroLogMoodCta` | « Noter mon humeur » | CTA État A |
| `heroSeeJournal` | « Voir mon journal » | lien A et B |
| `heroMoodTodayPrefix` | « Aujourd'hui tu te sens » | État B |
| `heroMoodLoggedAt` | « Humeur notée à {heure} » | **ICU** placeholder `heure` (String formatée locale) |
| `homeToolBubble` | « Choisis ta bulle » | |
| `homeToolDailyTip` | « Conseil du jour » | |
| `homePauseCta` | « Faire une pause » | |
| `homeScreenTime` | « Mon temps d'écran » | |
| `moodHappy` / `moodCalm` / `moodNeutral` / `moodSad` / `moodAngry` / `moodAnxious` | « Heureux·se » / « Calme » / « Neutre » / « Triste » / « En colère » / « Anxieux·se » | libellés d'humeur, mappés depuis `moodCode` |

- `heroMoodLoggedAt` : déclaration ICU avec `placeholders.heure` (type `String`).
- Conseils : si l'on stocke `tipKey` en base, prévoir les clés correspondantes (`tipDay01..tipDay07`)
  dans les ARB. Alternative plus simple acceptable en V1 : un seul jeu de conseils traduits côté ARB,
  la base ne stockant que l'index/clé.

---

## 9. Fichiers à créer / modifier

> **Fourni par Fondations (NE PAS créer ici)** : `lib/theme/theme.dart` (déjà existant, câblé par Fondations),
> `lib/data/local/app_database.dart` (+ `.g.dart`), `lib/locale/locale_cubit.dart`,
> `lib/common/placeholder_screen.dart`, routing/`AppRouter`, sections pubspec `assets:`/`fonts:`,
> assets `logo_digiharmony.png`/`logo_eu_funding.png` + `.ttf` DM Sans, init `bootstrap.dart`.

**Créer (propre à l'Accueil)** :
- `lib/home/view/home_page.dart` (`HomePage` — fournit `HomeBloc`)
- `lib/home/view/home_view.dart` (corps + HeroCard A/B + grille + pilule + lien)
- `lib/home/bloc/home_bloc.dart`, `home_event.dart`, `home_state.dart`
- `lib/home/widgets/hero_card.dart`, `mood_tile.dart`, `pause_pill.dart`
- `lib/app/widgets/breathing_halo.dart`, `floating_particles.dart` (décor a11y-aware) — partageables
  > Si Fondations ou le plan Splash livrent déjà un halo réutilisable, **réutiliser** plutôt que dupliquer (coordination registry).

**Modifier** :
- `lib/app/view/app.dart` : **uniquement** pointer `home: const HomePage()` (remplace le `HomePlaceholder` de
  Fondations + retire `CounterPage`). Thème/providers/locale = déjà posés par Fondations — ne pas dupliquer.
- 8 × `lib/l10n/arb/app_<lang>.arb` : ajout des clés (§8), puis `flutter gen-l10n`.
- `aidd_docs/tasks/_registry.md` : entrée Accueil (le fichier est créé par Fondations §13).

> **N'ajouter AUCUNE dépendance** (toutes présentes). **Codegen Drift** (`build_runner`) = déjà lancé par
> Fondations ; le relancer si le schéma change. Lancer **avant** `flutter test`.

---

## 10. Conformité contraintes projet (garde-fous)

- ✅ Zéro backend / Firebase / SDK réseau / analytics / Crashlytics / permission ajoutée.
- ✅ Journal dans Drift uniquement, dérivé via `watch()` (DEC-001/002) ; HydratedBloc réservé à l'état léger (langue).
- ✅ Vibration via `HapticFeedback` (pas de permission `VIBRATE`).
- ✅ a11y : `MediaQuery.disableAnimations` respecté (boucles désactivées, écran lisible).
- ✅ Android : `minify`/`shrinkResources` restent `false` (Drift/sqlite3).
- ✅ Monorepo Melos 7 / pub workspaces : ne pas figer `test ^x` ; commandes lancées depuis `apps/digiharmony_app/`.
- ✅ 8 langues, repli `en`, bascule live via `LocaleCubit`.

---

## 11. User Stories (dépendance — À CRÉER)

> **Aucune US n'existe pour l'écran Accueil.** Seule **US #1 (Splash)** existe à ce jour.

- **Dépendance** : créer **US-HOME-01 « Écran d'accueil »** (milestone **Phase 1**) avant développement,
  via l'agent PO (Erwin), couvrant : header+greeting, HeroCard états A/B pilotés par Drift, grille 2 tuiles,
  pilule pause, lien temps d'écran, navigation vers placeholders, a11y animations, i18n 8 langues.
- Critères d'acceptation à inscrire dans l'US (serviront de source aux tests Kent — Step 5) :
  - AC1 : sans entrée d'humeur du jour → HeroCard **État A** (CTA « Noter mon humeur » + lien journal).
  - AC2 : avec ≥1 entrée datée d'aujourd'hui → HeroCard **État B** (emoji + libellé + heure de la **dernière** entrée).
  - AC3 : ajout d'une entrée du jour → bascule A→B **réactive** (sans refresh manuel).
  - AC4 : conseil du jour **déterministe** (même conseil toute la journée, change le lendemain).
  - AC5 : chaque élément interactif navigue vers son placeholder + `HapticFeedback`.
  - AC6 : `disableAnimations == true` → aucune animation en boucle, écran lisible.
  - AC7 : erreur Drift → fallback État A, pas de crash.
  - AC8 : libellés/CTA traduits dans les 8 langues, wordmark « DigiHarmony » non traduit.

---

## 12. Registry & coordination

- `aidd_docs/tasks/_registry.md` est **créé par Fondations §13** (avec les entrées Fondations/Splash/Accueil).
  Vérifier que l'entrée Accueil est bien présente :
  `- Accueil (Home): /home (placeholder) — US-HOME-01 — accueil-home.md`
- Composants **consommés** (fournis par Fondations) : `AppTheme`/`AppColors`/`MoodColors`/`AppRadii`,
  `AppDatabase`, `LocaleCubit`, `PlaceholderScreen`, `AppRouter`. Composants **introduits ici** et réutilisables :
  `BreathingHalo`, `FloatingParticles`, `HeroCard`/`MoodTile`/`PausePill`. Les futurs écrans réutiliseront la
  base Drift et le thème — ne pas les dupliquer.

---

## 13. Décisions tranchées (rappel, ne pas re-poser)

- DEC-HOME-01 (Q1) : V1 = navigation vers **placeholders** pour toutes les cibles.
- DEC-HOME-02 (Q2) : État B dès ≥1 entrée du jour ; heure = **dernière** entrée du jour ; dérivé Drift `watch()`.
- DEC-HOME-03 (Q3) : « Conseil du jour » ≠ « Choisis ta bulle » ; table Drift `conseils` seedée ; rotation déterministe par date.
- DEC-HOME-04 (Q4) : greeting **fixe** « Bonjour » (pas de variation horaire).
- DEC-HOME-05 (Q5) : périmètre **écran Accueil seul** + couche **lecture** Drift « humeur du jour » read-only.
- DEC-HOME-06 (Q6) : thème central **déjà existant** (`lib/theme/theme.dart`), **câblé par Fondations** ;
  l'Accueil consomme `AppColors`/`AppRadii` ; Splash garde `AppColors.backgroundDeep` (`#16213C`).
- DEC-HOME-07 (a11y) : `MediaQuery.disableAnimations` désactive les boucles d'animation.

---

## 14. Auto-challenge (points signalés)

- ✅ **Fondations extraites** : base Drift, `HydratedBloc.storage`, `LocaleCubit`, thème, routing, placeholders,
  assets et splash natif sont désormais traités par le plan dédié `foundations-bootstrap.md` (US-FND-01),
  **implémenté EN PREMIER**. Ce plan ne les recrée plus — il les **consomme** (plus de double travail).
- ⚠️ **Police DM Sans / logos** : vendorisés par Fondations ; fallback police système + `errorBuilder` non bloquants
  tant que les fichiers ne sont pas fournis (Fondations DEC-FND-02/03).
- ⚠️ **Incohérence codes émotion** (6 libellés Accueil vs 7 `MoodColors`) : à arbitrer avec l'US « Noter mon humeur »
  (signalée Fondations §15.2). Non bloquant pour l'Accueil (lecture seule).
- ⚠️ **Seed conseils** : V1 minimal (≥7), local (Remote Config interdit — zéro réseau).
- 🔁 Composants réutilisés (thème, DB, `LocaleCubit`, `PlaceholderScreen`, `AppRouter`) viennent de Fondations ;
  halo/particules à mutualiser avec Splash si possible (coordination registry).
