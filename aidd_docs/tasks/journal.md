---
page: Mon Journal
slug: journal
route: JournalPage (push via AppRouter.versJournal)
feature_dir: apps/digiharmony_app/lib/pages/journal/
status: valide
github: "#10"
us:
  - "#10 — US-8 « Mon Journal » (milestone Phase 1)"
depends_on:
  - "#3 Fondations (US-FND-01) — thème, Drift, AppRouter, i18n"
  - "#6 Noter mon humeur — données EntreesHumeur + SaisieHumeur"
related:
  - "#2 Accueil — point d'entrée (carte humeur « Voir mon journal »)"
shared_components:
  - AppTheme
  - AppColors
  - MoodColors.byKey
  - AppSpacing
  - AppRadii
  - AppRouter (ajout versJournal)
  - AppDatabase (table EntreesHumeur — lecture, +2 observers)
  - emotionsCanoniques / emojiPourCode / valencePour (modèle existant)
i18n_keys:
  - journalTitle
  - journalMenuTooltip
  - journalSegmentDay
  - journalSegmentWeek
  - journalSegmentMonth
  - journalDayMoodPrefix
  - journalDayTipLabel
  - journalDayDoExerciseCta
  - journalDayEditMoodLink
  - journalDayEmptyTitle
  - journalDayEmptyBody
  - journalDayEmptyCta
  - journalWeekTitle
  - journalWeekNoEntry
  - journalWeekSummary
  - journalWeekSummaryEmpty
  - journalMonthTitle
  - journalMonthPrevTooltip
  - journalMonthNextTooltip
  - journalMonthSectionTitle
  - journalMonthSummary
  - journalMonthSummaryEmpty
  - journalMonthFrequencyLine
  - journalExerciseComingSoon
  - journalLocalDataNote
tests: aidd_docs/tasks/journal.tests.md (à remplir en Step 5 par Kent)
created: 2026-06-05
updated: 2026-06-05
---

# Page Plan — « Mon Journal »

## 0. Garde-fous (DEC-003 + contraintes projet) — FONT LOI

- **Sans backend, sans Firebase, zéro collecte.** Aucun SDK réseau/analytics/tracking. Lecture 100 % locale (Drift). Aucune permission ajoutée.
- **Drift = journal réactif** (`watch()`), **jamais** HydratedBloc pour les entrées d'humeur (DEC-001/002). Le journal lit Drift uniquement.
- **7 émotions canoniques** (DEC-003) : `happy`, `calm`, `dynamic`, `sad`, `angry`, `nervous`, `tired`. Source de vérité unique = `emotionsCanoniques` (`lib/pages/saisie_humeur/modeles/emotion_canonique.dart`). **Pas d'enum, pas de mapping parallèle, pas les emojis/couleurs du mockup.**
- **Emojis via `emojiPourCode`**, **couleurs via `MoodColors.byKey`** (`lib/theme/theme.dart`). **Jamais de hex en dur**, jamais d'emoji codé en dur.
- **Aucun score / classement / comparaison inter-période / streak / FOMO** (DEC-003). Outil de recul bienveillant : comptages neutres, ordre fixe d'`emotionsCanoniques`, formulations descriptives.
- **i18n obligatoire** : aucune chaîne FR/EN en dur. Clés `journal*` réelles fr+en, repli `en` pour `el/it/ro/tr/es/mk`.
- **a11y reduced-motion** : toutes les animations désactivables via `MediaQuery.disableAnimations` (respect du réglage système). En mode réduit : rendu statique, pas de cascade/pulse/breathe/halo.
- **1 entrée / jour** : la table `EntreesHumeur` a un index UNIQUE sur `jour` (minuit local) — schéma v2. Le journal n'écrit jamais ; il lit.

---

## 1. Contexte & objectif

`JournalPage` est un écran **empilé** (push, retour possible) ouvert depuis la carte humeur de l'Accueil (« Voir mon journal », états A et B). Il offre une relecture bienveillante des humeurs notées sur 3 horizons via un SegmentedControl : **Jour (défaut)**, **Semaine**, **Mois**.

- **Accès** : public mineur, pas d'authentification (app sans compte). Aucune permission.
- **Lecture seule sur le passé** : édition rétroactive hors périmètre V1 (V1.1). Seul le **jour courant** est modifiable, et uniquement via la redirection vers `SaisieHumeur` (#6).
- **Données** : 100 % Drift local, réactif (`watch()`).

---

## 2. Structure de fichiers (conforme nommage projet)

Racine domaine FR, suffixes Flutter standard, Bloc-only (pas de Cubit), Event/State autorisés, transformer explicite, states `Equatable` + enum `status`.

```
apps/digiharmony_app/lib/pages/journal/
├── bloc/
│   └── journal_bloc/
│       ├── journal_bloc.dart        # Bloc (transformer restartable explicite)
│       ├── journal_event.dart       # Events (sealed/abstract + sous-classes)
│       └── journal_state.dart       # State Equatable + enum JournalStatus
├── views/
│   ├── journal_page.dart            # static page() + static route()  (fournit le Bloc + AppDatabase)
│   └── journal_view.dart            # Scaffold + Toolbar haute + SegmentedControl + switch de vue
└── widgets/
    ├── journal_segmented_control.dart   # Jour / Semaine / Mois
    ├── journal_vue_jour.dart            # carte du jour OU état vide bienveillant
    ├── journal_carte_jour.dart          # emoji + libellé + conseil + CTA + lien modifier
    ├── journal_vue_semaine.dart         # bande 7 jours + résumé
    ├── journal_vue_mois.dart            # calendrier + navigation flèches bornée + bloc « Ce mois-ci »
    ├── journal_calendrier_mois.dart     # grille calendrier (emoji par jour noté, numéro grisé sinon)
    └── journal_synthese_mois.dart       # fréquences (comptages sans classement) + tendance descriptive
```

> Aucun hex hors `theme.dart`. Toolbar haute présente (cohérence avec le design capturé : retour · titre · menu).

---

## 3. Données & lectures Drift

### 3.1 Existant réutilisé (ne rien redéfinir)
- Table `EntreesHumeur` (`lib/data/local/app_database.dart`) : `id`, `codeEmotion`, `valence`, `creeLe`, `jour` (minuit local), index UNIQUE sur `jour` (schéma v2). DataClass `EntreeHumeur`.
- `observerDerniereHumeurDuJour() → Stream<EntreeHumeur?>` : humeur du jour courant (vue Jour).
- `conseilDuJour(DateTime) → Future<Conseil>` : conseil déterministe (rotation), DataClass `Conseil` (champ `cleConseil` → clé i18n `tipDay0X`).
- `emotionsCanoniques`, `emojiPourCode(code)`, `valencePour(code)` (modèle), `MoodColors.byKey` (theme).

### 3.2 À AJOUTER dans `AppDatabase` (réactifs, lecture seule)

```dart
/// Entrées d'humeur de la semaine contenant [jourReference], réactif.
/// Bornes [lundi 00:00, lundi+7j) en heure locale, tri creeLe ASC.
Stream<List<EntreeHumeur>> observerEntreesDeLaSemaine(DateTime jourReference);

/// Entrées d'humeur du mois de [jourReference], réactif.
/// Bornes [1er du mois 00:00, 1er mois suivant 00:00) en local, tri creeLe ASC.
Stream<List<EntreeHumeur>> observerEntreesDuMois(DateTime jourReference);
```

- Mêmes conventions que `observerDerniereHumeurDuJour` : bornes `>= start & < end` sur `creeLe`, **borne haute exclue**, pas de post-filtrage.
- Semaine : début = lundi (locale-aware via calcul `weekday`), 7 jours. À mapper côté UI sur les 7 cases jour-par-jour (clé d'agrégation = `jour`, garanti unique).
- Mois : navigation par flèches → le Bloc recalcule `jourReference` et relance le stream du mois ciblé.

> 1 entrée/jour garantie par l'index UNIQUE : pas de dédoublonnage côté UI. Les listes sont déjà « au plus une par jour ».

---

## 4. Bloc / État / Événements

**Bloc-only**, transformer explicite. Le Bloc orchestre la vue active + l'ancrage temporel (mois affiché) et combine les 3 sources Drift selon la vue.

### 4.1 `JournalStatus` (enum)
```
initial · chargement · pret · erreur
```

### 4.2 `JournalState` (Equatable)
- `status: JournalStatus`
- `vueActive: JournalVue` (enum `jour` | `semaine` | `mois`, défaut `jour`)
- `humeurDuJour: EntreeHumeur?` (null → état vide bienveillant)
- `conseilDuJourCle: String?` (clé i18n `tipDay0X`)
- `entreesSemaine: List<EntreeHumeur>`
- `entreesMois: List<EntreeHumeur>`
- `moisAffiche: DateTime` (1er du mois ancré ; borné au passé)
- `peutAvancerMois: bool` (false si `moisAffiche` == mois courant → flèche « suivant » désactivée)
- `erreur: bool` (fallback bienveillant)

`copyWith` + `props` complets. Pas de score, pas de classement stocké.

### 4.3 `JournalEvent` (sealed/abstract)
- `JournalDemarre` : abonnements initiaux (jour + conseil + semaine + mois courant). Transformer **restartable**.
- `JournalVueChangee(JournalVue vue)` : change `vueActive` (recharge paresseuse si nécessaire). Transformer **droppable** (anti double-tap segment).
- `JournalMoisPrecedent` : recule `moisAffiche` d'1 mois, relance `observerEntreesDuMois`. **droppable**.
- `JournalMoisSuivant` : avance `moisAffiche` d'1 mois **uniquement si `peutAvancerMois`** (borné au présent, jamais de futur). **droppable**.
- `_JournalDonneesRecues(...)` : events internes émis par les souscriptions Drift (jour/semaine/mois) → mise à jour du state, `status = pret`.

> Recalcul de `peutAvancerMois` à chaque changement de `moisAffiche` : `moisAffiche` strictement avant le 1er du mois courant.
> Gestion d'erreur Drift → `emit(status: erreur, erreur: true)` ; l'UI dégrade en rendu bienveillant (pas de crash, pas de stack).

---

## 5. Les 3 vues

### 5.1 Vue Jour (défaut) — `journal_vue_jour.dart` + `journal_carte_jour.dart`

**Si humeur du jour présente** (`humeurDuJour != null`) :
- Carte du jour : pastille emoji colorée (`emojiPourCode(code)` + `MoodColors.byKey[code]`, fond `withValues(alpha: 0.18)`) + libellé localisé de l'humeur (`journalDayMoodPrefix` + libellé `mood*` résolu par `code`).
- Conseil 💡 : `journalDayTipLabel` + texte du conseil (clé `conseilDuJourCle` → `tipDay0X`). Halo bienveillant (animation, désactivable reduced-motion).
- CTA **« Faire l'exercice »** (`journalDayDoExerciseCta`) = **STUB V1** (Détox non implémenté) → `SnackBar` `journalExerciseComingSoon`. Aucune navigation réelle.
- Lien **« Modifier mon humeur »** (`journalDayEditMoodLink`) → `AppRouter.versSaisieHumeur(context)` (jour courant uniquement, #6).

**Si AUCUNE humeur aujourd'hui** (`humeurDuJour == null`) → **état vide bienveillant** :
- Titre doux `journalDayEmptyTitle` + corps `journalDayEmptyBody` (ton non culpabilisant, pas de FOMO).
- CTA **« Noter mon humeur »** (`journalDayEmptyCta`) → `AppRouter.versSaisieHumeur(context)` (#6).
- **Le conseil du jour reste affiché** même sans humeur notée.

### 5.2 Vue Semaine — `journal_vue_semaine.dart`
- Titre `journalWeekTitle`.
- 7 cases (lundi→dimanche, locale-aware) : pour chaque jour, soit pastille emoji colorée (`emojiPourCode` + `MoodColors`) si une entrée existe ce `jour`, soit un point neutre « · » (`journalWeekNoEntry`) sinon.
- Étiquette jour courte localisée sous chaque case (`DateFormat.E(locale)`).
- Résumé **descriptif bienveillant** sous la bande : `journalWeekSummary` si ≥ 1 saisie (phrase neutre, ex. nombre de jours notés sur 7, sans jugement) ; `journalWeekSummaryEmpty` si aucune saisie. **Aucun classement, aucune moyenne-score.**

### 5.3 Vue Mois — `journal_vue_mois.dart` + `journal_calendrier_mois.dart` + `journal_synthese_mois.dart`

**Calendrier** :
- En-tête : flèche précédent (`journalMonthPrevTooltip`) · libellé mois/année (`DateFormat.yMMMM(locale)`) · flèche suivant (`journalMonthNextTooltip`).
- **Navigation bornée au passé** : flèche « suivant » **désactivée** quand `peutAvancerMois == false` (mois courant atteint). Jamais de mois futur.
- Grille : chaque jour noté affiche son emoji (`emojiPourCode`) ; jour non noté → numéro grisé (`AppColors.textMuted`). Jours hors mois → vides. Animation `month-pulse`/`day-cascade` désactivable reduced-motion.

**Bloc « Ce mois-ci »** (`journal_synthese_mois.dart`) — **mois courant/affiché seul, AUCUNE comparaison inter-mois (DEC-003)** :
- Titre `journalMonthSectionTitle`.
- **Répartition = comptages SANS classement** : itération dans l'**ordre fixe d'`emotionsCanoniques`** (jamais trié par fréquence). Une ligne neutre par émotion ayant ≥ 1 occurrence, format `journalMonthFrequencyLine` (ex. « Serein·e : 9 jours ») — pas de podium, pas de score, pas de %-comparé.
- Tendance : phrase **descriptive** `journalMonthSummary` (ton bienveillant, recul) si ≥ 1 saisie ; `journalMonthSummaryEmpty` sinon. Pas de « mieux/pire que le mois dernier ».

> Note discrète bas de page possible : `journalLocalDataNote` (« Tes données restent sur cet appareil. ») — cohérent zéro-collecte.

---

## 6. Navigation & recâblage Accueil

### 6.1 Ajout `AppRouter.versJournal` (`lib/app/routing/app_router.dart`)
Sur le modèle exact de `versSaisieHumeur` (push, transmission explicite de `AppDatabase` à travers la frontière de route via `RepositoryProvider.value`) :

```dart
/// Ouvre le journal (empilé, retour possible).
/// L'[AppDatabase] est transmise explicitement (nouveau sous-arbre de route).
static Future<void> versJournal(BuildContext context) {
  final database = context.read<AppDatabase>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => RepositoryProvider<AppDatabase>.value(
        value: database,
        child: const JournalPage(),
      ),
    ),
  );
}
```
> `JournalPage.route()` peut encapsuler ce `MaterialPageRoute` ; `AppRouter.versJournal` reste le point d'entrée canonique appelé depuis l'Accueil.

### 6.2 Recâblage `carte_humeur.dart` (états A ET B)
Remplacer les **deux** `onPressed: () => ouvrirPlaceholder(context, l10n.placeholderJournal)` du lien « Voir mon journal » par :
```dart
onPressed: () => AppRouter.versJournal(context),
```
- État A : ligne ~88 (`_CarteEtatA`).
- État B : ligne ~173 (`_CarteEtatB`).
- `l10n.heroSeeJournal` (libellé du lien) conservé. Le placeholder `placeholderJournal` n'est plus déclenché par la carte (peut rester défini ailleurs, hors périmètre).

### 6.3 Fourniture du Bloc
`JournalPage.page()` crée `BlocProvider<JournalBloc>` avec `JournalBloc(context.read<AppDatabase>())..add(const JournalDemarre())`, puis rend `JournalView`.

---

## 7. i18n (clés `journal*`, fr + en réels, repli en)

À ajouter dans `app_fr.arb` et `app_en.arb` (puis repli `en` copié dans `el/it/ro/tr/es/mk` — TODO traduction, conforme registry).

| Clé | EN (réf.) | Note |
|---|---|---|
| `journalTitle` | "My journal" | Titre Toolbar |
| `journalMenuTooltip` | "Options" | Tooltip menu Toolbar |
| `journalSegmentDay` | "Day" | Segment |
| `journalSegmentWeek` | "Week" | Segment |
| `journalSegmentMonth` | "Month" | Segment |
| `journalDayMoodPrefix` | "Today you are feeling" | Préfixe libellé |
| `journalDayTipLabel` | "Tip of the day" | Label conseil 💡 |
| `journalDayDoExerciseCta` | "Do the exercise" | CTA stub |
| `journalDayEditMoodLink` | "Edit my mood" | Lien → #6 |
| `journalDayEmptyTitle` | "No mood logged yet today" | État vide bienveillant |
| `journalDayEmptyBody` | "Whenever you feel ready, you can note how you feel." | Corps doux |
| `journalDayEmptyCta` | "Log my mood" | CTA → #6 |
| `journalWeekTitle` | "This week" | Titre vue semaine |
| `journalWeekNoEntry` | "·" | Marqueur jour non noté |
| `journalWeekSummary` | "You logged your mood on {count} of 7 days." | Placeholder ICU `{count}` |
| `journalWeekSummaryEmpty` | "No mood logged this week yet." | Semaine vide |
| `journalMonthTitle` | "This month" | Titre vue mois |
| `journalMonthPrevTooltip` | "Previous month" | Flèche |
| `journalMonthNextTooltip` | "Next month" | Flèche (désactivée si futur) |
| `journalMonthSectionTitle` | "This month at a glance" | Bloc synthèse |
| `journalMonthSummary` | "A gentle look back over your month." | Tendance descriptive |
| `journalMonthSummaryEmpty` | "No mood logged this month yet." | Mois vide |
| `journalMonthFrequencyLine` | "{label}: {count, plural, =1{1 day} other{{count} days}}" | ICU ; `{label}` = libellé `mood*` |
| `journalExerciseComingSoon` | "This exercise is coming soon." | SnackBar stub V1 |
| `journalLocalDataNote` | "Your data stays on this device." | Note zéro-collecte |

> Les libellés d'émotions réutilisent les clés existantes `moodHappy/moodCalm/moodDynamic/moodSad/moodAngry/moodNervous/moodTired` (résolution par `code`, comme dans `carte_humeur.dart`). **Ne pas créer de doublons.**

---

## 8. Accessibilité

- **Reduced-motion** : lire `MediaQuery.maybeOf(context)?.disableAnimations`. Si `true` → désactiver day-cascade, month-pulse, emoji-breathe, halo conseil ; rendu statique.
- Cibles tactiles ≥ 48dp (segments, flèches, CTA, cases calendrier).
- `Semantics` : label émotion sur chaque pastille (emoji seul non lu) ; flèche « suivant » désactivée annoncée comme telle ; segment actif annoncé.
- Contraste : libellés via `MoodColors` sur fond clair — couleurs theme déjà calibrées.
- Toolbar : bouton retour standard (`Navigator.maybePop`).

---

## 9. Décisions intégrées (font foi)

- **DEC-J-01** Jour = vue par défaut au lancement.
- **DEC-J-02** « Faire l'exercice » = STUB V1 (SnackBar `journalExerciseComingSoon`) — Détox non implémenté.
- **DEC-J-03** « Modifier mon humeur » / « Noter mon humeur » → `SaisieHumeur` (#6), **jour courant uniquement**.
- **DEC-J-04** État vide bienveillant si aucune humeur du jour ; le conseil reste affiché.
- **DEC-J-05** Navigation mois **bornée au passé** (pas de futur) ; flèche suivant désactivée au mois courant.
- **DEC-J-06** Synthèse mois = **mois courant seul**, **aucune comparaison inter-mois** (DEC-003).
- **DEC-J-07** Répartition = **comptages sans classement**, ordre fixe `emotionsCanoniques`, formulation neutre.
- **DEC-J-08** Jours passés = lecture seule (édition rétroactive V1.1).
- **DEC-J-09** Emojis/couleurs **jamais** issus du mockup → `emojiPourCode` + `MoodColors.byKey`.
- **DEC-J-10** Aucun score/streak/FOMO (DEC-003) ; outil de recul bienveillant.
- **DEC-J-11** Lecture Drift seule ; +2 observers réactifs (`observerEntreesDeLaSemaine`, `observerEntreesDuMois`).

---

## 10. Plan de tests prévisionnel (pour Kent — Step 5)

**Bloc (`bloc_test`)**
- `JournalDemarre` → `chargement` puis `pret` avec humeur/conseil/semaine/mois courant peuplés.
- `JournalDemarre` sans entrée du jour → `pret`, `humeurDuJour == null`, conseil présent.
- `JournalVueChangee` → `vueActive` mise à jour, données cohérentes.
- `JournalMoisPrecedent` → `moisAffiche` reculé, `peutAvancerMois == true`, stream mois relancé.
- `JournalMoisSuivant` au mois courant → no-op (`peutAvancerMois == false`, pas de futur).
- `JournalMoisSuivant` depuis un mois passé → avance, `peutAvancerMois` recalculé.
- Erreur Drift → `status: erreur`, `erreur: true`, pas de crash.
- Réactivité : nouvelle entrée Drift le jour courant → state ré-émis.

**AppDatabase (`AppDatabase.forTesting`, SQLite mémoire)**
- `observerEntreesDeLaSemaine` : bornes lundi→dimanche, borne haute exclue, tri ASC, 1/jour.
- `observerEntreesDuMois` : bornes 1er→fin de mois, borne haute exclue, mois sans entrée → liste vide.

**Widget**
- Vue Jour avec humeur : pastille emoji `emojiPourCode` + couleur `MoodColors`, libellé `mood*`, conseil, CTA exercice → SnackBar `journalExerciseComingSoon` (pas de navigation).
- Vue Jour vide : titre/corps/CTA bienveillants + conseil affiché ; CTA → versSaisieHumeur.
- Vue Semaine : 7 cases, « · » pour jours non notés, résumé `journalWeekSummary`/`Empty`.
- Vue Mois : flèche suivant désactivée au mois courant ; numéro grisé jour non noté.
- Synthèse mois : lignes dans l'ordre `emotionsCanoniques`, aucune ligne triée par fréquence, aucune comparaison inter-mois.
- reduced-motion : `MediaQueryData(disableAnimations: true)` → rendu statique.

**Navigation / recâblage**
- `AppRouter.versJournal` push `JournalPage` avec `AppDatabase` fournie.
- `carte_humeur.dart` états A et B : tap « Voir mon journal » → `versJournal` (et non plus `ouvrirPlaceholder`).

**i18n**
- Toutes les clés `journal*` présentes fr+en ; aucune chaîne en dur dans les widgets ; ICU `{count}`/`plural` valides.

**a11y**
- Sémantique pastille (label émotion), segment actif, flèche désactivée.

---

## 11. Hors périmètre V1 (→ V1.1)

- Édition rétroactive des jours passés.
- Écran/exercice Détox (« Faire l'exercice » → réel).
- Comparaisons inter-mois, tendances chiffrées, statistiques avancées.
- Export / partage du journal.
- Traductions réelles `el/it/ro/tr/es/mk` (repli `en` en V1).
