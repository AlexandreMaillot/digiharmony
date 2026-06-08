---
page: Paramètres (SettingsPage)
route: /settings (SettingsPage — écran plein écran, cible du bouton MENU / hamburger global ; chevron retour → parent Home/menu, par nom de route, non présumé)
us: []
shared_components: [DigiToolbar, AppBackground, AppTheme, LocaleCubit]
i18n_keys: [settingsTitle, settingsSectionLanguage, settingsSectionPrivacy, settingsPrivacyNotice, settingsSectionProject, settingsOpenSourceTitle, settingsOpenSourceSubtitle, settingsWebsiteTitle, settingsWebsiteSubtitle, settingsErasmusNotice, settingsVersion]
shared_components_extracted: [AppLocale (core_package — modèle statique pur : code locale + drapeau emoji + autonyme NON traduit), LocaleCubit (HydratedCubit<Locale>, FONDATION partagée — à créer si absente, pattern VoiceoverCubit), kSupportedAppLocales (liste statique des 8 locales en/fr/el/it/ro/tr/es/mk), SettingsSection / SettingsCard (présentation, candidat kit partagé), LanguageTile, ExternalLinkTile, PrivacyNoticeCard, ErasmusBanner]
tests: aidd_docs/tasks/parametres.tests.md (à remplir par Kent en étape 5)
created: 2026-06-05
updated: 2026-06-05
---

# Plan de page — « Paramètres » (SettingsPage)

> Plan auto-suffisant pour éditeur IA. Conforme aux règles `aidd_docs/memory/` +
> `aidd_docs/rules/` de DIGIHARMONY : Flutter, monorepo Melos 7
> (`apps/digiharmony_app` + `packages/core_package`), **client-only, zéro collecte,
> zéro réseau applicatif, zéro SDK analytics/tracking/Crashlytics**, vibration via
> `HapticFeedback` uniquement, aucune permission au-delà de `PACKAGE_USAGE_STATS`,
> i18n ARB gen-l10n 8 langues (repli `en`), **DM Sans en asset local** (jamais
> `google_fonts` → réseau interdit).
>
> 🌐 **PIÈCE MAÎTRESSE — le sélecteur de langue.** Cet écran est l'unique surface qui
> pilote la **bascule de langue LIVE** de toute l'application via le **`LocaleCubit`
> partagé** (HydratedBloc, posé au-dessus de `MaterialApp`). Taper une langue change
> instantanément la langue de l'app entière et **persiste** le choix entre sessions.
>
> ✅ **Liens externes via `url_launcher` — conformité « zéro réseau ».** Ouvrir une URL
> dans le **navigateur du système** est une **délégation à l'OS**, PAS une requête réseau
> émise par l'app ni du tracking. `url_launcher` est **déjà présent** au `pubspec`
> (`url_launcher: ^6.3.2`) — dépendance **déjà acceptée**, rien à valider (cf. §7).
>
> Cet écran **réutilise** les composants partagés `DigiToolbar`, `AppBackground`,
> `AppTheme` (créés par `choisis-ta-bulle.md`, étendus par `respiration.md`/`detox.md`).
> Il utilise le **fond STANDARD de l'app `#1F2C49`** — token réel `AppTheme.hubBackground`
> (PAS le fond bulle `#16213C`). ⚠️ Voir §3 : le registry/temps-decran parlent d'un token
> `appBackground`, mais le **token réellement présent dans le code** est `hubBackground`
> (`Color(0xFF1F2C49)`). On s'aligne sur le code.

---

## 1. Contexte de la page

| Élément | Valeur |
| --- | --- |
| Nom | « Paramètres » — langue de l'app, note de confidentialité, infos projet (open source, site, Erasmus+), version |
| Widget page | `SettingsPage` (entrée + providers) + `SettingsView` (UI), fichier `lib/settings/view/settings_page.dart` |
| Route logique | `/settings`, écran plein écran. **Cible du bouton MENU / hamburger global** (cf. §10). Chevron retour → parent (Home/menu) |
| Parent | Accueil / Home (point d'entrée exact branché côté routing Home — référencé **par nom de route**, non présumé) |
| Accès / rôles / auth | **Aucun** — app sans compte, sans identification. Accès libre |
| Données affichées | **Langue courante** (cochée), **liste statique des 8 locales**, note de confidentialité (texte), 2 liens projet (GitHub, site), bandeau Erasmus+, **version de l'app** |
| Source de données | **Langue** : `LocaleCubit` (HydratedBloc). **Liste des locales** : constante statique `kSupportedAppLocales` (code + drapeau emoji + autonyme). **Liens** : `LegalUrls` (déjà dans `lib/config/legal_urls.dart`). **Version** : constante de build (cf. §8). **Aucune** API, **aucune** DB, **aucune** permission |
| Persistance | Uniquement la **langue** via `LocaleCubit` (HydratedBloc, déjà le mécanisme prévu pour la langue — DEC-002 : HydratedBloc = état léger, jamais le journal). Le reste est **statique** |
| État applicatif | `LocaleCubit` (partagé, lecture + `setLocale`). Aucun Bloc/Cubit propre à l'écran |
| États écran | **Nominal uniquement** : liste langue + sections. **Pas** d'empty / loading / error (cf. §5) |

**Pourquoi aucun Bloc dédié à l'écran :** la seule donnée mutable est la langue, déjà gérée
par le `LocaleCubit` partagé. Tout le reste est statique (constantes + i18n). Inutile d'ajouter
un Cubit `SettingsCubit` — on lirait/écrirait simplement le `LocaleCubit`. **Ne pas en créer.**

---

## 2. User Stories liées

**Aucune US backlog référencée fournie.** Le plan s'appuie sur les **décisions validées par
l'utilisateur** (reportées en §13) qui font office de critères d'acceptation. À rattacher si une
US existe (mettre à jour le champ `us:` de l'en-tête + du registry).

---

## 3. Design — structure visuelle (fidèle à la maquette HTML/CSS fournie)

Fond **`#1F2C49`** (fond STANDARD app = `AppTheme.hubBackground`, PAS `bubbleBackground #16213C`)
\+ **halo radial cyan décoratif** (déjà rendu statiquement par `AppBackground`, compatible
`reduceMotion` par construction).

```
┌──────────────────────────────────────────────┐
│  [‹ 48x48]      Paramètres        [spacer 48] │  ← DigiToolbar (trailing=null)
│                                                │
│  LANGUE                                        │  ← label section (uppercase, muted)
│  ┌──────────── Carte liste (#283A5E) ────────┐│
│  │ 🇬🇧  English                               ││
│  │ 🇫🇷  Français                          ✓  ││  ← SÉLECTIONNÉ : fond cyan translucide,
│  │ 🇬🇷  Ελληνικά                              ││     texte foreground gras, check cyan
│  │ 🇮🇹  Italiano                              ││
│  │ 🇷🇴  Română                                ││
│  │ 🇹🇷  Türkçe                                ││
│  │ 🇪🇸  Español                               ││
│  │ 🇲🇰  Македонски                            ││
│  └────────────────────────────────────────────┘│
│                                                │
│  CONFIDENTIALITÉ                               │  ← label section
│  ┌──🛡──────────────────────────────────────┐  │
│  │ Aucune donnée personnelle n'est           │  │  ← shield-check cyan (Icons.verified_user)
│  │ enregistrée ni diffusée. Pas de compte,   │  │     POINT CLÉ RGPD (texte i18n statique)
│  │ pas d'identification.                     │  │
│  └────────────────────────────────────────────┘ │
│                                                │
│  LE PROJET                                     │  ← label section
│  ┌──────────── Carte liste (#283A5E) ────────┐│
│  │ (</>) Code open source                ↗  ││  → ouvre repo GitHub (navigateur OS)
│  │       GitHub · Licence GNU GPL            ││     icône Icons.code + Icons.open_in_new
│  │ ──────────── séparateur ────────────       ││
│  │ (🌐) digiharmony.org                  ↗  ││  → ouvre le site (navigateur OS)
│  │       Site officiel du projet             ││     Icons.public + Icons.open_in_new
│  └────────────────────────────────────────────┘│
│  ┌──🇪🇺──────────────────────────────────────┐ │  ← bandeau Erasmus+
│  │ Projet Erasmus+ — application gratuite,    │ │     carré bleu UE (emoji 🇪🇺)
│  │ sans publicité                             │ │
│  └────────────────────────────────────────────┘ │
│                                                │
│              DIGIHARMONY v1.0                  │  ← footer centré (muted)
└──────────────────────────────────────────────┘
```

**Ordre strict (haut → bas), à NE PAS réordonner :** Toolbar → section « LANGUE » (8 locales) →
section « CONFIDENTIALITÉ » (carte shield) → section « LE PROJET » (carte 2 liens + bandeau
Erasmus+) → footer version. La page **scrolle** (`SingleChildScrollView`) — contenu plus haut que
l'écran possible.

### Tokens de design (mappés sur `AppTheme` — code réel)

| Token (maquette) | Valeur | `AppTheme` (réel) | Rôle |
| --- | --- | --- | --- |
| fond app | `#1F2C49` | **`hubBackground`** | fond standard de cet écran (passé à `AppBackground(background:)`) |
| surface | `#283A5E` | `surface` | cartes liste + carte confidentialité |
| primary (cyan) | `#3FB8E6` | `primary` | langue sélectionnée (fond translucide + check), icônes section |
| foreground | `#F2F6FB` | `foreground` | titres, texte sélectionné gras |
| muted | `#A7B6CE` | `muted` | labels section, sous-titres, footer version, langues non sélectionnées |
| accent sélection langue | cyan translucide (`primary` @ ~12–15 % alpha) | dérivé de `primary` | fond de la ligne langue active |
| radius 8 / 12 / 16 / 24 | — | `radiusSmall=12`, `radiusMedium=20`, `radiusLarge=24` | ⚠️ pas de token `8` ni `16` exact. Utiliser `radiusSmall`(12) pour les lignes/icônes, `radiusLarge`(24) pour les cartes. Voir note ↓ |
| police | **DM Sans** (asset local) | `AppTheme.fontFamily` | toute la typo (jamais google_fonts) |

> ⚠️ **Radius** : la maquette cite 8/12/16/24 ; `AppTheme` n'expose que `12/20/24`. Pour rester
> fidèle, soit **ajouter** `radiusXSmall = 8` (et `radiusMedium16 = 16`) à `AppTheme`, soit mapper sur
> les rayons existants les plus proches. **Recommandation : mapper sur l'existant** (12 pour petits
> éléments, 24 pour cartes) pour éviter d'élargir les tokens sans nécessité ; ajouter un token seulement
> si le rendu diverge visiblement. À signaler, non bloquant.

> ⚠️ **Drapeaux = emojis texte** (🇬🇧 🇫🇷 🇬🇷 🇮🇹 🇷🇴 🇹🇷 🇪🇸 🇲🇰 / 🇪🇺), **jamais des assets image**.
> Rendus via `Text`. **Icônes Material only** : `Icons.verified_user` (shield-check), `Icons.code`
> (GitHub — **PAS de package d'icônes de marque tiers**), `Icons.public` (globe), `Icons.open_in_new`
> (external-link). Si un vrai logo GitHub est exigé plus tard → asset SVG **local** (`flutter_svg`),
> jamais un package d'icônes de marque. Voir §3 note marque.

---

## 4. Arborescence des widgets

```
SettingsPage  (lib/settings/view/settings_page.dart)
└─ (pas de BlocProvider local — consomme le LocaleCubit fourni en amont de MaterialApp)
   └─ SettingsView
      └─ AppBackground(background: AppTheme.hubBackground)        ← #1F2C49 + halo cyan déco statique
         └─ SafeArea
            └─ Column
               ├─ DigiToolbar(title: l10n.settingsTitle, trailing: null, onBack: Navigator.pop, backLabel: l10n.<back>)
               └─ Expanded
                  └─ SingleChildScrollView
                     └─ Column (padding latéral)
                        ├─ SettingsSection(label: l10n.settingsSectionLanguage)   ← « LANGUE »
                        │   └─ SettingsCard(surface)
                        │       └─ Column( for locale in kSupportedAppLocales →
                        │            LanguageTile(
                        │              locale,                         // AppLocale (code/flag/autonyme)
                        │              selected: locale.code == currentLocale.languageCode,
                        │              onTap: () => { HapticFeedback.selectionClick();
                        │                             context.read<LocaleCubit>().setLocale(locale.toLocale()); },
                        │            )
                        │            (+ séparateurs entre lignes)
                        │          )
                        ├─ SettingsSection(label: l10n.settingsSectionPrivacy)    ← « CONFIDENTIALITÉ »
                        │   └─ PrivacyNoticeCard(icon: Icons.verified_user, text: l10n.settingsPrivacyNotice)
                        ├─ SettingsSection(label: l10n.settingsSectionProject)    ← « LE PROJET »
                        │   ├─ SettingsCard(surface)
                        │   │   ├─ ExternalLinkTile(
                        │   │   │     leading: Icons.code, trailing: Icons.open_in_new,
                        │   │   │     title: l10n.settingsOpenSourceTitle,        // « Code open source »
                        │   │   │     subtitle: l10n.settingsOpenSourceSubtitle,  // « GitHub · Licence GNU GPL »
                        │   │   │     onTap: () => openExternal(LegalUrls.github))
                        │   │   ├─ Divider
                        │   │   └─ ExternalLinkTile(
                        │   │         leading: Icons.public, trailing: Icons.open_in_new,
                        │   │         title: l10n.settingsWebsiteTitle,           // « digiharmony.org »
                        │   │         subtitle: l10n.settingsWebsiteSubtitle,     // « Site officiel du projet »
                        │   │         onTap: () => openExternal(LegalUrls.website))
                        │   └─ ErasmusBanner(text: l10n.settingsErasmusNotice)   // bandeau + emoji 🇪🇺
                        └─ Center(child: Text(l10n.settingsVersion(AppInfo.version)))  // « DIGIHARMONY v1.0 »
```

### Composants réutilisés (registry)

| Composant | Origine | Usage ici |
| --- | --- | --- |
| `DigiToolbar` | choisis-ta-bulle (+ trailing respiration) | toolbar, `trailing: null` (spacer 48px à droite via `showMenu=false`), `onBack` → `Navigator.pop` |
| `AppBackground` | choisis-ta-bulle (+ `background` respiration) | fond `#1F2C49` (`hubBackground`) + halo cyan déco statique |
| `AppTheme` | choisis-ta-bulle (+ tokens detox/respiration) | `hubBackground`, `surface`, `primary`, `foreground`, `muted`, `radiusSmall/Large`, `fontFamily` |
| `LocaleCubit` | **FONDATION partagée** (HydratedBloc) | lecture langue courante + `setLocale` (cf. §6) |
| `LegalUrls` | `lib/config/legal_urls.dart` (déjà présent) | `LegalUrls.github`, `LegalUrls.website` (URLs réelles) |

### Nouveaux composants (créés / fondés par ce plan)

| Composant | Emplacement | Rôle |
| --- | --- | --- |
| `AppLocale` + `kSupportedAppLocales` | **core_package** `lib/src/locale/app_locale.dart` | modèle statique pur (code locale / drapeau emoji / autonyme NON traduit) + liste des 8 locales ordonnées en/fr/el/it/ro/tr/es/mk (cf. §7) |
| `LocaleCubit` | app `lib/locale/cubit/locale_cubit.dart` | `HydratedCubit<Locale>` partagé — **à créer si absent** (n'existe pas encore dans le code ; suivre le pattern `VoiceoverCubit`). Posé au-dessus de `MaterialApp` (cf. §6) |
| `SettingsSection` | app `lib/settings/widgets/settings_section.dart` | label uppercase muted + slot enfant (présentation) |
| `SettingsCard` | app `lib/settings/widgets/settings_card.dart` | conteneur `surface` arrondi pour listes |
| `LanguageTile` | app `lib/settings/widgets/language_tile.dart` | ligne langue : drapeau emoji + autonyme + état sélectionné (fond cyan translucide, gras, check) |
| `ExternalLinkTile` | app `lib/settings/widgets/external_link_tile.dart` | ligne lien : icône ronde + titre + sous-titre + `Icons.open_in_new` ; `onTap` → ouverture URL |
| `PrivacyNoticeCard` | app `lib/settings/widgets/privacy_notice_card.dart` | carte shield (texte i18n statique) |
| `ErasmusBanner` | app `lib/settings/widgets/erasmus_banner.dart` | bandeau Erasmus+ + emoji 🇪🇺 (texte i18n statique) |
| `AppInfo.version` | app `lib/config/app_info.dart` | constante de build exposant la version (cf. §8) |

> 🔁 **Candidat refactor cross-page (non bloquant) :** `SettingsCard` / ligne « icône + titre +
> sous-titre + chevron/trailing + HapticFeedback » est très proche de `ScreenTimeActionCard`
> (temps-decran.md) et des motifs « ligne d'action » d'autres écrans. À promouvoir dans le kit partagé
> `lib/wellbeing_shared/` (déjà proposé par etirement.md) **si** un 2ᵉ besoin se confirme. **Ne pas
> extraire prématurément.**

---

## 5. États de la page

| État | Présence ici | Justification |
| --- | --- | --- |
| `loading` | ❌ | Aucune source asynchrone. Langue lue de façon synchrone depuis `LocaleCubit` (déjà hydraté). Constantes statiques |
| `empty` | ❌ | Liste de langues = constante de 8 entrées toujours non vide |
| `error` | ❌ | Pas d'I/O. **Échec d'ouverture d'URL = fallback silencieux** (cf. §7), pas un état d'écran |
| `nominal` | ✅ | Liste langue (langue courante cochée) + sections confidentialité / projet + footer version |

**Un seul état affiché : nominal.** La sélection de langue ne provoque **aucun** état de chargement —
c'est une bascule synchrone du `LocaleCubit` qui reconstruit l'arbre (langue + check) instantanément.

---

## 6. Sélecteur de langue — intégration `LocaleCubit` (pièce maîtresse)

### 6.1 Le `LocaleCubit` (fondation partagée — à créer si absente)

> ⚠️ **État réel du code :** au moment de ce plan, **aucun `LocaleCubit` n'existe** dans
> `apps/digiharmony_app/lib`. Seul `VoiceoverCubit` (`lib/voiceover/cubit/voiceover_cubit.dart`)
> existe comme modèle `HydratedCubit`. `app/view/app.dart` câble déjà `AppTheme.themeData`, un
> `BlocProvider<VoiceoverCubit>` et un `RepositoryProvider<WellbeingStatsRepository>` au-dessus de
> `MaterialApp` (home = `BubblesPage`), mais **sans `LocaleCubit` ni `MaterialApp.locale`**. **Ce plan
> fonde donc le `LocaleCubit`** (ou le réutilise s'il a été créé entre-temps), strictement sur le
> pattern `VoiceoverCubit`.

`apps/digiharmony_app/lib/locale/cubit/locale_cubit.dart` :

```
/// Langue de l'app, persistée entre sessions (HydratedBloc).
/// État léger UNIQUEMENT (DEC-002) — jamais le journal/agrégats.
class LocaleCubit extends HydratedCubit<Locale> {
  LocaleCubit() : super(const Locale('en'));   // défaut + repli = en

  void setLocale(Locale locale) {
    // garde-fou : n'accepter qu'une locale supportée (8 codes du projet)
    if (kSupportedAppLocales.any((l) => l.code == locale.languageCode)) {
      emit(locale);
    }
  }

  @override
  Locale fromJson(Map<String, dynamic> json) =>
      Locale(json['languageCode'] as String? ?? 'en');

  @override
  Map<String, dynamic> toJson(Locale state) =>
      <String, dynamic>{'languageCode': state.languageCode};
}
```

### 6.2 Câblage au-dessus de `MaterialApp` (responsabilité de `app/view/app.dart`)

- Ajouter `LocaleCubit` au **`BlocProvider` existant** d'`app/view/app.dart` (le passer en
  `MultiBlocProvider` à côté de `VoiceoverCubit`), **au-dessus** de `MaterialApp`.
- Câbler `MaterialApp.locale` = `context.watch<LocaleCubit>().state` (actuellement absent) →
  **toute** l'app rebuild dans la nouvelle langue, **instantanément, sans redémarrage**.
- `localizationsDelegates: AppLocalizations.localizationsDelegates`,
  `supportedLocales: AppLocalizations.supportedLocales` (**déjà en place** dans `app.dart`).
- ⚠️ Ce plan **ne réécrit pas** `app.dart` (hors périmètre Paramètres) mais **documente le contrat** :
  sans `LocaleCubit` fourni + `MaterialApp.locale` câblé, la bascule live ne peut pas marcher. À fonder
  avec le `LocaleCubit`.

### 6.3 Comportement de l'écran Paramètres

- L'écran **lit** la langue courante : `final current = context.watch<LocaleCubit>().state;`
  La ligne dont `locale.code == current.languageCode` est rendue **sélectionnée**.
- **Tap sur une langue** :
  1. `HapticFeedback.selectionClick()`.
  2. `context.read<LocaleCubit>().setLocale(Locale(locale.code))`.
  3. → émission → `MaterialApp` rebuild → **toute l'app passe dans la nouvelle langue** (titres, labels,
     y compris le titre « Paramètres » de cette page).
  4. La pastille check **suit** l'état (la ligne nouvellement tapée devient cochée).
- **Persistance automatique** par HydratedBloc : au prochain lancement, l'app démarre dans la langue choisie.

### 6.4 Donnée statique des locales (autonymes NON traduits)

- La liste affichée vient de `kSupportedAppLocales` (cf. §7) — **statique**, ordre **exactement**
  en/fr/el/it/ro/tr/es/mk (= `AppLocalizations.supportedLocales`).
- Chaque entrée : **code locale**, **drapeau emoji**, **autonyme** (nom de la langue dans sa propre
  langue). ⚠️ **L'autonyme N'EST PAS traduit** : « Français » reste « Français », « Ελληνικά » reste
  « Ελληνικά », etc., quelle que soit la langue d'UI courante. **Ne PAS** mettre les noms de langue dans
  les ARB ; ce sont des constantes.

---

## 7. Liens externes — `url_launcher` (conformité « zéro réseau »)

### 7.1 Justification de conformité (à conserver tel quel)

Ouvrir une URL dans le **navigateur du système** (`launchUrl(..., mode: LaunchMode.externalApplication)`)
**délègue** l'ouverture à une autre application (le navigateur de l'OS). **L'app DIGIHARMONY n'émet
aucune requête réseau, ne télécharge rien, ne trace rien.** C'est une **délégation à l'OS**, pas un
appel réseau applicatif → **compatible** avec « zéro collecte / zéro réseau applicatif ».
`url_launcher` est un plugin standard, **déjà présent au `pubspec`** (`url_launcher: ^6.3.2`) :
**dépendance déjà acceptée**, rien à ajouter ni à valider.

### 7.2 Helper d'ouverture (avec gestion d'échec silencieuse)

```
Future<void> openExternal(String url) async {
  HapticFeedback.selectionClick();                 // feedback tap
  final uri = Uri.parse(url);
  // canLaunchUrl peut renvoyer false (aucune app capable d'ouvrir) → fallback silencieux
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  // Si échec/impossible : NE RIEN faire (pas de crash, pas de SnackBar bruyante).
  // (Option future, non requise : SnackBar discrète « impossible d'ouvrir le lien ».)
}
```

- URLs **réutilisées** depuis `LegalUrls` (déjà dans le code) :
  - GitHub : `LegalUrls.github` = `https://github.com/AlexandreMaillot/digiharmony`.
  - Site : `LegalUrls.website` = `https://digiharmony.org`.
- ⚠️ **Ne PAS coder en dur** les URLs dans le widget : passer par `LegalUrls` (source unique).
- **Gestion d'échec** : `canLaunchUrl == false` → **fallback silencieux** (ne pas planter, ne pas afficher
  d'erreur bloquante). Cas réaliste sur appareil sans navigateur.

---

## 8. Exposition de la version

**Recommandation par défaut : constante de build simple** (`AppInfo.version`), pour **éviter une
dépendance** :

```
// apps/digiharmony_app/lib/config/app_info.dart
class AppInfo {
  const AppInfo._();
  static const String version = '1.0';     // affiché : "DIGIHARMONY v1.0"
}
```

- Affichage : `l10n.settingsVersion(AppInfo.version)` → « DIGIHARMONY v1.0 » (placeholder `{version}`).
- ⚠️ **Risque de divergence** : cette constante doit rester synchrone avec la `version:` du `pubspec.yaml`.
  À maintenir manuellement (ou via un petit script de build) si on ne veut pas de dépendance.

**Alternative (signalée, non retenue par défaut) : `package_info_plus`.** Lit la version réelle du build
(toujours synchrone, pas de divergence). 100 % local (lit le bundle), pas de réseau → **conforme**. **Coût** :
une dépendance de plus + lecture asynchrone (introduirait un micro état de chargement pour le footer).
**Par défaut → constante simple** (footer purement décoratif, pas d'asynchrone). À basculer vers
`package_info_plus` si le dev préfère la version automatique — **à valider** avant ajout.

---

## 9. reduceMotion (accessibilité)

- Cet écran est **essentiellement statique** : pas d'animation lourde à neutraliser.
- Le **halo radial cyan** du fond est rendu **statiquement** par `AppBackground` (aucune boucle
  d'animation — compatible `reduceMotion` par construction).
- Si une transition d'apparition (fade des cartes) était ajoutée : la **neutraliser** sous
  `MediaQuery.disableAnimations` (rendu immédiat à l'état final). **Aucune information** ne dépend d'une
  animation ici.

---

## 10. Navigation & feedback haptique

| Élément | Action | Cible | Feedback |
| --- | --- | --- | --- |
| Chevron retour (toolbar) | `Navigator.pop` | parent (Home / menu — **par nom de route**, non présumé) | — (comportement toolbar standard) |
| Ligne langue (×8) | change la langue de l'app | `LocaleCubit.setLocale` (bascule live + persistance) | `HapticFeedback.selectionClick()` avant `setLocale` |
| « Code open source » | ouvre URL navigateur OS | `LegalUrls.github` (`launchUrl` externe) | `HapticFeedback.selectionClick()` (dans `openExternal`) |
| « digiharmony.org » | ouvre URL navigateur OS | `LegalUrls.website` (`launchUrl` externe) | `HapticFeedback.selectionClick()` (dans `openExternal`) |

### Lien avec le MENU global (cohérence inter-écrans — à documenter, pas à recâbler ici)

- `/settings` est **vraisemblablement la cible du bouton MENU / hamburger global** vu sur d'autres
  écrans (ex. guide notifications) et du menu de l'app.
- **Contrat documenté** : le hamburger global pousse la route **`/settings`** → `SettingsPage`.
- ⚠️ **Ce plan ne recâble PAS** les autres écrans (toolbar `showMenu`/menu global). Il **signale** le lien
  pour cohérence du routing. Le câblage effectif du hamburger → `/settings` se fait côté Home/menu global,
  hors périmètre de ce plan.

---

## 11. Internationalisation (clés ARB)

Fichiers `lib/l10n/arb/app_*.arb`. **FR + EN remplis**, **placeholders el/it/ro/tr/es/mk** (valeur
provisoire = texte EN, à traduire), repli `en`. Préfixe `settings*`.

| Clé | FR | EN |
| --- | --- | --- |
| `settingsTitle` | Paramètres | Settings |
| `settingsSectionLanguage` | Langue | Language |
| `settingsSectionPrivacy` | Confidentialité | Privacy |
| `settingsPrivacyNotice` | Aucune donnée personnelle n'est enregistrée ni diffusée. Pas de compte, pas d'identification. | No personal data is stored or shared. No account, no sign-in. |
| `settingsSectionProject` | Le projet | The project |
| `settingsOpenSourceTitle` | Code open source | Open source code |
| `settingsOpenSourceSubtitle` | GitHub · Licence GNU GPL | GitHub · GNU GPL License |
| `settingsWebsiteTitle` | digiharmony.org | digiharmony.org |
| `settingsWebsiteSubtitle` | Site officiel du projet | Official project website |
| `settingsErasmusNotice` | Projet Erasmus+ — application gratuite, sans publicité | Erasmus+ project — free app, no ads |
| `settingsVersion` | DIGIHARMONY v{version} | DIGIHARMONY v{version} |

> Notes :
> - `settingsVersion` est un **format paramétré** (`placeholders` : `version`, typé `String`). Rendu :
>   « DIGIHARMONY v1.0 ». Le préfixe « DIGIHARMONY » est conservé dans la clé (identique FR/EN).
> - `settingsWebsiteTitle` = « digiharmony.org » : nom de domaine, **identique** dans toutes les langues
>   (techniquement une clé i18n mais valeur stable).
> - **Les NOMS de langue (autonymes) ne sont PAS dans les ARB** : ce sont des constantes
>   `kSupportedAppLocales` (cf. §7). « Français », « Ελληνικά », « Македонски »… restent identiques quelle
>   que soit la langue d'UI.
> - `settingsPrivacyNotice` + `settingsErasmusNotice` = **textes i18n statiques** (jamais dynamiques).
>   La note de confidentialité est un argument central du projet (RGPD par absence de traitement).

---

## 12. Modèle de données — `core_package` (donnée pure)

`packages/core_package/lib/src/locale/app_locale.dart` (exporté via `core_package.dart`) :

```
/// Une langue supportée par l'app. Donnée pure, immuable, sans I/O, sans Flutter.
class AppLocale {
  final String code;      // code locale ISO: en, fr, el, it, ro, tr, es, mk
  final String flag;      // drapeau emoji: 🇬🇧 🇫🇷 🇬🇷 🇮🇹 🇷🇴 🇹🇷 🇪🇸 🇲🇰
  final String autonym;   // nom natif NON traduit: English, Français, Ελληνικά, ...
  const AppLocale({required this.code, required this.flag, required this.autonym});
  // == / hashCode (Equatable ou override)
}

/// Les 8 locales du projet, dans l'ORDRE de la maquette (= AppLocalizations.supportedLocales).
const List<AppLocale> kSupportedAppLocales = [
  AppLocale(code: 'en', flag: '🇬🇧', autonym: 'English'),
  AppLocale(code: 'fr', flag: '🇫🇷', autonym: 'Français'),
  AppLocale(code: 'el', flag: '🇬🇷', autonym: 'Ελληνικά'),
  AppLocale(code: 'it', flag: '🇮🇹', autonym: 'Italiano'),
  AppLocale(code: 'ro', flag: '🇷🇴', autonym: 'Română'),
  AppLocale(code: 'tr', flag: '🇹🇷', autonym: 'Türkçe'),
  AppLocale(code: 'es', flag: '🇪🇸', autonym: 'Español'),
  AppLocale(code: 'mk', flag: '🇲🇰', autonym: 'Македонски'),
];
```

- **Aucune dépendance Flutter/Android** dans `core_package` (pas de `Locale` Flutter ici → on stocke le
  `code` `String`). La conversion vers `Locale('xx')` se fait côté app (`LanguageTile`/`LocaleCubit`).
- ⚠️ **Cohérence d'ordre** : `kSupportedAppLocales` doit refléter `AppLocalizations.supportedLocales`
  (`l10n/gen`). Toute divergence d'ordre/d'ensemble est un bug. (Test d'invariant suggéré, cf. §14.)
- 🇬🇧 vs `en` : le drapeau anglais utilisé est le drapeau **UK** (🇬🇧) conformément à la maquette, bien que
  le code locale soit `en`. Choix assumé (maquette).

---

## 13. Critères d'acceptation (tiennent lieu d'US — source des tests Kent)

1. **AC-1** L'écran affiche, dans l'ordre exact : section « LANGUE » (8 locales en/fr/el/it/ro/tr/es/mk
   avec drapeau emoji + autonyme), section « CONFIDENTIALITÉ » (carte shield), section « LE PROJET »
   (2 liens + bandeau Erasmus+), footer « DIGIHARMONY v1.0 ».
2. **AC-2** La langue **courante** (état du `LocaleCubit`) est la seule ligne marquée sélectionnée
   (fond cyan translucide + texte gras + check cyan).
3. **AC-3** Taper une langue : déclenche `HapticFeedback.selectionClick`, appelle
   `LocaleCubit.setLocale`, fait **basculer la langue de toute l'app immédiatement** (le titre
   « Paramètres » lui-même change), et déplace la pastille check sur la langue tapée.
4. **AC-4** Le choix de langue **persiste** entre redémarrages (HydratedBloc).
5. **AC-5** Les **autonymes ne sont pas traduits** : « Français » reste « Français » même quand l'UI est
   en anglais (et inversement). Les noms de langue viennent de `kSupportedAppLocales`, pas des ARB.
6. **AC-6** « Code open source » ouvre `LegalUrls.github` dans le **navigateur système**
   (`launchUrl` externe) + `HapticFeedback.selectionClick` ; « digiharmony.org » ouvre `LegalUrls.website`
   de la même façon.
7. **AC-7** Si aucune app ne peut ouvrir l'URL (`canLaunchUrl == false`), l'app **ne plante pas** et ne
   lance aucune ouverture (**fallback silencieux**).
8. **AC-8** La note de confidentialité (« Aucune donnée personnelle… pas d'identification. ») et le
   bandeau Erasmus+ sont visibles, en **texte i18n statique**.
9. **AC-9** Le footer affiche la version via `settingsVersion({version})` alimentée par une **constante
   de build** (`AppInfo.version`), sans dépendance réseau.
10. **AC-10** **Aucune permission** ajoutée (au-delà de `PACKAGE_USAGE_STATS` déjà présente pour un autre
    écran), **aucun SDK réseau/analytics**, **aucune** écriture Drift ; seule la **langue** est persistée
    (HydratedBloc). `url_launcher` = délégation OS, pas de réseau applicatif.
11. **AC-11** `AppLocale` est une donnée pure de `core_package` (sans Flutter/`dart:io`) ; l'ordre de
    `kSupportedAppLocales` correspond à `AppLocalizations.supportedLocales`.

---

## 14. Découpage fichiers (indicatif, à confirmer par les règles d'architecture)

```
packages/core_package/lib/src/locale/app_locale.dart      (AppLocale + kSupportedAppLocales)
packages/core_package/lib/core_package.dart               (export)

apps/digiharmony_app/lib/locale/
└─ cubit/locale_cubit.dart                                (LocaleCubit — HydratedCubit<Locale>, FONDATION partagée si absente)

apps/digiharmony_app/lib/config/
├─ legal_urls.dart                                        (DÉJÀ présent — github / website réutilisés)
└─ app_info.dart                                          (AppInfo.version, NOUVEAU)

apps/digiharmony_app/lib/settings/
├─ view/settings_page.dart                                (Page + récupération LocaleCubit)
├─ view/settings_view.dart                                (UI nominale, scroll, sections)
└─ widgets/
   ├─ settings_section.dart                               (label uppercase + slot)
   ├─ settings_card.dart                                  (conteneur surface)
   ├─ language_tile.dart                                  (drapeau + autonyme + sélection + check)
   ├─ external_link_tile.dart                             (icône + titre + sous-titre + open_in_new + onTap)
   ├─ privacy_notice_card.dart                            (shield + texte i18n)
   └─ erasmus_banner.dart                                 (bandeau Erasmus+ + 🇪🇺)

apps/digiharmony_app/lib/l10n/arb/app_*.arb               (clés settings*)

apps/digiharmony_app/lib/app/view/app.dart                (CONTRAT : LocaleCubit au-dessus de MaterialApp +
                                                           MaterialApp.locale = LocaleCubit.state — à fonder si absent,
                                                           hors périmètre Paramètres mais nécessaire à la bascule live)
```

---

## 15. Points à valider explicitement (signalés, non tranchés unilatéralement)

- ⚠️ **`LocaleCubit` n'existe pas encore** dans le code (vérifié) : ce plan le **fonde** (pattern
  `VoiceoverCubit`) ainsi que son câblage au-dessus de `MaterialApp` (`app/view/app.dart` est encore le
  scaffold very_good). Si une fondation de langue a été créée entre-temps, **la réutiliser** plutôt que la
  recréer.
- ⚠️ **Token de fond** : la maquette/registry évoquent `appBackground` ; le **token réel** est
  `AppTheme.hubBackground` (`#1F2C49`). On s'aligne sur le code. Renommer en `appBackground` serait un
  refactor cross-page séparé (non fait ici).
- ⚠️ **Radius 8/16** absents d'`AppTheme` (présents : 12/20/24). Recommandation : **mapper sur l'existant**
  (12 / 24) ; ajouter `radiusXSmall=8` seulement si divergence visible.
- ⚠️ **Version** : constante `AppInfo.version` (défaut) vs `package_info_plus` (auto, conforme, +1 dépendance
  + asynchrone). Par défaut → constante. À trancher avec le dev.
- ⚠️ **Icône GitHub** : `Icons.code` (Material générique) par défaut — **pas** de package d'icônes de
  marque tiers. Asset SVG local possible si un vrai logo est exigé.
- ⚠️ **Lien MENU global → `/settings`** : contrat documenté, câblage du hamburger fait côté Home/menu
  (hors périmètre).
- ⚠️ **Drapeau 🇬🇧 pour `en`** : drapeau UK retenu (maquette), bien que le code locale soit `en`.
