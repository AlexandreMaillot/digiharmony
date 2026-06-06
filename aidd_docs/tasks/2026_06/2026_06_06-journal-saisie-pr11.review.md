---
name: code-review
description: Code review checklist and scoring template
argument-hint: N/A
---

# Code Review for PR #11 — « Mon Journal » (#10) + refonte « Noter mon humeur » (#6)

Revue statique de conformité (règles `.claude/rules/*.mdc`, garde-fous `aidd_docs/memory/`, plan `journal-mon-journal.plan.md`) sur le diff `main...HEAD` (branche `feat/noter-humeur`), périmètre `apps/**` (~57 fichiers applicatifs/docs/tests, `*.g.dart` exclus). `flutter analyze` clean et `flutter test` (187 verts) déjà validés en amont — non rejoués ici.

- Statuts: **APPROVE WITH COMMENTS** — aucun bloquant code ; 1 risque process/hygiène (suppression VCS des règles) à arbitrer avant merge `main`.
- Confidence: Élevée (lecture intégrale des fichiers focaux : segmented control, blocs journal/saisie, observers Drift, recâblage, ARB).

---

- [Main expected Changes](#main-expected-changes)
- [Scoring](#scoring)
- [Code Quality Checklist](#code-quality-checklist)
  - [Potentially Unnecessary Elements](#potentially-unnecessary-elements)
  - [Standards Compliance](#standards-compliance)
  - [Architecture](#architecture)
  - [Code Health](#code-health)
  - [Security](#security)
  - [Error management](#error-management)
  - [Performance](#performance)
  - [Frontend specific](#frontend-specific)
  - [Backend specific](#backend-specific)
- [Final Review](#final-review)

## Main expected Changes

- [x] Feature « Mon Journal » : page empilée, 3 vues (Jour/Semaine/Mois), `JournalBloc` bloc-only, 2 observers Drift réactifs, route `versJournal`, recâblage carte humeur états A & B.
- [x] Refonte « Noter mon humeur » : préselection humeur du jour via `SaisieDemarree`, flux 2-temps sélection/validation, fix DB `busy_timeout`.
- [x] Retouches récentes : menu ⋮ retiré (clé `journalMenuTooltip` purgée des 8 ARB), `journal_segmented_control.dart` refondu en pill custom (Container + Row d'Expanded + AnimatedContainer).
- [x] i18n : 25 clés `journal*` présentes et alignées sur les 8 ARB.

## Scoring

- [🟢] **Bloc-only (pas de Cubit)** `journal_bloc.dart`, `saisie_humeur_bloc.dart` — aucun `Cubit`, dichotomie events/states respectée, transformers explicites.
- [🟢] **Émotions = source unique** `journal_carte_jour.dart:31`, `journal_synthese_mois.dart:34` — `emotionsCanoniques` / `emojiPourCode` / `MoodColors.byKey`, aucune enum ou mapping parallèle.
- [🟢] **Zéro hex / zéro emoji en dur** `lib/pages/journal/**`, `lib/pages/saisie_humeur/**` — `grep 0xFF|Color(0x|#hex` = 0 ; couleurs via `AppColors`/`MoodColors`.
- [🟢] **withValues (pas withOpacity)** — `grep withOpacity` = 0 dans le périmètre ; `withValues(alpha: 0.18)` utilisé partout.
- [🟢] **i18n** `journal_view.dart`, `journal_vue_*.dart` — aucune chaîne FR/EN en dur ; 25 clés `journal*` cohérentes sur les 8 ARB ; ICU `journalWeekSummary({count})` / `journalMonthFrequencyLine` valides.
- [🟢] **Drift watch() vs HydratedBloc** `journal_bloc.dart:90-121` — journal lit Drift en `watch()` ; `grep HydratedBloc lib/pages/journal lib/pages/saisie_humeur` = 0.
- [🟢] **Observers Drift bornes `>= start & < end`** `app_database.dart:184-191` (semaine), `:204-211` (mois) — borne haute exclue, `orderBy ASC`, aucun post-filtrage ; conforme `observerDerniereHumeurDuJour`.
- [🟢] **Recâblage carte humeur états A & B** `carte_humeur.dart:86` (état A) & `:171` (état B) — les deux `ouvrirPlaceholder(...placeholderJournal)` remplacés par `AppRouter.versJournal(context)` ; `heroSeeJournal` conservé.
- [🟢] **Route `versJournal`** `app_router.dart:52-62` — calque exact de `versSaisieHumeur` (`RepositoryProvider<AppDatabase>.value`, `push`).
- [🟢] **Segmented control a11y/reduced-motion** `journal_segmented_control.dart:67-76` — `AnimatedContainer` à `Duration.zero` si `MediaQuery.disableAnimationsOf`, `Semantics(selected: actif)`, hauteur 48dp, `AppColors.*` uniquement.
- [🟢] **Préselection humeur** `saisie_humeur_bloc.dart:32-46` — `firstWhere((_) => true, orElse: () => null)` robuste sur stream vide, garde `state is! SaisieInitiale`, transformer `droppable()`, **aucune écriture**.
- [🟢] **Menu ⋮ retiré sans clé morte** — `grep journalMenuTooltip lib/` = 0 (code + 8 ARB) ; aucun `IconButton` menu résiduel dans `journal_view.dart`.
- [🟡] **DRY — résolveur de conseil dupliqué** `journal_vue_jour.dart:105-124` et `journal_carte_jour.dart:152-171` : la méthode `_texteConseil(l10n, cle)` (switch `tipDay01..07`) est copiée à l'identique dans 2 widgets, alors que `journal_emotion_utils.dart:7` centralise déjà `libelleEmotion` et documente explicitement « ne pas dupliquer cette logique dans les widgets journal ». (Extraire un `texteConseil(l10n, cle)` dans `journal_emotion_utils.dart`.)
- [🟡] **Mapping émotion dupliqué une 3e fois** `carte_humeur.dart:182-203` `_libelleEmotion` switch `happy..tired` — duplique `journal_emotion_utils.libelleEmotion`. Le helper vit sous `pages/journal/`, donc l'Accueil ne peut le réutiliser sans dépendance croisée ; le code mort potentiel est de remonter ce helper dans un emplacement partagé (`theme/` ou `common/`). (Pré-existant côté Accueil mais ravivé par la feature.)
- [🟡] **`JournalVueJour` masque la carte si conseil null** `journal_vue_jour.dart:22-24` — condition `humeur != null && conseilCle != null ? JournalCarteJour : _EtatVideBienveillant`. Si une humeur existe mais que `conseilDuJourCle == null` (cas non bloquant car le bloc passe en `erreur` si `conseilDuJour` throw, mais théoriquement possible), l'utilisateur voit l'état vide alors qu'il a noté son humeur. (Découpler l'affichage de la carte humeur de la présence du conseil.)
- [🟡] **Message d'erreur brut exposé** `saisie_humeur_bloc.dart:84` + `saisie_humeur_view.dart:111` — `EnregistrementEchoue(message: e.toString())` est affiché tel quel dans une `SnackBar` à un public mineur. Une exception Drift technique n'est ni localisée ni « user-friendly ». (Émettre une clé i18n d'erreur générique au lieu de `e.toString()`.)
- [🟡] **Transformer `droppable` sur events de navigation** `journal_bloc.dart:27,28,32` — `JournalVueChangee` / `JournalMoisPrecedent` / `JournalMoisSuivant` utilisent `droppable()`. La règle `3-flutter-bloc-concurrency` recommande `sequential` pour les events « modification d'état / navigation ». Le plan §4.3 prescrit **explicitement** `droppable` (anti double-tap), donc le plan fait loi ici — signalé pour traçabilité, pas une régression. Risque marginal : un tap mois pendant un changement de vue en vol pourrait être ignoré ; acceptable vu la latence quasi nulle.
- [🟢] **Structure de page Journal** `lib/pages/journal/{bloc/journal_bloc,views,widgets}` — conforme `0-flutter-pages-structure` (sous-dossier `journal_bloc/`).
- [🟡] **Structure de page Saisie non alignée** `lib/pages/saisie_humeur/bloc/*.dart` — bloc à plat, sans sous-dossier `saisie_humeur_bloc/` (la règle `0-flutter-pages-structure` impose `{nom_page}_bloc/`). Divergence avec la page Journal au sein de la même PR. Pré-existant (#6), `alwaysApply:false`. (Aligner pour cohérence intra-repo.)
- [🟡] **`utils/` hors arbo de page canonique** `lib/pages/journal/utils/journal_emotion_utils.dart` — la règle `0-flutter-pages-structure` ne prévoit que `bloc/`, `views/`, `widgets/`. `utils/` est toléré mais non décrit ; à acter ou déplacer dans `common/`.
- [🔴] **Suppression VCS des règles versionnées (hygiène/process)** — le diff `main...HEAD` **supprime 100 fichiers `.claude/rules/*.mdc`** (+ 44 autres `.claude/**` agents/commands/skills) et 5 `.specstory/**`, et `.gitignore:31-32` ignore désormais `.claude/` et `.specstory/` (origine commit `f428bee`). La suppression de `.specstory/` (logs de session) est **légitime**. En revanche `.claude/rules/*.mdc` sont les **règles de code versionnées référencées par `CLAUDE.md`** (`Contents of .../.claude/rules/...`) et servent de validateur à cette revue ; les retirer du contrôle de version au merge `main` les rend non-partagées, non-revues et dérivables silencieusement entre machines. Les fichiers restent présents sur le disque local (gitignorés) — donc aucune perte immédiate, mais perte de traçabilité d'équipe. **Ne pas corriger ici** : décider sciemment (a) ré-suivre `.claude/rules/` en retirant uniquement ce sous-dossier du `.gitignore`, ou (b) acter que les règles vivent ailleurs. Sévérité haute car cela touche la gouvernance du dépôt, pas le runtime.

## Code Quality Checklist

### Potentially Unnecessary Elements

- [x] `_texteConseil` dupliqué (2 occurrences) — voir finding 🟡 DRY conseil.
- [x] `_libelleEmotion` (Accueil) duplique `journal_emotion_utils.libelleEmotion` — voir finding 🟡.
- [x] `journalMonthTitle` (clé listée plan §7) absente des ARB et non utilisée (titre mois rendu via `DateFormat.yMMMM`) — clé planifiée abandonnée sans trace, neutre.

### Standards Compliance

- [x] Naming FR respecté (classes/fichiers/dossiers/events/states en français ; suffixes `Bloc`/`Event`/`State` anglais tolérés par dérogation projet 2026-06-05).
- [x] Coding rules ok (bloc-only, sealed events, `final class` states + `copyWith` + `props`, transformers explicites).

### Architecture

- [x] Design patterns respectés (Bloc + events internes privés `_JournalDonnees*`, sentinelle `Function()?` pour nullables dans `copyWith`).
- [x] Séparation des responsabilités (page fournit le bloc, view = Scaffold + switch de vue, widgets feuilles `StatelessWidget`).

### Code Health

- [x] Tailles de fichiers OK (< 300 lignes ; `journal_bloc.dart` = 219, `app_database.dart` ~339).
- [x] Complexité cyclomatique acceptable.
- [x] Pas de magic number visuel non motivé (tailles 40/48/56dp documentées ; alpha 0.18 récurrent).
- [x] Gestion d'erreur présente (bloc journal → `status: erreur` sans crash ; saisie → `EnregistrementEchoue`).
- [ ] Messages d'erreur user-friendly — partiel : `e.toString()` brut côté saisie (voir 🟡).

### Security

- [x] SQL injection : N/A — requêtes Drift typées (`select(...).where(...)`), aucune concaténation SQL.
- [x] XSS : N/A (Flutter natif).
- [x] Authentication flaws : N/A (app sans compte, public mineur).
- [x] Data exposure : zéro collecte respectée — aucun SDK réseau/analytics ajouté ; lecture 100 % locale Drift.
- [x] CORS : N/A.
- [x] Env vars : N/A — aucun secret introduit ; keystore non touché.

### Error management

- [x] Bloc journal : `onError` des 3 souscriptions Drift dispatche un payload neutre ; `conseilDuJour` throw → `status: erreur`. Pas de stack remontée à l'UI.
- [ ] Saisie : message d'exception brut affiché (voir 🟡).

### Performance

- [x] `context.select` utilisé dans `journal_view.dart:22` et `journal_segmented_control.dart:19` pour limiter les rebuilds au champ `vueActive`.
- [x] Souscriptions Drift fermées dans `close()` (`_cancelSubs`), `_subMois` annulé avant relance (`_relancerStreamMois`).
- [🟡] `journal_vue_jour/semaine/mois` utilisent `context.watch<JournalBloc>()` (rebuild sur tout changement de state) là où `context.select` ciblerait le sous-état pertinent — acceptable vu la taille des vues, micro-optimisation possible.

### Frontend specific

#### State Management

- [x] Loading states : `JournalStatus.chargement` géré.
- [x] Empty states : état vide bienveillant Jour, semaine/mois vides gérés (`journal*SummaryEmpty`).
- [x] Error states : `JournalStatus.erreur` (fallback bienveillant).
- [x] Success feedback : SnackBar exercice (stub), `HapticFeedback` au succès saisie.
- [x] Transition states : `AnimatedContainer` segment, désactivé en reduced-motion.

#### UI/UX

- [x] Design patterns cohérents (Card, AppSpacing, AppColors).
- [x] Cibles tactiles : segments 48dp, flèches mois 48×48 ; cases calendrier/semaine 40dp **non interactives** (pas de `onTap`) → la contrainte ≥48dp ne s'applique pas, OK.
- [x] Accessibilité : `Semantics` sur pastilles (label émotion), segments (`selected`), flèche suivant (`enabled: peutAvancer`), cases calendrier (clés sémantiques dédiées). Reduced-motion respecté.
- [x] Semantic HTML : N/A (Flutter).

### Backend specific

#### Logging

- [x] N/A — pas de backend ; aucun logging réseau (cohérent zéro-collecte).

## Final Review

- **Score**: 90/100 — conformité statique forte ; aucun bloquant runtime. Pénalités : duplication conseil/libellé (−3), message d'erreur brut (−2), divergence structure saisie/`utils` (−2), risque hygiène suppression règles VCS (−3).
- **Feedback**: Le cœur de la feature est propre et fidèle au plan (bloc-only, transformers explicites, Drift `watch()` jamais HydratedBloc, source d'émotion unique, zéro hex/emoji en dur, i18n complète sur 8 ARB, a11y/reduced-motion). Le segmented control refondu, la préselection humeur et le fix `busy_timeout` sont corrects et bien documentés. Le seul point réellement à arbiter avant merge est non-code : la suppression de `.claude/rules/*.mdc` du contrôle de version.
- **Follow-up Actions**:
  1. (🔴 process) Décider du sort des `.claude/rules/*.mdc` : ré-suivre ce sous-dossier ou acter explicitement leur dé-versionnement. Hors périmètre code — à trancher par le caller.
  2. (🟡) Extraire `texteConseil(l10n, cle)` dans `journal_emotion_utils.dart` et remplacer les 2 `_texteConseil` privés.
  3. (🟡) Remplacer `e.toString()` (`saisie_humeur_bloc.dart:84`) par une clé i18n d'erreur générique non technique.
  4. (🟡) Découpler l'affichage de `JournalCarteJour` de la présence du conseil (`journal_vue_jour.dart:22`).
  5. (🟡) Aligner la structure du dossier `saisie_humeur/bloc/` sur `{nom}_bloc/` et statuer sur `pages/journal/utils/`.
- **Additional Notes**:
  - Clés a11y `journalCalendarDayMoodSemantics` / `journalCalendarDaySemantics` ajoutées au-delà des 25 du plan §7 — amélioration accessibilité légitime (voir revue fonctionnelle, section Unplanned).
  - `flutter analyze` (clean) et `flutter test` (187 verts) non rejoués — confiance déléguée à la validation amont.
  - Les règles servant de validateur à cette revue ont été lues depuis le disque local (`.claude/rules/*.mdc`), encore présentes malgré leur suppression VCS.
