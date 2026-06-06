---
page: Conseils
slug: conseils
route: ConseilsPage (push via AppRouter.versConseils)
feature_dir: apps/digiharmony_app/lib/pages/conseils/
status: implemente
github:
us:
  - "US-CO-01 « Parcourir le deck de conseils » (à créer via Erwin — milestone Phase 2 🟡)"
  - "US-CO-02 « Voir un conseil adapté à mon humeur » (à créer via Erwin — dépend de #6)"
depends_on:
  - "#3 Fondations (US-FND-01) — thème, Drift, AppRouter, i18n, HaloRespirant, ParticulesFlottantes"
  - "#6 Noter mon humeur — table EntreesHumeur (lecture, pour les cartes émotion)"
related:
  - "#2 Accueil — point d'entrée (tuile « Conseil du jour », homeToolDailyTip)"
  - journal.md (conseil du jour + emotionsCanoniques)
  - soutien.md (CTA respiration / Détox = stub partagé)
shared_components:
  - AppTheme
  - AppColors
  - MoodColors.byKey
  - AppSpacing
  - AppRadii
  - AppRouter (ajout versConseils)
  - AppDatabase (Conseils + EntreesHumeur — LECTURE ; +2 lectures, +seed étendu)
  - emotionsCanoniques / emojiPourCode / valencePour / libelleEmotion
  - HaloRespirant (décor fond, a11y-aware)
  - ParticulesFlottantes (particules ambiantes, a11y-aware)
  - ouvrirPlaceholder (common/placeholder_screen.dart) — stub respiration/Détox
i18n_keys:
  - conseilsTitre
  - conseilsRetourTooltip
  - conseilsHintPrecedent
  - conseilsHintSuivant
  - conseilsTagEquilibre
  - conseilsTagRappel
  - conseilsTagConseilPratique
  - conseilsTagEmotion
  - conseilsEmotionHeadline
  - conseilsEmotionCta
  - conseilsEmotionRespirationBientot
  - conseilsCompteurSemantique
  - conseilsCarteSemantique
  - "conseilsContenu* (corpus de cartes — voir §7.2, PLACEHOLDERS à valider partenaires)"
i18n_keys_existantes_reutilisees:
  - "tipDay01..tipDay07 (conseils du jour existants — réinjectés comme cartes rappel/conseil)"
  - moodHappy / moodCalm / moodDynamic / moodSad / moodAngry / moodNervous / moodTired
  - homeToolDailyTip (libellé tuile Accueil — point d'entrée)
tests: aidd_docs/tasks/conseils.tests.md (à remplir en Step 5 par Kent)
created: 2026-06-06
updated: 2026-06-06
---

# Page Plan — « Conseils » (deck de cartes swipables)

> **STATUT : `proposition_a_valider`.** Plan auto-suffisant pour l'éditeur IA. Cible :
> `apps/digiharmony_app/`. App DIGIHARMONY, public mineur, Erasmus+, **SANS backend ni Firebase,
> ZÉRO collecte**. Maquette Banani `new_screen13` (« Conseils ») **récupérée et confirmée** (deck 3
> types de cartes : rappel / emotion / conseil). **Le contenu des cartes = PLACEHOLDERS à valider
> partenaires** (rien n'est figé comme définitif). Les points ouverts sont en **§13 Questions à
> valider** ; la **logique de sélection/composition du deck** (attente n°1 de l'utilisateur) est
> tranchée en **DEC-CO-03 à DEC-CO-06** avec alternatives + raison.

---

## 0. Garde-fous (FONT LOI — priment sur tout détail divergent ci-dessous)

- **Sans backend, sans Firebase, zéro collecte.** Aucun SDK réseau/analytics/tracking/Crashlytics.
  Lecture 100 % locale (Drift). Aucune permission ajoutée. Aucun appel réseau.
- **Lecture Drift seule** : la page **ne fait que LIRE** `Conseils` (corpus) et `EntreesHumeur`
  (humeur récente, pour prioriser les cartes émotion). **Aucune écriture.** (DEC-CO-09 : **aucun CTA
  « J'applique »** — supprimé, inutile.)
- **AUCUN score / classement / streak / FOMO / comparaison / boucle de rétention** (DEC-003 +
  design-system §garde-fous éthiques). Le compteur de cartes (dots) est un **indicateur de position**,
  **jamais** un score ou une progression à « compléter ». Pas de « X conseils appliqués », pas de
  badge, pas de pourcentage.
- **Public mineur, ton bienveillant** : le contenu des cartes est **doux, non culpabilisant, non
  injonctif agressif**. Do's/Don'ts formulés avec bienveillance. → **Tout le corpus est PLACEHOLDER à
  valider par les partenaires Erasmus+ avant figement** (DEC-CO-10).
- **Émotions = 7 canoniques** (DEC-003) : `happy/calm/dynamic/sad/angry/nervous/tired`. Source de
  vérité unique = `emotionsCanoniques` (`lib/pages/saisie_humeur/modeles/emotion_canonique.dart`).
  **Couleur d'une carte émotion = `MoodColors.byKey[code]` UNIQUEMENT** — JAMAIS le hex du mockup
  (le mockup met `#E5392B` pour Colère en dur : à **remplacer** par `MoodColors.angry`). Libellé via
  `libelleEmotion(l10n, code)`. Emoji via `emojiPourCode(code)`.
- **Couleurs (chrome / accents de carte rappel & conseil)** via tokens `AppColors` UNIQUEMENT — JAMAIS
  de hex en dur. Le mockup encode des accents bruts (`#3FB8E6`, `#A8D24E`, `#F0C84A`, `#8A3FD1`) → à
  **mapper sur tokens** : cyan `AppColors.primary`, lime `AppColors.signatureGradient[1]`, or
  `AppColors.accentGold`, violet **= n'existe pas dans le chrome** → voir DEC-CO-07 (l'accent violet
  du mockup pour une carte *conseil* serait une couleur d'émotion `MoodColors.nervous` détournée du
  chrome → **interdit**). On restreint donc les accents des cartes rappel/conseil à la palette chrome.
- **i18n obligatoire** : aucune chaîne FR/EN en dur. Clés `conseils*`/`conseil*` réelles fr+en, repli
  `en` (TODO) pour `el/it/ro/tr/es/mk`. Le corpus de cartes vit **dans les ARB** (jamais de texte en
  dur dans le dataset Dart — le dataset ne porte que des **clés**, comme la table `Conseils`).
- **a11y reduced-motion** : `MediaQuery.maybeOf(context)?.disableAnimations`. Si `true` →
  **particules OFF, halo statique, animations d'entrée/swipe OFF** (rendu statique). Tap ≥ 48×48 dp.
  **Swipe accessible** : navigation aussi possible **sans geste** (flèches/zones tap + actions de
  défilement sémantiques) pour lecteurs d'écran / motricité réduite (DEC-CO-08).
- **Bloc-only** (Cubit interdit, règle `1-bloc-only-no-cubit`) ; transformers explicites ; `State`
  `Equatable` avec enum `status`. Un **seul** `ConseilsBloc` qui **compose le deck** depuis Drift +
  dataset. Suffixes `Event`/`State` autorisés (dérogation).
- **Nommage FRANÇAIS** : dossier `lib/pages/conseils/`, classes `ConseilsPage`/`ConseilsView`/
  `ConseilsBloc`/`ConseilsState`/`ConseilsEvent`. Structure imposée (`0-flutter-pages-structure`) :
  `lib/pages/conseils/{bloc,views,widgets,modeles}`. Scaffolding technique reste anglais.
- **Android : `minify`/`shrinkResources = false`** (déjà acté Fondations).

---

## 1. Contexte & objectif

| Élément | Valeur |
|---|---|
| **But** | Offrir à l'ado un **deck de conseils bienveillants** sur le bien-être numérique, parcourable par **swipe** (ou flèches a11y), mêlant des **rappels** (citations courtes), des **conseils pratiques** (Do's/Don'ts) et — quand une humeur a été notée — une **carte émotion contextuelle** adaptée à ce qu'il ressent. |
| **Accès** | Aucune auth (app sans compte). Empilée (`push`) depuis la **tuile « Conseil du jour »** de l'Accueil (`TuileOutil` `homeToolDailyTip`, `accueil_view.dart` ~L105-115), aujourd'hui câblée sur `ouvrirPlaceholder(context, l10n.placeholderConseil)` → **à recâbler** vers `AppRouter.versConseils(context)` (§6). |
| **Route** | Pas de GoRouter (DEC-FND-07). Nouvelle méthode `AppRouter.versConseils(context)` en **`push`** (retour chevron), calquée sur `versJournal` (transmet `AppDatabase` à travers la frontière de route). |
| **Retour** | Toolbar haute : chevron `Icons.chevron_left` → `Navigator.pop`. Titre « Conseils » centré, espaceur à droite (**pas de menu/burger** — conforme mockup). |
| **Milestone** | **Phase 2** 🟡. Dépend de Fondations (#3) + Noter mon humeur (#6, pour l'humeur des cartes émotion). |

---

## 2. La maquette (Banani `new_screen13`) — éléments visuels confirmés

Fond profond `#16213C` = `AppColors.backgroundDeep`. **Particules ambiantes** (3) + **halo de fond**
teinté par l'accent de la carte active (désactivables reduced-motion).

1. **Toolbar** : chevron retour (48×48) · titre « Conseils » · espaceur 48 (pas de burger).
2. **Compteur de cartes (dots)** : un point par carte ; **carte active = pilule élargie** (largeur ~20
   vs 6) ; **couleur du point actif = accent de la carte active** ; inactifs = `textMuted @22%`.
3. **Deck de cartes swipables** (largeur max ~335, rayon 24 = `AppRadii.card`, fond `#283A5E` =
   `AppColors.surface`, bordure `accent @30%`) avec :
   - **peek de la carte suivante** derrière (scale 0.93, translateY +14, fond surface) ;
   - **bord de la carte précédente** à gauche (bande 32px, opacité 0.45).
   - Décor interne par carte : 2 « clouds » radiaux teintés accent + streak d'accent en haut (4px).
   - **3 types de cartes** :
     - **`rappel`** : tag (icône + libellé court, ex. « Équilibre »/« Rappel ») · **grande citation 2
       lignes** (~48px ; ligne 2 en couleur d'accent) · sous-texte (`textMuted`, max ~260px).
     - **`emotion`** : tag « Émotion » (**accent = couleur de l'émotion**) · headline « Quand tu te
       sens {émotion}… » · **Do's** (puce ✓ ronde accent) · **Don'ts** (puce ✗ ronde grise) · **CTA**
       « Essayer la respiration » (bouton plein accent, 44px) → **STUB** respiration/Détox.
     - **`conseil`** : tag « Conseil pratique » · headline · Do's/Don'ts (mêmes puces). Pas de CTA.
4. **Hint swipe** : « précédent ‹ | › suivant » (très atténué).

> ⚠️ **Suppression du CTA bas du mockup** : le bouton plein « J'applique ce conseil » du mockup
> **n'est PAS repris** (DEC-CO-09 — inutile : il n'écrivait rien, pas de score/historique anti-rétention).
> L'écran se termine sur le hint swipe ; la navigation entre cartes suffit.

> ⚠️ **Le mockup met les accents en hex brut** (`#E5392B`, `#3FB8E6`, `#A8D24E`, `#F0C84A`, `#8A3FD1`).
> **À NE PAS reproduire** : voir §0 + DEC-CO-07. Couleur émotion ⇒ `MoodColors.byKey` ; accents
> rappel/conseil ⇒ palette **chrome** (`primary` / `signatureGradient[1]` lime / `accentGold`).

---

## 3. ⚠️ LE POINT DUR — logique de SÉLECTION / COMPOSITION du deck

> **C'est l'attente explicite n°1.** « En fonction de quoi les conseils apparaissent ». Tout est
> **déterministe et local** (zéro collecte, testable). On distingue **(a)** d'où viennent les cartes
> (modèle de données), **(b)** comment chaque sous-ensemble est choisi, **(c)** comment le deck final
> est composé/ordonné, **(d)** le cas « aucune humeur notée ».

### 3.1 Décision globale — déterminisme local (DEC-CO-03)

**Le deck est composé de façon DÉTERMINISTE par jour, sans aléatoire non reproductible.** Même
ancrage que `conseilDuJour` : `joursDepuisEpoch = jourNormalise.difference(epoch(1970)).inDays`. Pour
une date et un état d'humeur donnés, **le deck est toujours identique** (rejouable, testable, cohérent
avec l'esprit zéro-collecte / non-addictif : pas de « tire encore pour voir du neuf »).

- **Alternatives écartées** :
  - *Aléatoire par session* (`Random()`) : non reproductible → intestable proprement, et crée une
    boucle « refresh pour du nouveau contenu » (mini-FOMO) → contraire DEC-003. ❌
  - *Aléatoire seedé sur le jour* (`Random(joursDepuisEpoch)`) : reproductible, mais surcoût et ordre
    moins lisible qu'une rotation modulaire explicite. ❌ (la rotation `%` suffit et est déjà le
    pattern maison `conseilDuJour`).
- **Raison du choix** : cohérence avec l'existant (`conseilDuJour`), testabilité parfaite (helper
  pur), zéro mécanique de rétention.

### 3.2 Cartes ÉMOTION — priorité contextuelle selon l'humeur (DEC-CO-04)

**Une carte émotion contextuelle est placée EN TÊTE du deck si — et seulement si — une humeur a été
notée pour le jour courant, ET que cette émotion possède une carte émotion dans le corpus.**

- **Source** : `AppDatabase.observerDerniereHumeurDuJour()` (déjà existant, réactif `watch()`) →
  `EntreeHumeur?`. On lit **le `codeEmotion` du jour** (la dernière saisie du jour).
- **Mapping** : `codeEmotion` (∈ `emotionsCanoniques`) → carte émotion correspondante du corpus
  (`CarteConseil` de type `emotion` portant ce `codeEmotion`).
- **Couleur** : `MoodColors.byKey[codeEmotion]` (jamais le hex mockup). Headline = `conseilsEmotionHeadline`
  avec placeholder `{emotion}` = `libelleEmotion(l10n, code)`.
- **Portée V1** : on cible **les 7 émotions canoniques** ; le corpus fournit **au moins les 4 émotions
  négatives** (`sad/angry/nervous/tired` — les plus utiles à accompagner) + idéalement les 3
  positives (`happy/calm/dynamic`) en cartes « entretien » bienveillantes. 🟡 Q-CO-3 : couvre-t-on les
  7 ou seulement les 4 négatives en V1 ? **Reco : les 7** (cohérence ; contenu placeholder).
- **« Humeur récente » V1 = humeur DU JOUR** (pas une tendance multi-jours). Justification : simple,
  déterministe, aligné sur la donnée déjà exposée (`observerDerniereHumeurDuJour`). Une **tendance**
  (ex. émotion négative dominante des 7 derniers jours) est **hors V1** (DEC-CO-04, voir §11 / Q-CO-4)
  — elle nécessiterait un agrégat supplémentaire et complexifierait le déterminisme.

> **Alternatives écartées** : (i) prioriser selon la **valence** plutôt que l'émotion exacte (« si
> négatif, montrer une carte de réconfort générique ») → moins pertinent que cibler l'émotion précise ;
> gardé en **repli** si l'émotion n'a pas de carte dédiée (DEC-CO-06). (ii) Insérer **plusieurs** cartes
> émotion → bruyant ; V1 = **une seule** carte émotion contextuelle, en tête.

### 3.3 Cartes RAPPEL / CONSEIL génériques — rotation déterministe quotidienne (DEC-CO-05)

Les cartes **rappel** et **conseil** (bien-être numérique générique, non liées à l'humeur) sont
choisies par **rotation déterministe quotidienne**, exactement comme `conseilDuJour` :

- Le corpus générique est une **liste ordonnée stable** (par `id`/ordre de seed).
- **Point de départ du jour** : `offset = joursDepuisEpoch % nbCartesGeneriques`.
- On prend **N cartes** à partir de `offset` (en boucle circulaire) dans l'ordre du corpus → le deck
  « tourne » d'un cran chaque jour (contenu stable dans la journée, frais le lendemain, sans aléatoire).
- **N (taille de la portion générique)** : 🟡 **Q-CO-2** — proposition **4** cartes génériques
  (+ éventuellement 1 carte émotion en tête = **3 à 5 cartes** au total, cohérent mockup « 2/5 »).

> **Réconciliation avec `conseilDuJour` / `tipDay0X` (DEC-CO-11)** : les 7 `tipDay01..07` existants
> (table `Conseils`) **deviennent des cartes du deck** (type `rappel` ou `conseil` selon leur nature).
> La **toute première carte générique du jour** (à `offset`) est, par construction, **le même conseil
> que `conseilDuJour(today)`** → **cohérence garantie** entre la tuile « Conseil du jour » de l'Accueil
> et le deck (la tuile affiche le tip du jour ; le deck l'ouvre en première carte générique). Pas de
> contenu divergent, pas de duplication de logique : même `joursDepuisEpoch % n`.

### 3.4 Composition & ordre final du deck (DEC-CO-06)

Ordre de construction (déterministe), géré par un **helper pur** `composerDeck(...)` testable :

```
deck = []
1. SI humeurDuJour != null ET corpus contient une carte emotion pour son code :
     deck.add( carteEmotion(code) )           // carte contextuelle EN TÊTE
   SINON SI humeurDuJour != null ET valence < 0 (repli, pas de carte dédiée) :
     deck.add( carteEmotionGenerique )         // repli réconfort (optionnel V1, Q-CO-3)
2. portion générique = rotation déterministe (DEC-CO-05) de N cartes
   en EXCLUANT une éventuelle carte déjà ajoutée en 1 (pas de doublon).
   deck.addAll(portionGenerique)
3. deck final = liste ordonnée (carte 0 = contextuelle si présente, sinon 1ʳᵉ générique = conseil du jour).
```

- **Aucune humeur notée** → **étape 1 sautée** → deck **100 % générique** (rotation du jour). C'est le
  cas « par défaut » (mockup le montre sans dépendre d'une humeur). Jamais d'écran vide : le corpus
  générique est toujours seedé (≥ 7), donc le deck a toujours ≥ N cartes.
- **Pas de doublon** : si la carte émotion contextuelle = une carte aussi présente dans la portion
  générique (improbable, types distincts), on déduplique par `cleContenu`.
- **Le compteur de dots** reflète `deck.length` (3 à 5 selon présence de la carte émotion).
- **Réactivité** : si l'utilisateur **note/modifie son humeur** pendant que l'écran est ouvert (peu
  probable depuis cet écran, mais possible en multitâche), le stream `observerDerniereHumeurDuJour`
  ré-émet → le Bloc **recompose le deck** et revient à la carte 0. 🟡 Q-CO-5 : recomposer en live ou
  figer à l'ouverture ? **Reco : figer le deck à l'ouverture** (DEC-CO-06) pour ne pas « voler » la
  position de lecture ; on lit l'humeur **une fois** au `ConseilsDemarre` (lecture ponctuelle, pas
  d'abonnement continu). Plus simple, plus stable UX.

### 3.5 Schéma de la composition (récap)

```
                ┌─────────────────────────────────────────────┐
   Drift LECTURE│ EntreesHumeur: observerDerniereHumeurDuJour  │ (1 lecture ponctuelle)
                │ Conseils     : corpus de cartes (clés)        │ (1 lecture)
                └───────────────┬─────────────────────────────┘
                                ▼
                       composerDeck(humeurDuJour, corpus, today)   ← helper PUR (testable)
                                ▼
   [ carteEmotion(code)? ]  +  [ rotation déterministe de N cartes génériques ]
                                ▼
                       List<CarteConseil>  → ConseilsState.deck
```

---

## 4. Modèle de données (Drift étendu — clés i18n, contenu FR/EN dans les ARB)

> **Principe** (cohérent avec l'existant `Conseils.cleConseil`) : **la base ne stocke que des CLÉS et
> des métadonnées structurelles**, jamais le texte (qui vit dans les ARB, 8 langues). Conventions
> **data en FRANÇAIS** (architecture.md).

### 4.1 Décision : étendre la table `Conseils` (DEC-CO-01)

On **étend la table `Conseils` existante** (plutôt qu'une 2ᵉ table) avec des colonnes structurelles.
Cela réutilise le seed/rotation déjà en place et garde **une source unique** du corpus.

```dart
@DataClassName('Conseil')
class Conseils extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Clé i18n du TITRE/headline ou de la citation (le texte vit dans les ARB).
  TextColumn get cleConseil => text().named('cle_conseil')();

  // ─── AJOUTS (schéma v4) ───
  /// Type de carte : 'rappel' | 'conseil' | 'emotion'.
  TextColumn get typeCarte => text().named('type_carte').withDefault(const Constant('conseil'))();

  /// Code émotion canonique si typeCarte == 'emotion' (sinon null).
  /// ∈ emotionsCanoniques ('happy','calm',...). Couleur via MoodColors.byKey.
  TextColumn get codeEmotion => text().named('code_emotion').nullable()();

  /// Jeton d'accent CHROME pour rappel/conseil : 'primary' | 'lime' | 'or'.
  /// IGNORÉ pour 'emotion' (accent = MoodColors). JAMAIS un hex. (DEC-CO-07)
  TextColumn get accentChrome => text().named('accent_chrome').withDefault(const Constant('primary'))();

  /// Ordre stable dans le corpus (rotation déterministe). Défaut = id.
  IntColumn get ordre => integer().withDefault(const Constant(0))();
}
```

> **Alternative écartée** : un **dataset Dart statique** (pas de Drift) pour le corpus. Rejeté car
> (i) le corpus existe **déjà** en Drift (`Conseils` seedé), (ii) la rotation `conseilDuJour` lit
> Drift, (iii) garder une seule source évite la divergence. **Le contenu textuel**, lui, reste **hors
> Drift** (ARB) — c'est déjà le cas.

### 4.2 Migration (schéma v3 → v4) — idempotente (DEC-CO-02)

`schemaVersion: 3 → 4`. Dans `onUpgrade`, bloc `if (from < 4)` **idempotent** (même prudence que les
migrations v2/v3 existantes : vérifier la présence des colonnes via `PRAGMA table_info` avant
`addColumn`, ne jamais dupliquer) :

- `addColumn` `type_carte`, `code_emotion`, `accent_chrome`, `ordre` **si absentes**.
- **Re-seed enrichi** : les colonnes ajoutées ont des `withDefault`, donc les lignes `tipDay01..07`
  existantes restent valides ; un **`UPDATE`** assigne `type_carte`/`accent_chrome`/`ordre` corrects
  aux 7 tips existants (voir §4.3), et un **`INSERT … WHERE NOT EXISTS`** ajoute les **nouvelles cartes
  émotion** (clés `conseilEmotion*`) sans dupliquer si déjà présentes (idempotence par `cle_conseil`).
- `beforeOpen` : le `_seedConseils()` existant doit devenir **`_seedCorpus()`** seedant le corpus
  complet (rappels + conseils + 7 émotions) **de façon idempotente** (skip si `cleConseil` déjà
  présente, pas seulement `count > 0` — sinon une base v3 à 7 lignes ne recevrait jamais les cartes
  émotion). 🟡 Détail d'implémentation à confirmer (Q-CO-6).

> ⚠️ **Après modif du modèle Drift** : `dart run build_runner build --delete-conflicting-outputs`
> (coding-assertions). Migration **idempotente obligatoire** (précédents v2/v3 = modèle de prudence).

### 4.3 Corpus seedé (clés — contenu PLACEHOLDER ARB, à valider partenaires)

| `cle_conseil` | `type_carte` | `code_emotion` | `accent_chrome` | Origine |
|---|---|---|---|---|
| `tipDay01`..`tipDay07` | `rappel` ou `conseil` (à répartir, Q-CO-7) | — | `primary`/`lime`/`or` (cyclique) | **Existant** réutilisé |
| `conseilEmotionAngry` | `emotion` | `angry` | (ignoré) | Nouveau |
| `conseilEmotionSad` | `emotion` | `sad` | (ignoré) | Nouveau |
| `conseilEmotionNervous` | `emotion` | `nervous` | (ignoré) | Nouveau |
| `conseilEmotionTired` | `emotion` | `tired` | (ignoré) | Nouveau |
| `conseilEmotionHappy` | `emotion` | `happy` | (ignoré) | Nouveau (positif, entretien) |
| `conseilEmotionCalm` | `emotion` | `calm` | (ignoré) | Nouveau |
| `conseilEmotionDynamic` | `emotion` | `dynamic` | (ignoré) | Nouveau |
| `conseilRappelPresent` | `rappel` | — | `primary` | Nouveau (« Scroll later, live now. ») |
| `conseilRappelLikes` | `rappel` | — | `or` | Nouveau (« Tu n'es pas ton like count. ») |
| `conseilPratiqueInteractions` | `conseil` | — | `lime` | Nouveau |
| `conseilPratiqueEspace` | `conseil` | — | `primary` | Nouveau |

> Les nombres exacts (combien de rappels/conseils/émotions) sont **ajustables** (Q-CO-2/3/7). Le
> tableau ci-dessus est une **proposition placeholder**. **Aucun texte ici n'est définitif.**

### 4.4 ViewModel UI (pas de logique dans la vue)

```dart
/// Carte composée prête à afficher (clés i18n résolues à l'affichage).
sealed class CarteConseil {
  final String cleContenu;     // base de clé i18n (ex. 'conseilRappelPresent')
}
class CarteRappel extends CarteConseil {
  final String accentChrome;   // 'primary'|'lime'|'or'  → résolu en Color via helper
  // texte = ARB: <cle>Citation1 / <cle>Citation2 / <cle>SousTexte / <cle>Tag (+ icône)
}
class CarteConseilPratique extends CarteConseil {
  final String accentChrome;
  // texte = ARB: <cle>Headline / <cle>Dos (List) / <cle>Donts (List) / <cle>Tag
}
class CarteEmotion extends CarteConseil {
  final String codeEmotion;    // ∈ emotionsCanoniques → couleur MoodColors.byKey
  // headline = conseilsEmotionHeadline({emotion}) ; dos/donts = ARB <cle>Dos/<cle>Donts
  // CTA = conseilsEmotionCta → STUB respiration
}
```

> **Résolution Do's/Don'ts en i18n** : une liste de puces = **clés indexées** (`<cle>Do1`, `<cle>Do2`,
> … / `<cle>Dont1`, …) car gen-l10n ne gère pas les listes natives. Helper de résolution
> `List<String> resoudreLignes(l10n, cleBase, suffixe, nb)`. 🟡 Q-CO-8 : nombre fixe de puces (ex. 3
> Do's + 2 Don'ts) pour simplifier les clés. **Reco : gabarit fixe 3 Do's / 2 Don'ts** (comme le
> mockup), clés `…Do1..3` / `…Dont1..2`.

---

## 5. Bloc / Event / State

**Pattern** : `flutter_bloc` (Bloc-only), `bloc_lint`. State `Equatable` + enum `status`. Transformers
explicites (`bloc_concurrency`). Le Bloc **compose le deck** (via helper pur) et gère la **carte
courante** (index).

### 5.1 `ConseilsStatus` (enum)
```
initial · chargement · pret · erreur
```

### 5.2 `ConseilsState` (Equatable)
- `status: ConseilsStatus`
- `deck: List<CarteConseil>` (composé, ordonné — vide tant que `chargement`)
- `indexCourant: int` (0-based ; carte active)
- `erreur: bool` (fallback bienveillant)

`copyWith` + `props` complets. **Aucun champ de score / progression.** Dérivés en getters :
`carteCourante`, `aPrecedent` (`indexCourant > 0`), `aSuivant` (`indexCourant < deck.length - 1`),
`accentCourant` (token chrome ou `MoodColors` selon le type — résolu côté View).

### 5.3 `ConseilsEvent` (sealed/abstract)
| Event | Déclenché par | Transformer | Charge |
|---|---|---|---|
| `ConseilsDemarre` | `page()` / ouverture | `restartable()` | — |
| `ConseilsCarteSuivante` | swipe gauche / flèche › / tap zone droite | `droppable()` | — |
| `ConseilsCartePrecedente` | swipe droite / flèche ‹ / tap zone gauche | `droppable()` | — |
| `ConseilsCarteAtteinte(int index)` | `PageView.onPageChanged` (source de vérité de la position) | `droppable()` | `index` |

### 5.4 Logique
- `ConseilsDemarre` :
  1. `status: chargement`.
  2. Lecture **ponctuelle** : `humeur = await db.observerDerniereHumeurDuJour().first` (ou méthode
     ponctuelle équivalente — Q-CO-5/DEC-CO-06 : on fige à l'ouverture) + `corpus = await db.lireCorpusConseils()`.
  3. `deck = composerDeck(humeurDuJour: humeur, corpus: corpus, jour: DateTime.now(), n: N)` (helper pur).
  4. `emit(status: pret, deck, indexCourant: 0)`.
  5. Exception (corpus vide, etc.) → `status: erreur` (fallback : afficher au moins le `tipDay01` en
     carte unique, jamais de crash).
- `ConseilsCarteSuivante`/`ConseilsCartePrecedente` : bornent l'index dans `[0, deck.length-1]`, mettent
  à jour `indexCourant` (la View anime le `PageView` en conséquence). No-op aux bornes (pas de wrap).
- `ConseilsCarteAtteinte(index)` : `indexCourant = index` (synchronise l'état avec le `PageView` après
  un swipe direct).
- **Helper pur** `composerDeck(...)` (testable isolément, §3.4) — **aucun accès Drift dedans**, reçoit
  les données déjà lues.

---

## 6. Vue(s) — structure visuelle (mockup confirmé)

> **Aucun hex en dur.** Accents cartes rappel/conseil = mapping token (`primary`/lime/`accentGold`) ;
> accent carte émotion = `MoodColors.byKey[code]`. Espacements `AppSpacing`, rayons `AppRadii`.

### 6.1 `ConseilsView` — squelette
```
Scaffold (backgroundColor: AppColors.backgroundDeep)
 └─ Stack
     ├─ HaloRespirant (teinté accent courant ; a11y-aware, statique si reduced-motion)
     ├─ ParticulesFlottantes (OFF si reduced-motion)
     └─ SafeArea > Column
          ├─ _Toolbar (chevron-left → pop · « Conseils » · espaceur 48 ; PAS de burger)
          ├─ _CompteurDots(deck.length, indexCourant, accentCourant)   // pilule active élargie
          ├─ Expanded > _DeckCartes(
          │      PageView(controller, onPageChanged → ConseilsCarteAtteinte)
          │      itemBuilder → switch(carte) { rappel→_CarteRappel, emotion→_CarteEmotion, conseil→_CarteConseilPratique }
          │      // peek carte suivante + bord carte précédente via viewportFraction < 1 + décor
          │  )
          └─ _HintSwipe (‹ précédent | suivant › ; très atténué ; masqué/adapté en reduced-motion)
          // PAS de CTA bas « J'applique » (DEC-CO-09 — supprimé)
```

### 6.2 Cartes (widgets dédiés sous `widgets/`)
- `_CarteRappel` : tag (icône + `…Tag`) · citation 2 lignes (`…Citation1` / `…Citation2` en accent) ·
  sous-texte (`…SousTexte`, `textMuted`). Décor : clouds + streak accent (tokens).
- `_CarteEmotion` : tag « Émotion » (accent = `MoodColors.byKey[code]`) · headline
  `conseilsEmotionHeadline({emotion})` (emoji `emojiPourCode(code)` optionnel) · Do's (✓ rond accent) ·
  Don'ts (✗ rond `textMuted`) · **CTA `conseilsEmotionCta`** (bouton plein accent émotion) →
  `ouvrirPlaceholder(context, l10n.conseilsEmotionRespirationBientot)` (**STUB**, pas de navigation
  réelle ; même esprit que le « Faire l'exercice » du Journal, DEC-J-02).
- `_CarteConseilPratique` : tag « Conseil pratique » · headline · Do's/Don'ts. Pas de CTA.

### 6.3 Accent — résolution (helper, jamais de hex)
```dart
Color accentDeCarte(CarteConseil c) => switch (c) {
  CarteEmotion(:final codeEmotion) => MoodColors.byKey[codeEmotion] ?? AppColors.primary,
  CarteRappel(:final accentChrome) || CarteConseilPratique(:final accentChrome) =>
    switch (accentChrome) {
      'or'   => AppColors.accentGold,
      'lime' => AppColors.signatureGradient[1],   // lime du dégradé signature
      _      => AppColors.primary,
    },
};
```

> **DEC-CO-07** : le mockup utilise un accent **violet** (`#8A3FD1`) pour une carte *conseil*. C'est la
> teinte **émotion** `MoodColors.nervous`, **interdite hors codage émotionnel** (design-system).
> → Pour les cartes **rappel/conseil**, on **restreint** les accents à la palette **chrome**
> (`primary`/lime/`or`). Le violet n'est employé **que** par une carte **émotion** `nervous`.

---

## 7. États de la page (synthèse)

| État | Déclencheur | Rendu |
|---|---|---|
| **initial** | 1ʳᵉ frame avant `ConseilsDemarre` | `SizedBox.shrink` (transitoire) |
| **chargement** | lecture Drift + composition en cours | skeleton/halo discret (public mineur, pas de spinner agressif) |
| **pret** | deck composé (≥ 1 carte) | deck + dots + hint + CTA |
| **erreur** | corpus vide / exception | fallback bienveillant : 1 carte `tipDay01` + CTA, **jamais de crash** |

- Le deck **n'est jamais vide** en nominal (corpus seedé ≥ 7). « Aucune humeur notée » n'est **pas** un
  état d'erreur : c'est le **deck générique** (DEC-CO-06).

---

## 7.2 i18n (clés ARB — 8 langues, repli `en`)

> Ajouter dans **les 8** `lib/l10n/arb/app_<lang>.arb` (template `app_en.arb`), `fr`+`en` réels, repli
> `en` pour `el/it/ro/tr/es/mk`. Puis `flutter gen-l10n`. **Réutiliser** `tipDay01..07`,
> `moodHappy..moodTired`, `homeToolDailyTip` — **ne pas recréer**. **Tout le corpus = PLACEHOLDER à
> valider partenaires.**

**Chrome / navigation :**

| Clé | FR (réf.) | EN |
|---|---|---|
| `conseilsTitre` | « Conseils » | "Tips" |
| `conseilsRetourTooltip` | « Retour » | "Back" |
| `conseilsHintPrecedent` | « précédent » | "previous" |
| `conseilsHintSuivant` | « suivant » | "next" |
| `conseilsTagEquilibre` | « Équilibre » | "Balance" |
| `conseilsTagRappel` | « Rappel » | "Reminder" |
| `conseilsTagConseilPratique` | « Conseil pratique » | "Practical tip" |
| `conseilsTagEmotion` | « Émotion » | "Emotion" |
| `conseilsEmotionHeadline` | « Quand tu te sens {emotion}… » | "When you feel {emotion}…" (placeholder ICU `{emotion}`) |
| `conseilsEmotionCta` | « Essayer la respiration » | "Try breathing" |
| `conseilsEmotionRespirationBientot` | « L'exercice de respiration arrive bientôt. » | "The breathing exercise is coming soon." (SnackBar STUB) |
| `conseilsCompteurSemantique` | « Carte {index} sur {total} » | "Card {index} of {total}" (a11y, ICU) |
| `conseilsCarteSemantique` | « Conseil {index} sur {total} » | "Tip {index} of {total}" (a11y deck) |

**Corpus de cartes (PLACEHOLDER — gabarit fixe 3 Do's / 2 Don'ts, Q-CO-8) :**

- **Rappels** : `<cle>Citation1`, `<cle>Citation2`, `<cle>SousTexte`, `<cle>Tag`.
  Ex. `conseilRappelPresentCitation1`="Scroll later," / `…Citation2`="live now." / `…SousTexte`=« Les
  moments présents ne reviennent pas. Le fil, lui, sera toujours là. » / `…Tag`=`conseilsTagEquilibre`.
- **Conseils pratiques** : `<cle>Headline`, `<cle>Do1..3`, `<cle>Dont1..2`, `<cle>Tag`.
- **Émotions** : `<cle>Do1..3`, `<cle>Dont1..2` (le headline est `conseilsEmotionHeadline({emotion})`,
  le tag `conseilsTagEmotion`). Ex. `conseilEmotionAngryDo1`=« Fais une pause avant de répondre ».

> Le **détail complet** des chaînes placeholder (les ~50 clés de contenu) sera produit à
> l'implémentation avec relecture partenaires (DEC-CO-10). Le plan fixe le **gabarit** (clés
> indexées, 3 Do's / 2 Don'ts) ; le **texte n'est pas figé**.

---

## 8. Navigation & recâblage Accueil

### 8.1 Ajout `AppRouter.versConseils` (`lib/app/routing/app_router.dart`)
Calqué **exactement** sur `versJournal` (transmet `AppDatabase` à travers la frontière de route) :

```dart
/// Ouvre le deck de conseils (empilé, retour possible).
///
/// La [AppDatabase] est transmise explicitement (nouveau sous-arbre de route),
/// comme `versJournal`. `push` (pas `pushReplacement`). Pas de GoRouter (DEC-FND-07).
static Future<void> versConseils(BuildContext context) {
  final database = context.read<AppDatabase>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => RepositoryProvider<AppDatabase>.value(
        value: database,
        child: const ConseilsPage(),
      ),
    ),
  );
}
```

### 8.2 Recâblage de la tuile « Conseil du jour » de l'Accueil
Dans `lib/pages/accueil/views/accueil_view.dart` (~L105-115), la `TuileOutil` `homeToolDailyTip` a
aujourd'hui :
```dart
onTap: () => ouvrirPlaceholder(context, l10n.placeholderConseil),
```
→ remplacer par :
```dart
onTap: () => AppRouter.versConseils(context),
```
- Le libellé `homeToolDailyTip` et la `description: tipTexte` (tip du jour) **sont conservés** : la
  tuile montre toujours le conseil du jour ; le tap **ouvre le deck**, dont **la 1ʳᵉ carte générique =
  ce même conseil** (cohérence garantie DEC-CO-11).
- `placeholderConseil` n'est plus déclenché par la tuile (peut rester défini ailleurs).
- ⚠️ **Dépendance d'intégration (Accueil #2)** : 1 ligne, append-only, à appliquer après merge Accueil
  (même pattern que le recâblage Journal/Temps d'écran). Voir §12.

### 8.3 `ConseilsPage.page()` / `route()`
`page()` crée `BlocProvider<ConseilsBloc>` avec
`ConseilsBloc(context.read<AppDatabase>())..add(const ConseilsDemarre())`, puis rend `ConseilsView`.
`route()` encapsule le `MaterialPageRoute` (mais `AppRouter.versConseils` reste le point d'entrée
canonique qui fournit la DB à la frontière de route).

---

## 9. Fichiers à créer / modifier

> **Fourni par Fondations / existant (NE PAS recréer)** : `theme.dart`, `app_router.dart`,
> `app_database.dart` (étendu), `common/placeholder_screen.dart` (`ouvrirPlaceholder`),
> `common/widgets/halo_respirant.dart`, `particules_flottantes.dart`, `emotion_canonique.dart`, `l10n/`.

**Créer (propre à `conseils`)** :
- `lib/pages/conseils/views/conseils_page.dart` (`ConseilsPage` + `route()` ; fournit `ConseilsBloc`).
- `lib/pages/conseils/views/conseils_view.dart` (`ConseilsView` : toolbar + dots + PageView deck + hint + CTA).
- `lib/pages/conseils/bloc/conseils_bloc.dart` / `conseils_event.dart` / `conseils_state.dart`.
- `lib/pages/conseils/modeles/carte_conseil.dart` (sealed `CarteConseil` + sous-types + `accentDeCarte`).
- `lib/pages/conseils/modeles/composeur_deck.dart` (helper PUR `composerDeck` — DEC-CO-03..06, testable).
- `lib/pages/conseils/widgets/compteur_dots.dart`, `carte_rappel.dart`, `carte_emotion.dart`,
  `carte_conseil_pratique.dart`, `hint_swipe.dart`.

**Modifier** :
- `lib/data/local/app_database.dart` : étendre `Conseils` (4 colonnes, §4.1) ; `schemaVersion 3→4` +
  migration idempotente `if (from < 4)` (§4.2) ; `_seedConseils → _seedCorpus` idempotent par clé ;
  **+** lecture `lireCorpusConseils()` (liste ordonnée par `ordre`/`id`). **NE PAS toucher**
  `conseilDuJour` (réutilisé tel quel ; il continue de pointer la 1ʳᵉ carte de rotation). → **codegen
  Drift requis** (`build_runner`).
- `lib/app/routing/app_router.dart` : **+** `versConseils(context)` (append-only, §8.1).
- `lib/pages/accueil/views/accueil_view.dart` : recâbler la `TuileOutil` `homeToolDailyTip` (1 ligne, §8.2).
- 8 × `lib/l10n/arb/app_<lang>.arb` : clés §7.2 (chrome + corpus placeholder), puis `flutter gen-l10n`.
- `aidd_docs/tasks/_registry.md` : ligne `conseils` (§12).

> **N'ajouter AUCUNE dépendance pub.** `PageView`/gestures = Flutter natif. **Pas de `google_fonts`**
> (DM Sans bundlé). Pas de package de swipe-deck tiers (Flutter `PageView` suffit, reste testable et
> a11y-friendly).

---

## 10. Conformité contraintes projet (garde-fous)

- ✅ Zéro backend/Firebase/SDK réseau/analytics/Crashlytics. Lecture Drift locale seule. Aucune permission.
- ✅ **Lecture Drift seule** (`Conseils`, `EntreesHumeur`) ; **aucune écriture** ; **aucun CTA « J'applique »** (supprimé, DEC-CO-09).
- ✅ **Aucun score/classement/streak/FOMO** : dots = position, pas progression (DEC-003). Déck déterministe (pas de boucle « refresh »).
- ✅ Émotions = `emotionsCanoniques` ; couleur émotion = `MoodColors.byKey` (jamais hex mockup) ; libellé `libelleEmotion`.
- ✅ Accents chrome via tokens `AppColors` (jamais hex) ; violet émotion **non** détourné en chrome (DEC-CO-07).
- ✅ Ton bienveillant, public mineur ; **contenu = placeholders à valider partenaires** (DEC-CO-10), rien figé.
- ✅ i18n 8 langues, repli `en`, aucune chaîne en dur ; corpus dans ARB (clés, pas de texte en Dart).
- ✅ a11y : reduced-motion (particules/halo/anim OFF), tap ≥ 48dp, **swipe accessible** (flèches + Semantics) (DEC-CO-08).
- ✅ Bloc-only, transformers explicites, `State` `Equatable` + enum `status`. Un seul `ConseilsBloc`.
- ✅ Nommage FR (`lib/pages/conseils/`), structure `{bloc,views,widgets,modeles}`.
- ✅ Migration Drift idempotente (modèle v2/v3) ; `build_runner` après modif modèle.
- ✅ Android `minify`/`shrinkResources = false`.
- ✅ Réutilise `conseilDuJour`/`tipDay0X` (cohérence Accueil↔deck, DEC-CO-11), `HaloRespirant`, `ParticulesFlottantes`, `ouvrirPlaceholder`.

---

## 11. Hors périmètre V1 (→ V1.1)

- **Exercice de respiration / Détox réel** (CTA carte émotion = STUB ; partagé avec Journal/Soutien).
- **Tendance multi-jours** pour les cartes émotion (V1 = humeur **du jour** ; tendance = US séparée, Q-CO-4).
- **Recomposition live** du deck si l'humeur change pendant la consultation (V1 = figé à l'ouverture, DEC-CO-06).
- **Favoris / sauvegarde de conseils**, partage, « conseils déjà vus » (impliquerait de la persistance → écarté zéro-collecte/anti-rétention).
- **Corpus piloté à distance** (Remote Config) — interdit (zéro réseau). Corpus = seed local.
- **Traductions réelles `el/it/ro/tr/es/mk`** (repli `en` en V1).
- **Validation finale du contenu** par les partenaires (le corpus V1 reste placeholder).

---

## 12. Registry & coordination

- Ligne à ajouter dans `aidd_docs/tasks/_registry.md` :
  `| [conseils.md](./conseils.md) | Conseils (deck swipable, ConseilsPage empilée — cartes rappel/conseil/emotion, sélection déterministe + carte émotion selon humeur du jour, contenu placeholder à valider partenaires) | US-CO-01/02 (à créer) | Phase 2 🟡 | Fondations (#3), Noter mon humeur (#6) | conseils.tests.md ⏳ | proposition_a_valider |`
- **Composants consommés** : `AppTheme`/`AppColors`/`MoodColors`/`AppRadii`/`AppSpacing`, `AppRouter`,
  `AppDatabase` (étendue), `HaloRespirant`, `ParticulesFlottantes`, `ouvrirPlaceholder`,
  `emotionsCanoniques`/`emojiPourCode`/`libelleEmotion`.
- **Introduit ici (réutilisable)** : `CarteConseil` (modèle), `composerDeck` (helper pur),
  `accentDeCarte`, lecture `lireCorpusConseils`, extension corpus de la table `Conseils`.
- **Coordination Drift** : extension `Conseils` + migration v4 → **coordonner avec tout autre lot
  touchant `app_database.dart`** (schéma partagé). `conseilDuJour` **non modifié** (compat Accueil/Journal).
- **Coordination Accueil (#2)** : recâblage tuile = 1 ligne append-only, après merge Accueil.

---

## 13. Questions à valider (Section ouverte)

> 🟡 **US non créées** (Erwin à solliciter) et **contenu non validé partenaires**. Maquette Banani
> confirmée. La logique de sélection (point dur) est **tranchée** (DEC-CO-03..06) mais ses **paramètres**
> (N, couverture émotions, répartition) restent à confirmer.

- **Q-CO-1 (US)** : créer **US-CO-01** (parcourir le deck) + **US-CO-02** (carte émotion selon humeur)
  via Erwin, milestone Phase 2. OK ?
- **Q-CO-2 (taille N du deck)** : nombre de cartes génériques par jour ? **Reco : 4** (+ 1 émotion
  éventuelle = 3-5 cartes, cohérent mockup « 2/5 »).
- **Q-CO-3 (couverture émotions)** : cartes émotion pour **les 7** canoniques, ou **seulement les 4
  négatives** en V1 ? **Reco : les 7** (placeholder).
- **Q-CO-4 (humeur du jour vs tendance)** : V1 = **humeur du jour** (dernière saisie). Une **tendance
  récente** (ex. émotion négative dominante 7 j) = **V1.1**. Confirmer.
- **Q-CO-5 (figer vs live)** : deck **figé à l'ouverture** (reco) ou **recomposé** si l'humeur change
  en multitâche ? **Reco : figé** (lecture ponctuelle, ne casse pas la position de lecture).
- **Q-CO-6 (re-seed idempotent)** : confirmer le passage `_seedConseils` (`count>0`) →
  `_seedCorpus` **idempotent par clé** (sinon les cartes émotion ne s'ajoutent pas à une base v3 déjà
  peuplée à 7 lignes).
- **Q-CO-7 (répartition tipDay01..07)** : lesquels des 7 tips existants deviennent `rappel` vs
  `conseil` ? (Ils sont des phrases courtes type rappel — **reco : tous `rappel`**, accents cycliques.)
- **Q-CO-8 (gabarit Do's/Don'ts)** : gabarit **fixe 3 Do's / 2 Don'ts** (clés indexées) pour toutes les
  cartes émotion/conseil ? **Reco : oui** (simplifie l'i18n ; conforme mockup).
- **Q-CO-9 (CTA « J'applique ce conseil »)** : ✅ **tranché — SUPPRIMÉ** (DEC-CO-09). Le bouton bas du
  mockup n'est pas repris (inutile, n'écrivait rien). Plus de SnackBar de confirmation associé.
- **Q-CO-10 (icônes de tag)** : le mockup utilise des icônes Lucide (`sun`/`heart`/`zap`/`star`/`shield`/
  `wind`). À mapper sur **Material Icons** (pas de package Lucide → cohérent, pas de dépendance). Mapping
  proposé : `sun→wb_sunny_outlined`, `heart→favorite_border`, `zap→bolt`, `star→star_border`,
  `shield→shield_outlined`, `wind→air`. Confirmer.
- **Q-CO-11 (halo teinté accent)** : le halo de fond se teinte de l'accent de la carte active (mockup).
  Acceptable ou halo neutre fixe ? **Reco : teinte douce suivant l'accent**, OFF en reduced-motion.

---

## 14. Décisions tranchées (DEC-CO)

| ID | Décision |
|---|---|
| DEC-CO-01 | **Corpus = table `Conseils` ÉTENDUE** (4 colonnes : `type_carte`, `code_emotion`, `accent_chrome`, `ordre`) — source unique, réutilise seed/rotation existants. Dataset Dart statique **rejeté** (le corpus est déjà en Drift). Le **texte** reste hors Drift (ARB). |
| DEC-CO-02 | **Migration `schemaVersion 3→4` idempotente** (`PRAGMA table_info` avant `addColumn`, re-seed par clé). Modèle de prudence v2/v3. `build_runner` requis. |
| DEC-CO-03 | **Composition DÉTERMINISTE par jour** (`joursDepuisEpoch % n`, comme `conseilDuJour`). Pas d'aléatoire (ni session, ni seedé) → testable, anti-rétention. |
| DEC-CO-04 | **Carte émotion contextuelle EN TÊTE si humeur notée le jour courant** (`observerDerniereHumeurDuJour`), mappée sur l'émotion canonique exacte, couleur `MoodColors.byKey`. **« Humeur récente » V1 = humeur du jour** (tendance multi-jours = V1.1). |
| DEC-CO-05 | **Rappels/conseils génériques = rotation déterministe quotidienne** (offset `joursDepuisEpoch % nbGeneriques`, N cartes circulaires). |
| DEC-CO-06 | **Deck = [carte émotion?] + [N génériques en rotation]**, dédupliqué, **figé à l'ouverture** (lecture humeur ponctuelle). **Aucune humeur** → deck 100 % générique (jamais vide). |
| DEC-CO-07 | **Accents** : carte émotion = `MoodColors.byKey` ; cartes rappel/conseil = palette **chrome** (`primary`/lime `signatureGradient[1]`/`accentGold`). Le **violet** (`MoodColors.nervous`) **interdit en chrome** → réservé à la carte émotion `nervous`. Jamais de hex mockup. |
| DEC-CO-08 | **Swipe accessible** : navigation aussi par flèches/tap + `Semantics` (carte X/Y, actions précédent/suivant). reduced-motion → particules/halo/anim OFF. |
| DEC-CO-09 | **Pas de CTA « J'applique ce conseil »** : le bouton bas du mockup est **supprimé** (jugé inutile — il n'écrivait rien : pas de score ni d'historique, cohérent anti-rétention DEC-003). L'écran se termine sur le hint swipe ; aucune action « valider », aucune persistance. |
| DEC-CO-10 | **Tout le corpus de cartes = PLACEHOLDER à valider partenaires Erasmus+** — rien figé comme définitif. Le plan fixe le **gabarit** (clés, 3 Do's/2 Don'ts), pas le texte. |
| DEC-CO-11 | **Réconciliation `conseilDuJour`/Accueil** : `tipDay01..07` deviennent des cartes du deck ; la 1ʳᵉ carte générique du jour = `conseilDuJour(today)` (même `% n`) → cohérence tuile Accueil ↔ deck, sans logique dupliquée. `conseilDuJour` **non modifié**. |
| DEC-CO-12 | Navigation `AppRouter.versConseils` en `push` (DEC-FND-07), calquée sur `versJournal` (DB à la frontière de route). Recâblage tuile Accueil = dépendance d'intégration append-only (#2). |
| DEC-CO-13 | Icônes de tag Lucide → **Material Icons** (pas de package tiers). CTA respiration → **STUB** `ouvrirPlaceholder` (partagé esprit Journal DEC-J-02 / Détox non implémenté). |

---

## 15. Plan de tests prévisionnel (pour Kent — Step 5)

**Helper pur `composerDeck` (unitaires — cœur du point dur)**
- Humeur `angry` du jour + corpus avec `conseilEmotionAngry` → **carte 0 = CarteEmotion(angry)**, suivie de N génériques en rotation.
- Humeur `angry` mais **pas** de carte dédiée → repli (carte réconfort si valence<0, ou pas de carte émotion) selon Q-CO-3.
- **Aucune humeur** → deck 100 % générique, **carte 0 = `conseilDuJour(today)`** (cohérence DEC-CO-11).
- **Déterminisme** : même `(jour, humeur, corpus)` → deck identique (rejouable). Jour+1 → rotation décalée d'un cran.
- Pas de doublon entre carte émotion et portion générique.
- Corpus trop court / vide → fallback (≥ 1 carte, pas de crash).

**Bloc (`bloc_test`)**
- `ConseilsDemarre` → `chargement` puis `pret` avec `deck` peuplé, `indexCourant: 0`.
- `ConseilsDemarre` avec humeur du jour → carte 0 = émotion correspondante.
- `ConseilsCarteSuivante`/`Precedente` → index borné `[0, len-1]`, no-op aux bornes.
- `ConseilsCarteAtteinte(i)` → `indexCourant == i`.
- **Aucune écriture Drift** sur tout le cycle de vie de l'écran (vérifier via DB mémoire) ; aucun event « appliquer ».
- Corpus vide → `status: erreur`, fallback carte unique.

**AppDatabase (`AppDatabase.forTesting`, SQLite mémoire)**
- Migration v3→v4 idempotente : colonnes ajoutées une seule fois ; `tipDay01..07` conservés + métadonnées assignées.
- `_seedCorpus` idempotent par clé : ré-ouverture n'ajoute pas de doublon ; cartes émotion présentes.
- `lireCorpusConseils()` : ordre stable (`ordre`/`id`), types/codes corrects.
- `conseilDuJour` **inchangé** (toujours rotation `% n`).

**Widget**
- Carte émotion : accent = `MoodColors.byKey[code]` (pas hex), libellé via `libelleEmotion`, CTA → SnackBar `conseilsEmotionRespirationBientot` (pas de navigation).
- Carte rappel/conseil : accent ∈ {primary, lime, or} (jamais violet ni hex), citation 2 lignes / Do's-Don'ts.
- Compteur dots : pilule active élargie, couleur = accent courant ; `deck.length` dots.
- PageView : swipe → `ConseilsCarteAtteinte` ; flèches/tap zones → suivant/précédent (a11y).
- **Aucun CTA « J'applique » dans l'arbre** (garde-fou : `find.text(...)` du libellé supprimé → `findsNothing`).
- reduced-motion : `MediaQueryData(disableAnimations: true)` → particules OFF, halo statique, rendu lisible (⚠️ **jamais `pumpAndSettle()`** avec halo/particules — piège testing.md ; piloter avec `pump(Duration)` ou `disableAnimations`).

**Navigation / recâblage**
- `AppRouter.versConseils` push `ConseilsPage` avec `AppDatabase` fournie.
- `accueil_view.dart` tuile `homeToolDailyTip` : tap → `versConseils` (et non plus `ouvrirPlaceholder`).

**i18n / a11y**
- Toutes les clés `conseils*` + corpus présentes fr+en ; aucune chaîne en dur ; ICU `{emotion}`/`{index}`/`{total}` valides.
- `Semantics` : carte X/Y annoncée, actions précédent/suivant, CTA labellisé.
