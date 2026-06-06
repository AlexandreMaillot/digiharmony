---
page: Paramètres
slug: parametres
route: ParametresPage (push via AppRouter.versParametres)
feature_dir: apps/digiharmony_app/lib/pages/parametres/
status: valide
github:
us:
  - "US-PARAM-01 « Changer la langue de l'application » → À CRÉER via Erwin (milestone Phase 2 🟡)"
  - "US-PARAM-02 « Consulter les infos confidentialité / projet (open source, site, Erasmus+) » → À CRÉER via Erwin (dépend de PARAM-01)"
depends_on:
  - "#3 Fondations (US-FND-01) — thème, AppRouter, i18n, HaloRespirant, LocaleBloc (HydratedBloc), LegalUrls"
  - "#2 Accueil (US-HOME-01) — point d'entrée (icône réglages du header)"
related:
  - accueil-home.md
  - temps-ecran.md
  - tuto-notifs.md
shared_components:
  - AppTheme
  - AppColors
  - AppSpacing
  - AppRadii
  - AppRouter (ajout versParametres)
  - HaloRespirant
  - LocaleBloc / LocaleEvent (LocaleChange) / LocaleState  (EXISTANT — réutilisé, NON recréé)
  - LegalUrls (config/legal_urls.dart — github + website EXISTANTS)
  - url_launcher (canLaunchUrl / launchUrl — déjà au pubspec, pattern bloc_ligne_ecoute.dart)
  - HapticFeedback
i18n_keys:
  - parametresTitre
  - parametresSectionLangue
  - parametresSectionConfidentialite
  - parametresConfidentialiteCorps
  - parametresSectionProjet
  - parametresOpenSourceTitre
  - parametresOpenSourceSousTitre
  - parametresSiteTitre
  - parametresSiteSousTitre
  - parametresErasmusCorps
  - parametresVersion
  - parametresLienIndisponible
  - parametresLangueActiveSemantique
i18n_keys_existantes_reutilisees:
  - reglagesTooltip       # tooltip de l'icône réglages (header Accueil) — déjà existant
  - homeBrandName         # wordmark « DigiHarmony » (non traduit)
i18n_NON_traduites:
  - "Libellés natifs des 8 langues (English / Français / Ελληνικά / Italiano / Română / Türkçe / Español / Македонски) = endonymes, JAMAIS traduits (constante Dart, hors ARB)"
tests: aidd_docs/tasks/parametres.tests.md (à remplir en Step 5 par Kent)
created: 2026-06-06
updated: 2026-06-06
---

# Page Plan — « Paramètres »

> **STATUT : `proposition_a_valider`.** Plan auto-suffisant pour l'éditeur IA. Cible :
> `apps/digiharmony_app/`. App Flutter DIGIHARMONY, public mineur, Erasmus+, **SANS backend
> ni Firebase, ZÉRO collecte**. L'écran **ne collecte rien**, **n'ajoute aucune permission** et
> **n'ajoute aucune dépendance pub**. Son cœur fonctionnel = **changer la langue de l'app en direct**
> via le **`LocaleBloc` existant** (déjà au-dessus de `MaterialApp`, persiste via HydratedBloc).
>
> **Maquette Banani « Paramètres » (new_screen14) transmise par l'utilisateur = FAIT LOI** (les agents
> n'atteignent pas Banani en arrière-plan ; la structure ci-dessous reprend la maquette fournie dans la
> consigne). Les points encore flous (URLs exactes, source de la version, harmonisation des clés i18n)
> sont regroupés en **§13 « Questions à valider »**. Tout ce qui est marqué 🟡 = à confirmer.

---

## 0. Garde-fous (FONT LOI — priment sur tout détail divergent ci-dessous)

- **Sans backend, sans Firebase, zéro collecte.** Aucun SDK réseau/analytics/tracking/Crashlytics.
  Changer de langue **n'envoie rien** : c'est un état local persistant (HydratedBloc, `LocaleBloc`).
  L'ouverture du GitHub / du site se fait via le **navigateur système** (`url_launcher`, déjà présent) :
  l'app **ne charge pas** ces pages, **ne journalise rien**.
- **AUCUNE permission ajoutée.** Ouvrir une URL https via `url_launcher` (`LaunchMode.externalApplication`)
  **ne requiert aucune permission**. La SEULE permission du projet reste `PACKAGE_USAGE_STATS` (non
  utilisée ici). **N'ajoute aucune autre permission, aucun SDK.**
- **AUCUNE dépendance pub ajoutée.** `url_launcher` est **déjà au pubspec** (vérifié, `^6.3.2`).
  ⚠️ **`package_info_plus` n'est PAS au pubspec** (vérifié) → **ne PAS l'ajouter** : la version
  s'affiche via une **constante** (DEC-PARAM-06). Pas de nouvelle dépendance, point.
- **Réutiliser `LocaleBloc`, NE PAS recréer.** Le `LocaleBloc` existe déjà (`lib/locale/locale_bloc.dart`),
  c'est un **`HydratedBloc`** (et non un Cubit — la consigne dit « LocaleCubit » mais le code réel est
  `LocaleBloc` ; **le code fait foi**). Il est fourni **au-dessus de `MaterialApp`** (bootstrap). Le tap
  sur une langue **dispatch `LocaleChange(Locale(code))`**. **Aucun nouveau Bloc** : l'écran est un
  `StatelessWidget` qui lit l'état via `BlocBuilder<LocaleBloc, LocaleState>` et dispatch via
  `context.read<LocaleBloc>().add(...)` (DEC-PARAM-02).
- **Pas de Drift, pas de HydratedBloc dédié.** Aucune lecture/écriture Drift. La seule persistance est
  celle **déjà** portée par `LocaleBloc` (langue). **Pas de codegen Drift** (aucune modif de schéma).
- **i18n obligatoire** : aucune chaîne FR/EN en dur. Clés `parametres*` (§8) ajoutées dans **les 8**
  ARB, `fr`+`en` réels, repli `en` (TODO) pour `el/it/ro/tr/es/mk`, puis `flutter gen-l10n`.
  **EXCEPTION (DEC-PARAM-03)** : les **libellés des 8 langues = endonymes** (« Français », « Ελληνικά »,
  « Македонски »…) ne sont **PAS traduits** ni mis en ARB — ce sont des **constantes Dart** (un nom de
  langue s'écrit pareil quelle que soit la langue d'affichage). Le wordmark « DigiHarmony » reste non traduit.
- **a11y reduced-motion** : `HaloRespirant` (et toute animation) désactivable via
  `MediaQuery.disableAnimations`. Tap ≥ 48×48 dp (lignes de langue, liens projet, chevron).
  Contraste AA. `HapticFeedback.selectionClick()` au choix d'une langue (pas de permission `VIBRATE`).
- **Couleurs via le design system** (`AppColors`/thème) — **aucun hex en dur**. La langue **active** est
  surlignée avec `AppColors.primary.withValues(alpha: 0.12)` (fond), texte `AppColors.text`, pastille
  check `AppColors.primary`. `MoodColors` **interdit** ici (cet écran n'est pas un écran d'humeur).
  Espacements `AppSpacing` (4/8/16/24/32), rayons `AppRadii` (card 24, button 12).
- **Public mineur, ton bienveillant** (DEC-003 + design-system §garde-fous éthiques) : **pas de FOMO,
  pas de score, pas de compte, pas d'identification.** La carte confidentialité **rassure** (« Aucune
  donnée personnelle n'est enregistrée ni diffusée. Pas de compte, pas d'identification. »).
- **Nommage FRANÇAIS** : dossier `lib/pages/parametres/`, classe `ParametresPage`/`ParametresView`.
  Structure imposée (règle `0-flutter-pages-structure`) : `lib/pages/parametres/{views,widgets}`
  (**pas** de dossier `bloc` — on réutilise `LocaleBloc`, DEC-PARAM-02). Méthode de route
  `AppRouter.versParametres(context)`. Scaffolding technique reste anglais.
- **Toolbar haute** présente (DEC-003 : toolbar partout **sauf** splash/accueil). Maquette : chevron
  retour · titre « Paramètres » · **PAS de burger** (espaceur d'équilibre — confirmé maquette).
- **Android : `minify`/`shrinkResources = false`** (déjà acté Fondations) — ne rien faire qui suppose
  le contraire.

---

## 1. Contexte & objectif de la page

| Élément | Valeur |
|---|---|
| **But** | Donner à l'ado un **écran Paramètres** centré sur le **choix de la langue** (8 langues, bascule **en direct**), et l'**informer** sur la confidentialité (zéro collecte) et le projet (open source, site officiel, financement Erasmus+). |
| **Cœur fonctionnel** | **Changer la langue de l'app EN DIRECT** via le **`LocaleBloc` existant** → la bascule est immédiate (le `MaterialApp` se reconstruit) et **persiste** (HydratedBloc). |
| **Accès** | Aucune auth (app sans compte). Aucune permission. Écran **empilé** (`push`, retour possible). |
| **Point d'entrée** | **Icône réglages `Icons.settings`** du **header de l'Accueil** (`accueil_view.dart`, `_Header`, **L224-228**). Elle ouvre aujourd'hui `ouvrirPlaceholder(context, l10n.placeholderReglages)` → **à recâbler** vers `AppRouter.versParametres(context)` (§6 + DEC-PARAM-08). Le `tooltip` `l10n.reglagesTooltip` est **conservé**. |
| **Route** | Pas de GoRouter (cohérent `AppRouter`, DEC-FND-07). Nouvelle méthode `AppRouter.versParametres(context)` en **`push`**, calquée sur `versTutoNotifs`/`versSoutien` (écran sans DB à transmettre → `ParametresPage.route()`). |
| **Retour** | Toolbar : chevron `Icons.chevron_left` → `Navigator.pop`. **Pas de burger** (maquette) → `actions` = `SizedBox` d'équilibre (titre reste centré). |
| **Périmètre plateforme** | Android + iOS identiques (aucun natif, aucune permission). L'ouverture d'URL via `url_launcher` est multiplateforme ; échec → SnackBar neutre (DEC-PARAM-05). |

---

## 2. Contrainte structurante n°1 — changement de langue via `LocaleBloc` (DEC-PARAM-01/02)

### 2.1 Le mécanisme existant (à réutiliser, NE PAS recréer)

`LocaleBloc` (`lib/locale/locale_bloc.dart`) — **vérifié dans le code** :

```dart
class LocaleBloc extends HydratedBloc<LocaleEvent, LocaleState> { ... }

sealed class LocaleEvent { ... }
final class LocaleChange extends LocaleEvent { const LocaleChange(this.locale); final Locale locale; }
final class LocaleSysteme extends LocaleEvent { const LocaleSysteme(); }

final class LocaleState extends Equatable { const LocaleState({this.locale}); final Locale? locale; }
```

- `LocaleState.locale == null` → **suivi de la langue système**. Une langue explicite → forcée.
- Persistance **automatique** via HydratedBloc (`toJson`/`fromJson` déjà implémentés, repli sûr si code
  non supporté). **Rien à persister de plus** côté Paramètres.
- Le `LocaleBloc` est fourni **au-dessus de `MaterialApp`** (bootstrap) → il est accessible par
  `context.read<LocaleBloc>()` / `context.watch` depuis n'importe quel écran empilé. **Aucun
  `BlocProvider` à recréer** dans `ParametresPage` (DEC-PARAM-02).

### 2.2 Conséquences pour l'écran Paramètres

- L'écran **lit** la langue active via `BlocBuilder<LocaleBloc, LocaleState>` :
  `final actif = state.locale?.languageCode ?? <code système courant>;` (voir §2.3 pour le « système »).
- Le tap sur une langue **dispatch** `context.read<LocaleBloc>().add(LocaleChange(Locale(code)))`
  + `HapticFeedback.selectionClick()`. La bascule est **immédiate** (le `MaterialApp` se reconstruit,
  les libellés `parametres*` se retraduisent) et **persistée** (HydratedBloc). **Pas de bouton « valider »**,
  **pas de SnackBar** (la bascule visible des textes = feedback suffisant — DEC-PARAM-04).
- **Aucun nouveau Bloc, aucun nouvel event, aucune modif de `LocaleBloc`.** L'écran est `StatelessWidget`.

### 2.3 Surlignage de la langue active & cas « suivi système » (DEC-PARAM-07)

- La maquette surligne **la langue active**. Quand `state.locale != null`, c'est trivial : surligner le
  code correspondant.
- Quand `state.locale == null` (**suivi système**, état initial avant tout choix), la langue « active »
  affichée = la langue **réellement résolue** par `MaterialApp` =
  `Localizations.localeOf(context).languageCode` (la locale effective après résolution `supportedLocales`
  + repli). C'est cette valeur qu'on surligne, pour que le check reflète **ce que l'utilisateur voit**.
- **V1 : pas de ligne « Langue du système »** distincte dans la liste (la maquette ne la montre pas).
  Choisir une langue **force** ce code (sort du suivi système). 🟡 Revenir au suivi système n'est **pas**
  exposé en V1 (Q-PARAM-4) — l'event `LocaleSysteme` existe mais n'est pas câblé à un contrôle UI ici.

---

## 3. Données affichées & sources

| Donnée | Source | Persistance |
|---|---|---|
| Langue active | `LocaleBloc` → `LocaleState.locale` (ou `Localizations.localeOf` si null, §2.3) | Persistée par HydratedBloc (existant) |
| Liste des 8 langues (code + endonyme + drapeau) | **Constante Dart** `languesSupportees` (DEC-PARAM-03), alignée sur `AppLocalizations.supportedLocales` | — (statique) |
| Texte confidentialité | i18n statique (`parametresConfidentialiteCorps`) | — |
| Liens projet (libellés) | i18n statique (`parametresOpenSourceTitre`…) | — |
| URLs GitHub / site | **`LegalUrls.github` / `LegalUrls.website`** (EXISTANTES, vérifiées) | — |
| Version de l'app | **Constante** `kVersionApp` (DEC-PARAM-06) — `package_info_plus` ABSENT du pubspec | — |

- **DEC-PARAM-03 (liste des langues = constante, endonymes non traduits)** : une constante Dart liste les
  8 langues supportées avec, pour chacune : `code` (en/fr/el/it/ro/tr/es/mk), `endonyme` (nom natif),
  `drapeau` (emoji 🇬🇧🇫🇷🇬🇷🇮🇹🇷🇴🇹🇷🇪🇸🇲🇰). **L'ordre suit la maquette** (en, fr, el, it, ro, tr, es, mk).
  Les endonymes ne sont **PAS** en ARB (ne se traduisent pas). La liste **doit rester alignée** sur
  `AppLocalizations.supportedLocales` (les 8 langues du projet) — garde-fou test (AC8).
- **DEC-PARAM-06 (version via constante, pas de `package_info_plus`)** : afficher « DIGIHARMONY v1.0 » via
  une **constante** (ex. `const kVersionApp = '1.0'` dans un fichier de config, ou réutiliser une constante
  existante si présente). **Ne PAS ajouter `package_info_plus`** (viole « zéro nouvelle dépendance »). Le
  libellé exact (avec/sans wordmark, format `v1.0` vs `1.0.0+1`) est à confirmer (Q-PARAM-3). 🟡

> **Pourquoi PAS Drift / pas de nouveau HydratedBloc ?** La seule donnée persistante (langue) est **déjà**
> gérée par `LocaleBloc`. Tout le reste est **statique** (i18n + constantes). Aucun modèle relationnel,
> aucune historisation → Drift **interdit ici**. Aucun flag → pas de nouveau HydratedBloc.

### 3.1 Modèle léger de langue (constante)

```
LangueSupportee {
  final String code;       // 'fr', 'en', ...   (== languageCode de supportedLocales)
  final String endonyme;   // 'Français', 'English', 'Ελληνικά', ...  (NON traduit, DEC-PARAM-03)
  final String drapeau;    // emoji '🇫🇷', '🇬🇧', ...
}

const List<LangueSupportee> languesSupportees = [ en, fr, el, it, ro, tr, es, mk ];  // ordre maquette
```

---

## 4. Architecture & état (V1 sans nouveau Bloc — DEC-PARAM-02)

- **Pas de `ParametresBloc`.** L'unique état dynamique (langue active) est porté par le **`LocaleBloc`
  existant**, lu via `BlocBuilder<LocaleBloc, LocaleState>`. Introduire un Bloc local serait du
  sur-engineering et dupliquerait l'état de langue (anti-pattern). **DEC-PARAM-02.**
- L'ouverture d'URL (GitHub/site) = simple action dans la View (méthode privée `_ouvrirUrl(context, url)`),
  calquée **à l'identique** sur `bloc_ligne_ecoute.dart` (pattern projet vérifié) :

```dart
Future<void> _ouvrirUrl(BuildContext context, String url) async {
  await HapticFeedback.selectionClick();
  final uri = Uri.parse(url);
  var succes = true;
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      succes = false;
    }
  } on Exception {
    succes = false;
  }
  if (!succes && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.parametresLienIndisponible),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```

> **Conformité `1-bloc-only-no-cubit`** : la règle interdit les **Cubits**, pas les `StatelessWidget`. On
> consomme un **Bloc** (`LocaleBloc`). Aucun Cubit introduit. (Précédent acté : `tuto-notifs` DEC-TN-05 —
> écran statique sans Bloc dédié.) Si une revue impose malgré tout un `ParametresBloc`, il serait un
> simple relais vers `LocaleBloc` (déconseillé, Q-PARAM-5).

---

## 5. Vue(s) — structure visuelle (maquette Banani new_screen14 = FAIT LOI)

> **Aucun hex en dur** : toutes les teintes = `AppColors`/`Theme.of(context)`. `MoodColors` **interdit**.
> Espacements `AppSpacing`, rayons `AppRadii`. Ton bienveillant.

### 5.1 `ParametresView` — squelette

```
Scaffold (backgroundColor: AppColors.background)
 ├─ AppBar (toolbar DEC-003)
 │   ├─ leading : IconButton chevron-left (Icons.chevron_left) → Navigator.pop  (≥ 48×48)
 │   ├─ title  : Text(parametresTitre) « Paramètres » centré
 │   └─ actions: [SizedBox(width: 48)]   // PAS de burger (maquette) — équilibre le leading
 └─ Stack
     ├─ HaloRespirant (décor de fond, common/widgets/halo_respirant.dart ; OFF si reduced motion)
     └─ SafeArea > SingleChildScrollView > Padding(AppSpacing.lg) > Column (crossAxis stretch)
          ├─ _SectionLangue()              // « Langue » + 8 lignes (cœur fonctionnel)
          ├─ SizedBox(AppSpacing.xl)
          ├─ _SectionConfidentialite()     // carte bouclier + texte rassurant
          ├─ SizedBox(AppSpacing.xl)
          ├─ _SectionProjet()              // open source · site · carte Erasmus+
          ├─ SizedBox(AppSpacing.xl)
          └─ _LigneVersion()               // « DIGIHARMONY v1.0 » centré, bodySmall textMuted
```

### 5.2 `_SectionLangue` (cœur fonctionnel)

- En-tête de section `Text(parametresSectionLangue)` (« Langue »), `titleMedium`, `AppColors.text`.
- `BlocBuilder<LocaleBloc, LocaleState>` → calcule `codeActif` (§2.3).
- Liste des **8** `languesSupportees` (ordre maquette) — chaque ligne = widget `_LigneLangue` :
  - **Drapeau** (emoji, `Text`) + **endonyme** (`bodyLarge`, `AppColors.text`).
  - Si `langue.code == codeActif` → **surligné** : fond `AppColors.primary.withValues(alpha: 0.12)`,
    rayon `AppRadii.buttonRadius`, **pastille check** (`Icons.check_circle`/`Icons.check`,
    `AppColors.primary`) à droite. Sinon : fond transparent, pas de check.
  - Tap (`InkWell`/`ListTile`, zone ≥ 48×48) →
    `context.read<LocaleBloc>().add(LocaleChange(Locale(langue.code)))` + `HapticFeedback.selectionClick()`.
    **Pas de SnackBar, pas de bouton valider** (DEC-PARAM-04) : les textes basculent immédiatement.
  - a11y : `Semantics(selected: estActif, label: "<endonyme>" (+ parametresLangueActiveSemantique si actif))`.
- **Aucune des 8 langues n'est désactivée** : toutes sont supportées par `supportedLocales` (repli `en`
  pour les traductions manquantes, mais la **bascule** fonctionne pour les 8 — DEC-PARAM-09).

### 5.3 `_SectionConfidentialite` (carte rassurante)

- En-tête `Text(parametresSectionConfidentialite)` (« Confidentialité »), `titleMedium`.
- Carte (`Container`/`Card`, fond `AppColors.surface`, rayon `AppRadii.cardRadius`, padding `AppSpacing.md`) :
  - Icône bouclier `Icons.verified_user` (ou `Icons.shield`/`Icons.privacy_tip`), `AppColors.primary`.
  - Texte `parametresConfidentialiteCorps` : « Aucune donnée personnelle n'est enregistrée ni diffusée.
    Pas de compte, pas d'identification. » (`bodyMedium`, `AppColors.text`/`textMuted`).
- Ton **rassurant**, cohérent zéro-collecte (renforce la promesse RGPD-par-absence).

### 5.4 `_SectionProjet` (open source · site · Erasmus+)

- En-tête `Text(parametresSectionProjet)` (« Le projet »), `titleMedium`.
- **Lien « Code open source »** — widget `_LienProjet` (ListTile-like, ≥ 48×48) :
  - icône `Icons.code` (ou logo GitHub Material `Icons.code`) à gauche.
  - titre `parametresOpenSourceTitre` (« Code open source ») + sous-titre `parametresOpenSourceSousTitre`
    (« GitHub · Licence GNU GPL ») `bodySmall textMuted`.
  - icône `Icons.open_in_new` (external-link) à droite.
  - tap → `_ouvrirUrl(context, LegalUrls.github)` (§4).
- **Lien « digiharmony.org »** — `_LienProjet` :
  - icône `Icons.public` (globe).
  - titre `parametresSiteTitre` (« digiharmony.org ») + sous-titre `parametresSiteSousTitre`
    (« Site officiel du projet »).
  - icône `Icons.open_in_new` à droite.
  - tap → `_ouvrirUrl(context, LegalUrls.website)` (§4).
- **Carte Erasmus+** — `_CarteErasmus` (carte `AppColors.surface`, rayon card) :
  - drapeau 🇪🇺 (emoji) + texte `parametresErasmusCorps` (« Projet Erasmus+ — application gratuite,
    sans publicité. »). **Pas un lien** (mention informative). Optionnel : asset `logo_eu_funding.png`
    (déjà au projet, footer) au lieu de l'emoji 🇪🇺 — 🟡 Q-PARAM-6.

### 5.5 `_LigneVersion` (bas de page)

- `Text(parametresVersion)` centré, `bodySmall`, `AppColors.textMuted`. Valeur ICU/placeholder
  `{version}` → constante `kVersionApp` (DEC-PARAM-06). Ex. FR « DIGIHARMONY v{version} ».
  Le segment « DIGIHARMONY » peut réutiliser `homeBrandName.toUpperCase()` (cohérence wordmark, §8). 🟡

### 5.6 `HaloRespirant` & reduced motion

- Réutiliser `common/widgets/halo_respirant.dart` (a11y-aware). Si `MediaQuery.disableAnimations == true`
  → halo **statique**. Ne **jamais** `pumpAndSettle()` en test (piège testing.md) → wrapper
  `MediaQuery(disableAnimations: true)`.

---

## 6. Navigation & recâblage Accueil

### 6.1 Ajout `AppRouter.versParametres` (`lib/app/routing/app_router.dart`)

Calqué sur `versTutoNotifs`/`versSoutien` (push, **pas** de DB à transmettre ; le `LocaleBloc` est déjà
au-dessus de `MaterialApp` donc disponible dans le sous-arbre de route) :

```dart
/// Ouvre l'écran « Paramètres » (empilé, retour possible).
///
/// Le [LocaleBloc] est déjà fourni au-dessus de `MaterialApp` (bootstrap) :
/// rien à transmettre à travers la frontière de route. `push`. Pas de GoRouter (DEC-FND-07).
static Future<void> versParametres(BuildContext context) {
  return Navigator.of(context).push(ParametresPage.route());
}
```

> `ParametresPage.route()` encapsule le `MaterialPageRoute<void>(builder: (_) => const ParametresPage())`.
> `AppRouter.versParametres` reste le point d'entrée canonique. **Vérifier** que `LocaleBloc` traverse
> bien la frontière `MaterialPageRoute` (il le fait : il est au-dessus de `MaterialApp`, donc de tous les
> `Navigator`). Si un doute apparaît à l'implémentation, fournir `BlocProvider.value(value: context.read<LocaleBloc>())`
> autour de `ParametresPage` — **mais ce ne devrait pas être nécessaire** (Q-PARAM-2).

### 6.2 Recâblage du point d'entrée (`accueil_view.dart`, `_Header`, L224-228)

Remplacer l'`onPressed` de l'`IconButton` réglages :

```dart
// AVANT (L227) :
onPressed: () => ouvrirPlaceholder(context, l10n.placeholderReglages),
// APRÈS :
onPressed: () => AppRouter.versParametres(context),
```

- `tooltip: l10n.reglagesTooltip` **conservé**. L'icône `Icons.settings` et le reste du `_Header` **ne
  changent pas**. `l10n.placeholderReglages` n'est plus déclenché par le header (peut rester défini
  ailleurs, hors périmètre).
- ⚠️ **Dépendance d'intégration (Accueil #2)** : `accueil_view.dart` appartient au lot Accueil (mergé).
  Modif **append-only de comportement, 1 ligne** (cf. DEC-J-... / DEC-TE-10 / DEC-SH-010 pour le
  précédent — même pattern de recâblage placeholder → route). **DEC-PARAM-08.**

---

## 7. États de la page (synthèse)

| État | Déclencheur | Rendu |
|---|---|---|
| **nominal** | ouverture de la page | toolbar + halo + 3 sections + version ; langue active surlignée |
| **langue changée** | tap sur une langue | `LocaleChange` dispatché → `MaterialApp` reconstruit → tous les libellés basculent + check déplacé (réactif, **sans** SnackBar) |
| **lien indisponible** | échec `canLaunchUrl`/`launchUrl` (GitHub/site) | SnackBar `parametresLienIndisponible` (pas de crash) |
| **reduced motion** | `MediaQuery.disableAnimations == true` | halo statique, reste inchangé |

- **Pas d'état « chargement »** (langue lue de façon synchrone via `LocaleBloc`, contenu statique).
  **Pas d'état « vide »** ni « erreur » bloquant. Aucune dépendance distante chargée par l'app.

---

## 8. i18n (clés ARB — 8 langues, repli `en`)

> Ajouter dans **les 8** `lib/l10n/arb/app_<lang>.arb` (template `app_en.arb`), `fr`+`en` réels, repli
> `en` (TODO traduction) pour `el/it/ro/tr/es/mk`. Puis `flutter gen-l10n`.
> **Réutiliser** `reglagesTooltip` (tooltip header, déjà existant) et `homeBrandName` (wordmark, non
> traduit). **Les endonymes des 8 langues NE sont PAS en ARB** (constantes Dart, DEC-PARAM-03).

| Clé | FR (référence) | EN |
|---|---|---|
| `parametresTitre` | « Paramètres » | "Settings" |
| `parametresSectionLangue` | « Langue » | "Language" |
| `parametresSectionConfidentialite` | « Confidentialité » | "Privacy" |
| `parametresConfidentialiteCorps` | « Aucune donnée personnelle n'est enregistrée ni diffusée. Pas de compte, pas d'identification. » | "No personal data is stored or shared. No account, no identification." |
| `parametresSectionProjet` | « Le projet » | "The project" |
| `parametresOpenSourceTitre` | « Code open source » | "Open source code" |
| `parametresOpenSourceSousTitre` | « GitHub · Licence GNU GPL » | "GitHub · GNU GPL license" |
| `parametresSiteTitre` | « digiharmony.org » | "digiharmony.org" |
| `parametresSiteSousTitre` | « Site officiel du projet » | "Official project website" |
| `parametresErasmusCorps` | « Projet Erasmus+ — application gratuite, sans publicité. » | "Erasmus+ project — free app, no ads." |
| `parametresVersion` | « DIGIHARMONY v{version} » | "DIGIHARMONY v{version}" |
| `parametresLienIndisponible` | « Impossible d'ouvrir le lien. Tu peux le retrouver dans ton navigateur. » | "Couldn't open the link. You can find it in your browser." |
| `parametresLangueActiveSemantique` | « Langue active » | "Active language" |

- `parametresVersion` : **ICU** avec placeholder `{version}` (type `String`), valeur = `kVersionApp`
  (DEC-PARAM-06). « digiharmony.org » est un nom de domaine → **identique** FR/EN (pas vraiment traduit).
- Ton de **tous** les libellés : neutre/rassurant, **jamais** culpabilisant.

---

## 9. Fichiers à créer / modifier

> **Fourni par Fondations / existant (NE PAS recréer)** : `theme.dart` (`AppColors`/`AppSpacing`/
> `AppRadii`), `app_router.dart`, `common/widgets/halo_respirant.dart`, `l10n/`,
> `lib/locale/locale_bloc.dart` (`LocaleBloc`/`LocaleChange`/`LocaleState`), `config/legal_urls.dart`
> (`LegalUrls.github`/`website`). **Aucune dépendance pub** (`url_launcher` déjà présent ;
> `package_info_plus` **PAS** à ajouter).

**Créer (propre à `parametres`)** :
- `lib/pages/parametres/views/parametres_page.dart` (`ParametresPage` + `static route()` ; rend
  `ParametresView` ; **pas** de `BlocProvider` — `LocaleBloc` déjà au-dessus de `MaterialApp`).
- `lib/pages/parametres/views/parametres_view.dart` (`ParametresView` : toolbar + halo + 3 sections +
  version ; `_ouvrirUrl` ; lit/dispatch `LocaleBloc`).
- `lib/pages/parametres/widgets/section_langue.dart` (`_SectionLangue` + `_LigneLangue`).
- `lib/pages/parametres/widgets/section_confidentialite.dart`.
- `lib/pages/parametres/widgets/section_projet.dart` (`_LienProjet` + `_CarteErasmus`).
- `lib/pages/parametres/modeles/langue_supportee.dart` (`LangueSupportee` + `const languesSupportees`,
  DEC-PARAM-03). 🟡 emplacement de `kVersionApp` à trancher (ici ou `lib/config/`, Q-PARAM-3).

**Modifier** :
- `lib/app/routing/app_router.dart` : **+** `versParametres(context)` (append-only, §6.1) + import
  `ParametresPage`.
- `lib/pages/accueil/views/accueil_view.dart` : **L227** `ouvrirPlaceholder(...)` →
  `AppRouter.versParametres(context)` (1 ligne, §6.2, DEC-PARAM-08). `tooltip` conservé.
- 8 × `lib/l10n/arb/app_<lang>.arb` : clés §8, puis `flutter gen-l10n`.
- `lib/config/legal_urls.dart` : **AUCUNE modif** (github + website existent). 🟡 confirmer URLs (Q-PARAM-1).
- `pubspec.yaml` : **AUCUNE modif** (aucune dépendance ajoutée).
- `android/app/src/main/AndroidManifest.xml` : **AUCUNE modif** (aucune permission ; `url_launcher` https
  ne requiert pas de `<queries>` pour `LaunchMode.externalApplication` https). 🟡 vérifier qu'aucune
  `<queries>`/`<intent>` n'est requise selon la version d'`url_launcher` (Q-PARAM-7).
- `aidd_docs/tasks/_registry.md` : ligne `parametres` (§12).

> **N'ajouter AUCUNE dépendance pub.** **Pas de codegen Drift** (aucune modif de schéma).

---

## 10. Conformité contraintes projet (garde-fous)

- ✅ Zéro backend / Firebase / SDK réseau / analytics / Crashlytics. Langue = état local persistant
  (`LocaleBloc`/HydratedBloc). Liens ouverts via navigateur système (`url_launcher`), rien chargé/journalisé.
- ✅ **Aucune permission ajoutée** (ouverture https `url_launcher` sans permission). `PACKAGE_USAGE_STATS` non utilisée ici.
- ✅ **Aucune dépendance pub ajoutée** (`url_launcher` déjà présent ; `package_info_plus` écarté → constante, DEC-PARAM-06).
- ✅ **`LocaleBloc` réutilisé**, pas recréé ; **aucun nouveau Bloc**, aucun Cubit (DEC-PARAM-02).
- ✅ **Pas de Drift, pas de nouveau HydratedBloc** (seule persistance = langue, déjà gérée).
- ✅ i18n 8 langues, repli `en`, aucune chaîne en dur ; endonymes des langues = constantes non traduites (DEC-PARAM-03) ; wordmark « DigiHarmony » non traduit.
- ✅ a11y : `MediaQuery.disableAnimations` (halo), tap ≥ 48×48, `Semantics(selected)` sur les langues, `HapticFeedback.selectionClick`.
- ✅ Couleurs via `AppColors`/thème (jamais hex en dur) ; surlignage actif `primary.withValues(alpha: 0.12)` ; `MoodColors` **interdit**.
- ✅ Ton bienveillant / rassurant : carte confidentialité « zéro donnée, pas de compte » ; pas de FOMO/score.
- ✅ Toolbar haute (chevron · titre · **pas de burger** = espaceur), DEC-003.
- ✅ Vibration via `HapticFeedback` (pas de permission `VIBRATE`).
- ✅ Android `minify`/`shrinkResources = false` (inchangé).

---

## 11. User Stories (dépendance — À CRÉER via Erwin)

> **Aucune US n'existe** pour cette page (Erwin non joignable en arrière-plan ; à créer et valider).

- **US-PARAM-01 « Changer la langue de l'application »** (milestone **Phase 2** 🟡), couvrant : icône
  réglages Accueil → page, liste des 8 langues (drapeau + endonyme), surlignage de l'active, bascule
  **en direct** via `LocaleBloc`, persistance, a11y, i18n.
- **US-PARAM-02 « Consulter confidentialité / projet »**, couvrant : carte confidentialité rassurante,
  lien open source (GitHub/GPL), lien site officiel, mention Erasmus+, ouverture via navigateur système,
  gestion d'échec bienveillante, version de l'app.

**Critères d'acceptation à inscrire (source des tests Kent — Step 5)** :
- AC1 : ouverture de la page → toolbar (chevron · « Paramètres » · **pas de burger**) + 3 sections + version.
- AC2 : les **8** langues affichées (drapeau + endonyme), dans l'ordre maquette (en, fr, el, it, ro, tr, es, mk).
- AC3 : la **langue active est surlignée** (fond `primary` α0.12 + check) ; cohérente avec `LocaleState` (ou locale résolue si suivi système, §2.3).
- AC4 : tap sur une langue → `LocaleBloc` reçoit `LocaleChange(Locale(code))` (vérifiable via Bloc test/`add`) → libellés basculent (réactif) **sans** SnackBar ni bouton valider.
- AC5 : choix d'une langue **persiste** (HydratedBloc — réouverture conserve le choix) : couvert par le comportement existant de `LocaleBloc` (test de régression léger).
- AC6 : tap « Code open source » → `launchUrl(LegalUrls.github, externalApplication)` (vérifiable via mock/abstraction `url_launcher`).
- AC7 : tap « digiharmony.org » → `launchUrl(LegalUrls.website, externalApplication)`.
- AC8 : échec d'ouverture (`canLaunchUrl == false`/exception) → SnackBar `parametresLienIndisponible`, **pas de crash**.
- AC9 : `languesSupportees` **alignée** sur `AppLocalizations.supportedLocales` (même ensemble de codes) — test garde-fou.
- AC10 : icône réglages Accueil → `AppRouter.versParametres` (et **non** `ouvrirPlaceholder`).
- AC11 : **zéro persistance ajoutée** : aucune écriture Drift, aucun nouveau HydratedBloc (seul `LocaleBloc` existant utilisé).
- AC12 : **aucune permission ajoutée** au manifeste (le manifeste ne contient que `PACKAGE_USAGE_STATS`) ; **aucune dépendance pub ajoutée** (pas de `package_info_plus`).
- AC13 : libellés `parametres*` traduits 8 langues (repli `en`) ; endonymes des langues non traduits ; wordmark « DigiHarmony » non traduit ; aucune chaîne en dur.
- AC14 : a11y — langues annoncées avec `selected`, cibles ≥ 48×48 ; `disableAnimations == true` → halo statique.
- AC15 : carte confidentialité présente (texte rassurant « zéro donnée / pas de compte ») ; carte Erasmus+ présente.

---

## 12. Registry & coordination

- Ajouter dans `aidd_docs/tasks/_registry.md` :
  `| [parametres.md](./parametres.md) | Paramètres (choix langue 8 via LocaleBloc en direct + confidentialité + projet open source/site/Erasmus+) | US-PARAM-01/02 (à créer) | Phase 2 🟡 | Fondations (#3), Accueil (#2), LocaleBloc | parametres.tests.md ⏳ | proposition_a_valider |`
- **Composants consommés** : `AppTheme`/`AppColors`/`AppSpacing`/`AppRadii`, `AppRouter`,
  `HaloRespirant`, **`LocaleBloc`** (existant), **`LegalUrls`** (existant), `url_launcher`,
  `HapticFeedback`. **Introduit ici (réutilisable)** : `LangueSupportee` + `languesSupportees` (constante),
  `kVersionApp` (constante version).
- **Coordination** :
  - `accueil_view.dart` = recâblage **1 ligne** (placeholder → route), après merge Accueil (#2) — même
    pattern que DEC-TE-10 / DEC-SH-010 (`temps-ecran`/`noter-humeur`). **DEC-PARAM-08.**
  - `app_router.dart` = ajout `versParametres` **append-only**.
  - **Pas de collision Drift** (aucune modif schéma). **Pas de collision pubspec** (aucune dépendance).
  - **Pas de collision MainActivity** (aucun MethodChannel, contrairement à `temps-ecran`/`tuto-notifs`).

---

## 13. Questions à valider

> ✅ **TRANCHÉES (2026-06-06) — plan `valide`** :
> - **Q-PARAM-3/6 (version)** : **dynamique via `package_info_plus`** (à ajouter au pubspec, règle `4-package-installation`) — lecture de la vraie version à l'exécution.
> - **Q-PARAM-4 (langue système)** : **non** — uniquement les 8 langues explicites (maquette) ; `LocaleSysteme` reste dormant.
> - **Q-PARAM-6/9 (visuel UE)** : **logo officiel bundlé `assets/images/logo_eu_funding.png`** (pas l'emoji).
> - **Q-PARAM-1 (liens)** : **GitHub seul** (`LegalUrls.github`, licence GNU GPLv3) ; **masquer `digiharmony.org`** tant que le site n'est pas confirmé en ligne (pas de lien mort). Le lien site sera réactivé plus tard.
> - **Q-PARAM-2 (LocaleBloc via MaterialPageRoute)** : détail d'implémentation — fournir `BlocProvider.value(LocaleBloc)` au push si besoin ; à vérifier au câblage.
> - **Q-PARAM-7 (`<queries>` Android url_launcher)** : vérifier au câblage (probablement déjà géré via soutien) ; ajouter le bloc `<queries>` si nécessaire.
>
> ⚠️ Note : `package_info_plus` = **nouvelle dépendance** (dérogation assumée par l'utilisateur pour une version juste).

### Historique des questions (résolues — traçabilité)
> joignables en arrière-plan ; structure visuelle = maquette fournie par l'utilisateur, font loi).

- **Q-PARAM-1 (URLs exactes)** : `LegalUrls.github` = `https://github.com/AlexandreMaillot/digiharmony`
  et `LegalUrls.website` = `https://digiharmony.org` (vérifiés dans le code). Sont-ce **bien** les URLs
  définitives à utiliser (dépôt public, domaine actif) ? La licence affichée est « GNU GPL » → confirmer
  qu'elle correspond à la licence réelle du dépôt.
- **Q-PARAM-2 (portée `LocaleBloc` à travers la route)** : V1 suppose que `LocaleBloc` (au-dessus de
  `MaterialApp`) est accessible dans le sous-arbre du `MaterialPageRoute` de `ParametresPage` — c'est le
  cas standard Flutter. Confirmer à l'implémentation ; sinon `BlocProvider.value(context.read<LocaleBloc>())`
  autour de la page (fallback documenté §6.1).
- **Q-PARAM-3 (source & format de la version)** : `package_info_plus` **absent** du pubspec → version via
  **constante** `kVersionApp` (DEC-PARAM-06). Confirmer : (a) valeur (« 1.0 » ? sync avec `pubspec.yaml`
  `version:` ?), (b) format affiché (« DIGIHARMONY v1.0 » ? avec build number ?), (c) emplacement de la
  constante (`lib/config/` ?). **Si** la version dynamique réelle est exigée → décision séparée d'ajouter
  `package_info_plus` (viole « zéro nouvelle dépendance » — à arbitrer explicitement).
- **Q-PARAM-4 (retour au suivi système)** : V1 n'expose **pas** de contrôle « Langue du système »
  (`LocaleSysteme`) ; choisir une langue force ce code. Faut-il une 9ᵉ entrée « Système / Automatique »
  en tête de liste (qui dispatcherait `LocaleSysteme`) ? (la maquette ne la montre pas).
- **Q-PARAM-5 (Bloc dédié ?)** : V1 = `StatelessWidget` consommant `LocaleBloc` (pas de `ParametresBloc`,
  DEC-PARAM-02). La revue veut-elle malgré tout un `ParametresBloc` pour homogénéité (déconseillé :
  relais inutile, duplication d'état de langue) ?
- **Q-PARAM-6 (visuel Erasmus+)** : mention via emoji 🇪🇺 + texte, ou via l'asset `logo_eu_funding.png`
  (déjà présent dans le projet) ? (la maquette montre 🇪🇺).
- **Q-PARAM-7 (`<queries>` Android pour `url_launcher`)** : selon la version d'`url_launcher`/cible SDK,
  l'ouverture https en `externalApplication` peut nécessiter un bloc `<queries><intent>` au manifeste
  (déjà présent ? `soutien` ouvre tel:/https: via le même package → probablement déjà géré). Vérifier
  qu'aucun ajout manifeste n'est requis (sinon = ajout `<queries>`, **pas** une permission).
- **Q-PARAM-8 (milestone)** : supposé **Phase 2** 🟡 (cohérent `temps-ecran`/`tuto-notifs`). À confirmer.
- **Q-PARAM-9 (endonymes & drapeaux)** : libellés natifs proposés : English, Français, Ελληνικά,
  Italiano, Română, Türkçe, Español, Македонски. Drapeaux emoji 🇬🇧🇫🇷🇬🇷🇮🇹🇷🇴🇹🇷🇪🇸🇲🇰. Confirmer
  l'orthographe des endonymes et le choix 🇬🇧 vs 🇺🇸 pour l'anglais (recommandé : 🇬🇧).

---

## 14. Décisions tranchées (DEC-PARAM)

| ID | Décision |
|---|---|
| DEC-PARAM-01 | Cœur fonctionnel = **changer la langue en direct**. Bascule immédiate (`MaterialApp` reconstruit) + persistée (HydratedBloc). Pas de bouton « valider », pas de SnackBar de confirmation (la bascule des textes = feedback). |
| DEC-PARAM-02 | **Réutiliser `LocaleBloc` existant** (HydratedBloc — **pas** un Cubit, le code fait foi malgré « LocaleCubit » dans la consigne). **Aucun nouveau Bloc/Cubit, aucune modif de `LocaleBloc`.** L'écran est un `StatelessWidget` qui `BlocBuilder<LocaleBloc, LocaleState>` (lecture) + `add(LocaleChange(...))` (écriture). |
| DEC-PARAM-03 | **Liste des 8 langues = constante Dart** (`languesSupportees`), endonymes (noms natifs) **NON traduits / hors ARB** ; doit rester **alignée** sur `AppLocalizations.supportedLocales`. Ordre = maquette (en, fr, el, it, ro, tr, es, mk). |
| DEC-PARAM-04 | Tap langue → `LocaleChange(Locale(code))` + `HapticFeedback.selectionClick()`. Feedback = bascule visible des libellés + déplacement du check. **Pas** de confirmation explicite. |
| DEC-PARAM-05 | Liens projet ouverts via **`url_launcher`** (`canLaunchUrl` + `launchUrl(externalApplication)`), pattern **identique** à `bloc_ligne_ecoute.dart`. Échec → SnackBar `parametresLienIndisponible` (bienveillant, pas de crash). |
| DEC-PARAM-06 | Version affichée via **constante `kVersionApp`** — **`package_info_plus` NON ajouté** (zéro nouvelle dépendance). Valeur/format/emplacement à confirmer (Q-PARAM-3). |
| DEC-PARAM-07 | Langue « active » surlignée = `LocaleState.locale?.languageCode` ; si `null` (suivi système) → `Localizations.localeOf(context).languageCode` (locale réellement résolue). Surlignage : fond `AppColors.primary.withValues(alpha: 0.12)` + check `primary`. |
| DEC-PARAM-08 | Point d'entrée = **icône réglages du header Accueil** (`accueil_view.dart` `_Header` **L227**) : recâbler `ouvrirPlaceholder(placeholderReglages)` → `AppRouter.versParametres(context)` (1 ligne, append-only, `tooltip reglagesTooltip` conservé). Dépendance d'intégration Accueil (#2). |
| DEC-PARAM-09 | Les **8** langues sont **toutes** sélectionnables (toutes dans `supportedLocales`) ; le repli `en` concerne les **traductions** manquantes (`el/it/ro/tr/es/mk`), **pas** la bascule de langue qui fonctionne pour les 8. |
| DEC-PARAM-10 | **Pas de Drift, pas de nouveau HydratedBloc, aucune permission, aucune dépendance pub.** Manifeste & pubspec inchangés. Pas de MethodChannel (≠ `temps-ecran`/`tuto-notifs`). |
| DEC-PARAM-11 | Navigation `AppRouter.versParametres` en **`push`** (DEC-FND-07, pas de GoRouter), via `ParametresPage.route()`. Toolbar : chevron · titre · **pas de burger** (espaceur d'équilibre). |

---

## 15. Auto-challenge (points signalés)

- ✅ **Consigne dit « LocaleCubit » mais le code réel est `LocaleBloc`** (HydratedBloc, vérifié
  `lib/locale/locale_bloc.dart`). → Le plan s'aligne sur le **code** (DEC-PARAM-02). Pas de Cubit créé
  (conforme `1-bloc-only-no-cubit`).
- ✅ **`package_info_plus` ABSENT du pubspec** (vérifié) → version via **constante** (DEC-PARAM-06),
  pas de nouvelle dépendance. Si version dynamique exigée → décision explicite séparée (Q-PARAM-3).
- ✅ **`url_launcher` présent** (`^6.3.2`) et **déjà utilisé** (`bloc_ligne_ecoute.dart`) avec le pattern
  `canLaunchUrl`/`launchUrl(externalApplication)` + SnackBar d'échec → **réutilisé à l'identique** (DEC-PARAM-05).
- ✅ **`LegalUrls.github` / `website` existent** (vérifié `config/legal_urls.dart`) → pas de nouvelle
  constante d'URL à créer (Q-PARAM-1 = simple confirmation).
- ✅ **Point d'entrée localisé** : `accueil_view.dart` `_Header` **L224-228**, `IconButton` `Icons.settings`
  → `ouvrirPlaceholder(placeholderReglages)`. Recâblage 1 ligne (DEC-PARAM-08).
- ⚠️ **`LocaleBloc` à travers la frontière de route** : standard Flutter (au-dessus de `MaterialApp` ⇒
  disponible partout) ; fallback `BlocProvider.value` documenté si besoin (Q-PARAM-2). À re-vérifier au
  branchement réel.
- ⚠️ **Surlignage en mode « suivi système »** (`locale == null`) : ne pas surligner « rien » — surligner
  la locale **résolue** par `Localizations.localeOf` (DEC-PARAM-07), sinon l'utilisateur ne voit aucun check.
- ⚠️ **Drapeaux emoji** : rendu dépend de la police système ; 🇲🇰 / 🇪🇺 peuvent ne pas s'afficher sur
  certaines ROMs Android (fallback = lettres régionales). Acceptable V1 ; alternative = picto neutre. 🟡
- ⚠️ **Tests + halo animé** : `HaloRespirant` (boucle) → ne **jamais** `pumpAndSettle()` (piège
  testing.md) ; wrapper `MediaQuery(disableAnimations: true)`.
- ⚠️ **Tester `url_launcher` sans natif** : ne pas invoquer le vrai `launchUrl` en test widget →
  abstraire/mocker (façade légère `OuvreurLien` ou override de plateforme) pour AC6/AC7/AC8. 🟡 décider
  de l'abstraction à l'implémentation (cohérent avec le précédent `bloc_ligne_ecoute.dart`).
- 🟡 **Design + US non confirmés par Erwin/Banani en direct** : maquette fournie par l'utilisateur =
  faisant loi ; §13 reste ouvert. Plan `proposition_a_valider`.
- 🔁 **Réutilisations** : `LocaleBloc` (langue), `LegalUrls` (URLs), `url_launcher` (pattern soutien),
  `HaloRespirant`, toolbar (calquée app), `AppRouter`. **Aucune duplication, aucune nouvelle dépendance.**
