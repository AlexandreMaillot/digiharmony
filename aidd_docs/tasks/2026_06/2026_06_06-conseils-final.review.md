---
name: code-review
description: Revue finale — Conseils (finalisation) + Identité d'app (production-only)
argument-hint: N/A
---

# Code Review for Conseils (finalisation) + Identité d'app

Revue indépendante (contexte frais) de l'état consolidé `origin/alexandre` vs `origin/main`,
focalisée sur le lot récent non encore relu : finalisation du deck Conseils (Do's/Don'ts sur toutes
les cartes, tags thématiques distincts, fidélité UI, libellés tappables, correctif régression
`conseilDuJour`) et identité d'app production-only (icône adaptative Android, appiconset iOS sans
alpha, splash natif, nom « Digiharmony »).

- Statut: **SHIP** (conforme, 2 findings low non bloquants)
- Confidence: **élevée** (analyze 0 issue ; 99 tests conseils+data verts ; tests accueil/app verts)

---

## Main expected Changes

- [x] Do's/Don'ts présents sur **toutes** les cartes (rappel inclus, #22)
- [x] Tags thématiques distincts par carte (icône + libellé, #23)
- [x] Fidélité UI deck vs maquette new_screen13 (hauteur carte, streak dégradé, anim swipe-hint, #21)
- [x] Libellés « précédent »/« suivant » tappables (#24)
- [x] Correctif régression `conseilDuJour` (rotation sur génériques uniquement, jamais une clé émotion)
- [x] Icône adaptative Android production-only (`flutter_launcher_icons` → `src/production`, #20)
- [x] AppIcon iOS sans canal alpha
- [x] Splash natif (`flutter_native_splash` Android `src/production` + iOS `LaunchScreenProduction`)
- [x] Nom « Digiharmony » sur 3 flavors (sans « App »)

## Scoring

### A. Conformité plan (fonctionnel) vs `conseils.md`

- [🟢] **Composition déterministe par jour** `composeur_deck.dart:69-85` — `joursDepuisEpoch % nbGeneriques`, helper pur, aucun accès Drift. Testé CD-1..CD-10.
- [🟢] **Carte émotion en tête selon humeur du jour** `composeur_deck.dart:39-55` — `CarteEmotion` ajoutée en position 0 si humeur du jour + carte dédiée présente.
- [🟢] **Deck figé à l'ouverture** `conseils_bloc.dart:38-43` — lecture ponctuelle `take(1).toList()` (pas d'abonnement continu), DEC-CO-06.
- [🟢] **Fallback corpus vide** `composeur_deck.dart:58-67` + `conseils_bloc.dart:52-60` — au moins une `CarteRappel('tipDay01')`, jamais de crash/écran vide.
- [🟢] **Cohérence `conseilDuJour` ↔ `composerDeck`** `app_database.dart:411-443` — `cartesGeneriquesOrdonnees()` mutualisé (filtre `type_carte != 'emotion'`, ordre `ordre`/`id`, même modulo). Testé CDJ-1/2/3 (carte 0 générique == `conseilDuJour`).
- [🟢] **`_resoudreConseil` couvre toutes les clés possibles** `accueil_view.dart:161-190` — les 11 clés génériques (tipDay01..07 + conseilRappelPresent/Likes + conseilPratiqueInteractions/Espace) sont explicitement mappées ; aucune clé émotion ne peut arriver (filtre `conseilDuJour`). Le `default → tipDay01` est défensif et inatteignable en nominal.
- [🟢] **Pas de CTA « J'applique »** (DEC-CO-09) — absent de l'arbre ; carte conseil pratique sans CTA (`carte_conseil_pratique.dart`).
- [🟢] **Migration v3→v4 idempotente** `app_database.dart:196-279` — `PRAGMA table_info` avant chaque `addColumn`, `INSERT … WHERE NOT EXISTS` par `cle_conseil`, re-seed `_seedCorpus` idempotent par clé (`app_database.dart:292-341`). `conseilDuJour` non cassé (testé CDB-7).
- [🟢] **Do's/Don'ts sur chaque carte** — rappel (`carte_rappel.dart:40-41,104-114`), conseil (`carte_conseil_pratique.dart:38-39`), émotion (`carte_emotion.dart:35-36`).
- [🟢] **Tags distincts par carte** `_carte_shell.dart:252-264` + `284-429` — table `_iconesTag` + clés `…Tag` propres à chaque carte (Respiration/Énergie/Gratitude/Présence/Estime de soi/Relations/Espace…).

### B. Conformité règles (code)

- [🟢] **ZÉRO collecte** — aucun SDK réseau/analytics ajouté ; Conseils en LECTURE Drift seule (grep insert/update/delete sur `lib/pages/conseils/` = aucun). Seule permission Android = `PACKAGE_USAGE_STATS` (`AndroidManifest.xml:5`).
- [🟢] **ZÉRO chaîne UI en dur** — tout via ARB ; corpus/tags = clés résolues par `resoudreCleCorpus`/`resoudreLignes` (`_carte_shell.dart:239-279`). fr+en réels, repli `en` pour el/it/ro/tr/es/mk.
- [🟢] **ZÉRO hex dans les widgets** — grep `0xFF|Color(0x|#hex` sur `lib/pages/conseils/` = NONE. Émotion = `MoodColors.byKey[code]` (`carte_conseil.dart:78-79`), chrome = tokens (`carte_conseil.dart:64-70`). Violet jamais retourné en chrome (DEC-CO-07).
- [🟢] **Bloc-only + Equatable + transformers** `conseils_bloc.dart:22-25` — `restartable`/`droppable`, State Equatable + enum `status`, nommage FR.
- [🟢] **a11y reduced-motion** `conseils_view.dart:60-107,342-352,394` — particules OFF, halo statique, swipe-hint stoppé ; anim infinie `stop()`/`repeat()` selon `actif && !disableAnimations`.
- [🟢] **Nav sans geste** — flèches 48dp + `customSemanticsActions` (`conseils_view.dart:257-266`) + libellés tappables (#24).
- [🟢] **Aucun `pumpAndSettle` sur anim infinie** — seules occurrences = commentaires expliquant l'évitement.
- [🟢] **Dépendances en dev_dependencies** `pubspec.yaml:42-43` — hors `dependencies` runtime. Android `minify`/`shrinkResources = false` (`build.gradle.kts:82-83`).
- [🟢] **iOS production-only isolé** — `LAUNCH_STORYBOARD_NAME = LaunchScreenProduction` uniquement sur configs production (pbxproj 628/726/819) ; dev/staging → défaut `LaunchScreen` (`Info.plist:33`). Icônes `AppIcon` vs `AppIcon-dev`/`AppIcon-stg`. Appiconset sans alpha (`sips hasAlpha: no`). `CFBundleDisplayName = $(FLAVOR_APP_NAME)`.
- [🟡] **Clés ARB mortes** — `conseilsTagEquilibre`/`conseilsTagRappel` définies dans les 8 ARB, non référencées (L-1).
- [🟡] **Cible tap libellés nav < 48dp** `hint_swipe.dart:144-159` (L-2, mitigé).

---

## Findings

### L-1 (low) — Clés ARB mortes `conseilsTagEquilibre` / `conseilsTagRappel`
- **Localisation** : `lib/l10n/arb/app_en.arb:633,635` (+ 7 autres ARB).
- **Règle/critère** : §A.8 (clés ARB mortes) + hygiène i18n.
- **Constat** : plus référencées dans `lib/` ; remplacées par les tags thématiques (#23). `conseilsTagConseilPratique` reste utilisé en fallback (`carte_conseil_pratique.dart:51`).
- **Fix (NON appliqué)** : supprimer les 2 clés (+ `@…`) des 8 ARB, `flutter gen-l10n`.

### L-2 (low) — Cible tap des libellés de navigation < 48dp
- **Localisation** : `lib/pages/conseils/widgets/hint_swipe.dart:144-159` (`_LienNav`).
- **Règle/critère** : §B.5 (cibles ≥ 48dp).
- **Constat** : padding vertical `sm`(8) + texte 13px ≈ 29dp. Mitigé : chevrons 48×48 + Semantics fournissent le chemin a11y primaire.
- **Fix (NON appliqué)** : `ConstrainedBox(minHeight: 48)` ou padding vertical `md`.

---

## Final Review

### Exécution
- `flutter gen-l10n` : OK (2 messages non traduits/langue non-fr/en = repli `en` attendu).
- `flutter analyze` : **No issues found!** (0).
- `flutter test test/pages/conseils/ test/data/` : **All tests passed!** (99).
- `flutter test test/accueil/ test/app/` : **All tests passed!** (non-régression recâblage tuile).

### Severity breakdown
- critical: 0 | high: 0 | medium: 0 | low: 2

### Quality score : **96 / 100**

### Verdict : **SHIP**
