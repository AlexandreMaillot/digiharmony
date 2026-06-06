---
name: review_functional
description: Functional review report template
argument-hint: N/A
---

# Functional Review for Écran de soutien (« Super conseil » / SoutienPage)

- **Plan**: `aidd_docs/plans/soutien-super-conseil.plan.md`
- **Page plan / spec**: `aidd_docs/tasks/soutien.md` (garde-fous §0 + DEC-SO-*)
- **Diff scope**: `e7d66b9...HEAD` (8 commits M1→M7 + format, `feat/noter-humeur`, non poussés)
- **Date**: 2026-06-06

## Verdict

PARTIAL — Le périmètre fonctionnel et tous les garde-fous SENSIBLES sont
implémentés et conformes ; mais le **déclenchement auto post-splash (M4-AC2)**
est probablement inerte au runtime (le `pushReplacement` démonte le contexte
avant l'évaluation) et n'est couvert par aucun test d'intégration. Aucun
blocker de sensibilité de contenu ; un blocker de fiabilité de déclenchement.

## Scoring Matrix

| Criterion | Files | Status | Severity | Notes |
| --------- | ----- | ------ | -------- | ----- |
| M1-AC1 Journal vide → 0 | `app_database.dart:243`, `soutien_compteur_test.dart:39` | Met | — | SO-CNT-1 vert |
| M1-AC2 7 négatives en tête → ≥7 | `app_database.dart:243`, `soutien_compteur_test.dart:43` | Met | — | SO-CNT-2 |
| M1-AC3 Positive en tête → 0 | `soutien_compteur_test.dart:50` | Met | — | SO-CNT-3 |
| M1-AC4 Série cassée par positive ancienne → tête seule | `soutien_compteur_test.dart:59` | Met | — | SO-CNT-4 (=3) |
| M1-AC5 Jours non consécutifs → ≥7 (saisies, pas jours) | `soutien_compteur_test.dart:71` | Met | — | SO-CNT-5 |
| M1-AC6 `aDeclencherSoutien` true ssi ≥7 | `app_database.dart:258`, `soutien_compteur_test.dart:101` | Met | — | SO-DEC-1/2/3 |
| M1 Pas de bump schéma (lecture seule) | `app_database.dart` | Met | — | aucune modif `schemaVersion`, méthodes `select().get()` |
| M2-AC1 compteur<7 → false (tout flag) | `evaluateur_soutien.dart:21`, `evaluateur_soutien_test.dart:6` | Met | — | SO-EVAL-1/2 |
| M2-AC2 ≥7 et !dejaMontre → true | `evaluateur_soutien_test.dart:26` | Met | — | SO-EVAL-3/4 |
| M2-AC3 ≥7 et dejaMontre → false | `evaluateur_soutien_test.dart:46` | Met | — | SO-EVAL-5 |
| M2 Pur, sans I/O / Flutter / Drift | `evaluateur_soutien.dart:8-28` | Met | — | `abstract final class`, importe seulement `AppDatabase.seuilSoutien` (constante) |
| M2/M1 Seuil unique centralisé (DEC-SOP-005) | `app_database.dart:235`, `evaluateur_soutien.dart:12` | Met | — | `seuil = AppDatabase.seuilSoutien` |
| M3-AC1 État initial false | `soutien_bloc.dart:16`, `soutien_bloc_test.dart:16` | Met | — | SO-BLOC-1 |
| M3-AC2 SoutienMontre → true + round-trip | `soutien_bloc.dart:25`, `soutien_bloc_test.dart:23/38` | Met | — | SO-BLOC-2/4/5/6 |
| M3-AC3 SoutienReinitialise → false | `soutien_bloc.dart:32`, `soutien_bloc_test.dart:30` | Met | — | SO-BLOC-3 |
| M3-AC4 Scénario épisode (pas de double affichage) | `soutien_bloc_test.dart:79` | Met | — | SO-BLOC-10 |
| M3 Bloc-only (PAS de Cubit) + transformer | `soutien_bloc.dart:14-18` | Met | — | `extends HydratedBloc`, `sequential()`, sealed events |
| M4-AC1 `versSoutien` push `const SoutienPage()` | `app_router.dart:68` | Met | — | `push(MaterialPageRoute(const SoutienPage()))`, pas de Drift transmis (DEC-SOP-003) |
| M4 `SoutienBloc` global `context.read` | `app.dart:30` | Met | — | `BlocProvider<SoutienBloc>` append-only |
| M4-AC compteur<7 → pas de push (régression Demarrage verte) | `demarrage_view.dart:104`, `demarrage_navigation_test.dart` | Partial | Minor | Régression OK (NAV-1→4 verts) MAIS verts car la branche se court-circuite (contexte démonté), pas car compteur<7 explicitement testé |
| **M4-AC2 compteur≥7 et !dejaMontre → SoutienMontre PUIS push soutien** | `demarrage_view.dart:122-134` | **Unmet** | **Blocker** | Code présent mais probablement inerte : `versAccueil` = `pushReplacement` (`app_router.dart:26`) démonte DemarrageView ; `if (!context.mounted) return;` (ligne 106) court-circuite avant lecture du compteur. **Aucun test ne prouve le déclenchement réel.** |
| M4-AC compteur≥7 et dejaMontre → pas de re-push | `demarrage_view.dart:122` | Partial | Major | Logique correcte (`doitDeclencher` false) mais non testée en intégration ; dépend du chemin M4-AC2 inerte |
| M4-AC compteur<7 et dejaMontre → SoutienReinitialise | `demarrage_view.dart:118-120` | Partial | Major | Réarmement codé mais non testé en intégration ; même fragilité de contexte |
| M4 Aucune entrée manuelle vers SoutienPage en prod | `app_router.dart:68`, `accueil_view.dart:25` | Met | — | Seule entrée runtime = FAB `kDebugMode` (tree-shaké en release) |
| M5-AC1 `flutter gen-l10n` sans erreur | ARB x8 | Met | — | validé en amont (analyze clean) |
| M5-AC2 11 clés `soutien*` dans les 8 ARB | `app_fr.arb:76`, `app_en.arb:339`, +6 | Met | — | fr+en réels, repli en x6 (11 clés/langue) |
| M5-AC3 Aucun doublon de clé | ARB x8 | Met | — | analyze clean |
| M5 Marqueurs « À VALIDER » | `app_en.arb:340-382` | Partial | Minor | EN porte `TODO validation partenaires` via `@`-desc ; **fr sans marqueur par clé** (asymétrie) |
| M6-AC1 Rend icône/titre/accroche/paragraphe/2 CTA/Plus tard/Aucune relance | `soutien_view.dart`, `soutien_view_test.dart:35` | Met | — | SO-VIEW-1 |
| M6-AC2 Bloc ligne d'écoute masqué si pas de ressource | `bloc_ligne_ecoute.dart:24`, `soutien_view_test.dart:68` | Met | — | SO-VIEW-3 ; présent-si-ressource non testé (table vide → impossible à pumper sans mock) |
| M6-AC3 Fond backgroundDeep + accroche primary, zéro hex | `soutien_view.dart:27/98`, `soutien_view_test.dart:60` | Met | — | SO-VIEW-2 ; `grep 0xFF` vide |
| M6-AC4 « Plus tard »/chevron → pop | `soutien_view.dart:35/132`, `soutien_view_test.dart:82` | Met | — | SO-VIEW-4 |
| M6-AC5 CTA respiration STUB → SnackBar, pas de nav | `soutien_view.dart:170`, `soutien_view_test.dart:127` | Met | — | SO-VIEW-5 `placeholderComingSoon` réutilisé |
| M6-AC6 Reduced-motion → halo statique | `halo_soutien.dart:32`, `soutien_view_test.dart:140` | Partial | Minor | Logique présente ; **SO-VIEW-6 n'asserte pas l'absence d'animation** (présence widget seule) |
| M6-AC7 HapticFeedback au tap (mock channel) | `bouton_action_soutien.dart:58/74` | Partial | Minor | Code présent ; **aucun test mock-channel** (plan §10 le demandait) |
| M6-AC8 Cibles ≥ 48×48 chevron + CTA | `soutien_view.dart:39`, `bouton_action_soutien.dart:69/87`, `soutien_view_test.dart:154` | Met | — | SO-VIEW-7 |
| M6-AC9 Garde-fou aucun « 3114 »/numéro réel | `ressource_ligne_ecoute.dart:46`, `soutien_compteur`/`ressource`/`view` tests | Partial | Major | Table VIDE confirmée (SO-RES-2) — garde-fou réel respecté. MAIS SO-RES-3 itère sur map vide et SO-VIEW-8 teste `''` → **tests tautologiques**, fausse assurance |
| M6 `RessourceLigneEcoute` + table `const {}` vide | `ressource_ligne_ecoute.dart:14/46` | Met | — | `// TODO(partenaires)`, aucun numéro réel |
| M6 `url_launcher` tel:/https: + échec SnackBar | `bloc_ligne_ecoute.dart:89-120` | Met | — | `canLaunchUrl`/`launchUrl(externalApplication)`, `try/on Exception`, SnackBar neutre |
| M7-AC1 CTA Confiance → ConfiancePage, pop, aucune collecte/formulaire | `soutien_view.dart:160`, `confiance_page.dart`, `confiance_page_test.dart` | Met | — | SO-CONF-1→5 (pas de TextField, pop, ≥48dp) |
| M7-AC2 Preview présente sous kDebugMode, absente en release, aucune entrée nav prod | `accueil_view.dart:25-35` | Met | — | `kDebugMode ? FAB : null`, commentaire tree-shaking |
| M7-AC3 Sémantique CTA + reduced-motion + ≥48dp | `bouton_action_soutien.dart:49`, `soutien_view.dart:31` | Met | — | Semantics présents ; reduced-motion testé partiellement (voir M6-AC6) |
| M7-AC4 Suite verte + lints 0 warning/info | — | Met | — | confirmé en amont (230 tests verts, analyze clean) |
| Garde-fou zéro collecte / aucun SDK réseau | `lib/pages/soutien/**` | Met | — | seul `url_launcher` ; aucun analytics/tracking |
| Garde-fou aucune permission Android ajoutée | (manifest non modifié dans le diff) | Met | — | aucun fichier manifest dans le diff |
| Garde-fou compteur jamais dupliqué dans HydratedBloc | `soutien_bloc.dart:39-49` | Met | — | sérialise seulement `shown` (bool) |

## Missing Behaviors

Critères d'acceptation sans preuve de bon fonctionnement dans le diff.

- [ ] **M4-AC2 — Déclenchement réel post-splash (compteur≥7 → push SoutienPage)** : code présent mais non prouvé fonctionnel ; aucun test d'intégration Demarrage couvre le chemin, et l'ordre `pushReplacement(Accueil)` puis évaluation sous garde `context.mounted` rend le déclenchement probablement inerte (le contexte est démonté). **Blocker fiabilité.**
- [ ] **M6-AC2 (variante « présent ») — Bloc ligne d'écoute RENDU quand la locale A une ressource** : seul le cas « masqué » est testé (table vide). Le cas positif (ressource mockée) du plan §10 n'est pas exercé.
- [ ] **M6-AC7 — Vérification mock-channel du HapticFeedback** : non implémentée.
- [ ] **M6-AC6 — Assertion stricte reduced-motion (absence d'animation)** : non assertée.

## Unplanned Behaviors

Changements présents dans le diff non rattachés à un critère d'acceptation.

- [ ] `journal_segmented_control.dart` reformaté (commit `5183e2e`) — hors périmètre soutien, purement cosmétique (`dart format`). Confirmer que c'est volontaire (pas de régression fonctionnelle).
- [ ] `SoutienState.copyWith` (`soutien_state.dart:18`) — exposé et testé (SO-BLOC-8) mais non utilisé par le bloc. Bénin.
- [ ] Message d'échec en dur `"Impossible d'ouvrir ce lien."` (`bloc_ligne_ecoute.dart:116`) non i18n — non spécifié comme clé ; code mort en V1 (table vide).

## Flow / Edge-case Gaps

Écarts révélés en parcourant chaque critère contre le diff.

- [ ] **Cycle de vie du contexte au hook Demarrage** : `_versAccueilPuisEvaluerSoutien` capture `db`/`soutienBloc` (lignes 108-110) APRÈS le premier `if (!context.mounted) return;`. Si ce garde passe, le `await db.compter...()` (ligne 112) suivi de `if (!context.mounted) return;` (114) reste exposé au démontage post-`pushReplacement`. À auditer au runtime / réordonner (évaluer le compteur avant le replacement).
- [ ] **Garde-fous sensibles tautologiques** : `SO-RES-3` (boucle sur `tableRessources.values` vide) et `SO-VIEW-8` (`const source = ''`) ne testent rien d'effectif. Le garde-fou opérationnel repose entièrement sur `SO-RES-2` (`isEmpty`). Dès qu'une ressource sera ajoutée, ces deux tests resteront verts sans détecter un éventuel « 3114 » réel.
- [ ] **Cas « ressource présente »** non couvert : ouverture `tel:`/`https:` via `url_launcher` (succès et échec) jamais exercée avec une ressource mockée — la branche `_ouvrirRessource` est du code non testé.
- [ ] **Réarmement / re-push** (compteur<7+dejaMontre ; compteur≥7+dejaMontre) testés unitairement via `EvaluateurSoutien`/`SoutienBloc` mais jamais en intégration depuis le hook Demarrage.

## Summary

- **Criteria covered**: 41/47 Met (≈ 87%) ; 6 Partial ; 1 Unmet (M4-AC2).
- **Blockers**: 1 (M4-AC2 déclenchement réel post-splash non prouvé / probablement inerte).
- **Follow-up actions**:
  1. (Blocker) Corriger l'ordre d'évaluation du hook Demarrage pour survivre au `pushReplacement` et ajouter un test d'intégration prouvant `compteur≥7 → SoutienMontre + push SoutienPage` (+ cas re-push/réarmement).
  2. Durcir les garde-fous « pas de 3114 » (lecture effective des sources ou assertion sur map remplie).
  3. Ajouter test mock-channel HapticFeedback + assertion stricte reduced-motion + cas « bloc ligne d'écoute présent » avec ressource mockée.
  4. Externaliser le message d'échec en dur ; aligner fr sur en pour les marqueurs « À VALIDER ».
- **Additional notes**: Tous les garde-fous SENSIBLES (public mineur) sont respectés au niveau du code : aucun numéro réel, table ressources vide, bloc masqué si vide, bloc-only sans Cubit, compteur Drift dérivé non dupliqué sans bump schéma, preview DEV tree-shakée, zéro hex en dur, zéro collecte, ton non alarmant + « aucune relance ». **Aucune fuite de numéro réel** → aucun finding 🔴 de contenu. Le seul blocker est de fiabilité de déclenchement, pas de sensibilité. Validation humaine partenaires (textes + numéros) reste bloquante hors périmètre code, correctement matérialisée.
