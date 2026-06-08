---
plan: aidd_docs/tasks/splash-screen.md
page: Splash Screen
route: "/"
us: [US-1.1]
github: "#1"
milestone: Phase 1
type: plan_de_tests_previsionnel
depends_on: [foundations-bootstrap.tests.md]
created: 2026-06-05
status: previsionnel_aucune_impl
---

# Plan de tests prévisionnel — Splash Screen (US-1.1, GitHub #1)

> **Document de planification TDD. AUCUN code de test exécutable ici** (implémentation inexistante).
> Liste les **comportements observables** à valider en Red → Green → Refactor.
>
> Source des cas : critères d'acceptation **US #1 / US-1.1** (splash-screen.md §2, AC-1→AC-7) +
> state machine `SplashBloc` (§6) + DEC-S-005/008/010 + DEC-FND-09.
>
> **Périmètre testé ici** : `SplashBloc` (state machine, `max(init, délai)`, lecture flag), `SplashView`/`SplashPage`
> (rendu, animations, reduced motion), routing depuis le splash. Le **socle** (storage, Drift, thème, `OnboardingCubit`,
> `AppRouter`, splash natif) est testé par **foundations-bootstrap.tests.md** — non redupliqué.

## Conventions & contraintes de test

- **Packages autorisés UNIQUEMENT** : `flutter_test`, `bloc_test`, `mocktail`. Aucune nouvelle dépendance.
- **Package member** : `test: any` si besoin (jamais `test ^x` — conflit `test_api`).
- **Temps** : utiliser `fakeAsync`/`FakeTimer` (`flutter_test`) ou injecter une horloge/délai paramétrable
  pour tester `max(init, délai)` **sans** attendre 2,5 s réelles. Les délais (2,5 s / 0,8 s) doivent être
  injectables (paramètre d'event `SplashDemarre(dureeMinimale)`).
- **`AppDatabase`** : mocké via `mocktail` ; le warm-up Drift = un `Future` contrôlable (complétion immédiate
  ou différée selon le cas testé). Ne PAS ouvrir de vraie base dans les tests du Bloc.
- **`OnboardingCubit`** : mocké (`mocktail`) pour fixer `state` (`true`/`false`) sans HydratedBloc réel.
- **reduced motion** : simulé via `MediaQuery(data: MediaQueryData(disableAnimations: true), child: ...)` dans les tests widget.
- Lints `very_good_analysis` + `bloc_lint`.

---

## 1. Tests unitaires — `SplashBloc` (state machine, AC-2/AC-3)

Fichier prévu : `test/splash/bloc/splash_bloc_test.dart`. Outils : `bloc_test`, `mocktail`, `fakeAsync`.

| # | Given | When | Then |
| --- | --- | --- | --- |
| SB-1 | bloc neuf | construction | état = `SplashInitial` |
| SB-2 | `SplashInitial`, warm-up Drift + timer mockés | `add(SplashDemarre(d))` | émet `SplashEnCours` (init lancée, chrono démarré) |
| SB-3 | warm-up Drift **rapide** (< d), `SplashDemarre(d)` | timer `d` écoulé | navigation **après** `d` (pas avant) — `max(init, d)` = `d` (AC-2) |
| SB-4 | warm-up Drift **lent** (> d), `SplashDemarre(d)` | warm-up terminé | navigation **après** l'init (pas après `d`) — `max(init, d)` = init (AC-2) |
| SB-5 | init prête + délai écoulé, `OnboardingCubit.state == false` | résolution finale | émet `SplashPretPourOnboarding` (AC-3 / DEC-S-010) |
| SB-6 | init prête + délai écoulé, `OnboardingCubit.state == true` | résolution finale | émet `SplashPretPourHome` (AC-3) |
| SB-7 | warm-up Drift **échoue** (Future error) | résolution | émet `SplashErreur(flag)` — l'app route quand même (§7) |
| SB-8 | `SplashErreur` avec flag `false` | routage | cible = Onboarding (même logique que le flag) |
| SB-9 | `SplashErreur` avec flag `true` | routage | cible = Home |
| SB-10 | `SplashDemarre(0.8s)` (reduced motion passé par la View) | flux | le délai minimal effectif = 0,8 s, pas 2,5 s (DEC-S-005 — la valeur vient de l'event) |
| SB-11 | warm-up + timer | `Future.wait([init, delayed(d)])` | le bloc attend bien **les deux** avant de résoudre (ni l'un ni l'autre seul ne déclenche la nav) |

> Red→Green : SB-1 (initial), SB-2 (démarre), puis SB-3/SB-4 (le cœur `max(init,d)`), puis le flag SB-5/SB-6,
> enfin l'erreur SB-7→SB-9 et la valeur de délai SB-10.

---

## 2. Tests de widget — `SplashView` / `SplashPage` rendu nominal (AC-1, AC-7)

Fichier prévu : `test/splash/view/splash_view_test.dart`. Outils : `flutter_test`, stubs `mocktail`.

| # | Given | When | Then |
| --- | --- | --- | --- |
| SV-1 | `SplashView` montée (i18n EN) | pump | affiche le logo `logo_digiharmony.png` (ou son `errorBuilder` si asset absent — pas de crash) |
| SV-2 | idem | pump | affiche le titre littéral **`DIGIHARMONY`** (texte, **non** localisé) |
| SV-3 | idem | pump | affiche la tagline **localisée** (clé `splashTagline`) — présence du widget Text lié à la clé |
| SV-4 | locale `fr` | pump | tagline = « Bien-être numérique · Erasmus+ » (AC-7) |
| SV-5 | locale `en` | pump | tagline = « Digital well-being · Erasmus+ » |
| SV-6 | idem | pump | présence de la **barre signature** (dégradé `AppColors.signatureGradient`, 3 stops `#3FB8E6/#A8D24E/#F0C84A`) — DEC-S-008 |
| SV-7 | idem | pump | présence des **3 loading dots** |
| SV-8 | idem | pump | présence du **footer logo UE** `logo_eu_funding.png` (image, pas d'i18n) + filet séparateur |
| SV-9 | idem | inspection couleur de fond | `Scaffold`/conteneur racine = `AppColors.backgroundDeep` (`#16213C`) — **aucun hex en dur**, via `AppColors` |
| SV-10 | titre DIGIHARMONY | scan i18n | n'est **pas** issu d'une clé ARB (littéral) — AC-7 |

---

## 3. Tests de widget — navigation depuis le splash (BlocListener, AC-3)

Fichier prévu : `test/splash/view/splash_navigation_test.dart`. NavigatorObserver mock (`mocktail`).

| # | Given | When | Then |
| --- | --- | --- | --- |
| NAV-1 | `SplashView` + `SplashBloc` mock émettant `SplashPretPourOnboarding` | pump + settle | `AppRouter.toOnboarding` est appelé → `pushReplacement` observé vers Onboarding |
| NAV-2 | bloc émet `SplashPretPourHome` | pump + settle | `pushReplacement` vers Home |
| NAV-3 | bloc émet `SplashErreur(flag=false)` | pump + settle | route quand même vers Onboarding (pas de crash, pas d'écran d'erreur visible) |
| NAV-4 | après navigation | tenter `pop` | le splash n'est pas réaffiché (pile remplacée — pas de retour vers `/`) |
| NAV-5 | bloc en `SplashEnCours` | pump | **aucune** navigation déclenchée (on reste sur le splash) |

---

## 4. Tests de widget — reduced motion / a11y (AC-6, DEC-S-005)

Fichier prévu : `test/splash/view/splash_reduced_motion_test.dart`.

| # | Given | When | Then |
| --- | --- | --- | --- |
| RM-1 | `MediaQuery.disableAnimations == true` | pump `SplashView` | **aucune boucle** d'animation active (halo/ondes/logo/dots en état statique de repos) |
| RM-2 | `disableAnimations == true` | pump | l'écran reste **lisible** (logo, titre, tagline, dots tous présents même statiques) |
| RM-3 | `disableAnimations == true` | inspection de l'event envoyé au Bloc | `SplashDemarre` reçoit la durée **réduite** (~0,8 s), pas 2,5 s (DEC-S-005) |
| RM-4 | `disableAnimations == false` (défaut) | pump | les animations en boucle sont actives ; `SplashDemarre` reçoit ~2,5 s |
| RM-5 | `disableAnimations == true` | fade-in titre | titre affiché immédiatement (pas d'attente d'animation) |
| RM-6 | n'importe quel mode | `pumpAndSettle` | **ne timeout pas** sur des boucles infinies — vérifier que les boucles n'empêchent pas la stabilisation des tests (utiliser `pump(duration)` ciblé plutôt que `pumpAndSettle` si boucles présentes) |

> RM-6 est un garde-fou méthodologique : `flutter_animate` en boucle infinie fait diverger `pumpAndSettle`.
> À l'implémentation, soit tester en reduced-motion (pas de boucle), soit piloter le temps avec `pump(Duration)`.

---

## 5. Tests d'intégration légers — séquence splash → routing

Fichier prévu : `test/splash/splash_flow_test.dart` (widget + bloc réel, dépendances mockées).

| # | Given | When | Then |
| --- | --- | --- | --- |
| FLOW-1 | `app.dart` avec `home: SplashPage`, warm-up immédiat, flag `false`, délai injecté court | pump + avance du temps | après le délai, `pushReplacement` vers Onboarding |
| FLOW-2 | idem mais flag `true` | pump + avance temps | `pushReplacement` vers Home |
| FLOW-3 | warm-up Drift lent puis OK, flag `true` | pump + avance temps jusqu'à fin init | navigation seulement après l'init (cohérent avec SB-4) |
| FLOW-4 | reduced motion ON, warm-up immédiat | pump + avance 0,8 s | navigation après 0,8 s (pas 2,5 s) |

---

## 6. Récapitulatif couverture US-1.1

| AC | Couvert par |
| --- | --- |
| AC-1 (rendu : fond, logo, titre, barre signature, tagline, dots, footer UE) | SV-1→SV-9 |
| AC-2 (`max(init, ~2,5s)`) | SB-3, SB-4, SB-11, FLOW-1/FLOW-3 |
| AC-3 (route Onboarding si flag faux, sinon Home) | SB-5, SB-6, NAV-1, NAV-2, FLOW-1, FLOW-2 |
| AC-4 (`flutter_animate` homogène) | implicite SV-6/RM-* (présence animations) |
| AC-5 (pas de flash blanc = splash natif) | **manuel** (Fondations AC8, non automatisable) |
| AC-6 (reduced motion : boucles off + délai réduit) | RM-1→RM-5, SB-10, FLOW-4 |
| AC-7 (tagline 8 langues, titre non traduit) | SV-3, SV-4, SV-5, SV-10 |

## 7. Points à arbitrer avant écriture (self-challenge)

1. **Délai injectable** : confirmer que `SplashDemarre(dureeMinimale)` porte bien la durée (calculée par la View
   selon `disableAnimations`). Indispensable pour tester sans attendre 2,5 s (SB-3/SB-10).
2. **`pumpAndSettle` vs boucles infinies** (RM-6) : décider de la stratégie de pilotage du temps en test.
3. **`SplashErreur` route quand même** : confirmer la tolérance (recommandé oui, app locale) — SB-7→SB-9, NAV-3.
4. **Traductions ARB** des 6 langues hors en/fr : placeholder EN en attendant ; SV-4/SV-5 ne testent que en/fr tant que le reste n'est pas fourni.
5. **Asset logo absent** : SV-1/SV-8 doivent tester le `errorBuilder` (placeholder neutre), pas exiger le PNG réel (DEC-FND-03).
