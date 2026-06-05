---
page: Noter mon humeur
slug: noter-humeur
route: SaisieHumeurPage (push via AppRouter.versSaisieHumeur)
feature_dir: apps/digiharmony_app/lib/saisie_humeur/
status: valide
us:
  - "Noter mon humeur (Erwin, milestone Phase 1)"
depends_on:
  - "#3 Fondations (US-FND-01)"
  - "#2 Accueil (US-HOME-01)"
shared_components:
  - AppTheme
  - AppColors
  - MoodColors.byKey
  - AppSpacing
  - AppRadii
  - AppRouter
  - AppDatabase (table EntreesHumeur étendue)
i18n_keys:
  - saisieHumeurTitre
  - saisieHumeurSousTitre
  - saisieHumeurSelectionne
  - saisieHumeurEnregistrementEnCours
  - saisieHumeurEnregistree
  - saisieHumeurAnnuler
  - saisieHumeurDonneesLocales
tests: aidd_docs/tasks/noter-humeur.tests.md (à remplir en Step 5 par Kent)
created: 2026-06-05
updated: 2026-06-05
---

# Page Plan — « Noter mon humeur »

## 0. Garde-fous (DEC-003 + contraintes projet) — FONT LOI

- **Sans backend, sans Firebase, zéro collecte.** Aucun SDK réseau/analytics/tracking. Écriture 100 % locale (Drift).
- **Drift = journal réactif** (`watch()`), **jamais** HydratedBloc pour les entrées d'humeur (DEC-001/002).
- **7 émotions canoniques** (DEC-003) : `happy`, `calm`, `dynamic`, `sad`, `angry`, `nervous`, `tired`. Aucune autre.
- **Couleurs via `MoodColors.byKey` uniquement** (`lib/theme/theme.dart`). **Jamais de hex en dur.**
- **Libellés via i18n** (`moodHappy`/`moodCalm`/`moodDynamic`/`moodSad`/`moodAngry`/`moodNervous`/`moodTired` — déjà existants).
- **Toolbar partout** sauf splash/accueil (DEC-003) → cet écran a une toolbar (retour · logo · menu).
- **`minify`/`shrinkResources = false`** : ne rien faire qui suppose le contraire.
- **Couche de données en FRANÇAIS** (architecture.md) ; suffixes Flutter conservés.
- **HORS PÉRIMÈTRE explicite** : la règle « 7 émotions négatives consécutives » (= 7 jours consécutifs avec ≥1 entrée négative). Le compteur est dérivable de Drift (DEC-001) mais **aucun déclenchement visible** ici — US dédiée ultérieure. Le champ `valence` est écrit pour préparer cette US, sans plus.

---

## 1. Contexte de la page

| Élément | Valeur |
|---|---|
| **But** | Saisir l'humeur du jour en **un seul tap**. Pas de bouton « Valider ». |
| **Accès** | Aucune auth (app sans compte). Ouverte depuis la carte humeur de l'Accueil (état A). |
| **Route** | Pas de GoRouter dans ce projet : navigation impérative via `AppRouter`. Nouvelle méthode `AppRouter.versSaisieHumeur(context)` en **`push`** (pas `pushReplacement` : on veut revenir en arrière via le chevron). |
| **Retour** | Chevron toolbar → `Navigator.pop`. À la fin de la fenêtre d'undo → `Navigator.pop` automatique vers l'Accueil (la carte bascule en état B toute seule via `observerDerniereHumeurDuJour()`/`watch()` — **aucune modif de l'Accueil**). |
| **Une entrée par jour** | UPSERT keyé par jour : re-noter le même jour **écrase** la valeur précédente. |

---

## 2. Arborescence des fichiers à créer / modifier

```
apps/digiharmony_app/lib/saisie_humeur/
├── saisie_humeur_page.dart            # SaisieHumeurPage (fournit le Bloc + Scaffold/toolbar)
├── saisie_humeur_view.dart            # SaisieHumeurView (UI : header, picker, feedback, footer)
├── bloc/
│   ├── saisie_humeur_bloc.dart        # SaisieHumeurBloc
│   ├── saisie_humeur_event.dart       # SaisieHumeurEvent (sealed)
│   └── saisie_humeur_state.dart       # SaisieHumeurState (sealed)
├── modeles/
│   └── emotion_canonique.dart         # liste ordonnée des 7 émotions (clé + emoji + valence)
└── widgets/
    ├── picker_emotions.dart           # grille/wrap des 7 pastilles
    ├── pastille_emotion.dart          # 1 pastille (émoji + libellé, flottement, anneau/halo)
    └── carte_feedback_selection.dart  # carte « Tu as sélectionné : … / Enregistrement en cours… »

# Fichiers MODIFIÉS
apps/digiharmony_app/lib/data/local/app_database.dart   # table EntreesHumeur étendue + migration v2 + méthodes data layer FR
apps/digiharmony_app/lib/app/routing/app_router.dart    # + versSaisieHumeur(context)
apps/digiharmony_app/lib/accueil/widgets/carte_humeur.dart  # recâblage CTA (dépendance d'intégration, voir §9)
apps/digiharmony_app/lib/l10n/arb/app_fr.arb            # 7 clés saisieHumeur* (réelles fr)
apps/digiharmony_app/lib/l10n/arb/app_en.arb            # 7 clés saisieHumeur* (réelles en) + métadonnées @
apps/digiharmony_app/lib/l10n/arb/app_{el,it,ro,tr,es,mk}.arb  # repli en (TODO traduction)
```

> Codegen après modif du schéma Drift : `dart run build_runner build --delete-conflicting-outputs` (depuis `apps/digiharmony_app/`). Puis `flutter gen-l10n`.

---

## 3. Modèle métier — les 7 émotions (mapping déterministe centralisé)

`lib/saisie_humeur/modeles/emotion_canonique.dart`

Liste **ordonnée** unique source de vérité de l'affichage et de la valence.

| Ordre | clé (`codeEmotion`) | emoji | libellé i18n | valence (déterministe) |
|---|---|---|---|---|
| 1 | `happy`   | 😊 | `l10n.moodHappy`   | `+1` (positive) |
| 2 | `calm`    | 😌 | `l10n.moodCalm`    | `+1` (positive) |
| 3 | `dynamic` | ⚡ | `l10n.moodDynamic` | `+1` (positive) |
| 4 | `sad`     | 😢 | `l10n.moodSad`     | `-1` (négative)  |
| 5 | `angry`   | 😠 | `l10n.moodAngry`   | `-1` (négative)  |
| 6 | `nervous` | 😬 | `l10n.moodNervous` | `-1` (négative)  |
| 7 | `tired`   | 😴 | `l10n.moodTired`   | `-1` (négative)  |

- **Règle de valence (centralisée, déterministe)** : négatives (`< 0`) = `sad`/`angry`/`nervous`/`tired` ; positives/neutres (`>= 0`) = `happy`/`calm`/`dynamic`. Exposer un helper pur `int valencePour(String codeEmotion)` testable isolément.
- **Couleur** : jamais stockée ici ; résolue à l'affichage par `MoodColors.byKey[cle]`.
- **Libellé** : jamais stocké ; résolu via `context.l10n` (réutiliser le `switch` déjà présent dans `carte_humeur.dart` — extraire dans un helper partagé `libelleEmotion(BuildContext, String)` pour éviter la duplication, ou dupliquer minimalement si l'extraction touche le Lot Accueil).

> Note émoji : `carte_humeur.dart` (état B) consomme déjà un `emoji` via son view model `HumeurDuJourVue`. La saisie n'écrit **pas** l'émoji en base (la base ne stocke que `codeEmotion`/`valence`/`creeLe`). L'émoji est dérivé du `codeEmotion` côté UI dans les deux features → la table de mapping de ce fichier doit rester cohérente avec celle de l'Accueil.

---

## 4. Schéma Drift étendu + migration

Fichier : `apps/digiharmony_app/lib/data/local/app_database.dart`

### 4.1 Table `EntreesHumeur` étendue

Colonnes existantes conservées : `id` (autoIncrement), `codeEmotion` (`code_emotion`), `valence`, `creeLe` (`cree_le`).

**Ajouts pour l'unicité quotidienne :**

```dart
/// Jour normalisé (minuit local) servant de clé d'unicité quotidienne.
/// Stocké comme DateTime à 00:00:00 local pour permettre un index unique.
DateTimeColumn get jour => dateTime().named('jour')();

@override
List<Set<Column>> get uniqueKeys => [
      {jour},
    ];
```

- **Une entrée par `jour`** → index unique sur `jour` (via `uniqueKeys`). Drift génère la contrainte `UNIQUE`.
- `creeLe` reste l'horodatage précis (utile pour le tri `DESC LIMIT 1` déjà utilisé par `observerDerniereHumeurDuJour()`).
- `jour` = `DateTime(now.year, now.month, now.day)` au moment de l'écriture.

### 4.2 Migration (schemaVersion 1 → 2)

`schemaVersion` passe de `1` à `2`. Ajouter un `onUpgrade` dans `MigrationStrategy` :

```dart
@override
int get schemaVersion => 2;

@override
MigrationStrategy get migration => MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await _seedConseils();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // Ajoute la colonne `jour` (nullable transitoire pour le backfill).
          await m.addColumn(entreesHumeur, entreesHumeur.jour);
          // Backfill : dérive `jour` depuis `cree_le` pour les lignes existantes.
          await customStatement(
            "UPDATE entrees_humeur "
            "SET jour = date(cree_le)", // normalisation au jour
          );
          // Déduplication avant index unique : ne garder que la dernière
          // entrée par jour (max(cree_le)), supprimer les doublons éventuels.
          await customStatement(
            "DELETE FROM entrees_humeur WHERE id NOT IN ("
            "  SELECT id FROM entrees_humeur e1 "
            "  WHERE cree_le = (SELECT MAX(cree_le) FROM entrees_humeur e2 "
            "                   WHERE date(e2.cree_le) = date(e1.cree_le)))",
          );
          // Index unique sur `jour`.
          await customStatement(
            "CREATE UNIQUE INDEX IF NOT EXISTS ux_entrees_humeur_jour "
            "ON entrees_humeur(jour)",
          );
        }
      },
      beforeOpen: (details) async {
        await _seedConseils();
      },
    );
```

> Le format exact du backfill (`date(cree_le)` vs recalcul minuit local) doit produire une valeur **comparable** à celle écrite par `enregistrerHumeurDuJour`. Si Drift sérialise `DateTime` en epoch seconds (config par défaut), le backfill doit produire le même encodage que `DateTime(y,m,d)`. Kaio validera l'encodage réel au codegen et ajustera le `customStatement` (epoch du minuit local) si nécessaire. Test de migration v1→v2 obligatoire (voir §10).

### 4.3 Méthodes data layer (en FRANÇAIS)

Ajouter à `AppDatabase` :

```dart
/// UPSERT de l'humeur du jour courant.
///
/// Écrase l'entrée existante du même `jour` (re-notation autorisée).
/// Retourne l'entrée précédente du jour (ou null) AVANT écrasement,
/// pour permettre l'annulation (restauration).
Future<EntreeHumeur?> enregistrerHumeurDuJour(String codeEmotion);

/// Annule la dernière saisie selon le contexte :
/// - si [ancienneEntree] != null → restaure l'ancienne valeur du jour ;
/// - si [ancienneEntree] == null → supprime l'entrée du jour.
Future<void> annulerDerniereSaisie({EntreeHumeur? ancienneEntree});
```

**Détail `enregistrerHumeurDuJour` :**
1. Calculer `now = DateTime.now()`, `jour = DateTime(now.year, now.month, now.day)`.
2. Lire l'entrée existante du `jour` (`select ... where jour == jour`) → `ancienne` (peut être null).
3. UPSERT : `into(entreesHumeur).insertOnConflictUpdate(EntreesHumeurCompanion.insert(codeEmotion: codeEmotion, valence: Value(valencePour(codeEmotion)), creeLe: now, jour: jour))` — conflit sur l'index unique `jour` → update.
4. Retourner `ancienne`.

**Détail `annulerDerniereSaisie` :**
- Si `ancienneEntree != null` → ré-UPSERT avec les champs de `ancienneEntree` (restaure `codeEmotion`/`valence`/`creeLe` d'origine).
- Sinon → `delete(entreesHumeur)..where((t) => t.jour.equals(jourDuJour))`.

> `observerDerniereHumeurDuJour()` existe déjà et reste inchangée : l'Accueil se met à jour automatiquement via `watch()`.

---

## 5. Bloc / Event / State

### 5.1 Events — `SaisieHumeurEvent` (sealed)

| Event | Déclenché par | Charge |
|---|---|---|
| `EmotionTapee` | tap sur une pastille | `String codeEmotion` |
| `SaisieAnnulee` | action « Annuler » du snackbar | — |
| `FenetreUndoExpiree` | fin du timer ~5s | — |

### 5.2 State — `SaisieHumeurState` (sealed)

Variantes :

| State | Sens | Champs |
|---|---|---|
| `SaisieInitiale` | aucun tap encore | — |
| `EnregistrementEnCours` | tap reçu, UPSERT en vol | `codeEmotion`, `ancienneEntree?` |
| `EnregistrementReussi` | UPSERT OK, fenêtre undo ouverte | `codeEmotion`, `ancienneEntree?` |
| `SaisieAnnuleeEtat` | undo effectué (restore/delete) | `codeEmotion?` (l'ancienne restaurée, sinon null) |
| `EnregistrementEchoue` | exception Drift | `codeEmotion`, message |

> Tap multiple : pendant `EnregistrementEnCours`, ignorer les nouveaux taps (droppable). Si l'utilisateur retape une **autre** émotion après `EnregistrementReussi` mais avant expiration → traiter comme nouvelle saisie (le nouvel UPSERT écrase, et `ancienneEntree` devient la valeur courante). Décision : pour V1 garder simple — désactiver le picker après le premier tap réussi (les pastilles deviennent non interactives, seule l'action « Annuler » reste). Cf. DEC-SH-004.

### 5.3 Logique

- `EmotionTapee` → émettre `EnregistrementEnCours(code, ancienne?)` → `await db.enregistrerHumeurDuJour(code)` (retourne `ancienne`) → émettre `EnregistrementReussi(code, ancienne)`. En cas d'exception → `EnregistrementEchoue`.
- La **fenêtre undo (~5s)** et le pop automatique vers l'Accueil sont pilotés **côté View** (timer + SnackBar Material qui expose nativement durée + action). Le Bloc ne porte pas de `Timer` (testabilité). À l'expiration sans annulation → `Navigator.pop`.
- `SaisieAnnulee` → `await db.annulerDerniereSaisie(ancienneEntree: ...)` → `SaisieAnnuleeEtat`. La View **ne pop pas** après annulation (l'utilisateur reste sur l'écran pour re-choisir). Réactiver le picker.
- HapticFeedback : `HapticFeedback.lightImpact()` (ou `selectionClick`) déclenché **côté View** au tap (pas dans le Bloc).

---

## 6. UI

### 6.1 Structure (`SaisieHumeurView`)

```
Scaffold
 ├─ AppBar (toolbar DEC-003)
 │   ├─ leading : IconButton chevron-left (Icons.chevron_left) → Navigator.pop
 │   ├─ title  : logo (logo_digiharmony_square.png, hauteur réduite) centré
 │   └─ actions: IconButton menu (Icons.menu) → ouvrirPlaceholder (V1, cohérent avec l'app)
 └─ SafeArea > Padding(AppSpacing.lg) > Column
     ├─ Header
     │   ├─ Text(saisieHumeurTitre)  style titleLarge, color AppColors.primary (cyan)
     │   └─ Text(saisieHumeurSousTitre) style bodyLarge, color AppColors.textMuted
     ├─ SizedBox(AppSpacing.xl)
     ├─ PickerEmotions  (Wrap des 7 PastilleEmotion)
     ├─ SizedBox(AppSpacing.lg)
     ├─ CarteFeedbackSelection (visible dès le 1er tap : « Tu as sélectionné : {emotion} » + « Enregistrement en cours… »)
     ├─ Spacer()
     └─ Text(saisieHumeurDonneesLocales) centré, bodySmall, textMuted  (« Tes données restent sur ton appareil »)
```

### 6.2 `PastilleEmotion`

- Pastille circulaire **~62 px** : `Container` rond (`shape: BoxShape.circle`), émoji centré + libellé i18n **sous** la pastille (ou dans la pastille selon densité ; respecter la maquette : émoji + libellé).
- **Au repos** : effet « flottant » (animation verticale légère, boucle douce). Couleur de fond atténuée dérivée de `MoodColors.byKey[cle].withValues(alpha: 0.18)`.
- **Sélectionné** : anneau (`Border` 2 px `MoodColors.byKey[cle]`) + halo (`BoxShadow` couleur émotion, blur). **Aucun hex en dur** — toujours via `MoodColors.byKey`.
- **Tap** : `onTap` → `HapticFeedback` + `context.read<SaisieHumeurBloc>().add(EmotionTapee(cle))`.
- **Zone tactile ≥ 48×48** (a11y) : envelopper dans `InkResponse`/`GestureDetector` avec contrainte min, même si le visuel fait 62 px (déjà ≥ 48).
- **Désactivation** après saisie réussie (DEC-SH-004) : `onTap = null` + opacité réduite sur les pastilles non sélectionnées.

### 6.3 `CarteFeedbackSelection`

- Apparaît au 1er tap. `Card` (rayon `AppRadii.card`).
- Ligne 1 : `saisieHumeurSelectionne` avec placeholder `{emotion}` = libellé i18n de l'émotion choisie, teintée `MoodColors.byKey[cle]`.
- Ligne 2 (pendant `EnregistrementEnCours`) : `saisieHumeurEnregistrementEnCours` + petit `CircularProgressIndicator`.
- En `EnregistrementReussi` : ligne 2 disparaît (le SnackBar prend le relais).

### 6.4 SnackBar de confirmation + undo

- À l'entrée dans `EnregistrementReussi` (via `BlocListener`) :
  - `ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(saisieHumeurEnregistree), duration: const Duration(seconds: 5), action: SnackBarAction(label: saisieHumeurAnnuler, onPressed: () => bloc.add(SaisieAnnulee()))))`.
  - Capturer la `ScaffoldFeatureController` retournée. Sur son `.closed.then(...)` : si **non** fermé par l'action undo → `Navigator.pop` (retour Accueil). S'assurer de `mounted` avant pop.
- En `SaisieAnnuleeEtat` : masquer le SnackBar courant (`hideCurrentSnackBar`), **ne pas** pop, réactiver le picker, repasser visuellement en état de sélection.
- En `EnregistrementEchoue` : SnackBar d'erreur (réutiliser une clé générique d'erreur si elle existe, sinon message inline), réactiver le picker, **ne pas** pop.

### 6.5 Couleurs / espacements / rayons

- Espacements : `AppSpacing` (xs 4 / sm 8 / md 16 / lg 24 / xl 32).
- Rayons : `AppRadii.card` (cartes/bulles), `AppRadii.button`.
- Titre cyan = `AppColors.primary`. Texte atténué = `AppColors.textMuted`.

---

## 7. Navigation

- **Entrée** : `AppRouter.versSaisieHumeur(context)` (nouvelle méthode, `push` — pas `pushReplacement`).
- **Sortie chevron** : `Navigator.pop` (annule la saisie en cours visuellement ; si une entrée a déjà été écrite et la fenêtre undo non expirée, le pop ferme aussi le SnackBar → l'entrée **reste** persistée, comportement attendu : retour notée).
- **Sortie auto fin de fenêtre** : `Navigator.pop` → l'Accueil bascule en état B via `watch()` (aucune modif Accueil).
- Pas de GoRouter (cohérent `AppRouter` existant, DEC-FND-07).

`app_router.dart` à ajouter :

```dart
/// Ouvre l'écran de saisie de l'humeur (empilé, retour possible).
static Future<void> versSaisieHumeur(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const SaisieHumeurPage(),
    ),
  );
}
```

---

## 8. i18n

7 nouvelles clés, ajoutées dans `app_fr.arb` (réel) et `app_en.arb` (réel + métadonnées `@`), puis **repli `en`** dans `el/it/ro/tr/es/mk`.

| Clé | fr | en |
|---|---|---|
| `saisieHumeurTitre` | « Comment tu te sens aujourd'hui ? » | "How are you feeling today?" |
| `saisieHumeurSousTitre` | « Un seul tap — c'est tout ce qu'il faut. » | "A single tap — that's all it takes." |
| `saisieHumeurSelectionne` | « Tu as sélectionné : {emotion} » | "You selected: {emotion}" |
| `saisieHumeurEnregistrementEnCours` | « Enregistrement en cours… » | "Saving…" |
| `saisieHumeurEnregistree` | « Humeur enregistrée » | "Mood saved" |
| `saisieHumeurAnnuler` | « Annuler » | "Undo" |
| `saisieHumeurDonneesLocales` | « Tes données restent sur ton appareil » | "Your data stays on your device" |

- `saisieHumeurSelectionne` est paramétrée : placeholder ICU `{emotion}` (type `String`), métadonnée `@saisieHumeurSelectionne` avec `placeholders.emotion`.
- Les **libellés d'émotion** réutilisent les clés `mood*` existantes (ne pas recréer).
- Après ajout : `flutter gen-l10n`.

---

## 9. Intégration (dépendance d'autre lot)

- **Recâblage CTA** : dans `apps/digiharmony_app/lib/accueil/widgets/carte_humeur.dart`, l'`ElevatedButton.icon` état A appelle aujourd'hui `ouvrirPlaceholder(context, 'Noter mon humeur')` (ligne ~79-80). Le remplacer par `AppRouter.versSaisieHumeur(context)`.
- **⚠️ Dépendance d'intégration** : ce fichier vit sur la branche **Lot 3 (#2 Accueil)**. Le recâblage doit être fait **après** merge du Lot Accueil (ou coordonné avec Kaio). Si la branche de ce lot part avant, prévoir un patch d'intégration dédié (append-only sur la ligne du CTA) pour éviter une collision Git.
- Le `TextButton` « Mon journal » reste sur son placeholder (hors périmètre).

---

## 10. Plan de tests prévisionnel (pour Kent — Step 5)

> Réutiliser les packages de test déjà présents (`flutter_test`, `bloc_test` si dispo, `drift` `NativeDatabase.memory()` via `AppDatabase.forTesting`). Ne pas ajouter de dépendance de test sans accord. Lancer le codegen Drift avant les tests si le schéma a changé.

### Data layer (`AppDatabase`)
- `valencePour` : positives `happy/calm/dynamic` → `>= 0` ; négatives `sad/angry/nervous/tired` → `< 0` (déterministe, 7 cas).
- `enregistrerHumeurDuJour` crée une entrée quand aucune n'existe pour le jour (retourne `null`).
- `enregistrerHumeurDuJour` **écrase** l'entrée existante du jour (UPSERT) et **retourne l'ancienne** (unicité quotidienne respectée : 1 seule ligne pour le jour).
- `enregistrerHumeurDuJour` deux jours différents → 2 lignes.
- `annulerDerniereSaisie` avec `ancienneEntree != null` → **restaure** l'ancienne (`codeEmotion`/`valence`/`creeLe`).
- `annulerDerniereSaisie` avec `ancienneEntree == null` → **supprime** l'entrée du jour (table revient à 0 ligne pour le jour).
- `observerDerniereHumeurDuJour()` émet bien la nouvelle valeur après UPSERT (réactivité `watch()`).
- **Migration v1→v2** : ouvrir une base v1 avec lignes existantes, migrer, vérifier colonne `jour` peuplée + index unique présent + déduplication (1 ligne/jour max).

### Bloc (`SaisieHumeurBloc`)
- `EmotionTapee` → `[EnregistrementEnCours, EnregistrementReussi]` avec `codeEmotion` correct.
- `EmotionTapee` quand l'UPSERT lève → `[EnregistrementEnCours, EnregistrementEchoue]`.
- Tap pendant `EnregistrementEnCours` ignoré (droppable).
- `SaisieAnnulee` après réussite avec ancienne valeur → restore appelé → `SaisieAnnuleeEtat(code ancienne)`.
- `SaisieAnnulee` après réussite sans ancienne valeur → delete appelé → `SaisieAnnuleeEtat(null)`.

### Widget (`SaisieHumeurView`)
- Rend la toolbar (chevron, logo, menu) + header (titre + sous-titre) + 7 pastilles + footer « Tes données restent sur ton appareil ».
- Couleur de pastille sélectionnée vient de `MoodColors.byKey` (pas de hex en dur — vérifier que le widget lit bien la map).
- Tap pastille → `CarteFeedbackSelection` affiche « Tu as sélectionné : {libellé} » + « Enregistrement en cours… ».
- Après réussite → SnackBar « Humeur enregistrée » + action « Annuler » présents (durée 5 s).
- Action « Annuler » du SnackBar → pas de pop, picker réactivé.
- Zone tactile ≥ 48×48 sur chaque pastille (a11y).
- **Reduced motion** : avec `MediaQuery.disableAnimations = true` → flottement OFF (pas d'animation continue).
- HapticFeedback déclenché au tap (vérifiable via mock du channel `SystemChannels.platform` / `HapticFeedback`).

### Hors périmètre (à NE PAS tester ici)
- Déclenchement « 7 émotions négatives consécutives » : aucune assertion visible attendue sur cet écran.

---

## 11. Décisions (DEC-SH)

| ID | Décision |
|---|---|
| DEC-SH-001 | UPSERT keyé par colonne `jour` normalisée (minuit local) + index unique. Re-notation écrase. |
| DEC-SH-002 | `valence` écrite à chaque saisie via helper déterministe centralisé (`valencePour`), pour préparer l'US « 7 négatives consécutives » — sans aucun déclenchement visible ici. |
| DEC-SH-003 | Pas de bouton Valider : un tap = sélection + enregistrement (UPSERT immédiat). |
| DEC-SH-004 | Après une saisie réussie, le picker est désactivé ; seule l'action « Annuler » du SnackBar reste active. Simplifie la gestion des taps multiples en V1. |
| DEC-SH-005 | Fenêtre undo ~5 s portée par le SnackBar Material (durée + action natives) ; le Bloc ne porte pas de `Timer`. Pop auto vers l'Accueil à l'expiration sans annulation. |
| DEC-SH-006 | Navigation via `AppRouter.versSaisieHumeur` en `push` (retour chevron possible). Pas de GoRouter (cohérent DEC-FND-07). |
| DEC-SH-007 | Annulation : restaure l'ancienne valeur du jour si écrasement, sinon supprime l'entrée. |
| DEC-SH-008 | `schemaVersion` 1 → 2 avec `onUpgrade` (addColumn `jour` + backfill depuis `cree_le` + dédup + index unique). |
| DEC-SH-009 | Mapping émoji/clé/valence centralisé dans `emotion_canonique.dart`, cohérent avec le mapping de l'Accueil. La base ne stocke jamais l'émoji. |
| DEC-SH-010 | Recâblage du CTA Accueil = dépendance d'intégration sur le Lot Accueil (#2), append-only, coordonné avec Kaio. |

---

## 12. Risques / coordination

- **Collision Git `carte_humeur.dart`** (Lot Accueil #2) : 1 ligne CTA → append-only, faire après merge Accueil.
- **Encodage `DateTime` Drift dans le backfill** : valider l'encodage réel au codegen ; ajuster le `customStatement` si Drift stocke en epoch (test de migration obligatoire).
- **Cohérence du mapping émoji** entre Accueil et Saisie : single source de vérité recommandée (extraire `libelleEmotion`/`emojiPour` partagés). À surveiller pour éviter la divergence.
- **Aucune modif de l'Accueil** au-delà du recâblage CTA : la bascule état A→B est automatique via `watch()`.
