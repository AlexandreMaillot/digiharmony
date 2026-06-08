---
name: code-review
description: Review CODE indépendante de la branche feat/noter-humeur vs main (DIGIHARMONY)
argument-hint: N/A
---

# Code Review for branche `feat/noter-humeur` (vs `main`)

Review CODE indépendante (contexte frais) du diff `git diff main` sur la branche
courante. Périmètre : code Dart (`lib/**`, `test/**`), Swift iOS, ARB i18n,
manifeste Android, pubspec. Docs `aidd_docs/**` exclus. Fichiers générés exclus
sauf anomalie.

Deux features principales livrées sur la branche :

1. **Écran Paramètres** (`pages/parametres`) — sélection de langue live via
   `LocaleBloc`, carte confidentialité zéro-collecte, section projet (GitHub +
   Erasmus+), ligne de version dynamique (`package_info_plus`).
2. **Câblage iOS Screen Time** (`pages/temps_ecran` + Swift) — FamilyControls +
   DeviceActivityReport derrière le flag `kScreenTimeIosActif`, façade
   `ServiceTempsEcranIos`, `MethodChannel digiharmony/screen_time`, PlatformView
   `DeviceActivityReport`.
3. **Fix transverse url_launcher** — suppression du gate `canLaunchUrl` dans
   `bloc_ligne_ecoute.dart` (Soutien) + déclaration des `<queries>` Android.

- Statuts: **À corriger avant merge sur findings medium** (aucun critical/high)
- Confidence: **Élevée** — `flutter analyze` propre (0 issue), tests présents et
  cohérents, contraintes dures (zéro-collecte, i18n 8 langues, bloc-only, tokens
  couleur, url_launcher) respectées sur le chemin principal.

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

- [x] Écran Paramètres (langue live, confidentialité, projet, version)
- [x] Câblage iOS Screen Time (FamilyControls + DeviceActivityReport) derrière flag
- [x] Fix url_launcher (pas de gate `canLaunchUrl`) + `<queries>` Android
- [x] i18n des nouvelles clés sur les 8 langues
- [x] Tests widget Paramètres + tests Bloc/View Temps d'écran (chemins iOS + Android)

## Scoring

- [🟢] **Zéro collecte (contrainte dure 1)** : aucun SDK réseau/analytics/tracking/Crashlytics ajouté. `pubspec.yaml` n'ajoute que `package_info_plus` (lecture locale de version) + deux `*_platform_interface` en dev (mocks de test). Permission Android inchangée : seule `PACKAGE_USAGE_STATS` (`AndroidManifest.xml:5`). Pas de permission `VIBRATE` — vibration via `HapticFeedback` (`section_langue.dart:125`, `section_projet.dart:49`, `vue_autorisation_ios.dart:56`). iOS : les chiffres ne traversent jamais vers Dart (`service_temps_ecran_ios.dart:52`, rendu côté extension `TotalActivityReport.swift`).
- [🟢] **Bloc-only (contrainte dure 4)** : `TempsEcranBloc` est un `Bloc`, transformers explicites (`restartable` chargement/refresh, `droppable` permission — `temps_ecran_bloc.dart:24-33`). Aucun `Cubit`. `LocaleBloc` consommé sans `emit` direct dans la view.
- [🟢] **Tokens couleur (contrainte dure 3)** : aucun hex `Color(0x..)` dans les widgets nouveaux ; uniquement `AppColors.*` / `AppColors.vertAppel`. `MoodColors` non détourné. `withValues(alpha:)` utilisé (`section_langue.dart:90`), aucun `withOpacity`.
- [🟢] **url_launcher (contrainte dure 6)** : `section_projet.dart:55-62` et `bloc_ligne_ecoute.dart:98-105` appellent directement `launchUrl(externalApplication)` en try/catch (`PlatformException` + `Exception`), sans gate `canLaunchUrl`. `<queries>` https/http/tel déclarés (`AndroidManifest.xml:52-64`).
- [🟢] **pushReplacement async (rule)** : `versParametres` utilise `push` (pas `pushReplacement`), pas d'`await` problématique (`app_router.dart:127`).
- [🟡] **i18n — clés mortes** `parametresSiteTitre`, `parametresSiteSousTitre`, `tempsEcranIosRefuse` : définies dans les 8 ARB + générées mais jamais référencées dans le code écrit (voir finding #2).
- [🟡] **Couverture iOS** : la façade réelle `ServiceTempsEcranIos` et `ScreenTimeIosChannel._parseStatut` ne sont couvertes par aucun test (voir finding #1).
- [🟡] **Chaîne UI en dur (Swift)** `"aujourd'hui"` dans l'extension (voir finding #3).
- [🟡] **Doc/flag incohérent** : `kScreenTimeIosActif = true` contredit son propre docstring (voir finding #4).
- [🟡] **Dossier Swift dupliqué/obsolète** (voir finding #5).
- [🟢] **`flutter analyze`** : « No issues found! » (0 warning/erreur). Voir [Final Review](#final-review).

## Code Quality Checklist

### Potentially Unnecessary Elements

- [🟡] **Clés i18n mortes** `apps/digiharmony_app/lib/l10n/arb/app_en.arb:612-615` (et 7 autres ARB) — `parametresSiteTitre` / `parametresSiteSousTitre` jamais consommées (lien site « masqué » dans `section_projet.dart:12-13`). Idem `tempsEcranIosRefuse` (`app_en.arb:534`). Bloat i18n × 8 langues. (Finding #2.)
- [🟡] **Dossier Swift obsolète** `apps/digiharmony_app/ios/ScreenTimeScaffold/DeviceActivityReportExtension/` — duplique `ios/DeviceActivityReportExtension/` mais incomplet (pas de `TotalActivityReport.swift`). (Finding #5.)

### Standards Compliance

- [x] Naming conventions FR respectées (classes/fichiers/dossiers/clés en FR : `SectionLangue`, `LangueSupportee`, `ServiceTempsEcranIos`, `langue_supportee.dart`). Suffixes `Bloc`/`Event`/`State` EN tolérés (dérogation 2026-06-05).
- [x] Structure `lib/pages/<page>/{bloc,views,widgets,modeles,services}` respectée.
- [🟡] **`bloc_ligne_ecoute.dart`** mélange `TextStyle` brut + `fontSize: 13` au lieu de `textTheme` (rule `3-flutter-texttheme-current`) — **pré-existant**, hors du diff de cette branche (le diff ne touche que `_ouvrirRessource`). Noté pour information, non imputable à la branche. (Finding #6.)

### Architecture

- [x] Séparation des couches respectée : façade `ServiceTempsEcran` (interface) + impls Android/iOS, Bloc agnostique de la plateforme (`temps_ecran_bloc.dart:71-122`), View qui choisit le rendu via `rapportEmbarque`.
- [x] Persistance : iOS n'écrit jamais dans Drift (`temps_ecran_bloc.dart:86-89`, vérifié par test iOS-AC4) ; Android persiste seulement l'agrégat total. Conforme DEC-001/DEC-002 (journal jamais dans HydratedBloc).
- [x] `LocaleBloc` consommé au-dessus de `MaterialApp`, pas re-fourni (pas de double provider).

### Code Health

- [x] Tailles de fichiers/fonctions raisonnables, pas de complexité excessive.
- [x] Pas de magic strings UI (tout via `context.l10n`). Magic numbers de layout via `AppSpacing.*`.
- [x] Null-safety correcte (`state.resume!` n'est lu qu'en `status == pret` Android — `temps_ecran_view.dart:147`).
- [x] Gestion d'erreurs complète (try/catch sur launchUrl, sur écriture Drift best-effort `temps_ecran_bloc.dart:100-104`, sur channel iOS `screen_time_ios_channel.dart:70-72/90-92`).
- [x] Messages d'erreur user-friendly et i18n (`tempsEcranErreur`, `parametresLienIndisponible`, `soutienErreurLien`).
- [🟡] **Docstring obsolète** `screen_time_ios_channel.dart:15-16` : « Tant que ce flag est `false`… » alors que `kScreenTimeIosActif = true` ligne 17. (Finding #4.)

### Security

- [x] SQL injection : N/A (Drift typé, pas de SQL brut).
- [x] XSS : N/A (Flutter natif).
- [x] Authentication flaws : N/A (app sans compte, sans backend).
- [x] Data exposure : **conforme zéro-collecte** — aucune donnée transmise. Les chiffres Screen Time iOS restent dans le process système sandboxé (`AppDelegate.swift:54-55`, `TotalActivityView.swift:12-13`). Entitlement `family-controls` requis géré côté natif avec dégradation gracieuse en `indisponible`.
- [x] CORS / variables d'env : N/A.

### Error management

- [x] `launchUrl` : try/catch `PlatformException` + `Exception` → SnackBar i18n neutre, pas de crash, pas de log distant (`section_projet.dart:56-70`, `bloc_ligne_ecoute.dart:99-115`).
- [x] Canal iOS : toute erreur native → `indisponible` (jamais de crash) — `screen_time_ios_channel.dart`, `AppDelegate.swift:78-81`.
- [x] Écriture Drift non bloquante pour l'affichage (`temps_ecran_bloc.dart:100-104`).

### Performance

- [x] `_LigneVersion` utilise `FutureBuilder<PackageInfo>` (un appel ponctuel, acceptable).
- [🟢] Halo respirant désactivé si `disableAnimations` (a11y + perf) — `parametres_view.dart:23/55`.
- [x] Aucune recomputation lourde dans `build`.

### Frontend specific

#### State Management

- [x] Loading state : `TempsEcranStatus.chargement` rendu (`temps_ecran_view.dart:105`).
- [x] Empty state : `TempsEcranStatus.vide` + message bienveillant (`temps_ecran_view.dart:151`).
- [x] Error state : `TempsEcranStatus.erreur` + Réessayer (`temps_ecran_view.dart:166`).
- [x] Success feedback : bascule de langue immédiate, pas de SnackBar (vérifié PM-VIEW-6).
- [x] États iOS dédiés (permission/pret) différenciés via `rapportEmbarque`.

#### UI/UX

- [x] Patterns de design cohérents (cartes `AppColors.surface` + `AppRadii.cardRadius`).
- [x] Accessibilité : zones tap ≥ 48dp (`section_langue.dart:87`, `parametres_view.dart:34`, `temps_ecran_view.dart:59`), `Semantics(selected:)` sur la langue active (`section_langue.dart:73-77`), halo statique si reduced-motion.
- [x] Semantic HTML : N/A (Flutter).

### Backend specific

#### Logging

- [x] N/A (app client-only, zéro collecte, aucun log distant — conforme).

## Final Review

- **Score**: **88 / 100** (qualité). Completion de la review : **100 %** des fichiers de code en périmètre inspectés. Aucun finding **critical** ni **high**. `flutter analyze` = 0 issue.

- **Feedback**:
  Travail propre et conforme aux contraintes dures du projet (zéro-collecte,
  i18n 8 langues, bloc-only + transformers, tokens couleur, url_launcher sans
  gate, iOS Screen Time non lu par l'app). Les findings restants sont de la
  dette mineure (couverture de test de la façade iOS, clés i18n mortes, une
  chaîne Swift en dur, docstring/flag désynchronisés, dossier Swift dupliqué).
  Rien de bloquant fonctionnellement ; à nettoyer avant merge pour l'hygiène.

- **Findings (détail — `fichier:ligne` · sévérité · règle · fix décrit, NON appliqué)**:

  1. **[MEDIUM]** `apps/digiharmony_app/lib/pages/temps_ecran/services/service_temps_ecran_ios.dart:1-53` & `apps/digiharmony_app/lib/pages/temps_ecran/services/screen_time_ios_channel.dart:64-106`
     - Règle : `aidd_docs/memory/testing.md` (séparer tests fixture vs implémentation réelle) + couverture de l'implémentation réelle.
     - Problème : `ServiceTempsEcranIos` et le parseur `ScreenTimeIosChannel._parseStatut` ne sont couverts par **aucun** test. Bloc et View testent un `_MockService` ; le mapping `String → StatutAutorisationIos`, le passage `accorde → aLAcces() == true`, et le `rapportEmbarque == true` réels ne sont jamais exercés. Une régression du mapping de statut passerait inaperçue.
     - Fix : ajouter un test unitaire injectant un `MethodChannel` mocké (les deux classes acceptent déjà `canal`/`channel` en paramètre) couvrant les 4 statuts + le fallback `indisponible` (`null`/valeur inconnue/`PlatformException`), et un test de `ServiceTempsEcranIos.aLAcces()` (accorde → true, autres → false) et `usageDuJour()` → `[]`.

  2. **[LOW]** `apps/digiharmony_app/lib/l10n/arb/app_en.arb:612-615` (+ `app_fr/el/it/ro/tr/es/mk.arb`) et `app_en.arb:534`
     - Règle : `3-flutter-i18n` (clés explicites, cohérence) / clean-code (pas de code mort).
     - Problème : `parametresSiteTitre`, `parametresSiteSousTitre` et `tempsEcranIosRefuse` sont définies dans les 8 ARB (et générées dans `app_localizations*.dart`) mais jamais consommées par le code écrit (lien site « masqué V1 » — `section_projet.dart:12-13` ; `tempsEcranIosRefuse` non lu). 24 entrées mortes (3 clés × 8 langues).
     - Fix : soit retirer ces clés des 8 ARB et régénérer (`flutter gen-l10n`), soit les câbler si l'usage est prévu à court terme (documenter alors un TODO daté).

  3. **[LOW]** `apps/digiharmony_app/ios/DeviceActivityReportExtension/TotalActivityView.swift:24`
     - Règle : contrainte projet « aucune chaîne UI en dur » (CLAUDE.md / coding-assertions) — la règle `3-flutter-i18n` cible le Dart, mais la contrainte est plus large.
     - Problème : le label `"aujourd'hui"` est codé en dur en français dans l'extension. Pour un utilisateur en EN/EL/IT/RO/TR/ES/MK, le sous-titre du rapport restera en français.
     - Fix : localiser via le bundle de l'extension (`NSLocalizedString` + `.strings` par langue dans le target extension) ou, a minima, documenter explicitement la limitation a11y/i18n déjà reconnue (DEC-TE-16) comme couvrant aussi cette chaîne.

  4. **[LOW]** `apps/digiharmony_app/lib/pages/temps_ecran/services/screen_time_ios_channel.dart:15-17`
     - Règle : clean-code (commentaires véridiques) ; cohérence doc/état.
     - Problème : le docstring affirme « Tant que ce flag est `false`, le comportement iOS reste `indisponible` » alors que la valeur est `const bool kScreenTimeIosActif = true;`. Lecture trompeuse de l'état réel d'activation.
     - Fix : aligner le commentaire sur la valeur (`true` = chemin iOS actif, prérequis entitlement supposés satisfaits) ou rebasculer le flag à `false` si l'entitlement n'est pas effectivement provisionné sur tous les flavors. Le runtime dégrade en `indisponible` si l'entitlement manque (`AppDelegate.swift:78-81`), donc pas de crash — mais le docstring doit refléter l'intention.

  5. **[LOW]** `apps/digiharmony_app/ios/ScreenTimeScaffold/DeviceActivityReportExtension/`
     - Règle : clean-code (pas de duplication/code mort).
     - Problème : ce dossier duplique `ios/DeviceActivityReportExtension/` mais est **incomplet** (pas de `TotalActivityReport.swift`). Risque : si le target Xcode pointe par erreur sur ce dossier scaffold, la scène `TotalActivityReport` manque → l'extension ne compile pas / ne déclare aucune scène.
     - Fix : confirmer quel dossier est référencé par le target `DeviceActivityReportExtension` dans `project.pbxproj`, puis supprimer le dossier scaffold non utilisé (ou le déplacer sous `aidd_docs` comme matériel de référence).

  6. **[LOW — pré-existant, hors imputation branche]** `apps/digiharmony_app/lib/pages/soutien/widgets/bloc_ligne_ecoute.dart:54-65`
     - Règle : `3-flutter-texttheme-current` (utiliser `textTheme`, pas de `TextStyle` brut ni `fontSize` magique).
     - Problème : titre et sous-titre utilisent `TextStyle(color:..., fontWeight:..., fontSize: 13)` au lieu de `Theme.of(context).textTheme.*`. Le diff de cette branche ne modifie **que** `_ouvrirRessource` (fix url_launcher), pas ces lignes — donc non régressé ici, mais le fichier touché reste non conforme.
     - Fix : remplacer par `textTheme.titleSmall`/`bodySmall` avec `copyWith(color: ...)`. À traiter dans un nettoyage dédié (pas un blocage de cette PR).

- **Follow-up Actions**:
  1. (medium) Ajouter les tests unitaires `ServiceTempsEcranIos` + `ScreenTimeIosChannel` (finding #1).
  2. (low) Nettoyer les clés i18n mortes ou les câbler (finding #2).
  3. (low) Localiser ou documenter la chaîne `"aujourd'hui"` (finding #3).
  4. (low) Resynchroniser docstring/flag `kScreenTimeIosActif` (finding #4).
  5. (low) Supprimer le dossier Swift dupliqué après vérification du target (finding #5).

- **Résolution (2026-06-06 — tous les findings traités)**:
  1. **[MEDIUM] #1 façade iOS non testée** → ✅ `parseStatut` exposé `@visibleForTesting static` ; 2 fichiers de test ajoutés (`screen_time_ios_channel_test.dart` : 6 cas de mapping incl. fallback null/inconnu/vide ; `service_temps_ecran_ios_test.dart` : `aLAcces` 4 statuts, `ouvrirReglagesAcces` délègue, `usageDuJour==[]`, `rapportEmbarque`/`plateformeSupportee`). +14 tests.
  2. **[LOW] #2 clés i18n mortes** → ✅ `parametresSiteTitre`/`parametresSiteSousTitre`/`tempsEcranIosRefuse` retirées des 8 ARB (+ `@`-métadonnées) + `flutter gen-l10n`.
  3. **[LOW] #3 chaîne Swift `"aujourd'hui"`** → ✅ localisée via `Locale.current` dans les 8 langues du projet (fallback EN) — `TotalActivityView.swift`.
  4. **[LOW] #4 docstring/flag désynchro** → ✅ docstring `kScreenTimeIosActif` réécrit (flag `true`, dégradation runtime `indisponible` si entitlement absent) + docstring de classe corrigé.
  5. **[LOW] #5 dossier Swift dupliqué** → ✅ `ScreenTimeScaffold/DeviceActivityReportExtension/` supprimé (target Xcode confirmé sur `ios/DeviceActivityReportExtension/`) ; README scaffold redirigé vers le dossier réel.
  6. **[LOW] #6 `TextStyle` brut `bloc_ligne_ecoute.dart`** → ✅ remplacé par `textTheme.bodyLarge`/`bodySmall` + `copyWith`.
  - Vérif : `flutter analyze` = « No issues found! » ; `flutter test` = **311/311** verts.

- **Additional Notes**:
  - `flutter analyze` exécuté depuis `apps/digiharmony_app/` : **« No issues found! » (0 warning, 0 erreur)** — aucun finding analyzer à reporter.
  - Parité ARB des **nouvelles** clés (Paramètres + Screen Time iOS, 18 clés) : présentes dans les **8** langues. Les langues non-FR/EN portent encore l'anglais comme valeur (repli `en`) — conforme à la stratégie projet (fr+en réels, repli en).
  - Écart ARB constaté mais **hors périmètre branche** : `saisieHumeurErreur` / `saisieHumeurValider` absentes dans 6 langues (el/it/ro/tr/es/mk). Introduites par les commits saisie-humeur (US #6) présents dans `main..HEAD` mais antérieurs aux features de cette PR. À traiter dans un correctif i18n dédié si non déjà tracké.
  - Pas de piège `pumpAndSettle` avec animation infinie : les tests widget utilisent `disableAnimations: true` + `pump()` (halo statique). Conforme `testing.md`.
  - Le test bloc (`temps_ecran_bloc_test.dart`) exerce le **vrai** `TempsEcranBloc` + vraie `AppDatabase.forTesting` (Drift en mémoire) avec un service plateforme mocké — séparation correcte unité/plateforme.
