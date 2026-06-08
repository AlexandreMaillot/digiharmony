---
objective: Offrir un écran « Mon Journal » empilé (push) qui relit en lecture seule les humeurs notées sur 3 horizons (Jour défaut / Semaine / Mois) via Drift réactif, sans aucun score ni jugement.
success_condition: >
  Depuis apps/digiharmony_app/ : `dart run build_runner build --delete-conflicting-outputs`
  régénère sans conflit, `melos exec -- dart format --set-exit-if-changed .` et
  `melos exec -- dart analyze --fatal-infos` passent à 0 warning/info, et
  `melos exec --dir-exists=test -- flutter test` est vert. Critères vérifiables :
  (1) JournalPage accessible depuis la carte humeur (« Voir mon journal » états A & B → AppRouter.versJournal, plus ouvrirPlaceholder) ;
  (2) les 3 vues rendent les données Drift via watch() (Jour/Semaine/Mois) ;
  (3) navigation mois bornée au présent (flèche suivant désactivée au mois courant) ;
  (4) aucune chaîne UI en dur (toutes clés journal* présentes fr+en, repli en pour el/it/ro/tr/es/mk) ;
  (5) reduced-motion rend un état statique ;
  (6) aucun score/classement/streak/comparaison inter-mois ; répartition dans l'ordre fixe d'emotionsCanoniques.
iteration: 0
created_at: 2026-06-06
source: aidd_docs/tasks/journal.md
github: "#10"
branch: feat/noter-humeur
---

# Plan exécutable — « Mon Journal » (US-8, #10)

> Source de vérité : `aidd_docs/tasks/journal.md` (status: valide). Ce plan ne ré-invente
> rien ; il ordonne l'implémentation en milestones livrables et testables. Les garde-fous
> de la section 0 du page plan **font loi**.

## État des dépendances (vérifié sur disque, branche `feat/noter-humeur`)

| Dépendance | Attendu | Présent ? | Emplacement |
| --- | --- | --- | --- |
| Table `EntreesHumeur` + DataClass `EntreeHumeur` | oui | ✅ | `lib/data/local/app_database.dart:15` |
| `observerDerniereHumeurDuJour()` | oui | ✅ | `app_database.dart:154` (bornes `>= start & < end`, `watchSingleOrNull`) |
| `conseilDuJour(DateTime) → Future<Conseil>`, champ `cleConseil` (`tipDay0X`) | oui | ✅ | `app_database.dart:173` ; table `Conseils:48` |
| `emotionsCanoniques` / `emojiPourCode` / `valencePour` | oui | ✅ | `lib/pages/saisie_humeur/modeles/emotion_canonique.dart` |
| `MoodColors.byKey` | oui | ✅ | `lib/theme/theme.dart:53` |
| `AppRouter.versSaisieHumeur` (modèle à copier) | oui | ✅ | `lib/app/routing/app_router.dart:33` |
| `AppRouter.versJournal` | à AJOUTER | ⛔ absent | M2 |
| `observerEntreesDeLaSemaine` / `observerEntreesDuMois` | à AJOUTER | ⛔ absents (attendu) | M1 |
| Carte humeur lien « Voir mon journal » | branché sur `ouvrirPlaceholder(l10n.placeholderJournal)` | ✅ à recâbler | `carte_humeur.dart:88` (état A) & `:174` (état B) |
| Clés i18n `journal*` | à AJOUTER | ⛔ absentes (`grep journalTitle app_en.arb` = 0) | M4 |

**Aucun écart bloquant** entre le page plan et le code. Une seule micro-divergence de référence :
le page plan §6.2 cite les états A/B « ligne ~88 / ~173 » ; le code réel a le lien état A en
`carte_humeur.dart:88` et état B en `carte_humeur.dart:174` (et non 173). Sans impact —
recâbler les **deux** occurrences de `ouvrirPlaceholder(context, l10n.placeholderJournal)`.

---

## M — MUST (périmètre V1, font loi)

- Écran `JournalPage` empilé (push, retour possible), ouvert depuis la carte humeur de l'Accueil.
- SegmentedControl 3 vues : **Jour (défaut)**, Semaine, Mois.
- 2 observers Drift réactifs ajoutés : `observerEntreesDeLaSemaine`, `observerEntreesDuMois` (lecture seule, `watch()`, bornes `>= start & < end`).
- `AppRouter.versJournal` (modèle exact `versSaisieHumeur`, `RepositoryProvider<AppDatabase>.value`).
- Recâblage carte humeur états A **et** B → `AppRouter.versJournal(context)`.
- Bloc-only (pas de Cubit) : `JournalBloc` + `JournalEvent` (sealed) + `JournalState` (Equatable, enum `JournalStatus`), transformers explicites (restartable pour `JournalDemarre`, droppable pour vue/mois).
- Vue Jour : carte humeur+conseil+CTA exercice (stub SnackBar)+lien modifier, OU état vide bienveillant (conseil toujours affiché).
- Vue Semaine : bande 7 jours (lundi→dimanche, locale-aware) + résumé descriptif neutre.
- Vue Mois : calendrier borné au passé (flèche suivant désactivée au mois courant) + synthèse « Ce mois-ci » (comptages sans classement, ordre `emotionsCanoniques`).
- i18n : toutes les clés `journal*` (§7) en fr + en réels ; repli `en` copié dans `el/it/ro/tr/es/mk`. ICU `{count}`/`plural` valides.
- a11y reduced-motion (`MediaQuery.disableAnimations` → rendu statique), cibles ≥ 48dp, `Semantics` sur pastilles/segments/flèches.
- Tests : Drift (mémoire), bloc_test, widget, navigation/recâblage, i18n, a11y (cf. page plan §10).

## C — COULD (souhaitable, non bloquant si M complet)

- Note discrète bas de page `journalLocalDataNote` (« Tes données restent sur cet appareil. »).
- Animations bienveillantes (halo conseil, emoji-breathe, day-cascade, month-pulse) — **toutes désactivables** reduced-motion. En cas de doute, livrer le rendu statique d'abord.
- Encapsulation `JournalPage.route()` autour du `MaterialPageRoute` (le point d'entrée canonique reste `AppRouter.versJournal`).

## D — DON'T (interdits absolus — DEC-003 + garde-fous projet)

- ❌ Aucun score, classement, podium, moyenne-score, streak, FOMO, formulation culpabilisante.
- ❌ Aucune comparaison inter-période / inter-mois (« mieux/pire que le mois dernier »).
- ❌ Aucun hex en dur (couleurs **uniquement** `MoodColors.byKey` / `AppColors`), aucun emoji codé en dur (**uniquement** `emojiPourCode`).
- ❌ Aucune enum d'émotion parallèle ni mapping dupliqué : source unique = `emotionsCanoniques`. Réutiliser les clés `moodHappy/...moodTired` existantes (pas de doublon).
- ❌ Jamais `HydratedBloc` pour le journal (DEC-001/002) — Drift `watch()` exclusivement.
- ❌ Aucune écriture par le journal (lecture seule). Édition rétroactive des jours passés = hors V1.
- ❌ Aucun tri par fréquence de la répartition : ordre **fixe** d'`emotionsCanoniques`.
- ❌ Aucune navigation vers le futur (mois). « Faire l'exercice » = stub SnackBar (pas de navigation Détox).
- ❌ Aucun SDK réseau/analytics/tracking, aucune permission ajoutée, aucun `google_fonts`.
- ❌ Cubit interdit (`1-bloc-only-no-cubit`).
- ❌ Aucune chaîne FR/EN en dur dans les widgets.

---

## Table de règles projet applicables

| Règle | Application dans cette feature | Vérification |
| --- | --- | --- |
| i18n obligatoire (gen-l10n, 8 langues) | Toute chaîne via ARB ; clés `journal*` fr+en réels, repli `en` pour 6 langues | `grep` absence de littéraux ; `flutter gen-l10n` OK |
| reduced-motion | `MediaQuery.maybeOf(context)?.disableAnimations` gate toutes les animations | Test widget `disableAnimations: true` → statique |
| Drift réactif `watch()` | Les 3 sources passent par des `Stream` ; bloc s'abonne | Code review ; pas de `.get()` ponctuel pour le rendu vue |
| Bloc-only + transformers explicites | `JournalBloc` ; `restartable()` (démarre) / `droppable()` (vue, mois) | `bloc_lint` ; review imports `bloc_concurrency` |
| Couche données en français | Méthodes/DataClass en français, conventions `observer*` | review noms |
| Bornes temporelles `>= start & < end` | Les 2 nouveaux observers : borne haute **exclue**, pas de post-filtrage | Test Drift bornes ; review `isSmallerThanValue(end)` |
| 1 entrée/jour (index UNIQUE) | Pas de dédoublonnage UI ; agrégation par `jour` | review ; test Drift 1/jour |
| Émotions = source unique | `emotionsCanoniques`, `emojiPourCode`, `MoodColors.byKey`, clés `mood*` | review ; aucun hex/emoji/enum nouveau |
| Zéro collecte / aucune permission | Aucun import réseau ; aucune perm ajoutée | review imports + `AndroidManifest` inchangé |
| Pages `lib/pages/<page>/{bloc,views,widgets}` + `page()`/`route()` | Arbo §2 respectée | review structure |
| Lints stricts 0 warning/info | `very_good_analysis` + `bloc_lint` | `dart analyze --fatal-infos` |
| Codegen avant tests | `build_runner` après ajout des observers (DataClass déjà générée, mais regen sûr) | commande M1 |

---

## Phases (milestones)

Ordre d'implémentation sûr : données → routing → bloc → i18n → UI (Jour→Semaine→Mois) → a11y/polish.
Chaque milestone est un commit logique. **Validation `analyze` + `test` doit rester verte à chaque
milestone** ; les milestones UI s'appuient sur le bloc et l'i18n déjà en place.

### M1 — Couche données : 2 observers Drift réactifs

**Objectif** : exposer la semaine et le mois en lecture seule réactive.

**Fichiers touchés**
- `apps/digiharmony_app/lib/data/local/app_database.dart` (ajout des 2 méthodes ; **ne pas** toucher au schéma, pas de bump de version — lecture seule)
- `apps/digiharmony_app/test/data/local/app_database_test.dart` (ou fichier de test Drift existant)

**Travail**
- `Stream<List<EntreeHumeur>> observerEntreesDeLaSemaine(DateTime jourReference)` : début = lundi de la semaine de `jourReference` (calcul `weekday`, locale-aware), bornes `[lundi 00:00, lundi+7j)`, `orderBy creeLe ASC`, `.watch()`.
- `Stream<List<EntreeHumeur>> observerEntreesDuMois(DateTime jourReference)` : bornes `[1er du mois 00:00, 1er du mois suivant 00:00)`, `orderBy creeLe ASC`, `.watch()`.
- Mêmes conventions exactes que `observerDerniereHumeurDuJour` (`isBiggerOrEqualValue(start) & isSmallerThanValue(end)`, borne haute exclue, **pas de post-filtrage**).
- Docstrings français cohérents avec l'existant.

**Critères d'acceptation**
- Semaine : bornes lundi→dimanche, borne haute exclue, tri ASC, au plus 1 entrée/jour ; entrée à `lundi 00:00` incluse, entrée à `lundi+7j 00:00` exclue.
- Mois : bornes 1er→fin de mois, borne haute exclue ; mois sans entrée → liste vide ; réactif (nouvelle entrée → ré-émission).
- Aucun changement de version de schéma.

**Validation** (depuis `apps/digiharmony_app/`)
```
dart run build_runner build --delete-conflicting-outputs
dart analyze --fatal-infos lib/data/local/app_database.dart
flutter test test/data/local/app_database_test.dart
```

### M2 — Routing : `AppRouter.versJournal` + recâblage Accueil

**Objectif** : rendre `JournalPage` atteignable (avec un stub minimal de page si nécessaire pour compiler, finalisé en M3/M5).

**Fichiers touchés**
- `apps/digiharmony_app/lib/app/routing/app_router.dart` (ajout `versJournal`, import `JournalPage`)
- `apps/digiharmony_app/lib/pages/accueil/widgets/carte_humeur.dart` (2 recâblages, lignes ~88 et ~174)
- `apps/digiharmony_app/lib/pages/journal/views/journal_page.dart` (créé ici a minima pour la compilation ; contenu réel en M3/M5)
- `apps/digiharmony_app/test/.../carte_humeur_test.dart` + `app_router` test si présent

**Travail**
- `versJournal(BuildContext)` calqué **exactement** sur `versSaisieHumeur` (`context.read<AppDatabase>()`, `MaterialPageRoute`, `RepositoryProvider<AppDatabase>.value`, `child: const JournalPage()`).
- Carte humeur états A **et** B : remplacer les deux `onPressed/onTap: () => ouvrirPlaceholder(context, l10n.placeholderJournal)` par `() => AppRouter.versJournal(context)`. Conserver `l10n.heroSeeJournal`.

**Critères d'acceptation**
- `AppRouter.versJournal` push `JournalPage` avec `AppDatabase` fournie via `RepositoryProvider.value`.
- Carte humeur états A et B : tap « Voir mon journal » → `versJournal` (et **plus** `ouvrirPlaceholder`). `placeholderJournal` n'est plus déclenché par la carte.
- App compile et lance.

**Validation**
```
dart analyze --fatal-infos
flutter test test/pages/accueil/
```

### M3 — Bloc / State / Events Journal

**Objectif** : orchestrer vue active + ancrage mois + combinaison des 3 sources Drift.

**Fichiers touchés**
- `apps/digiharmony_app/lib/pages/journal/bloc/journal_bloc/journal_bloc.dart`
- `.../journal_event.dart`
- `.../journal_state.dart`
- `.../views/journal_page.dart` (fournit `BlocProvider<JournalBloc>` + `AppDatabase`)
- `apps/digiharmony_app/test/pages/journal/bloc/journal_bloc_test.dart`

**Travail**
- `JournalStatus { initial, chargement, pret, erreur }`.
- `JournalState` (Equatable) : `status`, `vueActive` (`JournalVue { jour, semaine, mois }`, défaut `jour`), `humeurDuJour` (`EntreeHumeur?`), `conseilDuJourCle` (`String?`), `entreesSemaine`, `entreesMois`, `moisAffiche` (1er du mois ancré), `peutAvancerMois` (bool), `erreur` (bool). `copyWith` + `props` complets.
- `JournalEvent` (sealed) : `JournalDemarre` (restartable, abonnements jour+conseil+semaine+mois courant), `JournalVueChangee(JournalVue)` (droppable), `JournalMoisPrecedent` (droppable), `JournalMoisSuivant` (droppable, **seulement si `peutAvancerMois`**), `_JournalDonneesRecues(...)` (interne, émis par les souscriptions Drift).
- `peutAvancerMois` recalculé à chaque changement de `moisAffiche` : strictement avant le 1er du mois courant.
- Erreur Drift → `emit(status: erreur, erreur: true)`, pas de crash.
- `conseilDuJour` est `Future` → résolu une fois au démarrage (clé stockée), les humeurs via streams.

**Critères d'acceptation** (cf. page plan §10)
- `JournalDemarre` → `chargement` puis `pret` (humeur/conseil/semaine/mois peuplés).
- Sans entrée du jour → `pret`, `humeurDuJour == null`, conseil présent.
- `JournalVueChangee` → `vueActive` à jour.
- `JournalMoisPrecedent` → `moisAffiche` reculé, `peutAvancerMois == true`, stream mois relancé.
- `JournalMoisSuivant` au mois courant → no-op (`peutAvancerMois == false`).
- `JournalMoisSuivant` depuis un mois passé → avance + recalcul.
- Erreur Drift → `status: erreur`, pas de crash.
- Réactivité : nouvelle entrée jour courant → state ré-émis.
- Aucun score/classement stocké dans le state.

**Validation**
```
dart analyze --fatal-infos
flutter test test/pages/journal/bloc/
```

### M4 — i18n : clés `journal*`

**Objectif** : zéro chaîne en dur ; clés réelles fr+en, repli en.

**Fichiers touchés**
- `apps/digiharmony_app/lib/l10n/arb/app_fr.arb`
- `.../app_en.arb`
- `.../app_el.arb`, `app_it.arb`, `app_ro.arb`, `app_tr.arb`, `app_es.arb`, `app_mk.arb` (repli `en`)

**Travail**
- Ajouter les 25 clés du tableau §7 (EN de référence fourni ; FR à rédiger en cohérence ton bienveillant).
- ICU : `journalWeekSummary` (`{count}`), `journalMonthFrequencyLine` (`{label}` + `{count, plural, ...}`). Déclarer les `placeholders` + métadonnées `@key` correctes.
- Repli `en` copié verbatim dans les 6 langues non finalisées (conforme registry ; traductions réelles = V1.1).
- **Ne pas** recréer `moodHappy/...moodTired` ni `heroSeeJournal` (existants).

**Critères d'acceptation**
- `flutter gen-l10n` génère sans erreur ; ICU valides.
- Les 25 clés présentes dans les 8 ARB.
- Aucun doublon de clé `mood*`.

**Validation**
```
flutter gen-l10n
dart analyze --fatal-infos lib/l10n/
```

### M5 — UI Vue Jour (carte + état vide bienveillant)

**Fichiers touchés**
- `apps/digiharmony_app/lib/pages/journal/views/journal_view.dart` (Scaffold + Toolbar + SegmentedControl + switch de vue)
- `.../widgets/journal_segmented_control.dart`
- `.../widgets/journal_vue_jour.dart`
- `.../widgets/journal_carte_jour.dart`
- `apps/digiharmony_app/test/pages/journal/widgets/journal_vue_jour_test.dart`

**Travail**
- Toolbar haute (retour `Navigator.maybePop` · titre `journalTitle` · menu `journalMenuTooltip`).
- SegmentedControl `journalSegmentDay/Week/Month`, défaut **Jour** (DEC-J-01) → dispatch `JournalVueChangee`.
- Si `humeurDuJour != null` : pastille `emojiPourCode(code)` + `MoodColors.byKey[code]` (fond `withValues(alpha: 0.18)`) + libellé `journalDayMoodPrefix` + `mood*` résolu par code ; conseil `journalDayTipLabel` + `conseilDuJourCle` → `tipDay0X` ; CTA `journalDayDoExerciseCta` → **SnackBar** `journalExerciseComingSoon` (stub, aucune nav, DEC-J-02) ; lien `journalDayEditMoodLink` → `AppRouter.versSaisieHumeur(context)` (DEC-J-03).
- Si `humeurDuJour == null` : `journalDayEmptyTitle` + `journalDayEmptyBody` + CTA `journalDayEmptyCta` → `versSaisieHumeur` ; **le conseil reste affiché** (DEC-J-04).

**Critères d'acceptation**
- Avec humeur : pastille via `emojiPourCode`/`MoodColors` (pas de hex/emoji en dur), libellé `mood*`, conseil, CTA exercice → SnackBar (pas de navigation).
- Vide : titre/corps/CTA bienveillants + conseil affiché ; CTA → `versSaisieHumeur`.
- Aucune chaîne en dur.

**Validation**
```
dart analyze --fatal-infos
flutter test test/pages/journal/widgets/journal_vue_jour_test.dart
```

### M6 — UI Vue Semaine

**Fichiers touchés**
- `apps/digiharmony_app/lib/pages/journal/widgets/journal_vue_semaine.dart`
- `apps/digiharmony_app/test/pages/journal/widgets/journal_vue_semaine_test.dart`

**Travail**
- Titre `journalWeekTitle`.
- 7 cases lundi→dimanche (locale-aware) : pastille `emojiPourCode`+`MoodColors` si entrée ce `jour`, sinon point neutre `journalWeekNoEntry` (« · »). Étiquette jour courte `DateFormat.E(locale)`.
- Résumé descriptif : `journalWeekSummary` (`{count}` jours notés sur 7) si ≥ 1 saisie, `journalWeekSummaryEmpty` sinon. **Aucune moyenne/classement.**
- Agrégation par `jour` (1/jour garanti).

**Critères d'acceptation**
- 7 cases ; « · » pour jours non notés ; résumé `journalWeekSummary`/`Empty` correct.
- Aucune chaîne en dur ; aucun score.

**Validation**
```
dart analyze --fatal-infos
flutter test test/pages/journal/widgets/journal_vue_semaine_test.dart
```

### M7 — UI Vue Mois (calendrier borné + synthèse « Ce mois-ci »)

**Fichiers touchés**
- `apps/digiharmony_app/lib/pages/journal/widgets/journal_vue_mois.dart`
- `.../widgets/journal_calendrier_mois.dart`
- `.../widgets/journal_synthese_mois.dart`
- `apps/digiharmony_app/test/pages/journal/widgets/journal_vue_mois_test.dart`

**Travail**
- En-tête : flèche précédent (`journalMonthPrevTooltip` → `JournalMoisPrecedent`) · libellé `DateFormat.yMMMM(locale)` · flèche suivant (`journalMonthNextTooltip` → `JournalMoisSuivant`, **désactivée** si `!peutAvancerMois`, DEC-J-05).
- Grille : jour noté → `emojiPourCode` ; jour non noté → numéro grisé `AppColors.textMuted` ; hors mois → vide. Jamais de mois futur.
- Synthèse `journal_synthese_mois.dart` (mois affiché seul, **aucune comparaison inter-mois**, DEC-J-06) : titre `journalMonthSectionTitle` ; répartition = comptages **dans l'ordre fixe d'`emotionsCanoniques`** (jamais trié par fréquence, DEC-J-07), une ligne `journalMonthFrequencyLine` par émotion avec ≥ 1 occurrence ; tendance `journalMonthSummary` si ≥ 1 saisie, `journalMonthSummaryEmpty` sinon.

**Critères d'acceptation**
- Flèche suivant désactivée au mois courant ; aucun mois futur accessible.
- Jour non noté → numéro grisé ; jour noté → emoji.
- Synthèse : lignes dans l'ordre `emotionsCanoniques`, **aucune** ligne triée par fréquence, **aucune** comparaison inter-mois, aucun %-comparé.
- Aucune chaîne en dur.

**Validation**
```
dart analyze --fatal-infos
flutter test test/pages/journal/widgets/journal_vue_mois_test.dart
```

### M8 — a11y reduced-motion + polish + validation globale

**Fichiers touchés**
- Tous les widgets `journal_*` (ajout des gardes reduced-motion, `Semantics`, cibles ≥ 48dp)
- Note `journalLocalDataNote` (COULD)
- Suite de tests complète

**Travail**
- `MediaQuery.maybeOf(context)?.disableAnimations` : `true` → désactiver day-cascade, month-pulse, emoji-breathe, halo conseil ; rendu statique.
- Cibles tactiles ≥ 48dp (segments, flèches, CTA, cases calendrier).
- `Semantics` : label émotion sur chaque pastille (emoji seul non lu), flèche suivant désactivée annoncée, segment actif annoncé.
- Note discrète bas de page `journalLocalDataNote` (optionnel).

**Critères d'acceptation**
- `MediaQueryData(disableAnimations: true)` → rendu statique (test widget).
- Sémantique pastille / segment actif / flèche désactivée présentes.
- Toute la suite verte ; lints 0 warning/info.

**Validation finale (Before commit complet, depuis `apps/digiharmony_app/`)**
```
dart run build_runner build --delete-conflicting-outputs
melos exec -- dart format --set-exit-if-changed .
melos exec -- dart analyze --fatal-infos
melos exec --dir-exists=test -- flutter test
flutter gen-l10n
```

---

## Décisions intégrées (font foi — reprises de journal.md §9)

DEC-J-01..11 s'appliquent telles quelles. Rappel des plus structurantes pour l'implémentation :
DEC-J-01 (Jour défaut), DEC-J-02 (exercice = stub SnackBar), DEC-J-05 (mois borné au passé),
DEC-J-06 (mois seul, pas d'inter-mois), DEC-J-07 (comptages ordre fixe, pas de classement),
DEC-J-09 (`emojiPourCode`+`MoodColors`, jamais le mockup), DEC-J-10 (aucun score/streak/FOMO),
DEC-J-11 (lecture Drift seule + 2 observers).

## Hors périmètre V1 (→ V1.1)

Édition rétroactive jours passés ; écran/exercice Détox réel ; comparaisons inter-mois /
statistiques chiffrées ; export/partage ; traductions réelles `el/it/ro/tr/es/mk`.
