---
objective: >
  Offrir un écran de soutien bienveillant (« Super conseil » / SoutienPage), auto-déclenché
  à l'ouverture de l'app lorsque les 7 dernières SAISIES d'humeur sont négatives consécutives
  (compteur dérivé de Drift, jamais dupliqué), montré UNE FOIS par épisode, sans aucune
  relance ni collecte. Tous les textes et ressources de ligne d'écoute sont des PLACEHOLDERS
  explicitement marqués « À VALIDER » par les partenaires (public mineur, Erasmus+).
success_condition: >
  Depuis apps/digiharmony_app/ : `dart run build_runner build --delete-conflicting-outputs`
  régénère sans conflit, `flutter gen-l10n` génère sans erreur, `melos exec -- dart format
  --set-exit-if-changed .` et `melos exec -- dart analyze --fatal-infos` passent à
  0 warning/info, et `melos exec --dir-exists=test -- flutter test` est vert. Critères
  vérifiables :
  (1) `compterSaisiesNegativesConsecutives()` (Drift) compte les saisies négatives en tête de
      journal, jours sans saisie ignorés, s'arrête à la 1re valence >= 0 ;
  (2) `EvaluateurSoutien.doitDeclencher(compteur, dejaMontre)` est pur (sans I/O) et déclenche
      ssi compteur >= 7 et !dejaMontre ;
  (3) anti-relance porté par un HydratedBloc (PAS de Cubit), montré une fois par épisode,
      réarmé quand le compteur repasse sous 7, persistant (round-trip toJson/fromJson) ;
  (4) écran atteignable uniquement par déclenchement auto post-splash (`push` au-dessus de
      l'Accueil) — AUCUNE entrée manuelle dans la navigation de production ;
  (5) aucune chaîne UI en dur (clés `soutien*` présentes fr+en, repli `en` pour el/it/ro/tr/es/mk),
      aucun hex en dur (tokens AppColors/AppSpacing/AppRadii), aucun numéro réel hardcodé
      (pas de 3114), table ressources `const {}` vide par défaut ;
  (6) reduced-motion rend un halo statique ; cibles tactiles >= 48dp ; HapticFeedback discret ;
  (7) prévisualisation DEV-only (derrière kDebugMode) non intrusive, absente en release.
iteration: 0
created_at: 2026-06-06
source: aidd_docs/tasks/soutien.md
branch: feat/noter-humeur
---

# Plan exécutable — Écran de soutien (« Super conseil » / `SoutienPage`)

> ⚠️ **Écran sensible (public mineur, Erasmus+).** La section 0 du page plan source
> (`aidd_docs/tasks/soutien.md`) **fait loi**. Ce plan n'invente rien ; il ordonne
> l'implémentation en milestones livrables/testables et tranche les écarts spec↔code relevés
> ci-dessous. **Tous les textes affichés et toutes les ressources de ligne d'écoute sont des
> PLACEHOLDERS À VALIDER HUMAINEMENT** — aucun numéro réel, jamais.

## État des dépendances (vérifié sur disque, branche `feat/noter-humeur`)

| Dépendance attendue (spec) | Présent ? | Emplacement réel / note |
| --- | --- | --- |
| Table `EntreesHumeur` + DataClass `EntreeHumeur` + colonne `valence` (< 0 = négative) | ✅ | `lib/data/local/app_database.dart:15` (`valence:29`, `creeLe:32`, `jour:38`) |
| `valencePour(codeEmotion)` (sad/angry/nervous/tired → -1) | ✅ | `app_database.dart:309` (source unique de la valence) |
| `observerDerniereHumeurDuJour()` (modèle de borne temporelle à copier) | ✅ | `app_database.dart:153` |
| `compterSaisiesNegativesConsecutives()` / `aDeclencherSoutien()` | ⛔ à AJOUTER | M1 |
| `AppRouter` (modèle `push` + `RepositoryProvider<AppDatabase>.value`) | ✅ | `lib/app/routing/app_router.dart:34` (`versSaisieHumeur`) |
| `AppRouter.versSoutien(context)` | ⛔ à AJOUTER | M3 |
| `app.dart` providers globaux (HydratedBloc déjà câblés) | ✅ | `lib/app/view/app.dart:25` (`LocaleBloc`, `BienvenueBloc`) |
| Point de déclenchement post-splash (Demarrage → Accueil) | ✅ (hook à ajouter) | `lib/pages/demarrage/views/demarrage_view.dart:81` (`_onEtat` → `versAccueil` sur `DemarragePret`/`DemarrageErreur`) |
| HydratedBloc storage initialisé avant `runApp` | ✅ | `lib/bootstrap.dart:67` |
| Pattern HydratedBloc à copier (event/state/`id`/`fromJson`/`toJson`) | ✅ | `lib/pages/bienvenue/bloc/bienvenue_bloc.dart` |
| `url_launcher` au pubspec | ✅ | `pubspec.yaml:33` (`^6.3.2`) |
| Tokens `AppColors.backgroundDeep/primary/surface/text/textMuted`, `AppSpacing`, `AppRadii.button/card` | ✅ | `lib/theme/theme.dart:13/75/84` |
| `HaloRespirant` (esprit du halo à réutiliser) | ✅ | `lib/common/widgets/halo_respirant.dart` |
| Clé i18n « bientôt disponible » (STUB respiration) | ✅ | `placeholderComingSoon` (`app_fr.arb` / gen) — réutiliser, ne pas recréer |
| `kDebugMode` (prévisualisation dev) | ✅ | `package:flutter/foundation.dart` (déjà utilisé dans `demarrage_bloc.dart:8`) |
| Infra de test : `AppDatabase.forTesting`, `NativeDatabase.memory()`, `bloc_test`, `test/helpers/` | ✅ | `test/data/local/*`, `test/pages/journal/bloc/journal_bloc_test.dart` |

### Écarts spec ↔ code tranchés dans ce plan (à lire avant d'implémenter)

1. **`SoutienCubit (HydratedCubit)` → INTERDIT.** Le page plan §2/§5.3 propose un `SoutienCubit`.
   La règle `01-standards/1-bloc-only-no-cubit.mdc` est `alwaysApply: true` et **n'admet aucune
   exception** sur le no-Cubit ; un plan ne doit même jamais mentionner « Cubit ». Le projet est
   Bloc-only en pratique (`LocaleBloc`, `BienvenueBloc`). → **DÉCISION : `SoutienBloc extends
   HydratedBloc<SoutienEvent, SoutienState>`** (suffixes anglais `Event`/`State` autorisés par la
   dérogation 2026-06-05), avec events `SoutienMontre` / `SoutienReinitialise`, état
   `dejaMontrePourEpisodeEnCours`, `id = 'soutien'`, `fromJson`/`toJson`. Calqué exactement sur
   `BienvenueBloc`. (DEC-SOP-001)

2. **Arborescence `lib/soutien/` → `lib/pages/soutien/`.** Le code réel range chaque écran sous
   `lib/pages/<feature>/{bloc,views,widgets,modeles}` (cf. `saisie_humeur`, `journal`, `demarrage`).
   Le page plan §2 écrit `lib/soutien/…`. → **DÉCISION : tout sous `lib/pages/soutien/`** pour
   rester cohérent avec la convention de structure du repo. (DEC-SOP-002)

3. **Provider `AppDatabase` à travers la frontière de route.** `versSaisieHumeur`/`versJournal`
   transmettent explicitement `context.read<AppDatabase>()` via `RepositoryProvider<AppDatabase>.value`
   parce que `MaterialPageRoute` crée un sous-arbre neuf. → `versSoutien` **doit faire pareil** si la
   `SoutienPage` relit la base ; sinon, le compteur étant déjà évalué en amont (au déclenchement),
   la page peut être `const SoutienPage()` sans Drift. → **DÉCISION : `versSoutien` ne transmet PAS
   Drift** (la page n'a besoin que du `SoutienBloc` global + `LocaleBloc` + l10n). (DEC-SOP-003)

4. **`SoutienBloc` global dans `app.dart`.** Comme `BienvenueBloc`, fourni une fois au-dessus de
   `MaterialApp` (état léger persistant), accessible via `context.read` partout, y compris depuis le
   hook Demarrage. (DEC-SOP-001)

5. **Pas de `flutter_animate` obligatoire pour le halo.** Le splash utilise `flutter_animate`, mais
   le halo doit être OFF en reduced-motion. Réutiliser l'esprit de `HaloRespirant` (`animer:` +
   `opaciteStatique:`) suffit. (cf. M5)

**Aucun écart bloquant.** Toutes les dépendances dures (#6 Noter-humeur, Demarrage, HydratedBloc,
url_launcher, theme) sont présentes. Les écarts ci-dessus sont des choix de conformité aux règles
projet, pas des manques de code.

---

## M — MUST (périmètre V1, font loi)

- `AppDatabase.compterSaisiesNegativesConsecutives()` : compteur **dérivé** de Drift (lecture
  ponctuelle, pas un `watch()`), compte les saisies négatives (valence < 0) en tête de journal
  trié `creeLe DESC`, **jours sans saisie ignorés**, s'arrête à la 1re valence >= 0. Jamais dupliqué
  ailleurs (DEC-001).
- `AppDatabase.aDeclencherSoutien()` : sucre `compteur >= seuil` (seuil constant centralisé = 7).
- `EvaluateurSoutien.doitDeclencher(compteur, dejaMontre)` : helper **pur, sans I/O**, testable
  isolément ; `seuil = 7` constante.
- Anti-relance **Bloc-only** : `SoutienBloc extends HydratedBloc<SoutienEvent, SoutienState>`
  (events `SoutienMontre`/`SoutienReinitialise`, état `dejaMontrePourEpisodeEnCours`, `id='soutien'`,
  `fromJson`/`toJson`). Fourni global dans `app.dart`. **PAS de Drift dedans** (flag léger, DEC-002).
- `AppRouter.versSoutien(context)` en **`push`** (au-dessus de l'Accueil ; « Plus tard »/chevron = `pop`).
- Hook de déclenchement post-splash dans `DemarrageView._onEtat` (append-only) : après `versAccueil`,
  évaluer `(compteur, dejaMontre)` ; réarmer si compteur < 7 et dejaMontre ; si `doitDeclencher` →
  `SoutienMontre` **puis** `versSoutien`. Marquage **à l'affichage**, pas à la sortie (DEC-SO-004).
- `SoutienView` : halo doux NON alarmant + header (icône ronde, titre, accroche, paragraphe) + 2 CTA
  (Confiance primaire → `ConfiancePage` ; Respiration secondaire = **STUB** SnackBar
  `placeholderComingSoon`) + bloc ligne d'écoute **conditionnel** + « Plus tard » (`pop`) + mention
  « Aucune relance ».
- `ConfiancePage` in-app : pistes bienveillantes (parent/prof/ami·e/adulte de confiance), **textes
  placeholders à valider**, retour = `pop`. Aucune collecte, aucun formulaire, aucun réseau.
- `BlocLigneEcoute` rendu **uniquement** si la locale courante a une ressource ; sinon **masqué**
  (pas de bloc vide). Ouverture via `url_launcher` (`tel:`/`https:`), échec → SnackBar neutre.
- `RessourceLigneEcoute` + table statique `const <String, RessourceLigneEcoute>{}` **VIDE par défaut**
  (commentaire `// TODO partenaires`). **Aucun numéro/URL réel hardcodé.**
- i18n : toutes les clés `soutien*` (§8) en fr+en (provisoires, marquées `// TODO validation`), repli
  `en` copié dans `el/it/ro/tr/es/mk`.
- a11y : reduced-motion → halo statique ; cibles >= 48dp (chevron, CTA) ; `HapticFeedback.lightImpact()`
  discret au tap (côté View).
- Tous les hex du mockup → tokens `theme.dart` (`backgroundDeep` = `#16213C`, accent = `primary`).
- Prévisualisation **DEV-only** derrière `kDebugMode`, non intrusive, **absente en release** (M7).
- Tests : Drift (mémoire), évaluateur pur, `bloc_test` anti-relance, table ressources (garde-fou
  « pas de 3114 »), widget (CTA, bloc conditionnel, reduced-motion, a11y), routing.

## C — COULD (souhaitable, non bloquant si M complet)

- `SoutienPage.page()`/`route()` encapsulant le `MaterialPageRoute` (point d'entrée canonique
  reste `AppRouter.versSoutien`).
- Note discrète zéro-collecte sous le bloc ligne d'écoute (« tu sortiras de l'app »).
- Animation douce du halo (chaleur/cyan) — **désactivable** reduced-motion ; en cas de doute, livrer
  le rendu statique d'abord.

## D — DON'T (interdits absolus — section 0 du page plan + garde-fous projet)

- ❌ **Aucune collecte / aucun réseau / aucun SDK** analytics/tracking/Crashlytics. La seule sortie =
  ouverture d'une app tierce via `url_launcher` (rien envoyé, rien journalisé).
- ❌ **Aucun Cubit** (`1-bloc-only-no-cubit`, sans exception). L'anti-relance est un `HydratedBloc`.
- ❌ **Aucune relance** : pas de notification, pas de re-poussée, pas de minuterie/rappel. Montré une
  fois par épisode, point.
- ❌ Aucun streak/badge/score/podium/FOMO ; **ton jamais alarmant, jamais culpabilisant** ; pas de
  rouge d'alerte (halo chaud/cyan doux).
- ❌ **Aucun numéro/URL réel hardcodé** (pas de 3114 ni numéro universel). Table ressources `const {}`
  vide tant que les partenaires n'ont rien validé ; locale sans ressource → bloc masqué.
- ❌ **Aucun texte sensible figé comme définitif** : tout est placeholder marqué « À VALIDER ».
- ❌ Aucun hex en dur (couleurs/espacements/rayons **uniquement** via `AppColors`/`AppSpacing`/`AppRadii`).
- ❌ **Aucune entrée manuelle dans la navigation de production** : l'écran est strictement
  auto-déclenché. La prévisualisation dev est derrière `kDebugMode` et n'apparaît jamais en release.
- ❌ Le compteur n'est **jamais** stocké/dupliqué dans HydratedBloc (DEC-001) — dérivé de Drift à la
  demande.
- ❌ Aucune redéfinition de la liste des émotions négatives : consommer `valencePour` (source unique).
- ❌ Aucune permission Android ajoutée ; `minify`/`shrinkResources` restent `false`.
- ❌ Respiration guidée = **STUB V1** (pas de navigation Détox réelle).

---

## Table de règles projet applicables

| Règle | Application dans cette feature | Vérification |
| --- | --- | --- |
| `1-bloc-only-no-cubit` (alwaysApply) | Anti-relance = `SoutienBloc extends HydratedBloc<Event,State>`, jamais Cubit | `bloc_lint` ; review imports ; aucune occurrence « Cubit » |
| i18n obligatoire (gen-l10n, 8 langues) | Toute chaîne via ARB ; clés `soutien*` fr+en, repli `en` x6 | `grep` absence de littéraux UI ; `flutter gen-l10n` OK |
| reduced-motion | `MediaQuery.of(context).disableAnimations` gate le halo | Test widget `disableAnimations: true` → halo statique |
| Drift dérivé, jamais dupliqué (DEC-001/002) | Compteur lu à la demande (`.get()`), flag léger dans le Bloc | review : pas de stockage du compteur hors Drift |
| Bornes temporelles `>= start & < end` / tri DESC | `compterSaisiesNegativesConsecutives` lit `ORDER BY creeLe DESC`, pas de post-filtrage | Test Drift ordre + arrêt à la 1re positive |
| Émotions = source unique | Réutiliser `valencePour` ; ne pas redéfinir la liste négative | review : aucune enum/mapping parallèle |
| Couche données en français | Méthode `compterSaisiesNegativesConsecutives`, docstrings FR | review noms |
| Pages `lib/pages/<page>/{bloc,views,widgets,modeles}` + `page()`/`route()` | Arbo sous `lib/pages/soutien/` (écart §2 tranché) | review structure |
| Zéro collecte / aucune permission | Aucun import réseau ; `url_launcher` seul ; AndroidManifest inchangé | review imports + manifest |
| `url_launcher` `tel:`/`https:` | `canLaunchUrl`/`launchUrl(externalApplication)`, échec → SnackBar neutre | review + test (ressource mockée, pas de vrai numéro) |
| Tokens thème, zéro hex en dur | `AppColors`/`AppSpacing`/`AppRadii` ; `#16213C` → `backgroundDeep` | review ; `grep` `0xFF` interdit dans `lib/pages/soutien/` |
| a11y (tap >= 48dp, Semantics, Haptic) | Chevron/CTA >= 48dp, `Semantics` sur CTA, `HapticFeedback.lightImpact` | review + test widget |
| DEV-only derrière `kDebugMode` | Prévisualisation gated, absente en release | review : aucun chemin de prod n'expose l'écran manuellement |
| Lints stricts 0 warning/info | `very_good_analysis` + `bloc_lint` | `dart analyze --fatal-infos` |
| Codegen avant tests | `build_runner` après ajout méthode Drift | commande M1 |

---

## Phases (milestones)

Ordre d'implémentation sûr : **données → évaluateur pur → état anti-relance → routing/intégration →
i18n → UI → sous-écran → prévisualisation/a11y**. Chaque milestone est un commit logique ;
`analyze` + `test` doivent rester verts à chaque étape. Chaque phase est indépendante de la suivante
(compatibilité), modulo un stub minimal de `SoutienPage` créé tôt pour compiler les phases UI.

### M1 — Drift : compteur dérivé `compterSaisiesNegativesConsecutives` + `aDeclencherSoutien`

**Objectif** : exposer le compteur dérivé du journal (lecture ponctuelle), sans toucher au schéma.

**Fichiers**
- `apps/digiharmony_app/lib/data/local/app_database.dart` (ajout 2 méthodes ; **pas** de bump de
  `schemaVersion`, lecture seule)
- `apps/digiharmony_app/test/data/local/app_database_test.dart` (ou nouveau fichier de test dédié)

**Travail**
- `Future<int> compterSaisiesNegativesConsecutives()` : `SELECT valence FROM entrees_humeur
  ORDER BY cree_le DESC` (via le query builder Drift, `orderBy creeLe DESC`, `.get()`), parcourir la
  liste et compter tant que `valence < 0`, **s'arrêter à la première `valence >= 0`**. Retour = nombre
  de négatives consécutives en tête. Journal vide → 0. Docstring FR (DEC-001 : dérivé, jamais dupliqué).
- `Future<bool> aDeclencherSoutien()` : `await compterSaisiesNegativesConsecutives() >= seuil`. Le
  seuil (7) est une constante centralisée — la définir une seule fois (réutilisée par
  `EvaluateurSoutien.seuil` en M2 ; éviter le nombre magique dupliqué : exposer une constante partagée
  ou faire pointer l'un vers l'autre).

**Critères d'acceptation** (cf. page plan §10)
- Journal vide → 0.
- 7 saisies négatives consécutives en tête → >= 7.
- Saisie **positive** en tête → 0 (la série est cassée).
- Série négative interrompue par une positive plus ancienne → ne compte que la tête (s'arrête à la positive).
- 7 saisies négatives réparties sur des jours **non consécutifs** (jours vides entre) → toujours >= 7
  (on compte des saisies, pas des jours calendaires).
- `aDeclencherSoutien()` true ssi compteur >= 7.

**Validation** (depuis `apps/digiharmony_app/`)
```
dart run build_runner build --delete-conflicting-outputs
dart analyze --fatal-infos lib/data/local/app_database.dart
flutter test test/data/local/app_database_test.dart
```

### M2 — Logique pure : `EvaluateurSoutien.doitDeclencher`

**Objectif** : isoler la décision de déclenchement dans un helper pur, testable sans I/O.

**Fichiers**
- `apps/digiharmony_app/lib/pages/soutien/declenchement/evaluateur_soutien.dart`
- `apps/digiharmony_app/test/pages/soutien/declenchement/evaluateur_soutien_test.dart`

**Travail**
- `EvaluateurSoutien` avec `static const int seuil = 7` (source unique du seuil, partagée avec M1).
- `static bool doitDeclencher({required int compteurNegativesConsecutives, required bool
  dejaMontrePourEpisodeEnCours})` : `compteur >= seuil && !dejaMontre`. Aucun I/O, aucune dépendance
  Flutter/Drift.

**Critères d'acceptation**
- compteur < 7 → false (quel que soit le flag).
- compteur >= 7 et `dejaMontre == false` → true.
- compteur >= 7 et `dejaMontre == true` → false (une fois par épisode).

**Validation**
```
dart analyze --fatal-infos lib/pages/soutien/declenchement/
flutter test test/pages/soutien/declenchement/evaluateur_soutien_test.dart
```

### M3 — Anti-relance : `SoutienBloc` (HydratedBloc, Bloc-only)

**Objectif** : seul état persistant (flag anti-relance), calqué sur `BienvenueBloc`.

**Fichiers**
- `apps/digiharmony_app/lib/pages/soutien/bloc/soutien_bloc.dart`
- `.../soutien_event.dart` (sealed)
- `.../soutien_state.dart` (Equatable)
- `apps/digiharmony_app/test/pages/soutien/bloc/soutien_bloc_test.dart`

**Travail**
- `SoutienState extends Equatable` : `final bool dejaMontrePourEpisodeEnCours` (défaut `false`),
  `props`, `copyWith`.
- `SoutienEvent` (sealed) : `SoutienMontre` (transformer `sequential()`), `SoutienReinitialise`
  (`sequential()`).
- `SoutienBloc extends HydratedBloc<SoutienEvent, SoutienState>` : `id => 'soutien'`,
  `on<SoutienMontre>` → `emit(dejaMontre: true)`, `on<SoutienReinitialise>` → `emit(dejaMontre: false)`,
  `fromJson`/`toJson` sérialisant le seul booléen (clé p.ex. `'shown'`). Calque exact de
  `bienvenue_bloc.dart`. **Pas de Drift ici.**

**Critères d'acceptation** (cf. page plan §10)
- État initial `dejaMontrePourEpisodeEnCours == false`.
- `SoutienMontre` → true ; round-trip `toJson`/`fromJson` (persistance).
- `SoutienReinitialise` → false.
- Scénario épisode : montré (true) → re-éval à 7 ne re-montre pas → réinitialisé → remonte à 7 →
  re-montre (pas de double affichage dans un épisode).

**Validation**
```
dart analyze --fatal-infos lib/pages/soutien/bloc/
flutter test test/pages/soutien/bloc/soutien_bloc_test.dart
```

### M4 — Routing + intégration du déclenchement post-splash (+ provider global + stub page)

**Objectif** : rendre `SoutienPage` atteignable **uniquement** par déclenchement auto, sans casser la
navigation/tests Demarrage existants.

**Fichiers**
- `apps/digiharmony_app/lib/pages/soutien/views/soutien_page.dart` (stub minimal ici pour compiler ;
  UI réelle en M6)
- `apps/digiharmony_app/lib/app/routing/app_router.dart` (ajout `versSoutien`, import `SoutienPage`)
- `apps/digiharmony_app/lib/app/view/app.dart` (ajout `BlocProvider<SoutienBloc>` global, append-only)
- `apps/digiharmony_app/lib/pages/demarrage/views/demarrage_view.dart` (hook dans `_onEtat`, append-only)
- `apps/digiharmony_app/test/app/routing/...` + `test/demarrage/view/...` (régression Demarrage)

**Travail**
- `AppRouter.versSoutien(BuildContext context)` : `Navigator.of(context).push(MaterialPageRoute(
  builder: (_) => const SoutienPage()))` (DEC-SOP-003 : pas de transmission Drift — la page ne relit
  pas la base). Docstring FR ; pas de GoRouter (DEC-FND-07).
- `app.dart` : ajouter `BlocProvider<SoutienBloc>(create: (_) => SoutienBloc())` à la liste des
  providers globaux (à côté de `LocaleBloc`/`BienvenueBloc`). Modif minimale, append-only.
- **Hook Demarrage** (`_onEtat`, sur `DemarragePret()`/`DemarrageErreur()`), append-only après
  `versAccueil` :
  1. `await AppRouter.versAccueil(context)` (l'Accueil devient le fond — comportement actuel conservé).
  2. lire `compteur = await db.compterSaisiesNegativesConsecutives()` (`db = context.read<AppDatabase>()`).
  3. `dejaMontre = context.read<SoutienBloc>().state.dejaMontrePourEpisodeEnCours`.
  4. si `compteur < 7 && dejaMontre` → `context.read<SoutienBloc>().add(SoutienReinitialise())` (réarme).
  5. si `EvaluateurSoutien.doitDeclencher(compteur, dejaMontre)` → `add(SoutienMontre())` **puis**
     `AppRouter.versSoutien(context)` (marquage à l'affichage, DEC-SO-004).
  6. sinon → ne rien faire.
  - Gardes `context.mounted` après chaque `await` (le `pushReplacement` change l'arbre). Si le contexte
    n'est plus monté, abandonner silencieusement (pas de crash, aucune relance).
  - **Aucune notification, aucune minuterie** : strictement « à l'ouverture si série >= 7 et pas déjà
    montré ».

**Critères d'acceptation**
- `versSoutien` push `SoutienPage` (const).
- `SoutienBloc` disponible via `context.read` partout sous `MaterialApp`.
- Demarrage : compteur < 7 → aucun push soutien (régression : route normalement vers Accueil, tests
  Demarrage existants **toujours verts**).
- Demarrage : compteur >= 7 et !dejaMontre → `SoutienMontre` émis **puis** push soutien.
- Demarrage : compteur >= 7 et dejaMontre → pas de re-push.
- Demarrage : compteur < 7 et dejaMontre → `SoutienReinitialise` émis.
- **Aucune entrée manuelle** vers `SoutienPage` ailleurs dans la nav.

**Validation**
```
dart analyze --fatal-infos
flutter test test/demarrage/ test/app/
```

### M5 — i18n : clés `soutien*` (placeholders À VALIDER)

**Objectif** : zéro chaîne en dur ; clés provisoires fr+en, repli `en`.

**Fichiers**
- `apps/digiharmony_app/lib/l10n/arb/app_fr.arb`
- `.../app_en.arb`
- `.../app_el.arb`, `app_it.arb`, `app_ro.arb`, `app_tr.arb`, `app_es.arb`, `app_mk.arb` (repli `en`)

**Travail**
- Ajouter les clés `soutien*` du tableau §8 du page plan : `soutienTitre`, `soutienAccroche`,
  `soutienParagraphe`, `soutienCtaConfiance`, `soutienCtaRespiration`, `soutienLignePrefix`,
  `soutienLigneDispoPrefix`, `soutienPlusTard`, `soutienAucuneRelance`, `soutienConfianceTitre`,
  `soutienConfianceParagraphe`. Valeurs fr+en provisoires fournies par le page plan, **chaque entrée
  commentée `// TODO validation partenaires`** (ou métadonnée `@`-description équivalente).
- Repli `en` copié verbatim dans les 6 langues non finalisées (traductions réelles = V1.1).
- **NE PAS** recréer `placeholderComingSoon` (réutilisé pour le STUB respiration).
- Ton bienveillant, jamais alarmant/culpabilisant. Aucun numéro dans les ARB.

**Critères d'acceptation**
- `flutter gen-l10n` génère sans erreur.
- Les 11 clés `soutien*` présentes dans les 8 ARB.
- Aucun doublon de clé existante.

**Validation**
```
flutter gen-l10n
dart analyze --fatal-infos lib/l10n/
```

### M6 — UI `SoutienView` + halo + 2 CTA + bloc ligne d'écoute conditionnel

**Objectif** : l'écran sensible complet, ton bienveillant, tokens thème uniquement.

**Fichiers**
- `apps/digiharmony_app/lib/pages/soutien/views/soutien_page.dart` (finalise : fournit le `Scaffold`,
  toolbar douce ; le `SoutienBloc` est déjà global)
- `apps/digiharmony_app/lib/pages/soutien/views/soutien_view.dart`
- `apps/digiharmony_app/lib/pages/soutien/widgets/halo_soutien.dart`
- `.../widgets/bouton_action_soutien.dart`
- `.../widgets/bloc_ligne_ecoute.dart`
- `apps/digiharmony_app/lib/pages/soutien/modeles/ressource_ligne_ecoute.dart`
- `apps/digiharmony_app/test/pages/soutien/views/soutien_view_test.dart`
- `apps/digiharmony_app/test/pages/soutien/modeles/ressource_ligne_ecoute_test.dart`

**Travail**
- `RessourceLigneEcoute` (`nom`, `cible`, `type` enum `{telephone, lien}`, `disponibilite`) + table
  `const Map<String, RessourceLigneEcoute> tableRessources = {};` **VIDE** avec `// TODO partenaires`.
  **Aucun numéro/URL réel.**
- `HaloSoutien` : dégradé radial `AppColors.primary.withValues(alpha: 0.18)` → transparent, chaud/cyan
  **non alarmant** (pas de rouge). Param `animer` ; si `MediaQuery.of(context).disableAnimations` →
  halo **statique** (pas de boucle). Aucun hex en dur.
- `BoutonActionSoutien` : icône + label, rayon `AppRadii.button`, zone >= 48×48, `HapticFeedback
  .lightImpact()` au tap. Primaire (rempli `AppColors.primary`) / secondaire (outline/ghost).
- `SoutienView` (structure §6.1 du page plan) : `Scaffold(backgroundColor: AppColors.backgroundDeep)`,
  toolbar douce (chevron `Navigator.pop`, logo centré), `Stack(HaloSoutien + contenu scrollable)` :
  icône ronde douce (teinte `primary` atténuée), `soutienTitre`/`soutienAccroche`(cyan)/`soutienParagraphe`,
  CTA primaire → `push ConfiancePage` (M7), CTA secondaire → **STUB** SnackBar `placeholderComingSoon`
  (aucune navigation Détox), `BlocLigneEcoute` **conditionnel**, `TextButton(soutienPlusTard)` → `pop`,
  `Text(soutienAucuneRelance)`.
- `BlocLigneEcoute` : rendu **uniquement si** `tableRessources[locale.languageCode] != null` ; carte
  `AppColors.surface`/`AppRadii.card`, `soutienLignePrefix`+nom, `soutienLigneDispoPrefix`+dispo,
  action → `url_launcher` (`tel:`/`https:`, §4.2) ; échec (`canLaunchUrl` false/exception) → SnackBar
  neutre, **pas de crash, pas de log distant**.
- Tous les hex du mockup mappés aux tokens (`#16213C` → `backgroundDeep`, accent → `primary`).

**Critères d'acceptation** (cf. page plan §10)
- Rend : icône, `soutienTitre`, `soutienAccroche`, `soutienParagraphe`, 2 CTA, « Plus tard »,
  « Aucune relance ».
- Bloc ligne d'écoute **masqué** quand la locale n'a pas de ressource ; **présent** sinon (test avec
  une ressource mockée, jamais un vrai numéro).
- Fond = `AppColors.backgroundDeep`, accroche teinte `AppColors.primary` (aucun hex en dur — review
  `grep 0xFF` vide dans `lib/pages/soutien/`).
- « Plus tard » / chevron → `Navigator.pop`.
- CTA respiration (STUB) → SnackBar/placeholder, **aucune** navigation réelle.
- Reduced-motion (`disableAnimations: true`) → halo statique.
- `HapticFeedback` déclenché au tap (mock channel).
- Cibles tactiles >= 48×48 sur chevron et CTA.
- Garde-fou : aucune chaîne « 3114 »/numéro réel dans le code.

**Validation**
```
dart analyze --fatal-infos lib/pages/soutien/
flutter test test/pages/soutien/
```

### M7 — Sous-écran `ConfiancePage` + prévisualisation DEV-only + a11y/polish + validation globale

**Objectif** : le CTA primaire mène à un écran in-app bienveillant ; l'écran est visualisable en dev
sans entrée manuelle de prod ; finition a11y ; suite complète verte.

**Fichiers**
- `apps/digiharmony_app/lib/pages/soutien/confiance/confiance_page.dart`
- `apps/digiharmony_app/lib/pages/soutien/views/soutien_view.dart` (câblage CTA primaire → `ConfiancePage`)
- Mécanisme de prévisualisation dev (voir ci-dessous, derrière `kDebugMode`)
- Tous les widgets `soutien_*` (Semantics, gardes reduced-motion finales)
- `apps/digiharmony_app/test/pages/soutien/confiance/confiance_page_test.dart`
- Suite de tests complète

**Travail**
- `ConfiancePage` : même toolbar douce ; `soutienConfianceTitre` + `soutienConfianceParagraphe`
  (pistes : parent, prof, ami·e, adulte de confiance). **Aucun formulaire, aucun réseau, aucune
  collecte.** Retour = `pop`. Textes = placeholders à valider.
- CTA primaire de `SoutienView` → `Navigator.push(ConfiancePage)`.
- **Prévisualisation DEV-only (DEC-SOP-004)** — approche retenue, non intrusive, jamais en release :
  - L'évaluateur reste pur et le déclenchement réel inchangé. La prévisualisation **ne passe pas** par
    une entrée de navigation de production.
  - Choix recommandé : **bouton/long-press de debug gardé par `kDebugMode`** placé dans un point déjà
    réservé au dev (p.ex. un `if (kDebugMode) …` dans l'Accueil ou un `Banner`/`FloatingActionButton`
    de debug conditionnel) qui appelle `AppRouter.versSoutien(context)`. Tout le bloc est sous
    `if (kDebugMode)` → **tree-shaké en release** (le compilateur élimine la branche morte). Le
    garde-fou « pas d'entrée manuelle en prod » reste respecté.
  - Alternative équivalente (si on préfère ne rien ajouter à l'Accueil) : un **seed de test**
    `AppDatabase.forTesting` insérant 7 saisies négatives, déjà couvert par les tests, permet de voir
    l'écran via un test/golden — mais ne rend pas l'écran « cliquable » au runtime. Documenter le choix
    final dans le code.
  - **À implémenter : la variante `kDebugMode`** (la plus proche de la demande « pouvoir VOIR l'écran »),
    avec un commentaire explicite « DEV-only — retiré du build release par tree-shaking ».
- a11y : `Semantics` (label sur CTA, icône décorative ignorée du lecteur), reduced-motion confirmé,
  cibles >= 48dp partout.

**Critères d'acceptation**
- CTA Confiance → `ConfiancePage` (pistes locales) ; retour `pop` ; aucune collecte/réseau/formulaire.
- Prévisualisation : présente sous `kDebugMode`, **absente du build release** (review : tout le code de
  preview est dans une branche `if (kDebugMode)`), et **n'ajoute aucune entrée de nav en prod**.
- Sémantique des CTA présente ; reduced-motion → halo statique ; cibles >= 48dp.
- Toute la suite verte ; lints 0 warning/info.

**Validation finale (avant commit complet, depuis `apps/digiharmony_app/`)**
```
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
melos exec -- dart format --set-exit-if-changed .
melos exec -- dart analyze --fatal-infos
melos exec --dir-exists=test -- flutter test
```

---

## Décisions intégrées (font foi)

### Reprises du page plan source (`soutien.md` §11) — s'appliquent telles quelles
DEC-SO-001 (7 dernières **saisies** négatives consécutives, jours sans saisie ignorés ; compteur dérivé
de Drift), DEC-SO-002 (négatives = sad/angry/nervous/tired, valence < 0, via `valencePour`), DEC-SO-003
(évaluation à l'ouverture post-splash, `push` au-dessus de l'Accueil, aucune entrée manuelle), DEC-SO-004
(anti-relance : une fois par épisode, marqué à l'affichage, réarmé sous le seuil), DEC-SO-005 (respiration
= STUB V1), DEC-SO-006 (Confiance = écran in-app local, textes à valider), DEC-SO-007 (ligne d'écoute =
table statique par locale, bloc masqué si absente, aucun numéro universel hardcodé, ouverture `url_launcher`),
DEC-SO-008 (« Plus tard »/chevron = `pop`), DEC-SO-009 (hex → tokens, halo non alarmant), DEC-SO-010
(a11y : reduced-motion, >= 48dp, Haptic), DEC-SO-011 (tous textes/ressources = placeholders à valider),
DEC-SO-012 (aucun streak/badge/score/FOMO, aucune relance, jamais culpabiliser).

### Décisions de planification spécifiques à ce plan (écarts spec↔code)
| ID | Décision | Rationale |
| --- | --- | --- |
| DEC-SOP-001 | Anti-relance = `SoutienBloc extends HydratedBloc<SoutienEvent, SoutienState>` (events `SoutienMontre`/`SoutienReinitialise`), fourni global dans `app.dart`. **Jamais de Cubit.** | `1-bloc-only-no-cubit.mdc` est `alwaysApply: true` sans exception ; le projet est Bloc-only (`BienvenueBloc` est le modèle exact). Le page plan parlait de `SoutienCubit` — non conforme. |
| DEC-SOP-002 | Toute l'arbo sous `lib/pages/soutien/{bloc,views,widgets,modeles,confiance,declenchement}` (et tests miroir sous `test/pages/soutien/`). | Convention de structure réelle du repo (`saisie_humeur`, `journal`, `demarrage`), pas `lib/soutien/`. |
| DEC-SOP-003 | `AppRouter.versSoutien` fait un `push(const SoutienPage())` **sans** transmettre `AppDatabase`. | Le compteur est évalué en amont (au hook Demarrage) ; la page n'a besoin que du `SoutienBloc` global + l10n. Évite un `RepositoryProvider` inutile. |
| DEC-SOP-004 | Prévisualisation DEV-only via un déclencheur gardé `if (kDebugMode)` (tree-shaké en release), appelant `AppRouter.versSoutien`. Aucune entrée de nav de prod. | Permet de « voir » l'écran auto-déclenché en dev sans violer « pas d'entrée manuelle en prod ». |
| DEC-SOP-005 | Seuil `7` défini une seule fois (constante partagée entre `aDeclencherSoutien` et `EvaluateurSoutien.seuil`). | Évite un nombre magique dupliqué / divergence de seuil. |

---

## Risques / coordination

- **Dépendance #6 Noter-humeur** : présente (table + `valencePour`). Sans entrées de journal, compteur
  = 0 → écran jamais déclenché (comportement correct).
- **Hook Demarrage** : le seul point d'intégration sensible. `pushReplacement(Accueil)` change l'arbre ;
  bien garder `context.mounted` après chaque `await` pour éviter un usage de contexte démonté. Append-only
  pour ne pas casser les tests Demarrage existants (`test/demarrage/`).
- **`app.dart`** : un seul `BlocProvider<SoutienBloc>` ajouté (état léger global), modif minimale.
- **Validation humaine bloquante (hors périmètre code)** : aucun déploiement de contenu sensible (textes
  + numéros de ligne d'écoute) sans relecture des partenaires. Les placeholders sont explicitement marqués
  « À VALIDER » et la table ressources reste **vide** tant que rien n'est validé.

## Hors périmètre V1 (→ V1.1)
Respiration/Détox réel ; remplissage des numéros/URL de ligne d'écoute (partenaires) ; traductions réelles
`el/it/ro/tr/es/mk` ; toute notification/rappel (interdit par DEC-003).

---

## Confiance : 9/10

✅ Spec source détaillée et `valide` ; toutes les dépendances dures vérifiées présentes sur disque ;
modèles de code exacts à copier identifiés (`BienvenueBloc` pour le HydratedBloc, `versSaisieHumeur`
pour le routing, `observerDerniereHumeurDuJour` pour les bornes Drift, `placeholderComingSoon` pour le
STUB) ; écarts spec↔code (Cubit, arbo) tranchés conformément aux règles ; phases indépendantes et testables.

❌ Risque résiduel : la séquence exacte du hook Demarrage (push Accueil puis évaluation puis push Soutien)
peut nécessiter un ajustement fin selon le comportement de `pushReplacement` + `context.mounted` au runtime
(à confirmer par les tests d'intégration Demarrage en M4). Contenu sensible reste sous validation humaine
partenaires (par conception, non bloquant pour le code).
