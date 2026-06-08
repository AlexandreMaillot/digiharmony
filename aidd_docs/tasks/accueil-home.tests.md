---
plan: aidd_docs/tasks/accueil-home.md
page: Accueil (Home)
route: /home (placeholder)
us: [US-HOME-01]
github: "#2"
milestone: Phase 1
type: plan_de_tests_previsionnel
depends_on: [foundations-bootstrap.tests.md]
created: 2026-06-05
status: previsionnel_aucune_impl
---

# Plan de tests prévisionnel — Accueil / Home (US-HOME-01, GitHub #2)

> **Document de planification TDD. AUCUN code de test exécutable ici** (implémentation inexistante).
> Liste les **comportements observables** à valider en Red → Green → Refactor.
>
> Source des cas : critères d'acceptation **US-HOME-01** (accueil-home.md §11, AC1→AC8) +
> gestion d'état `HomeBloc` (§7) + états A/B (§5) + DEC-HOME-01→07 + DEC-001/002.
>
> **Périmètre testé ici** : `HomeBloc` (dérivation A/B depuis Drift via `watch()`, conseil du jour),
> `HomePage`/`HomeView` (rendu, HeroCard A/B, navigation placeholders, haptique, reduced motion),
> `HeroCard`/`MoodTile`/`PausePill`, décor `BreathingHalo`/`FloatingParticles`. Le **socle** (Drift,
> thème, `LocaleCubit`, `PlaceholderScreen`, `AppRouter`) est testé par **foundations-bootstrap.tests.md**.
> La **lecture** Drift (`watchLastMoodToday`/`tipOfTheDay`) est testée côté Fondations (MOOD-*/TIP-*) ;
> ici on teste la **dérivation A/B** par le Bloc, pas la requête elle-même.

## Conventions & contraintes de test

- **Packages autorisés UNIQUEMENT** : `flutter_test`, `bloc_test`, `mocktail`. Aucune nouvelle dépendance.
- **Package member** : `test: any` si nécessaire (jamais `test ^x` — conflit `test_api`).
- **`AppDatabase`** : mocké via `mocktail`. `watchLastMoodToday()` renvoie un `StreamController` contrôlé par le test
  (émettre `null`, une entrée, puis une autre pour tester la réactivité). `tipOfTheDay(now)` renvoie un `Future` mocké.
- **`HapticFeedback`** : intercepté via le mock du canal de plateforme `SystemChannels.platform`
  (`TestDefaultBinaryMessenger.setMockMethodCallHandler`) pour vérifier l'appel `HapticFeedback.vibrate`/`lightImpact`.
- **i18n** : pump avec `AppLocalizations` et `Locale` ciblée pour tester les libellés/repli.
- **reduced motion** : `MediaQuery(data: MediaQueryData(disableAnimations: true), ...)`.
- **`watch()` réactif** : ne jamais dupliquer le journal dans HydratedBloc (DEC-001/002) — vérifier que l'état A/B
  est **dérivé** du stream, pas stocké en HydratedBloc.
- Lints `very_good_analysis` + `bloc_lint`.

---

## 1. Tests unitaires — `HomeBloc` (dérivation état A/B + conseil, AC1→AC4, AC7)

Fichier prévu : `test/home/bloc/home_bloc_test.dart`. Outils : `bloc_test`, `mocktail`.

| # | Given | When | Then |
| --- | --- | --- | --- |
| HB-1 | bloc neuf | construction | état initial = `HomeLoading` |
| HB-2 | `watchLastMoodToday()` émet `null`, `tipOfTheDay` résout | `add(HomeStarted)` | émet `HomeReady(humeurDuJour: null, conseil: ...)` → rendu **État A** (AC1) |
| HB-3 | `watchLastMoodToday()` émet une entrée du jour | `add(HomeStarted)` | émet `HomeReady(humeurDuJour: MoodTodayView(...), ...)` → **État B** (AC2) |
| HB-4 | stream émet `null` **puis** une entrée (insertion du jour) | abonnement actif | enchaîne `HomeReady(null)` → `HomeReady(non-null)` → bascule A→B **réactive** sans nouvel event (AC3, `watch()`) |
| HB-5 | entrée du jour avec `moodCode` + `createdAt` | mapping | `MoodTodayView` porte le `moodCode`, l'**emoji** mappé en dur, et `loggedAt == createdAt` (dernière entrée) |
| HB-6 | `tipOfTheDay(now)` résout `tipKey='tipDay03'` | `HomeStarted` | `HomeReady.conseil == DailyTipView(tipKey: 'tipDay03')` (AC4 — déterminisme délégué à Drift/Fondations) |
| HB-7 | `watchLastMoodToday()`/`tipOfTheDay` **lève** une exception | `HomeStarted` | émet `HomeError` (l'UI rendra État A en fallback) — AC7 |
| HB-8 | `HomeStarted` restartable | `add(HomeStarted)` deux fois | le 2e abonnement remplace le 1er (pas de double abonnement au stream) |
| HB-9 | aucune écriture | tout le cycle de vie | le `HomeBloc` n'écrit **jamais** dans `mood_entries` (lecture seule — DEC-HOME-05/DEC-001) |

> Red→Green : HB-1 (loading), HB-2 (État A), HB-3 (État B), puis la réactivité HB-4, le mapping HB-5/HB-6,
> et enfin l'erreur HB-7.

---

## 2. Tests de widget — `HomeView` rendu & états A/B (AC1, AC2, AC8)

Fichier prévu : `test/home/view/home_view_test.dart`. `HomeBloc` mocké (`mocktail`) pour fixer l'état.

| # | Given | When | Then |
| --- | --- | --- | --- |
| HV-1 | état `HomeLoading` | pump | HeroCard en **skeleton/placeholder neutre** (pas de spinner agressif) ; reste de l'écran rendu (§5) |
| HV-2 | état `HomeReady(null)` | pump | HeroCard **État A** : titre `heroMoodQuestion`, CTA `heroLogMoodCta` (« Noter mon humeur »), lien `heroSeeJournal` |
| HV-3 | état `HomeReady(non-null)` | pump | HeroCard **État B** : emoji + `heroMoodTodayPrefix` + **libellé** humeur + `heroMoodLoggedAt` (heure) + lien `heroSeeJournal` |
| HV-4 | état `HomeError` | pump | rend **État A** en fallback, **pas** de crash, pas de message d'erreur visible (AC7) |
| HV-5 | n'importe quel état | pump | header : logo + wordmark **« DigiHarmony »** (uppercase, **non traduit**, `homeBrandName`) + bouton Réglages |
| HV-6 | n'importe quel état | pump | greeting **fixe** `homeGreeting` (« Bonjour 👋 ») + `homeGreetingSubtitle` (pas de variation horaire — DEC-HOME-04) |
| HV-7 | n'importe quel état | pump | grille 2 tuiles : `homeToolBubble` + `homeToolDailyTip` |
| HV-8 | n'importe quel état | pump | pilule `homePauseCta` (« Faire une pause ») + lien `homeScreenTime` (« Mon temps d'écran ») |
| HV-9 | n'importe quel état | inspection couleurs | fond = `AppColors.background` via le thème ; **aucun hex en dur** (DEC-FND-01) |

---

## 3. Tests de widget — `HeroCard` (états A/B isolés)

Fichier prévu : `test/home/widgets/hero_card_test.dart`.

| # | Given | When | Then |
| --- | --- | --- | --- |
| HC-1 | `HeroCard` état A (humeur = null) | pump | icône `book-heart` (Material équivalent), titre `heroMoodQuestion`, CTA `plus-circle` |
| HC-2 | `HeroCard` état B (`MoodTodayView` happy à 14:30) | pump | emoji de l'humeur + libellé `moodHappy` + heure « 14:30 » formatée locale |
| HC-3 | état B avec `moodCode` connu | mapping | `MoodColors.byKey[moodCode]` utilisé pour la pastille/emoji (codage émotionnel réservé — §3 thème) |
| HC-4 | état B, locale `en` vs `fr` | pump dans chaque locale | l'heure `heroMoodLoggedAt` est formatée selon la locale (ICU placeholder `heure`) |
| HC-5 | les deux états | tap sur CTA / lien | cible 48×48 minimum respectée (a11y tap target) |
| HC-6 | `moodCode` inconnu/non mappé | pump | fallback gracieux (libellé neutre ou `moodNeutral`), pas de crash |

---

## 4. Tests de widget — navigation placeholders + haptique (AC5)

Fichier prévu : `test/home/view/home_navigation_test.dart`. NavigatorObserver + mock `HapticFeedback`.

| # | Given | When | Then |
| --- | --- | --- | --- |
| HN-1 | bouton Réglages (header) | tap | push vers `PlaceholderScreen(Réglages)` |
| HN-2 | CTA « Noter mon humeur » (État A) | tap | push vers `PlaceholderScreen(Noter mon humeur)` |
| HN-3 | lien « Voir mon journal » (A et B) | tap | push vers `PlaceholderScreen(Mon journal)` |
| HN-4 | tuile « Choisis ta bulle » | tap | push vers `PlaceholderScreen(Choisis ta bulle)` |
| HN-5 | tuile « Conseil du jour » | tap | push vers `PlaceholderScreen(Conseil du jour)` |
| HN-6 | pilule « Faire une pause » | tap | push vers `PlaceholderScreen(Faire une pause)` |
| HN-7 | lien « Mon temps d'écran » | tap | push vers `PlaceholderScreen(Mon temps d'écran)` |
| HN-8 | **chaque** geste ci-dessus | tap | déclenche un `HapticFeedback.lightImpact()` (vérifié via mock canal plateforme) — AC5, sans permission `VIBRATE` |
| HN-9 | retour depuis « Noter mon humeur » | pop | pas de refresh manuel ; le stream Drift pilote A/B (cohérent HB-4) |

---

## 5. Tests de widget — reduced motion / a11y décor (AC6, DEC-HOME-07)

Fichier prévu : `test/home/view/home_reduced_motion_test.dart`.

| # | Given | When | Then |
| --- | --- | --- | --- |
| RM-1 | `disableAnimations == true` | pump `HomeView` | `BreathingHalo` rendu **statique** (pas de boucle scale/opacity) |
| RM-2 | `disableAnimations == true` | pump | `FloatingParticles` statique (pas de flottement en boucle) |
| RM-3 | `disableAnimations == true` | pump | pilule « Faire une pause » : respiration désactivée |
| RM-4 | `disableAnimations == true` | pump | l'écran reste **lisible** (tout le contenu présent, juste sans boucles) |
| RM-5 | `disableAnimations == false` | pump | animations en boucle actives (halo/particules/pause) |
| RM-6 | mode avec boucles | pilotage temps | éviter `pumpAndSettle` infini — `pump(Duration)` ciblé (garde-fou méthodologique) |

---

## 6. Tests i18n — libellés 8 langues & repli (AC8)

Fichier prévu : `test/home/view/home_i18n_test.dart`.

| # | Given | When | Then |
| --- | --- | --- | --- |
| I18-1 | locale `fr` | pump | `heroLogMoodCta` == « Noter mon humeur », `homeGreeting` == « Bonjour 👋 » |
| I18-2 | locale `en` | pump | libellés en anglais (référence ARB) |
| I18-3 | wordmark « DigiHarmony » | toute locale | **identique** dans toutes les langues (constante `homeBrandName`, non traduite) — AC8 |
| I18-4 | locale non encore traduite (ex. `mk` partiel) | pump | **repli `en`** sans crash (DEC-002) |
| I18-5 | libellés d'humeur `moodHappy..moodAnxious` | mapping depuis `moodCode` | chaque code mappe son libellé localisé (6 libellés du plan, cf. incohérence §8.2) |

---

## 7. Récapitulatif couverture US-HOME-01

| AC | Couvert par |
| --- | --- |
| AC1 (sans entrée → État A) | HB-2, HV-2 |
| AC2 (entrée du jour → État B, dernière entrée) | HB-3, HB-5, HV-3, HC-2 |
| AC3 (ajout entrée → bascule A→B réactive) | HB-4, HN-9 |
| AC4 (conseil du jour déterministe) | HB-6 (+ TIP-* côté Fondations) |
| AC5 (navigation placeholders + haptique) | HN-1→HN-8 |
| AC6 (reduced motion : boucles off, lisible) | RM-1→RM-5 |
| AC7 (erreur Drift → fallback État A, pas de crash) | HB-7, HV-4 |
| AC8 (8 langues, wordmark non traduit) | I18-1→I18-5 |

## 8. Points à arbitrer avant écriture (self-challenge)

1. **Codes émotion 6 vs 7** : le plan Accueil liste 6 libellés (`happy/calm/neutral/sad/angry/anxious`),
   `MoodColors` expose 7 clés (`happy/calm/dynamic/sad/angry/nervous/tired`). HC-3/HC-6/I18-5 doivent gérer
   le **fallback** d'un code non mappé sans crash, en attendant l'arbitrage avec l'US « Noter mon humeur ».
2. **Skeleton de chargement** (HV-1) : confirmer le rendu attendu (placeholder neutre, public mineur, pas de spinner agressif).
3. **Formatage heure locale** (HC-2/HC-4) : confirmer le format (24 h ? locale-aware via `intl`). ICU placeholder `heure` = String.
4. **Tap target 48×48** (HC-5) : valider par `tester.getSize` sur les zones interactives.
5. **`watch()` réactivité** (HB-4) : s'assurer que le test émet réellement deux valeurs sur le `StreamController` mocké pour observer la bascule.
6. **`BreathingHalo`/`FloatingParticles` mutualisés** avec le Splash (coordination registry) : si réutilisés, tester une seule fois et référencer.
