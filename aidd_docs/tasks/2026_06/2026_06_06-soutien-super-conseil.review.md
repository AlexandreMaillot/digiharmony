---
name: code-review
description: Code review checklist and scoring template
argument-hint: N/A
---

# Code Review for Écran de soutien (« Super conseil » / SoutienPage)

Revue statique des 8 commits soutien (M1→M7 + format) sur `feat/noter-humeur`,
non poussés, diff `e7d66b9..HEAD`. Écran SENSIBLE (public mineur, Erasmus+).
Garde-fous §0 du page plan `aidd_docs/tasks/soutien.md` et plan
`aidd_docs/plans/soutien-super-conseil.plan.md` traités comme faisant loi.

Les garde-fous sensibles (zéro numéro réel, table ressources vide, bloc-only,
compteur Drift dérivé non dupliqué, preview DEV derrière kDebugMode, hex en dur)
sont **respectés**. Trois faiblesses de tests (garde-fous tautologiques, haptic
non vérifié) et une **fragilité d'intégration du hook Demarrage** sont relevées.

- Statuts: PASS avec réserves (aucun finding 🔴 bloquant sur la sensibilité du contenu ; 1 finding 🟡 majeur sur la fiabilité du déclenchement)
- Confidence: 8/10 (analyze clean + 230 tests verts validés en amont ; revue centrée conformité statique + traçabilité plan↔code)

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

- [x] Compteur Drift dérivé `compterSaisiesNegativesConsecutives` + `aDeclencherSoutien` (M1)
- [x] `EvaluateurSoutien.doitDeclencher` logique pure (M2)
- [x] `SoutienBloc extends HydratedBloc` anti-relance (M3, PAS de Cubit)
- [x] Routing `versSoutien` + provider global + hook Demarrage post-splash (M4)
- [x] Clés i18n `soutien*` fr+en + repli en x6 (M5)
- [x] `SoutienView` + halo + 2 CTA + bloc ligne d'écoute conditionnel + `RessourceLigneEcoute` table vide (M6)
- [x] `ConfiancePage` + preview DEV `kDebugMode` + a11y (M7)

## Scoring

- [🟢] **Aucun numéro réel hardcodé** `lib/pages/soutien/**` — `grep -rn '3114'` sur tout le périmètre soutien : 0 occurrence. `tableRessources` = `const <String, RessourceLigneEcoute>{}` vide (`ressource_ligne_ecoute.dart:46-47`) avec `// TODO(partenaires)`. Garde-fou sensible respecté.
- [🟢] **Bloc ligne d'écoute masqué si vide** `bloc_ligne_ecoute.dart:24` `if (ressource == null) return const SizedBox.shrink();` — aucun bloc vide rendu.
- [🟢] **Bloc-only, aucun Cubit** `grep -rniE 'cubit' lib/pages/soutien/` : 0 occurrence. `SoutienBloc extends HydratedBloc<SoutienEvent, SoutienState>` (`soutien_bloc.dart:14`), events sealed (`soutien_event.dart:4`), transformer explicite `sequential()` (`soutien_bloc.dart:17-18`). Conforme `1-bloc-only-no-cubit` + `3-flutter-bloc-concurrency` + `3-flutter-sealed-class-mocktail`.
- [🟢] **Compteur Drift dérivé, lecture seule, non dupliqué** `app_database.dart:243-252` — `select(entreesHumeur)..orderBy([desc(creeLe)])).get()`, parcours, arrêt au 1er `valence >= 0`. Pas de bump `schemaVersion`. Pas de stockage du compteur dans HydratedBloc (`soutien_bloc.dart` ne sérialise que `shown`). Conforme DEC-001/002.
- [🟢] **Seuil centralisé unique** `app_database.dart:235` `static const int seuilSoutien = 7` ; `evaluateur_soutien.dart:12` `static const int seuil = AppDatabase.seuilSoutien`. Pas de nombre magique dupliqué (DEC-SOP-005).
- [🟢] **Preview DEV derrière kDebugMode** `accueil_view.dart:25-35` — `floatingActionButton: kDebugMode ? FloatingActionButton.small(...) : null`, commentaire « retiré du build release par tree-shaking ». Aucune entrée manuelle de prod. Conforme DEC-SOP-004.
- [🟢] **Aucun hex en dur** `grep -rn '0xFF\|0x[0-9a-fA-F]{6,8}' lib/pages/soutien/` : 0 occurrence. Tokens `AppColors`/`AppSpacing`/`AppRadii`/`withValues(alpha:)` partout. Conforme DEC-SO-009 + `3-flutter-withvalues`.
- [🟢] **Ton non alarmant** : halo `AppColors.primary.withValues(alpha: 0.18)` (`halo_soutien.dart:25-27`), aucun rouge, aucun streak/score. Texte « Aucune relance » présent (`soutien_view.dart:144`). Anti-relance marqué à l'affichage (`demarrage_view.dart:131` `add(SoutienMontre())` avant le push). Conforme DEC-SO-012.
- [🟢] **a11y reduced-motion** `halo_soutien.dart:32-34` `if (disableAnimations) return halo;` (halo statique, pas de boucle). Cibles ≥ 48dp : chevron `BoxConstraints(minWidth/minHeight: 48)` (`soutien_view.dart:39-42`), CTA `minimumSize: Size(48,48)` (`bouton_action_soutien.dart:69/87`). `HapticFeedback.lightImpact()` au tap (`bouton_action_soutien.dart:58/74`). Conforme DEC-SO-010.
- [🟢] **i18n, aucune chaîne UI en dur côté soutien_view/confiance** — 11 clés `soutien*` présentes dans les 8 ARB (fr+en réels, repli en x6). EN porte les marqueurs `TODO validation partenaires` via `@`-descriptions (`app_en.arb:340-382`). Conforme `3-flutter-i18n`.
- [🟢] **Zéro collecte / aucun SDK réseau** — seul `url_launcher` importé (`bloc_ligne_ecoute.dart:5`) pour `tel:`/`https:`. `canLaunchUrl`/`launchUrl(externalApplication)`, échec → SnackBar neutre, pas de crash, pas de log (`bloc_ligne_ecoute.dart:100-120`).
- [🟢] **Hook Demarrage append-only + context.mounted** `demarrage_view.dart:104-135` — `if (!context.mounted) return;` après chaque `await` (3 gardes). `DemarragePret()`/`DemarrageErreur()` partagent le handler ; le comportement « toujours router vers Accueil » est conservé.
- [🟡] **Le hook de déclenchement soutien est probablement inerte au runtime** `demarrage_view.dart:104-135` — `versAccueil` fait un `pushReplacement` (`app_router.dart:26`) qui démonte `DemarrageView`. Le `BuildContext` de `_onEtat` devient defunct ; `if (!context.mounted) return;` ligne 106 court-circuite alors la lecture du compteur AVANT tout déclenchement. Aucun test ne prouve le chemin `compteur>=7 → push SoutienPage` depuis Demarrage (les tests `demarrage_navigation_test.dart` NAV-1/NAV-2 passent justement parce que la branche se court-circuite, cf. `takeException isNull`). Le plan flaggait ce risque (M4 confiance 9/10). À valider par un test d'intégration réel ou en réordonnant (évaluer AVANT `pushReplacement`, ou capturer `db`/`soutienBloc` avant l'await — déjà capturés ligne 108-110, mais le `await db.compter...()` ligne 112 + garde 114 reste sous risque de démontage). Voir review fonctionnelle (critère M4-AC2 Unmet/Major).
- [🟡] **Garde-fous « pas de 3114 » tautologiques** `ressource_ligne_ecoute_test.dart:18-26` itère sur `tableRessources.values` qui est VIDE → l'assertion ne s'exécute jamais. `soutien_view_test.dart:178-184` (SO-VIEW-8) teste `const source = ''` et asserte qu'une chaîne vide ne contient pas '3114' → toujours vrai, ne lit aucune source. Le vrai garde-fou opérationnel est `SO-RES-2` (`tableRessources isEmpty`), qui est solide tant que la table reste vide ; les deux tests « 3114 » donnent une fausse assurance. Remplacer par une lecture effective du fichier source ou un test sur le contenu de la map quand elle sera remplie.
- [🟡] **HapticFeedback non vérifié par test** `soutien_view_test.dart` — le plan §10 demandait un test mock-channel confirmant le déclenchement haptique au tap. SO-VIEW-6/7 ne couvrent pas le haptic. Le code l'appelle bien (`bouton_action_soutien.dart:58/74`) mais le critère de test reste non couvert.
- [🟡] **Reduced-motion non assertée** `soutien_view_test.dart:140-152` (SO-VIEW-6) ne vérifie que la présence de `HaloSoutien`, sans asserter l'absence d'animation en `disableAnimations: true` (commentaire l'admet : « On verifie juste que le widget est present »). La logique statique existe (`halo_soutien.dart:32`) mais n'est pas verrouillée par un test.
- [🟢] **FR ARB sans marqueur TODO par clé** `app_fr.arb:76-86` — pas de `@`-description « À VALIDER » côté fr (seul EN les porte). Le plan acceptait « commentaire OU métadonnée `@` équivalente » ; EN couvre la traçabilité de validation. Non bloquant, simple asymétrie fr/en.
- [🟢] **SnackBar d'erreur en dur (FR)** `bloc_ligne_ecoute.dart:116` `Text("Impossible d'ouvrir ce lien.")` — chaîne UI en dur non i18n. Code mort tant que `tableRessources` est vide (le bouton n'est jamais rendu), donc impact nul en V1 ; à externaliser en clé i18n avant remplissage partenaires. Classé 🟢 car non atteignable en production V1.

## Code Quality Checklist

### Potentially Unnecessary Elements

- [x] `SoutienState.copyWith` (`soutien_state.dart:18-23`) défini mais non utilisé par le bloc (les emits passent par constructeurs directs). Couvert par test SO-BLOC-8. Bénin.
- [x] Changements de format `journal_segmented_control.dart` (commit `5183e2e`) hors périmètre fonctionnel soutien — purement cosmétiques (dart format), sans risque.

### Standards Compliance

- [x] Naming conventions followed — couche données en français (`compterSaisiesNegativesConsecutives`, `seuilSoutien`), suffixes Flutter (`Bloc`/`Event`/`State`/`View`/`Page`) conservés. Conforme `1-french-naming-code`.
- [x] Coding rules ok — `0-flutter-pages-structure` : arbo `lib/pages/soutien/{bloc,views,widgets,modeles,confiance,declenchement}` + tests miroir. `3-hydrated-bloc` : `id`/`fromJson`/`toJson` présents, clé `'shown'`. `3-flutter-bloc-concurrency` : `sequential()` explicite.

### Architecture

- [x] Design patterns respected — HydratedBloc calqué sur `BienvenueBloc` ; évaluateur pur isolé ; compteur dérivé Drift.
- [x] Proper separation of concerns — décision (`EvaluateurSoutien`) / état (`SoutienBloc`) / données (`AppDatabase`) / UI (`SoutienView`) séparés. ⚠️ Couplage d'intégration fragile : la séquence du hook Demarrage (push Accueil PUIS évaluer) dépend du cycle de vie du contexte (voir finding 🟡 hook inerte).

### Code Health

- [x] Functions and files sizes — fichiers courts, méthodes lisibles.
- [x] Cyclomatic complexity acceptable.
- [x] No magic numbers/strings — seuil centralisé (`seuilSoutien`). Note : `width/height: 320` et `80` (halo/icône) et `height: 36/52` (logo/bouton) sont des dimensions de layout littérales non tokenisées (`AppSpacing` couvre les paddings, pas les tailles de composants) — pratique courante du repo, non bloquant.
- [x] Error handling complete — `try/on Exception` autour de `canLaunchUrl`/`launchUrl` (`bloc_ligne_ecoute.dart:101-111`).
- [ ] User-friendly error messages implemented — message d'échec en dur non i18n (`bloc_ligne_ecoute.dart:116`), voir finding.

### Security

- [x] SQL injection risks — N/A (query builder Drift typé, pas de SQL brut).
- [x] XSS vulnerabilities — N/A (Flutter natif).
- [x] Authentication flaws — N/A (app sans compte).
- [x] Data exposure points — **zéro collecte vérifiée** : aucun SDK réseau/analytics, seul `url_launcher` (sortie vers app tierce, rien envoyé/journalisé). Conforme garde-fou §0.
- [x] CORS configuration — N/A.
- [x] Environment variables secured — N/A.

### Error management

- [x] Échec d'ouverture ressource → SnackBar neutre, pas de crash, pas de log distant (`bloc_ligne_ecoute.dart:113-120`).

### Performance

- [x] Compteur lu ponctuellement (`.get()`), pas de `watch()` permanent — conforme intention « évaluation unique à l'ouverture ».

### Frontend specific

#### State Management

- [x] Loading states implemented — N/A (écran transitoire, pas de chargement distant).
- [x] Empty states designed — bloc ligne d'écoute masqué si pas de ressource.
- [x] Error states handled — SnackBar échec ouverture.
- [x] Success feedback provided — HapticFeedback au tap.
- [x] Transition states smooth — halo animé (désactivé reduced-motion).

#### UI/UX

- [x] Consistent design patterns — toolbar douce partagée SoutienView/ConfiancePage, tokens thème.
- [x] Responsive design implemented — `SingleChildScrollView` + `Column stretch`.
- [x] Accessibility standards met — `Semantics` sur chevron (`soutien_view.dart:31`) et CTA (`bouton_action_soutien.dart:49`), cibles ≥ 48dp, reduced-motion. Conforme `7-testing-frontend` côté implémentation (réserves sur la couverture de test : haptic + reduced-motion non assertés).
- [x] Semantic HTML used — N/A (Flutter), Semantics équivalent présent.

### Backend specific

#### Logging

- [x] Logging implemented — N/A (zéro collecte ; aucun log distant par conception, conforme).

## Final Review

- **Score**: 8.5/10
- **Feedback**: Implémentation conforme aux garde-fous SENSIBLES (aucun numéro réel, table vide, bloc masqué si vide, bloc-only sans Cubit, compteur Drift dérivé non dupliqué sans bump schéma, preview DEV tree-shakée, zéro hex en dur, zéro collecte, a11y présente). **Aucun finding 🔴 bloquant sur la sensibilité du contenu.** Réserves : (1) le hook de déclenchement Demarrage est très probablement inerte au runtime car `pushReplacement` démonte le contexte avant l'évaluation et aucun test ne couvre le chemin de déclenchement réel — 🟡 majeur ; (2) deux garde-fous « pas de 3114 » sont tautologiques (boucle sur map vide / chaîne vide) et donnent une fausse assurance — à durcir avant remplissage partenaires ; (3) haptic et reduced-motion non assertés par test ; (4) message d'erreur en dur non i18n (code mort en V1).
- **Follow-up Actions**:
  1. (🟡 majeur) Ajouter un test d'intégration Demarrage prouvant `compteur>=7 → SoutienMontre + push SoutienPage`, et corriger l'ordre d'évaluation pour qu'il survive au `pushReplacement` (évaluer avant le replacement, ou ne pas dépendre du `context.mounted` du DemarrageView pour la lecture du compteur).
  2. Remplacer les garde-fous tautologiques `SO-RES-3` et `SO-VIEW-8` par une lecture effective des sources / une assertion sur le contenu réel.
  3. Ajouter le test mock-channel HapticFeedback et l'assertion reduced-motion (absence d'`Animate` en boucle).
  4. Externaliser `"Impossible d'ouvrir ce lien."` en clé i18n avant remplissage de `tableRessources`.
  5. (mineur) Aligner fr sur en pour les marqueurs « À VALIDER » par clé.
- **Additional Notes**: 230 tests verts + analyze clean confirmés en amont (non re-exécutés ici). Validation humaine partenaires (textes + numéros) reste bloquante hors périmètre code, correctement matérialisée par les placeholders et la table vide.
