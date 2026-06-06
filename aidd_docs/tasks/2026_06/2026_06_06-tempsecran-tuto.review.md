---
name: code-review
description: Code review checklist and scoring template
argument-hint: N/A
---

# Code Review for « Mon temps d'écran » + « Réduire mes notifications »

Revue de code des deux features livrées dans `c3a2d78..HEAD` (code = commit `fd18be4`).
Périmètre = **commits uniquement** (working tree iOS non commité ignoré). Priorité utilisateur :
**STRICT i18n / texte en dur + règles projet**.

Bilan : implémentation propre, conforme aux garde-fous structurants (zéro collecte, Bloc-only,
i18n 8 langues, tokens design-system, aucun natif pour le tuto, channel `usage_access` seul). **Aucun
texte en dur utilisateur trouvé. Aucun hex/emoji en dur.** Les findings sont **mineurs** (clés i18n
mortes, magic numbers) + **un risque non vérifié** (Kotlin non compilé) + **une lacune de test**
(migration v2→v3 réelle non exercée).

- Statuts: 🟢 APPROUVÉ AVEC RÉSERVES MINEURES (aucun bloquant)
- Confidence: Élevée (analyze clean + 271 tests verts annoncés ; build Kotlin natif **non compilé** = seul angle mort)

---

- [Main expected Changes](#main-expected-changes)
- [Scoring](#scoring)
- [Code Quality Checklist](#code-quality-checklist)
- [Final Review](#final-review)

## Main expected Changes

- [x] Page « Mon temps d'écran » : Bloc + façade `ServiceTempsEcran` + vues d'états + agrégation pure
- [x] MethodChannel `digiharmony/usage_access` (Kotlin) dans `MainActivity` (`com.creappi.digiharmony`)
- [x] Migration Drift `schemaVersion 2→3` + table `UsagesEcranJournaliers` (historique local)
- [x] Tutoriel « Réduire mes notifications » OS-aware **statique** (StatelessWidget, aucun natif)
- [x] Routes `versTempsEcran` / `versTutoNotifs` + 2 liens Accueil (recâblage + ajout append-only)
- [x] 46 clés ARB ajoutées × 8 langues (fr/en réels, repli en) + gen-l10n commité
- [x] Suppression du doublon stale `com/creappi/digiharmony_app/MainActivity.kt`

## Scoring

- [🟢] **Texte en dur (i18n)** : aucune chaîne FR/EN en dur côté utilisateur. Balayage complet des deux
  feature dirs : seuls matches = commentaires, noms de méthodes `MethodChannel` (`'aLAcces'`,
  `'ouvrirReglagesAcces'`), set de segments techniques de `nomLisible` (`{'com','android','app',...}`),
  label `Semantics` composé de chaînes déjà localisées (`'${etape.titre}. ${etape.corps}'`), et `'$numero'`.
- [🟢] **Hex / emoji en dur** : aucun. Toutes les teintes via `AppColors.*` ; `withValues` (jamais
  `withOpacity`) ; badge/halo/encouragement via tokens (`AppColors.primary`/`accentGold`/`surface`).
- [🟢] **`MoodColors` non utilisé** dans ces écrans (garde-fou respecté : pas un écran d'humeur).
- [🟢] **Bloc-only / transformers** : `TempsEcranBloc` est un `Bloc` (pas Cubit) ; transformers explicites
  `restartable()` (Demarre/RevenuAuPremierPlan/Reessaye = chargement) et `droppable()`
  (PermissionDemandee = action critique). Conforme `1-bloc-only-no-cubit` + `3-flutter-bloc-concurrency`.
- [🟢] **Façade mockable** : `ServiceTempsEcran` (`abstract interface class`) + impl injectable
  (`canal`/`appUsage` paramétrables). Tests mockent la façade, pas le `MethodChannel`. Conforme DEC-TE-08.
- [🟢] **Sealed + mocktail** : `TempsEcranEvent` sealed + `final class` ; tests utilisent `whenListen` avec
  `initialState` réel (pas de `Fake` cross-library). Conforme `3-flutter-sealed-class-mocktail`.
- [🟢] **StatelessWidget / pas de méthode→Widget** : `_Contenu` (temps_ecran) et widgets factorisés sont
  des classes ; le switch d'états vit dans `_Contenu.build` (classe, pas méthode `_buildX`). Conforme
  `3-flutter-stateless-widgets`. Le tuto est `StatefulWidget` **uniquement** pour la bascule OS locale
  (justifié par la RÉVISION Banani, état UI pur sans logique métier).
- [🟢] **Nommage FR** : dossiers/classes/fichiers FR (`temps_ecran`, `TempsEcranBloc`, `vue_resume.dart`…) ;
  suffixes `Event`/`State` (dérogation actée). Conforme `1-french-naming-code`.
- [🟢] **Structure pages** : `temps_ecran/{bloc,modeles,services,views,widgets}` + `tuto_notifs/{modeles,
  views,widgets}` — aligné sur le précédent projet (`saisie_humeur`, `soutien`). Le sous-dossier
  `{nom}_bloc/` de la `.mdc` n'est pas la convention de CE repo (toutes les pages existantes sont en
  `bloc/` plat) → pas une violation.
- [🟢] **Zéro collecte / persistance** : tuto = `RepositoryProvider` absent, aucun Drift/HydratedBloc, aucun
  service natif. Temps d'écran = seul l'**agrégat total** (secondes) persisté dans Drift (DEC-TE-04 révisé,
  local) ; le détail par app reste éphémère. Aucune permission ajoutée, aucune dépendance pub, manifeste
  inchangé (vérifié sur le diff).
- [🟢] **Socle natif** : `MainActivity` (`com.creappi.digiharmony`) n'enregistre **que** `usage_access`.
  **Aucun** channel `notification_settings`, **aucun** `ServiceReglagesNotifs` (RÉVISION Banani respectée :
  le tuto ne câble pas de natif). Doublon stale `digiharmony_app/MainActivity.kt` **supprimé** (vérifié).
- [🟡] **Clés i18n mortes** : `tempsEcranTitre` et `tempsEcranSousTitre` sont définies dans les 8 ARB mais
  **jamais référencées** dans le code (la toolbar affiche le logo ; aucun sous-titre rendu). Q-TE-7 du plan
  tranchait « réutiliser `homeScreenTime` » — d'où des clés orphelines. Mineur (poids mort i18n, pas de bug).
  (`lib/l10n/arb/app_*.arb` : `tempsEcranTitre`, `tempsEcranSousTitre`)
- [🟡] **Magic numbers de layout** : valeurs nues au lieu de tokens —
  `carte_etape.dart:46-47` badge `width: 32, height: 32` + `size: 22` ; `ligne_app.dart:61` `Radius.circular(4)`
  + `:62` `minHeight: 6` ; `vue_permission.dart:28` `size: 56` ; `vue_etat_message.dart:40` `size: 48` ;
  `temps_ecran_view.dart:61`/`tuto_notifs_view.dart:130` logo `height: 32`. Le design-system expose
  `AppRadii`/`AppSpacing` mais pas de tokens « tailles d'icône/badge ». Cohérent avec l'existant du projet
  (les rayons inline `10`/`4` existent déjà dans `accueil_view`/`saisie_humeur`). Mineur.
- [🟡] **Catch silencieux `on Object`** : `temps_ecran_bloc.dart:84-88` avale l'échec d'écriture Drift sans
  log (best-effort assumé, affichage prioritaire) ; `:95-97` mappe toute exception en `erreur`. Intentionnel
  et documenté (zéro remontée réseau = pas de Crashlytics). Acceptable, mais aucune trace locale en debug.
- [🟡] **`copierAvec` n'efface jamais `resume`** : `TempsEcranState.copierAvec` utilise `resume ?? this.resume`,
  donc un retour `permissionRequise`/`vide`/`erreur` après un état `pret` **conserve** l'ancien `resume` dans
  le state (non rendu, car le switch ignore `resume` hors `pret`). Le chemin `pret` reconstruit un `TempsEcranState(...)` neuf (resume frais) → pas de bug d'affichage observable. À noter pour robustesse. Mineur.
- [🟡] **`_basculerOs` ne réinitialise pas le scroll** : bascule iOS↔Android via `setState` sans remettre le
  `SingleChildScrollView` en haut — cosmétique, non bloquant.

## Code Quality Checklist

### Potentially Unnecessary Elements

- [x] Clés ARB `tempsEcranTitre` / `tempsEcranSousTitre` non consommées (voir finding 🟡 ci-dessus).

### Standards Compliance

- [x] Naming conventions FR respectées (`1-french-naming-code`)
- [x] Coding rules ok : `1-bloc-only-no-cubit`, `3-flutter-bloc-concurrency`, `3-flutter-withvalues`,
  `3-flutter-stateless-widgets`, `3-flutter-sealed-class-mocktail`, `0-flutter-pages-structure`, `3-flutter-i18n`

### Architecture

- [x] Façade plateforme isolée et injectée (`ServiceTempsEcran`) ; frontière de route via `MultiRepositoryProvider`
- [x] Séparation vues d'états en widgets dédiés ; helpers purs (`agregeUsage`/`formaterDuree`/`nomLisible`)
- [x] Cycle de vie observé par la View (`WidgetsBindingObserver`), pas par le Bloc (testabilité)

### Code Health

- [x] Tailles de fichiers raisonnables (< 200 lignes), complexité faible
- [ ] Magic numbers de layout résiduels (mineur, voir 🟡)
- [x] Helpers purs déterministes, bien testés isolément (AC12)
- [x] Gestion d'erreur présente (états `erreur`/`vide`/`indisponible`, jamais de crash)
- [x] Messages utilisateur bienveillants et localisés (ton non culpabilisant : pas de score/objectif/jauge)

### Security

- [x] Pas de SQL injection : Drift typé ; les `customStatement` de migration sont des constantes (pas
  d'interpolation d'entrée utilisateur)
- [x] Pas d'exposition de données : usage 100 % local, jamais transmis ; aucun SDK réseau ajouté
- [x] Permissions : aucune ajoutée ; manifeste inchangé ; `PACKAGE_USAGE_STATS` (déjà présent) seul
- [x] Variables d'environnement / secrets : N/A

### Error management

- [x] Exceptions natives → état `erreur` + « Réessayer » ; échec persistance Drift non bloquant.
- [🟡] Catch `on Object` silencieux (sans log debug) — intentionnel, voir finding.

### Performance

- [x] Agrégation O(n log n) sur une liste d'apps (petite) ; recalcul à l'ouverture/resumed uniquement.
- [x] Halo a11y-aware (statique si `disableAnimations`), pas de `pumpAndSettle` exploité en test.

### Frontend specific

#### State Management

- [x] Loading (`chargement`), Empty (`vide`), Error (`erreur`), Indisponible (iOS) implémentés
- [x] Success feedback : `_VueResume` ; bascule réactive `permissionRequise → pret/vide` au `resumed`
- [x] Transitions douces ; pas de spinner agressif

#### UI/UX

- [x] Tokens design-system cohérents (`AppColors`/`AppSpacing`/`AppRadii`)
- [x] a11y : `Semantics` sur lignes d'app et étapes ; cibles ≥ 48×48 (chevron contraint + test AC11) ;
  reduced-motion respecté
- [x] Wordmark « DigiHarmony » non traduit

### Backend specific

#### Logging

- [N/A] App sans backend ; zéro logging réseau par conception. Pas de log local en debug pour les catch (mineur).

#### Native (Kotlin) — RISQUE NON VÉRIFIÉ

- [🔴-risque] **Le code Kotlin de `MainActivity` n'a PAS été compilé** (build natif non lancé). La
  signature `configureFlutterEngine`, les imports (`AppOpsManager`, `Settings`, `Process`), et l'API
  `unsafeCheckOpNoThrow` (API 29+) / fallback `checkOpNoThrow` paraissent corrects à la lecture, mais
  **non garantis sans compilation Gradle/Kotlin**. À valider par un `flutter build apk` avant merge.
  Ce n'est pas un finding de qualité de code mais un **angle mort de validation** à signaler.

## Final Review

- **Score**: 92 / 100
  - −3 magic numbers de layout (mineur, cohérent existant)
  - −2 clés i18n mortes (`tempsEcranTitre`/`tempsEcranSousTitre`)
  - −3 risque non vérifié (Kotlin non compilé) + catch silencieux sans log debug
- **Feedback**: Travail conforme et soigné. La **priorité i18n / texte en dur est pleinement satisfaite**
  (0 chaîne en dur, 0 hex/emoji). Garde-fous structurants respectés (zéro collecte, Bloc-only, façade
  mockable, channel `usage_access` seul, tuto sans natif, doublon stale supprimé). Aucun finding bloquant.
- **Follow-up Actions**:
  1. **Compiler le natif** (`flutter build apk --flavor …`) pour lever le risque Kotlin avant merge.
  2. Ajouter un test de migration **réelle v2→v3** (table `usages_ecran_journaliers` créée sur base
     pré-existante) — la suite actuelle ne couvre que `onCreate` v3 et simule le guard v1→v2 (voir review fonctionnelle).
  3. Supprimer ou consommer `tempsEcranTitre`/`tempsEcranSousTitre`.
  4. (Optionnel) Introduire des tokens « taille d'icône/badge » dans le design-system si on veut éradiquer
     les magic numbers ; sinon documenter qu'ils sont tolérés (cohérent existant).
- **Additional Notes**: Revue strictement sur `c3a2d78..HEAD` ; working tree iOS non commité ignoré comme
  demandé. 271 tests verts + analyze clean pris comme acquis (non ré-exécutés ici).
