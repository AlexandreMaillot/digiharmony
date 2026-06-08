---
name: review_functional
description: Functional review report template
argument-hint: N/A
---

# Functional Review for « Mon temps d'écran » + « Réduire mes notifications »

- **Plans**: `aidd_docs/tasks/temps-ecran.md` (valide) + `aidd_docs/tasks/tuto-notifs.md`
  (section ⭐ RÉVISION Banani FAIT LOI)
- **Diff scope**: `c3a2d78...HEAD` (code = `fd18be4`) — commits uniquement, working tree iOS ignoré
- **Date**: 2026-06-06

## Verdict

**PARTIAL** — Tous les critères d'acceptation des deux plans sont tracés et **Met** dans le diff. Le
verdict n'est pas PASS pour **un seul** motif non fonctionnel : le **code natif Kotlin n'a pas été
compilé** (channel `usage_access` non vérifié à l'exécution → AC2/AC3 temps-écran reposent sur du Kotlin
non build) et la **migration réelle v2→v3** n'est pas exercée par un test (seul `onCreate` v3 + simulation
du guard v1→v2). Aucun gap fonctionnel dans le code Dart. Les deux réserves sont **Major** (à lever avant
merge), aucune n'est Blocker.

## Scoring Matrix

### Temps d'écran (AC1–AC12, `temps-ecran.md` §11)

| Criterion | Files | Status | Severity | Notes |
| --------- | ----- | ------ | -------- | ----- |
| AC1 : accès non accordé → `_VuePermission` + CTA, pas de crash/données | `temps_ecran_bloc.dart`, `vue_permission.dart`, bloc_test/view_test | Met | — | Bloc émet `permissionRequise` ; vue rend `VuePermission` + CTA. Testé (bloc AC1 + view AC1). |
| AC2 : tap CTA → ouvre `ACTION_USAGE_ACCESS_SETTINGS` (`ouvrirReglagesAcces` appelé) | `temps_ecran_bloc.dart`, `service_temps_ecran.dart`, `MainActivity.kt` | Met | Major | Dart vérifié (bloc AC2 : `verify ouvrirReglagesAcces`). **Kotlin `Intent(ACTION_USAGE_ACCESS_SETTINGS)` non compilé** → comportement réel système non garanti. |
| AC3 : retour 1er plan → re-vérif → bascule pret/vide sans refresh | `temps_ecran_view.dart` (`didChangeAppLifecycleState`), bloc_test AC3 | Met | — | View observe `resumed` → `TempsEcranRevenuAuPremierPlan` → `_charger`. Testé au niveau Bloc (AC3). |
| AC4 : accès OK + usage → `_VueResume` (total + top apps triées + « Autres ») | `resume_temps_ecran.dart`, `vue_resume.dart`, `ligne_app.dart` | Met | — | `agregeUsage` trie desc, top N + bucket ; vue rend total + lignes + « Autres ». Testé (bloc AC4 + view AC4 + modeles). |
| AC5 : accès OK + aucune donnée → `_VueVide` (bienveillant, pas d'erreur) | `temps_ecran_bloc.dart`, `vue_etat_message.dart` | Met | — | `agregeUsage`→null → `vide` ; `VueEtatMessage` doux. Testé (bloc AC5 + view AC5). |
| AC6 : iOS / plateforme non supportée → `_VueIndisponible`, pas de crash | `service_temps_ecran.dart` (`Platform.isAndroid`), bloc/view test AC6 | Met | — | `plateformeSupportee` court-circuite vers `indisponible`. Testé. |
| AC7 : exception native → `_VueErreur` + « Réessayer » | `temps_ecran_bloc.dart`, `vue_etat_message.dart` | Met | — | catch `on Object` → `erreur` ; action « Réessayer » → `TempsEcranReessaye`. Testé (bloc AC7 + view AC7). |
| AC8 : zéro persistance abusive (seul agrégat total dans Drift, DEC-TE-04 révisé) | `app_database.dart`, `temps_ecran_bloc.dart`, `usage_ecran_journalier_test.dart` | Met | — | Seul `total` (secondes) persisté (UPSERT 1 ligne/jour) ; détail par app éphémère ; aucun HydratedBloc. Testé (bloc AC8 + 3 tests DB). |
| AC9 : ton non culpabilisant + footer « données locales » | `vue_resume.dart`, `temps_ecran_view.dart`, ARB | Met | — | Message bienveillant, pas de score/jauge/alerte ; footer `tempsEcranDonneesLocales` présent (testé view AC9). |
| AC10 : `disableAnimations == true` → halo statique, écran lisible | `temps_ecran_view.dart`, view tests (`MediaQuery disableAnimations`) | Met | Minor | Halo a11y-aware réutilisé ; tests wrappent `disableAnimations: true` et `pump()` (pas de `pumpAndSettle`). Pas de test dédié vérifiant explicitement le halo statique, mais comportement couvert par le widget partagé. |
| AC11 : 8 langues (repli en) ; wordmark non traduit | 8 × `app_*.arb`, `app_localizations_*.dart` | Met | — | 46 clés × 8 langues (fr/en réels, repli en pour el/it/ro/tr/es/mk) ; gen-l10n commité ; wordmark intact. |
| AC12 : helpers purs déterministes testés isolément | `resume_temps_ecran.dart`, `formatage_duree.dart`, tests modeles | Met | — | `agregeUsage`/`nomLisible`/`formaterDuree` purs et testés (resume_temps_ecran_test + formatage_duree_test). |

### Réduire mes notifications (AC1–AC12, `tuto-notifs.md` §11, **lus à la lumière de la RÉVISION Banani**)

> ⚠️ La RÉVISION (FAIT LOI) **supersède** AC2/AC3/AC4/AC10/AC12 d'origine (qui parlaient de CTA réglages,
> MethodChannel `notification_settings`, permission). Le tuto est désormais **statique OS-aware sans natif**.
> Les critères ci-dessous sont réinterprétés selon la RÉVISION ; les critères caducs sont marqués.

| Criterion | Files | Status | Severity | Notes |
| --------- | ----- | ------ | -------- | ----- |
| AC1 : tuto complet rendu (titre, intro, 5 étapes, encouragement, rassurance) | `tuto_notifs_view.dart`, `carte_etape.dart`, `carte_encouragement.dart` | Met | — | Titre + intro + 5 `CarteEtape` + `CarteEncouragement` + rassurance. Testé (TN-1). |
| AC2 (RÉVISÉ) : ~~CTA ouvre réglages~~ → **aucun natif** (RÉVISION) | `tuto_notifs_view.dart`, `MainActivity.kt` | Met | — | **Caduc d'origine.** Conformité RÉVISION : aucun CTA réglages, aucun `notification_settings`, aucun `ServiceReglagesNotifs` (vérifié : 0 occurrence). |
| AC3 (RÉVISÉ) : ~~exception → SnackBar~~ → pas de chemin natif, pas de crash | `tuto_notifs_view.dart` | Met | — | **Caduc.** Écran statique : aucun appel faillible. Pas de SnackBar requis. |
| AC4 (RÉVISÉ) : iOS sans crash → bascule OS + 5 étapes iOS | `tuto_notifs_view.dart` (`CibleOs`, `_basculerOs`) | Met | — | Détection `Platform.isIOS` + bascule « autre téléphone » ; 5 étapes iOS. Testé (TN-2 + TN-3). |
| AC5 : « Compris »/chevron → `Navigator.pop` | `tuto_notifs_view.dart`, `tuto_notifs_page.dart` | Partial | Minor | Chevron retour → `Navigator.pop` présent et testé (AC11 ≥48×48). **Pas de bouton « Compris »** : la RÉVISION a remplacé le bas d'écran par le lien bascule + rassurance ; le retour se fait par le chevron. Écart **assumé par la RÉVISION** (le footer « Compris » des §5 est caduc). Conforme à la maquette, mais l'AC5 littéral (« Compris ») n'est pas implémenté → noté Partial/Minor. |
| AC6 : zéro persistance (ni Drift ni HydratedBloc) | `tuto_notifs_*`, `app_router.dart` | Met | — | StatelessWidget→StatefulWidget UI-only ; aucun provider DB, aucun flag. Vérifié. |
| AC7 : ton non culpabilisant + footer rassurance (l'app n'émet pas de notifs) | `tuto_notifs_view.dart`, ARB `tutoNotifsRassurance` | Met | — | Footer rassurance présent et testé (AC7 : `never sends you notifications`). Encouragement bienveillant. |
| AC8 : `disableAnimations == true` → halo statique | `tuto_notifs_view.dart`, view test wrapper | Met | Minor | Halo a11y-aware ; tests en `disableAnimations: true` + `pump()`. Pas d'assertion dédiée halo statique (couvert par widget partagé). |
| AC9 : 8 langues (repli en) ; wordmark non traduit ; aucune chaîne en dur | 8 × `app_*.arb` | Met | — | Clés `tutoNotifs*` × 8 langues ; 0 chaîne en dur (balayage complet). |
| AC10 : lien Accueil → `AppRouter.versTutoNotifs` (pas `ouvrirPlaceholder`) | `accueil_view.dart:149-164`, `app_router.dart:109` | Met | — | Lien sœur append-only → `versTutoNotifs`. Vérifié (diff append-only). |
| AC11 : a11y — étapes annoncées (`Semantics`), cibles ≥ 48×48 | `carte_etape.dart` (`Semantics`), `tuto_notifs_view.dart` (chevron contraint) | Met | — | `Semantics(label: titre. corps, container: true)` sur chaque étape ; chevron 48×48 testé (AC11). |
| AC12 (RÉVISÉ) : ~~aucune permission ajoutée au manifeste~~ | AndroidManifest (diff vide) | Met | — | Manifeste **inchangé** dans le range (diff vide). Aucune permission/dépendance ajoutée. |

## Missing Behaviors

Critères d'acceptation sans trace dans le diff.

- [ ] **AC5 tuto littéral (« Compris » → pop)** : le bouton « Compris » du §5.1 n'est pas implémenté (le
  retour se fait via le chevron). Écart **explicitement assumé par la RÉVISION Banani** (FAIT LOI), donc
  pas un manque réel — signalé pour traçabilité (Partial/Minor, non bloquant).

## Unplanned Behaviors

Changements présents dans le diff non tracés à un critère d'acceptation.

- [ ] **Persistance Drift de l'agrégat temps-écran** (`UsagesEcranJournaliers`, `observerHistoriqueUsage`,
  `enregistrerUsageDuJour`) : prévu par DEC-TE-04 **révisé** (Q-TE-5, historique multi-jours local) mais
  **aucun écran ne consomme `observerHistoriqueUsage`** dans ce lot. C'est de la **plomberie en avance**
  pour une future vue « 7 derniers jours ». Conforme aux décisions, mais code mort côté UI aujourd'hui —
  confirmer que la consommation est bien différée à une US ultérieure.
- [ ] **Clés ARB `tempsEcranTitre` / `tempsEcranSousTitre`** définies mais non consommées (Q-TE-7 tranchait
  « réutiliser `homeScreenTime` »). Poids mort i18n.
- [ ] **Bouton menu (toolbar) → `ouvrirPlaceholder(placeholderReglages)`** dans les deux écrans : non décrit
  comme AC, cohérent avec le reste de l'app (V1 placeholder). À confirmer scope.

## Flow / Edge-case Gaps

Lacunes relevées en parcourant chaque critère.

- [ ] **Migration réelle v2→v3 non exercée** (AC8 temps-écran / garde-fou « migration idempotente »).
  `migration_test.dart` teste `onCreate` v3 (base fraîche) + **simule** le guard v1→v2, mais le chemin
  `onUpgrade` `from < 3` (check `sqlite_master` + `CREATE UNIQUE INDEX IF NOT EXISTS`) n'est **jamais joué
  contre une base déjà en v2 contenant la table**. L'idempotence réelle (table déjà présente → pas de
  `createTable`) n'est donc pas couverte par un test. **Major** (la priorité « migration idempotente » du
  ticket repose sur une assertion non vérifiée par l'exécution). Recommandation : ouvrir une base v2 via
  `schemaVersion` forcé et exécuter le `MigrationStrategy` réel.
- [ ] **Native Kotlin non compilé** (AC2/AC3 temps-écran). Le channel `usage_access` (vérif `AppOpsManager`,
  ouverture `Intent`) n'a pas été passé par un build Gradle/Kotlin. Le Dart est testé (façade mockée), mais
  la frontière native n'est validée ni par compilation ni par test d'instrumentation. **Major** — lever par
  `flutter build apk` avant merge.
- [ ] **`_charger` re-persiste à chaque `resumed`** : un agrégat est écrit en Drift à chaque retour au premier
  plan (UPSERT idempotent même jour → pas de duplication, mais I/O répétée). Acceptable (UPSERT), noté.
- [ ] **`copierAvec` conserve `resume` stale** lors d'un retour vers un état non-`pret` : non rendu (switch
  ignore `resume` hors `pret`), donc sans impact visuel — robustesse uniquement. Minor.
- [ ] **AC10 temps-écran (halo statique)** et **AC8 tuto (halo statique)** : couverts indirectement (wrapper
  `disableAnimations` + `pump()`), pas d'assertion explicite sur l'état statique du halo. Minor.

## Summary

- **Criteria covered**: 24/24 tracés (12 temps-écran + 12 tuto). 22 Met, 2 Partial (AC10/AC8 halo + AC5 tuto littéral).
- **Blockers**: 0
- **Follow-up actions**:
  1. Compiler le natif (`flutter build apk`) → lever la réserve AC2/AC3 (Major).
  2. Ajouter un test de migration **réelle** v2→v3 (idempotence table `usages_ecran_journaliers`) (Major).
  3. Brancher un consommateur de `observerHistoriqueUsage` (ou acter le différé en US dédiée).
  4. Nettoyer `tempsEcranTitre`/`tempsEcranSousTitre` (clés mortes).
- **Additional notes**: La **priorité i18n / texte en dur est satisfaite** (0 chaîne en dur, 0 hex/emoji,
  8 langues cohérentes). La RÉVISION Banani du tuto est **pleinement respectée** : aucun MethodChannel
  `notification_settings`, aucun service natif, StatelessWidget + bascule OS locale, 5 étapes iOS/Android,
  encouragement, a11y. Doublon stale `MainActivity` supprimé. `MainActivity` active = `usage_access` seul.
  Verdict PARTIAL motivé uniquement par les deux réserves de **validation** (Kotlin non compilé + migration
  réelle non testée), pas par un défaut fonctionnel du code livré.
