---
name: review_functional
description: Functional review report template
argument-hint: N/A
---

# Functional Review for « Mon Journal » (#10) + refonte « Noter mon humeur » (#6) — PR #11

- **Plan**: `aidd_docs/plans/journal-mon-journal.plan.md` (+ décisions `aidd_docs/tasks/journal.md` DEC-J-01..11)
- **Diff scope**: `main...HEAD` (branche `feat/noter-humeur`, périmètre `apps/**`)
- **Date**: 2026-06-06

## Verdict

**PASS** — Les 6 critères vérifiables du `success_condition` et l'ensemble des critères M1→M8 sont tracés dans le diff ; aucun interdit DEC-J/DON'T violé. Les seuls écarts sont mineurs (états vide/conseil couplés, message d'erreur saisie brut) et non bloquants. La refonte saisie (#6) est cohérente et tracée.

## Scoring Matrix

| Criterion | Files | Status | Severity | Notes |
| --------- | ----- | ------ | -------- | ----- |
| SC-1 — JournalPage accessible depuis la carte humeur (états A & B → `versJournal`, plus `ouvrirPlaceholder`) | `carte_humeur.dart:86,171`, `app_router.dart:52` | Met | — | Les 2 occurrences recâblées sur `AppRouter.versJournal` ; `heroSeeJournal` conservé. |
| SC-2 — Les 3 vues rendent les données Drift via `watch()` (Jour/Semaine/Mois) | `app_database.dart:153,173,199`, `journal_bloc.dart:90-121`, `journal_vue_*.dart` | Met | — | `observerDerniereHumeurDuJour`/`observerEntreesDeLaSemaine`/`observerEntreesDuMois` en `.watch()`/`.watchSingleOrNull()`. |
| SC-3 — Navigation mois bornée au présent (flèche suivant désactivée au mois courant) | `journal_bloc.dart:51-54,174-186`, `journal_vue_mois.dart:63-79` | Met | — | `peutAvancerMois` strict `<` mois courant ; `onPressed: null` quand `!peutAvancer` ; `Semantics(enabled:)`. |
| SC-4 — Aucune chaîne UI en dur ; clés `journal*` fr+en, repli en pour 6 langues | 8 × `app_*.arb`, `journal_view.dart`, `journal_vue_*.dart` | Met | — | 25 clés `journal*` présentes et alignées sur les 8 ARB ; fr/en identiques en clés ; aucun littéral FR/EN dans les widgets. |
| SC-5 — Reduced-motion rend un état statique | `journal_segmented_control.dart:67-76` | Met | Minor | Seule animation du périmètre (segment) gated `Duration.zero` via `disableAnimationsOf`. Aucune autre animation (halo/cascade/pulse) implémentée → pas de gate manquant. |
| SC-6 — Aucun score/classement/streak/comparaison ; répartition ordre fixe `emotionsCanoniques` | `journal_synthese_mois.dart:27-65`, `journal_state.dart` | Met | — | Comptage puis itération `emotionsCanoniques.where(count>0)` (jamais trié) ; state sans champ score/streak ; synthèse mono-mois. |
| M1 — Semaine : bornes lundi→dim, borne haute exclue, ASC, ≤1/jour | `app_database.dart:173-192` | Met | — | `start = lundi`, `end = start+7j`, `>= & <`, `orderBy ASC`. Aucun bump de schéma. |
| M1 — Mois : bornes 1er→fin de mois, borne haute exclue, mois vide → liste vide, réactif | `app_database.dart:199-212` | Met | — | `start = DateTime(y,m)`, `end = DateTime(y,m+1)` (dépassement décembre géré), `>= & <`, ASC, `.watch()`. |
| M2 — `versJournal` push `JournalPage` avec `AppDatabase` via `RepositoryProvider.value` | `app_router.dart:52-62` | Met | — | Calque exact de `versSaisieHumeur`. |
| M3 — `JournalDemarre` → `chargement` puis `pret` ; vide → `humeurDuJour==null`+conseil ; vue/mois ; erreur Drift sans crash | `journal_bloc.dart:57-212`, `journal_state.dart` | Met | — | Tracé + couvert par `journal_bloc_test.dart` JB-1..9. |
| M3 — Aucun score/classement stocké dans le state | `journal_state.dart:33-115` | Met | — | Champs = statut/vue/humeur/conseilCle/listes/moisAffiche/peutAvancer/erreur. Aucun agrégat de score. |
| M4 — `flutter gen-l10n` sans erreur ; 25 clés sur 8 ARB ; pas de doublon `mood*` | 8 × `app_*.arb` | Met | — | Compte = 25 par ARB ; ICU `{count}`/`plural` déclarés. `analyze` clean (amont). |
| M5 — Vue Jour avec humeur : pastille `emojiPourCode`/`MoodColors`, libellé `mood*`, conseil, CTA exercice → SnackBar (pas de nav) | `journal_carte_jour.dart:28-149` | Met | — | SnackBar `journalExerciseComingSoon` ; lien modifier → `versSaisieHumeur`. Aucun hex/emoji en dur. |
| M5 — Vue Jour vide : titre/corps/CTA bienveillants + conseil affiché ; CTA → `versSaisieHumeur` | `journal_vue_jour.dart:31-103` | Partial | Minor | Conseil bien réaffiché dans l'état vide. MAIS l'aiguillage `humeur!=null && conseilCle!=null` (`:22`) force l'état vide si conseil null alors qu'une humeur existe — incohérence d'affichage théorique (cf. revue code). |
| M6 — Vue Semaine : 7 cases, « · » jours non notés, résumé `journalWeekSummary`/`Empty`, aucun score | `journal_vue_semaine.dart:39-160` | Met | — | `List.generate(7)` lundi→dim, `DateFormat.E(locale)`, `journalWeekNoEntry` sinon. Indexation par `jour`. |
| M7 — Vue Mois : flèche suivant désactivée au mois courant ; jour noté→emoji, non noté→numéro grisé ; hors mois→vide | `journal_vue_mois.dart`, `journal_calendrier_mois.dart:30-145` | Met | — | Grille `GridView.count(7)`, décalage `weekday-1`, numéro `AppColors.textMuted` sinon emoji. |
| M7 — Synthèse mois : lignes ordre `emotionsCanoniques`, pas de tri par fréquence, pas d'inter-mois | `journal_synthese_mois.dart:34-65` | Met | — | `emotionsCanoniques.where(count>0)` ; tendance `journalMonthSummary` mono-mois. |
| M8 — Reduced-motion → rendu statique (test widget) | `journal_segmented_control.dart:67`, `journal_a11y_test.dart` | Met | — | Gate présent ; test a11y au diff. |
| M8 — Sémantique pastille / segment actif / flèche désactivée | `journal_carte_jour.dart:47`, `journal_segmented_control.dart:68`, `journal_vue_mois.dart:63-66` | Met | — | `Semantics(label/selected/enabled)` présents ; cases calendrier dotées de clés sémantiques dédiées. |
| #6 — Préselection humeur du jour à l'ouverture (`SaisieDemarree`), aucune écriture | `saisie_humeur_bloc.dart:32-46`, `saisie_humeur_page.dart:26` | Met | — | Lecture ponctuelle `firstWhere(orElse: null)`, garde `state is! SaisieInitiale`, `droppable()`. Émet `EmotionSelectionneeEtat` (pas d'UPSERT). |
| #6 — Flux 2-temps sélection/validation, retour Accueil au succès | `saisie_humeur_bloc.dart:51-89`, `saisie_humeur_view.dart:104-117` | Met | — | `EmotionSelectionnee`→état visuel ; `SaisieValidee`→UPSERT ; pop au `EnregistrementReussi`. |
| #6 — Fix DB `busy_timeout` (verrou transitoire) | `app_database.dart:330-335` | Met | — | `PRAGMA busy_timeout = 5000;` en `setup`, motivé en commentaire. Migration `onUpgrade` idempotente (`IF NOT EXISTS`). |
| Retouche — Menu ⋮ retiré sans clé i18n morte (`journalMenuTooltip`) | `journal_view.dart`, 8 × `app_*.arb` | Met | — | `grep journalMenuTooltip` = 0 (code + ARB). Aucun `IconButton` menu résiduel. |
| Retouche — Segmented control pill custom (sans hex, Semantics selected, reduced-motion, ≥48dp) | `journal_segmented_control.dart` | Met | — | `Container(height:48)` + `Row<Expanded>` + `AnimatedContainer` ; `AppColors.*` only ; `Semantics(selected:)` conservé. |

## Missing Behaviors

Acceptance criteria with no trace in the diff.

- none — tous les critères du `success_condition` et des milestones M1→M8 sont tracés dans le diff.

## Unplanned Behaviors

Changes present in the diff but not traced to any acceptance criterion.

- [ ] Clés i18n `journalCalendarDayMoodSemantics` / `journalCalendarDaySemantics` ajoutées (au-delà des 25 du plan §7) — amélioration a11y des cases calendrier, cohérente avec l'esprit du plan (Semantics). Confirmer comme accepté.
- [ ] Note `journalLocalDataNote` affichée dans les vues Semaine **et** Mois (`journal_vue_semaine.dart:75`, `journal_vue_mois.dart:95`) — le plan la classe COULD « note discrète bas de page ». Livrée ; non bloquant.
- [ ] Suppression VCS de 100 `.claude/rules/*.mdc` + 44 autres `.claude/**` + 5 `.specstory/**` (commit `f428bee`) — hors périmètre fonctionnel de la feature ; traitée comme finding hygiène/process dans la revue de code (sévérité haute, à arbitrer avant merge `main`).
- [ ] `journalMonthTitle` (clé listée plan §7) jamais ajoutée ni utilisée — titre mois rendu via `DateFormat.yMMMM`. Abandon de clé planifiée, neutre.

## Flow / Edge-case Gaps

Gaps surfaced while walking each criterion against the diff.

- [ ] **Humeur présente + conseil null → état vide affiché** (`journal_vue_jour.dart:22`) : l'aiguillage exige `conseilCle != null` pour montrer `JournalCarteJour`. En pratique le bloc passe en `erreur` si `conseilDuJour` échoue, donc le cas est peu atteignable, mais le couplage affichage-humeur ↔ présence-conseil est fragile. Découpler.
- [ ] **Message d'erreur saisie brut** (`saisie_humeur_bloc.dart:84` → `saisie_humeur_view.dart:111`) : `e.toString()` d'une exception Drift affiché en SnackBar à un public mineur — non localisé, non bienveillant. Remplacer par une clé i18n générique.
- [ ] **`droppable` sur navigation mois/vue** (`journal_bloc.dart:27-32`) : conforme au plan §4.3 (anti double-tap), mais diverge de la reco `sequential` de `3-flutter-bloc-concurrency` pour les events de navigation. Un tap mois émis pendant un changement de vue en vol peut être ignoré ; impact négligeable vu la latence. Plan fait loi — signalé pour traçabilité.
- [ ] **Vue Semaine ancrée sur `DateTime.now()`** (`journal_vue_semaine.dart:27`) : le lundi est recalculé côté widget depuis `now()`, indépendamment de toute ancre du bloc. Cohérent (la semaine n'est pas navigable), mais le calcul du lundi est dupliqué entre `app_database.observerEntreesDeLaSemaine` (`:182`) et le widget (`:88`) — risque de divergence si un seul des deux change. Centraliser le calcul « lundi de la semaine ».

## Summary

- **Criteria covered**: 25/25 (tous Met ; 1 Partial mineur sur M5-vide).
- **Blockers**: 0 (fonctionnel). 1 risque process hors-runtime (suppression VCS des règles) documenté en revue de code.
- **Follow-up actions**:
  1. Découpler l'affichage carte humeur de la présence du conseil (`journal_vue_jour.dart:22`).
  2. Localiser le message d'erreur saisie (`saisie_humeur_bloc.dart:84`).
  3. Centraliser le calcul « lundi de la semaine » (DB + widget).
  4. Confirmer l'acceptation des clés a11y et de la note `journalLocalDataNote` ajoutées hors plan.
  5. (Process, hors feature) Arbitrer le dé-versionnement de `.claude/rules/*.mdc`.
- **Additional notes**: Le diff est fidèle au plan et aux décisions DEC-J-01..11 ; aucun interdit DON'T violé (pas de score/streak/inter-mois, pas de hex/emoji en dur, pas de HydratedBloc pour le journal, pas d'écriture par le journal, pas de navigation future, pas de SDK réseau/permission). Couverture de test traçable (JB-1..9 ↔ plan §10).
