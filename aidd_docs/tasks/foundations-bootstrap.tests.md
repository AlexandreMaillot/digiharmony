---
plan: aidd_docs/tasks/foundations-bootstrap.md
page: Fondations / Bootstrap (infrastructure transverse)
us: [US-FND-01]
github: ""
milestone: Phase 1
type: plan_de_tests_previsionnel
created: 2026-06-05
status: previsionnel_aucune_impl
---

# Plan de tests prévisionnel — Fondations / Bootstrap (US-FND-01)

> **Document de planification TDD. AUCUN code de test exécutable ici** (l'implémentation n'existe pas
> encore — stade scaffold VGV). Ce fichier liste les **comportements observables** à valider en
> Red → Green → Refactor lors de l'implémentation à venir.
>
> Source des cas : critères d'acceptation **US-FND-01** (foundations-bootstrap.md §12, AC1→AC8) +
> décisions DEC-FND-01→09 + DEC-001/002/003.

## Conventions & contraintes de test (à respecter à l'implémentation)

- **Packages de test autorisés UNIQUEMENT** : `flutter_test`, `bloc_test`, `mocktail` (déjà présents).
  **Aucune** nouvelle dépendance de test.
- **Package member** : ne JAMAIS figer `test ^x` dans le pubspec membre (conflit `test_api` avec
  `flutter_test`). Si une contrainte `test` est requise, utiliser `test: any`.
- **Drift en test** : base **en mémoire** via `NativeDatabase.memory()` (aucun fichier disque, pas de
  `path_provider` réel). Lancer `dart run build_runner build --delete-conflicting-outputs` **avant** `flutter test`.
- **HydratedBloc en test** : `HydratedBloc.storage` doit être mocké (mocktail) et affecté en `setUp`,
  remis à `null`/restauré en `tearDown`. Pas de stockage disque réel.
- **Lints** : `very_good_analysis` + `bloc_lint` doivent passer sur les fichiers de test.
- **Zéro collecte** : aucun test ne doit introduire de mock réseau/HTTP/analytics (rien à mocker — il n'y a aucun SDK réseau).
- **Commandes** : `flutter test` lancé depuis `apps/digiharmony_app/`.

---

## 1. Tests unitaires — `LocaleCubit` (HydratedCubit, AC5)

Fichier prévu : `test/locale/locale_cubit_test.dart`. Outils : `bloc_test`, `mocktail` (mock `Storage`).

| # | Given | When | Then |
| --- | --- | --- | --- |
| LC-1 | storage vide, `LocaleCubit` neuf | construction | état initial = `null` (suit la langue système) — DEC-FND / défaut `null` |
| LC-2 | `LocaleCubit` neuf | `setLocale(Locale('fr'))` | émet état `Locale('fr')` |
| LC-3 | `LocaleCubit` avec état `fr` | `useSystem()` | émet état `null` |
| LC-4 | un état `Locale('el')` | sérialisation `toJson` | produit un map contenant `languageCode == 'el'` |
| LC-5 | un `toJson` produit par LC-4 | désérialisation `fromJson` | restitue `Locale('el')` (round-trip stable) |
| LC-6 | storage pré-rempli avec `{languageCode: 'it'}` | construction du cubit (hydratation) | état initial = `Locale('it')` (persistance après redémarrage simulé) |
| LC-7 | une langue **non** supportée (ex. `de`) passée à `fromJson` | hydratation | repli sûr (état `null` ou `en`) — **jamais** d'exception ; valider le repli `en` (DEC-002) |
| LC-8 | les 8 langues `en/fr/el/it/ro/tr/es/mk` | `setLocale` de chacune | chaque langue est acceptée (aucune rejetée) |

> Note Red→Green : commencer par LC-1 (état initial `null`), puis LC-2, puis le round-trip LC-4/LC-5,
> puis l'hydratation LC-6, enfin le repli LC-7.

---

## 2. Tests unitaires — `OnboardingCubit` (HydratedCubit<bool>, AC6)

Fichier prévu : `test/onboarding/onboarding_cubit_test.dart`. Outils : `bloc_test`, `mocktail`.

| # | Given | When | Then |
| --- | --- | --- | --- |
| OB-1 | storage vide | construction | état initial = `false` (`isOnboardingCompleted == false`) — DEC-FND-08 |
| OB-2 | état `false` | `complete()` | émet `true` |
| OB-3 | état `true` | `toJson`/`fromJson` round-trip | restitue `true` (persistance) |
| OB-4 | storage pré-rempli `true` sous clé `'onboarding'` | construction | état initial = `true` (persiste après redémarrage simulé) |
| OB-5 | cubit hydraté | vérifier la **clé** HydratedBloc | la clé de stockage est bien `'onboarding'` (DEC-FND-08) |

---

## 3. Tests unitaires — Drift `AppDatabase` (AC3, AC4)

Fichier prévu : `test/data/local/app_database_test.dart`. Base **en mémoire** (`NativeDatabase.memory()`),
nouvelle instance par test, `tearDown` ferme la connexion.

### 3.1 Seed + rotation déterministe des conseils (`tipOfTheDay`, AC3)

| # | Given | When | Then |
| --- | --- | --- | --- |
| TIP-1 | base fraîche (onCreate exécuté) | compter la table `conseils` | ≥ 7 entrées seedées (`tipDay01..tipDay07`) |
| TIP-2 | base seedée | `tipOfTheDay(DateTime(2026,6,5))` appelé deux fois | **même** `tipKey` les deux fois (déterminisme intra-appel) |
| TIP-3 | base seedée | `tipOfTheDay(d)` pour un `d` donné | `tipKey` == conseil d'index `joursDepuisEpoch % n`, avec `joursDepuisEpoch = DateTime(d.year,d.month,d.day).difference(DateTime(1970,1,1)).inDays` |
| TIP-4 | base seedée | `tipOfTheDay(d)` vs `tipOfTheDay(d + 1 jour)` | conseils **différents** si `n > 1` (rotation au changement de jour) |
| TIP-5 | base seedée | `tipOfTheDay(d)` vs `tipOfTheDay(d + n jours)` (n = nb conseils) | **même** conseil (cycle modulo n) |
| TIP-6 | deux `DateTime` du même jour à heures différentes (00:01 et 23:59) | `tipOfTheDay` sur chacun | **même** conseil (stable toute la journée — composante horaire ignorée) |
| TIP-7 | seed déjà présent | ré-ouverture de la base / onCreate idempotent | pas de doublon de seed (idempotence) |

### 3.2 Lecture humeur du jour (`watchLastMoodToday`, AC4)

> Pour ces tests, l'écriture dans `mood_entries` est faite **directement par le test** (insert technique),
> car l'app ne fournit pas d'API d'écriture (hors périmètre). Stream observé via `bloc_test`/`expectLater`.

| # | Given | When | Then |
| --- | --- | --- | --- |
| MOOD-1 | base vide | `watchLastMoodToday()` (1re émission) | émet `null` (aucune entrée du jour) |
| MOOD-2 | 1 entrée `createdAt` = aujourd'hui | `watchLastMoodToday()` | émet cette entrée (non null) |
| MOOD-3 | 1 entrée `createdAt` = **hier** uniquement | `watchLastMoodToday()` | émet `null` (entrée d'hier ignorée) |
| MOOD-4 | 2 entrées aujourd'hui à 09:00 et 18:00 | `watchLastMoodToday()` | émet l'entrée de **18:00** (tri `createdAt DESC LIMIT 1` = dernière) |
| MOOD-5 | base vide puis insertion d'une entrée du jour après abonnement | observer le stream | 1re émission `null`, puis ré-émission avec la nouvelle entrée (réactivité `watch()` — DEC-001) |
| MOOD-6 | entrée à 23:59:59 hier et 00:00:01 aujourd'hui | `watchLastMoodToday()` | émet uniquement celle d'aujourd'hui (bornes `[minuit, minuit+1j)` correctes) |

---

## 4. Tests de widget — câblage thème & providers dans `app.dart` (AC1)

Fichier prévu : `test/app/view/app_test.dart`. Outils : `flutter_test` (+ `bloc_test`/`mocktail` pour stubs).

| # | Given | When | Then |
| --- | --- | --- | --- |
| APP-1 | `App` monté (storage mocké) | pump | le `MaterialApp` a `theme == AppTheme.dark` et `darkTheme == AppTheme.dark` |
| APP-2 | `App` monté | pump | `MaterialApp.themeMode == ThemeMode.dark` (mode foncé seul — DEC-003/DEC-FND-01) |
| APP-3 | `App` monté | inspection de l'arbre | `RepositoryProvider<AppDatabase>` accessible sous `MaterialApp` |
| APP-4 | `App` monté | inspection de l'arbre | `LocaleCubit` et `OnboardingCubit` fournis au-dessus de `MaterialApp` |
| APP-5 | `LocaleCubit` à `Locale('fr')` | pump | `MaterialApp.locale == Locale('fr')` (bascule live câblée) |
| APP-6 | délégués i18n | pump | `localizationsDelegates` inclut `AppLocalizations.delegate` ; `supportedLocales` = 8 langues |
| APP-7 | n'importe quel rendu | scan statique/manuel | **aucune couleur hex en dur** hors `theme.dart` (vérification par revue + grep en CI ; pas un test runtime strict, mais consigne DEC-FND-01) |

> APP-7 n'est pas un assert runtime ; le noter comme garde-fou de revue (grep `0xFF`/`Color(0x` hors `lib/theme/`).

---

## 5. Tests unitaires — `AppRouter` helpers (AC7)

Fichier prévu : `test/app/routing/app_router_test.dart`. Outils : `flutter_test` (NavigatorObserver mock via `mocktail`).

| # | Given | When | Then |
| --- | --- | --- | --- |
| RT-1 | un `Navigator` monté avec un écran initial + observer | `AppRouter.toHome(context)` | une route est **remplacée** (`didReplace` observé) — `pushReplacement`, pas de retour possible |
| RT-2 | idem | `AppRouter.toOnboarding(context)` | `pushReplacement` vers la cible Onboarding |
| RT-3 | après `toHome` | tenter `Navigator.pop` | l'écran source (splash) n'est **pas** réaffiché (pile remplacée) |
| RT-4 | helper `toHome` | inspection cible | route vers `HomePlaceholder` tant qu'Accueil non livré, puis `HomePage` une fois livré (point de bascule documenté) |

---

## 6. Tests de widget — placeholders

Fichier prévu : `test/common/placeholder_screen_test.dart`.

| # | Given | When | Then |
| --- | --- | --- | --- |
| PH-1 | `PlaceholderScreen(titre: 'X')` | pump | affiche le titre `'X'` et un message « Bientôt disponible » (ou clé i18n équivalente) |
| PH-2 | `OnboardingPlaceholder` | pump | rend un `Scaffold` neutre sans crash |
| PH-3 | `HomePlaceholder` | pump | rend un `Scaffold` neutre sans crash |
| PH-4 | n'importe quel placeholder | pump | fond conforme au thème (`AppColors.background`), aucun hex en dur |

---

## 7. Tests d'intégration légers — séquence bootstrap (AC2, AC8)

Fichier prévu : `test/bootstrap_test.dart` (intégration légère, sans device réel).

| # | Given | When | Then |
| --- | --- | --- | --- |
| BOOT-1 | environnement de test (binding initialisé, storage mockable) | exécuter `bootstrap(builder)` | `HydratedBloc.storage` est **non null** **avant** que `builder()`/`runApp` ne soit appelé (ordre AC2 / DEC-FND-05) |
| BOOT-2 | bootstrap exécuté | construire un `HydratedCubit` immédiatement après | **aucune** exception (storage prêt) |
| BOOT-3 | bootstrap exécuté | inspecter | `Bloc.observer` est un `AppBlocObserver` (déjà en place, non régressé) |
| BOOT-4 | bootstrap exécuté | inspecter | une instance unique `AppDatabase` est créée et fournie (pas de double ouverture) |
| BOOT-5 | `FlutterError.onError` | déclencher une erreur de framework | est routée vers le handler bootstrap (non régressé) |

> AC8 (`flutter_native_splash` génère un splash `#16213C` + logo, anti-flash blanc) est **build-time**
> et **non testable en unitaire** → **vérification manuelle** sur les 3 flavors (development/staging/production),
> Android 12+ inclus. À consigner comme checklist manuelle, pas comme test automatisé.

---

## 8. Récapitulatif couverture US-FND-01

| AC | Couvert par |
| --- | --- |
| AC1 (thème foncé appliqué, pas de hex en dur) | APP-1, APP-2, APP-7 (revue) |
| AC2 (storage init avant cubits hydratés) | BOOT-1, BOOT-2 |
| AC3 (Drift ouvre, `tipOfTheDay` déterministe, seed ≥ 7) | TIP-1→TIP-7 |
| AC4 (`watchLastMoodToday` null/dernière) | MOOD-1→MOOD-6 |
| AC5 (Locale live + persistance + repli) | LC-1→LC-8, APP-5 |
| AC6 (`OnboardingCubit` défaut false/complete/persiste) | OB-1→OB-5 |
| AC7 (routing `pushReplacement`) | RT-1→RT-4 |
| AC8 (splash natif) | **manuel** (non automatisable) |

## 9. Points à arbitrer avant écriture (self-challenge)

1. **Codes émotion 6 vs 7** (`MoodColors` 7 clés vs Accueil 6 libellés) : non bloquant pour Fondations
   (le code est stocké libre). MOOD-* utilisent des codes arbitraires, pas la liste figée. À aligner avec l'US « Noter mon humeur ».
2. **Repli langue (LC-7)** : confirmer le comportement attendu pour une langue non supportée (`null` système vs `en` forcé). DEC-002 = repli `en`.
3. **Mock HydratedBloc.storage** : choisir entre `MockStorage` mocktail global et fake en mémoire — rester cohérent sur tous les fichiers.
4. **TIP-4** suppose `n > 1` ; garantir que le seed contient ≥ 7 conseils distincts pour que la rotation soit observable.
