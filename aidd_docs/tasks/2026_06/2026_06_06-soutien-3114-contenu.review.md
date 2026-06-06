---
name: code-review
description: Code review checklist and scoring template
argument-hint: N/A
---

# Code Review for Soutien / Super conseil — contenu + 3114 + fix déclenchement

Revue stricte du diff `git diff 5183e2e..HEAD` (commits `9750c14` fix déclenchement, `0c1b47e`/`02f2a02`/`ca46fa0` contenu + docs). Priorité utilisateur : conformité aux règles projet et **chasse au texte en dur (i18n)**. Aucun fichier de code modifié.

- Statuts: **CHANGES REQUESTED** — 1 finding 🔴 bloquant (régression i18n), 1 finding 🟡 (3114 fallback toutes langues), reste conforme.
- Confidence: Élevée (diff lu intégralement, règles `.mdc` croisées, plan `soutien-super-conseil.plan.md` confronté ligne à ligne).

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

- [x] Ajout du 3114 (numéro national prévention suicide FR) comme entrée `fr` de `tableRessources`, utilisé en fallback toutes locales.
- [x] Refonte maquette `BlocLigneEcoute` (carte tappable, icône `phone` verte + `open_in_new` verte).
- [x] Token couleur `AppColors.vertAppel` (`#34C759`) dans `theme.dart`.
- [x] `ConfiancePage` : 5 pistes bienveillantes via clés i18n `soutienConfiancePiste01..05`.
- [x] Fix séquence de déclenchement post-splash (`demarrage_view.dart`) : `unawaited(pushReplacement)` + capture du `Navigator`/blocs avant `await`.
- [x] Clé i18n `soutienErreurLien` (SnackBar échec ouverture).
- [ ] **Régression** : suppression des clés `soutienLignePrefix`/`soutienLigneDispoPrefix` au profit de chaînes FR codées en dur dans le modèle Dart.

## Scoring

- [🔴] **i18n — texte en dur (RÉGRESSION)** `lib/pages/soutien/modeles/ressource_ligne_ecoute.dart:56,59` — `nom: "Ligne d'écoute"` et `disponibilite: 'Disponible 24h/24'` sont des **libellés d'interface FR codés en dur** dans le modèle Dart, rendus tels quels par `bloc_ligne_ecoute.dart:51` (`Text(ressource.nom)`) et `:58` (`Text('${ressource.cible} — ${ressource.disponibilite}')`). Ce diff **supprime** les clés ARB existantes `soutienLignePrefix` (« Ligne d'écoute : » / « Helpline: ») et `soutienLigneDispoPrefix` (`app_fr.arb` / `app_en.arb`, retirées dans le diff). Conséquence concrète : un utilisateur **non-FR** (en/el/it/ro/tr/es/mk) qui passe par le fallback `fr` voit « Ligne d'écoute » et « Disponible 24h/24 » **en français non traduit**. Viole `3-flutter-i18n.mdc` (« INTERDIRE tout texte en dur… Aucune exception ») et `coding-assertions.md:21` (« Toute chaîne UI passe par l'ARB »). Viole AUSSI le plan qui fait loi (`soutien-super-conseil.plan.md` §5(5), M6 §398 : « `soutienLignePrefix`+nom, `soutienLigneDispoPrefix`+dispo »). **Distinction donnée/UI** : seul `cible='3114'` est une donnée partenaire légitime (numéro par pays). « Ligne d'écoute » est un **libellé générique d'UI** → doit être une clé i18n (ex. `soutienLigneTitre`). « Disponible 24h/24 » est aussi un libellé localisable → clé i18n (ex. `soutienLigneDispo`), seule la valeur du numéro restant une donnée. *(Correctif : réintroduire `soutienLigneTitre`/`soutienLigneDispo` dans les 8 ARB ; `BlocLigneEcoute` affiche `l10n.soutienLigneTitre` + `'${ressource.cible} — ${l10n.soutienLigneDispo}'` ; ne garder dans le modèle que `cible`/`type`.)*
- [🟡] **Sensibilité contenu mineur — 3114 montré à toutes les locales** `ressource_ligne_ecoute.dart:55` — Le 3114 est France-only. Le fallback `fr` l'affiche à `en/el/it/ro/tr/es/mk`. La réserve est **tracée** (commentaire `TODO(partenaires)` lignes 48-50, docstring `DEC-SO-007` lignes 12-14, `Hors périmètre V1` du plan). Ce n'est donc pas un oubli mais une **dette assumée**. Reste un risque produit réel : un mineur non-français pourrait composer un numéro non opérant dans son pays. (Suggestion : masquer le bloc pour les locales sans entrée propre — comportement d'origine prévu par DEC-SO-007 « bloc masqué si absente » — OU bloquer le numéro derrière une garde locale `fr` explicite tant que les partenaires n'ont pas validé les autres pays.)
- [🟢] **Hex en dur** — Aucun `0xFF` dans `lib/pages/soutien/**`. Le token `vertAppel` vit bien dans `theme.dart:39`, jamais d'hex dans le widget (`bloc_ligne_ecoute.dart:42,69` consomment `AppColors.vertAppel`). Conforme à la règle DON'T du plan §154.
- [🟢] **`withValues` vs `withOpacity`** — Aucun `withOpacity` dans le diff ; `demarrage_view.dart:188` utilise `AppColors.primary.withValues(alpha: 0)`. Conforme `3-flutter-withvalues.mdc`.
- [🟢] **Bloc-only / no Cubit** — Aucun `Cubit` introduit. `SoutienBloc` (HydratedBloc) inchangé dans ce diff. Conforme `1-bloc-only-no-cubit`.
- [🟢] **Nommage FR** — `RessourceLigneEcoute`, `tableRessources`, `_ouvrirRessource`, `_versAccueilPuisEvaluerSoutien`, `compterSaisiesNegativesConsecutives` : couche/logique en français. Conforme `1-french-naming-code`.
- [🟢] **Structure pages** — Fichiers sous `lib/pages/soutien/{modeles,widgets,confiance,views}`. Conforme `0-flutter-pages-structure` + DEC-SOP-002.
- [🟢] **StatelessWidget / extraction** — `BlocLigneEcoute`, `ConfiancePage`, `_BlocMarque`, `_FooterFinancement`, `_LogoAnime` sont des `StatelessWidget` ; aucune méthode `_buildX()` retournant un widget. Conforme `01-widget-extraction` + `3-flutter-stateless-widgets`. *(Note 🟢 mineure : `ConfiancePage` construit `pistes.map(...)` inline ; acceptable — pas une méthode helper widget, et la liste est courte.)*

## Code Quality Checklist

### Potentially Unnecessary Elements

- [x] Aucun import mort introduit. `url_launcher` est la seule dépendance de sortie (conforme zéro-collecte).

### Standards Compliance

- [x] Naming conventions followed (français côté données/logique, anglais autorisé pour suffixes Event/State).
- [ ] **Coding rules ok** — `3-flutter-i18n` + `coding-assertions §21` **violés** par les chaînes FR en dur du modèle (voir 🔴).

### Architecture

- [x] Design patterns respectés (modèle de données séparé de la vue, table statique, HydratedBloc pour le flag).
- [x] Separation of concerns OK (donnée `RessourceLigneEcoute` ≠ widget `BlocLigneEcoute`). **Réserve** : le mélange donnée/UI dans le modèle (libellé « Ligne d'écoute ») casse justement cette séparation et est la cause racine du 🔴.

### Code Health

- [x] Tailles de fichiers/fonctions raisonnables.
- [x] Complexité cyclomatique acceptable (`_versAccueilPuisEvaluerSoutien` linéaire, commentée).
- [ ] **No magic numbers/strings** — chaînes UI en dur (« Ligne d'écoute », « Disponible 24h/24 ») = magic strings d'interface (voir 🔴). Les `fontSize: 13` (`bloc_ligne_ecoute.dart:61`), `size: 24/20/6` (icônes) sont des littéraux numériques de style tolérés ici mais hors tokens (`AppSpacing`/`AppRadii` couvrent espacements/rayons, pas les tailles d'icône) — 🟢 mineur, non bloquant.
- [x] Error handling complet (try/catch sur `canLaunchUrl`/`launchUrl`).
- [x] Messages d'erreur user-friendly (`soutienErreurLien` via SnackBar i18n).

### Security

- [x] SQL injection : N/A (lecture Drift typée, pas de SQL brut concaténé dans ce diff).
- [x] XSS : N/A (Flutter natif).
- [x] Authentication flaws : N/A (app 100% locale, sans backend).
- [x] Data exposure : conforme zéro-collecte — seule sortie = `launchUrl` (`tel:`/`https:`), rien envoyé, rien journalisé à distance.
- [x] CORS : N/A.
- [x] Environment variables : N/A.

### Error management

- [x] **Pas de catch silencieux critique** (`7-catch-silencieux-lookup`) — `bloc_ligne_ecoute.dart:100-112` : `on Exception` → `succes=false` PUIS feedback UX explicite (`SnackBar(soutienErreurLien)`). Le `canLaunchUrl==false` (`:94`) mène aussi au même SnackBar. Pas de `catch(_){}` muet sur le critical path. Conforme. *(Note : pas de `developer.log` ; la règle l'exige pour les exceptions, mais l'app est zéro-collecte et le feedback UX est présent → tolérable, 🟢.)*

### Performance

- [x] `BlocLigneEcoute` est `const`-friendly ; lookup `tableRessources[...]` O(1). Pas de recalcul coûteux en build.

### Frontend specific

#### State Management

- [x] Loading states : N/A (écran statique).
- [x] Empty states : bloc masqué si `ressource == null` (`bloc_ligne_ecoute.dart:28`).
- [x] Error states : SnackBar échec ouverture.
- [x] Success feedback : ouverture app tierce (système).
- [x] Transition states : reduced-motion géré côté `demarrage_view` (halo statique, `disableAnimations`).

#### UI/UX

- [ ] **Consistent design patterns** — `vertAppel` (`#34C759`) est un vert d'action distinct du « calme » émotions (`#2FAE5F`) et du dégradé signature : OK vs `design-system.md` (« Succès = vert dédié distinct du calme »). 🟢. **Mais** la cohérence i18n est rompue (libellé FR figé) → 🟡 UX pour non-FR.
- [x] Responsive : `Expanded`/`Row` adaptatifs, pas de largeur fixe sur le texte.
- [ ] **Accessibility** — Cibles tactiles : `confiance_page.dart:37` chevron `minWidth/minHeight: 48` ✅ ≥48dp. `BlocLigneEcoute` : `InkWell` sur toute la carte avec `Padding(AppSpacing.md)` → hauteur effective ≥48dp ✅. Reduced-motion géré en amont. **Réserve a11y** : pas de `Semantics` explicite sur la carte `BlocLigneEcoute` (action « appeler ») ; le label vocal sera la concaténation brute `nom — cible — dispo`, en français figé pour les non-FR (conséquence du 🔴). 🟡.
- [x] Semantic HTML : N/A (Flutter).

### Backend specific

#### Logging

- [x] N/A — pas de backend ; logging distant **interdit** (zéro-collecte). Conforme.

## Final Review

- **Score**: 72/100 — Le code est propre sur tokens, no-Cubit, structure, gestion d'erreur, nommage FR et sécurité. Un **bloquant i18n** (régression de chaînes FR en dur + suppression de clés ARB existantes) le maintient sous le seuil de passage.
- **Feedback**:
  - 🔴 **BLOQUANT** : réintroduire les libellés `nom` (« Ligne d'écoute ») et `disponibilite` (« Disponible 24h/24 ») comme **clés i18n** (`soutienLigneTitre`/`soutienLigneDispo`) dans les 8 ARB ; les consommer dans `BlocLigneEcoute` via `context.l10n`. Ne laisser dans `RessourceLigneEcoute` que `cible` (donnée numéro) et `type`. Sans ce correctif, tout utilisateur non-FR voit du français non traduit (violation directe d'une règle `alwaysApply: true`).
  - 🟡 Décider explicitement du sort du 3114 hors France (masquer le bloc pour locales sans entrée validée, ou garde locale `fr`) — la dette est tracée mais le risque produit pour public mineur non-français est réel.
- **Follow-up Actions**:
  1. Recréer `soutienLigneTitre` + `soutienLigneDispo` (fr+en, repli en x6) avec `@description` « TODO validation partenaires ».
  2. Refactor `BlocLigneEcoute` pour consommer ces clés ; retirer `nom`/`disponibilite` du modèle (ou les garder comme champs purement optionnels non rendus).
  3. Mettre à jour `SO-RES-2` (test) qui fige `fr.nom == "Ligne d'écoute"` — ce test verrouille actuellement la régression.
  4. Trancher la garde locale du 3114 (DEC-SO-007 évolutive).
- **Additional Notes**:
  - Le fix de déclenchement (`demarrage_view.dart`) est **correct et réellement prouvé** : l'ancien code awaitait `versAccueil` (= `pushReplacement`, Future qui ne se résout jamais), rendant l'évaluation soutien inatteignable au runtime. Le nouveau capture le `Navigator` avant tout `await`, lit le compteur, puis `unawaited(pushReplacement)`. Les tests NAV-S-1..4 (`demarrage_navigation_test.dart`) couvrent `compteur≥7→SoutienMontre+SoutienPage`, `<7→rien`, `déjàMontré→pas de re-push`, `réarmement<7+flag→SoutienReinitialise`.
  - Garde-fous « pas d'autre numéro réel » **intacts et efficaces** : `SO-RES-3` (liste noire 116111/119/3919/15/112/988… dans les ARB) + assertion stricte `fr.cible == '3114'`. ARB sans numéro. Ton non alarmant, aucune relance, zéro collecte respectés.
