---
page: Réduire mes notifications (tutoriel)
slug: tuto-notifs
route: TutoNotifsPage (push via AppRouter.versTutoNotifs)
feature_dir: apps/digiharmony_app/lib/pages/tuto_notifs/
status: valide
github:
us:
  - "US-TN-01 « Apprendre à réduire mes notifications » → À CRÉER via Erwin (milestone Phase 2 🟡)"
  - "US-TN-02 « Ouvrir les réglages notifications du système » → À CRÉER via Erwin (dépend de TN-01)"
depends_on:
  - "#3 Fondations (US-FND-01) — thème, AppRouter, i18n, HaloRespirant, ouvrirPlaceholder"
related:
  - temps-ecran.md
  - accueil-home.md
shared_components:
  - AppTheme
  - AppColors
  - AppSpacing
  - AppRadii
  - AppRouter
  - HaloRespirant
  - ouvrirPlaceholder (common/placeholder_screen.dart)
  - HapticFeedback
i18n_keys:
  - tutoNotifsTitre
  - tutoNotifsSousTitre
  - tutoNotifsPourquoiTitre
  - tutoNotifsPourquoiCorps
  - tutoNotifsEtape1Titre
  - tutoNotifsEtape1Corps
  - tutoNotifsEtape2Titre
  - tutoNotifsEtape2Corps
  - tutoNotifsEtape3Titre
  - tutoNotifsEtape3Corps
  - tutoNotifsCtaOuvrirReglages
  - tutoNotifsCtaRetour
  - tutoNotifsIndisponiblePlateforme
  - tutoNotifsReglagesIndisponibles
  - tutoNotifsRassurance
  - tutoNotifsAccueilLien
i18n_keys_existantes_reutilisees: []
tests: aidd_docs/tasks/tuto-notifs.tests.md (à remplir en Step 5 par Kent)
created: 2026-06-06
updated: 2026-06-06
---

# Page Plan — « Réduire mes notifications » (tutoriel in-app)

> **STATUT : `proposition_a_valider`.** Plan auto-suffisant pour l'éditeur IA. Cible :
> `apps/digiharmony_app/`. App Flutter DIGIHARMONY, public mineur, Erasmus+, **SANS backend
> ni Firebase, ZÉRO collecte**. L'écran **n'envoie rien** et **ne lit aucune donnée d'usage** :
> c'est un **tutoriel pédagogique statique** + un **CTA** qui ouvre l'écran système des réglages
> de notifications.
>
> **Design Banani NON confirmé** (MCP Banani non joignable en mode arrière-plan) et **US non
> encore créées** (Erwin idem). La structure visuelle ci-dessous est dérivée de la mémoire projet
> (design-system « Navy & Halo », ton bienveillant DEC-003) et de l'existant (`temps-ecran.md`,
> `soutien.md`). Les points à valider humainement sont regroupés en **§13 « Questions à valider »**.
> Tout ce qui est marqué 🟡 = hypothèse non confirmée.

---

## ⭐ RÉVISION (2026-06-06) — ALIGNEMENT MAQUETTE BANANI (FAIT LOI, prime sur le reste)

Maquette Banani « Tuto — Notifications » (flow `kh_4MGOGFJNA`, thème Navy & Halo) récupérée et
validée par l'utilisateur. Le tuto est un **guide pas-à-pas adapté à l'OS**, **PAS** un écran avec
bouton « ouvrir les réglages ». Conséquences :

- ❌ **DEC-TN-02 / DEC-TN-06 SUPERSEDÉES** : **AUCUN MethodChannel** `notification_settings`, **aucun
  code natif** pour le tuto, **aucune ouverture de réglages système**. (Le socle natif partagé n'a donc
  plus besoin que du channel `usage_access` de Temps d'écran.)
- ❌ **US-TN-02 abandonnée** (« ouvrir les réglages ») → remplacée par « détection OS + bascule ».
- ✅ **Écran = tutoriel statique OS-aware** :
  - Navbar standard (chevron retour · logo + « DIGIHARMONY » · menu — cohérent app).
  - Intro : `tutoNotifsIntro` « Moins de notifications, plus de calme. »
  - **Détection OS** (`Platform.isIOS`/`isAndroid`) → affiche la liste d'étapes correspondante. Lien
    discret en bas **`tutoNotifsAutreTelephone`** « Voir pour un autre téléphone » qui **bascule** la
    vue vers l'autre OS (état UI local → `StatefulWidget`, ou Bloc minimal si la revue l'exige).
  - **5 étapes iOS** + **5 étapes Android**, chaque étape = badge n° (cercle cyan) + icône (Lucide →
    `Icons` Material équivalent) + titre + description. Contenu (clés i18n, fr réels de la maquette,
    repli en) :
    - iOS : 1 Réglages · 2 Notifications · 3 Choisir une app distrayante · 4 Désactiver ou regrouper
      (« Résumé programmé ») · 5 Répéter pour chaque app.
    - Android : 1 Paramètres · 2 Applications · 3 Sélectionner une app · 4 Notifications → Désactiver ·
      5 Mode « Ne pas déranger ».
  - Carte d'**encouragement** (icône soleil or `AppColors.accentGold`) : `tutoNotifsEncouragement`
    « Chaque notification en moins, c'est une interruption de moins. Prends ton temps. »
  - Cartes étapes : fond `AppColors.surface`, rayon 12, bord léger ; tokens design-system, **aucun hex
    en dur**.
- **DEC-TN-05 confirmé** : pas de logique métier → `StatelessWidget` + le toggle OS en état UI local.
- i18n : clés `tutoNotifs*` (intro, encouragement, lien bascule, + titre/description ×10 étapes), fr+en
  réels, repli en pour el/it/ro/tr/es/mk. **Contenu pédagogique = à faire relire par les partenaires**
  (public mineur), mais issu de la maquette validée.

> Les sections §2–§15 ci-dessous décrivant le MethodChannel/CTA réglages sont **CADUQUES** ; ne garder
> que ce qui concerne la structure de page, l'i18n, l'a11y et le recâblage Accueil.

---

## 0. Garde-fous (FONT LOI — priment sur tout détail divergent ci-dessous)

- **Sans backend, sans Firebase, zéro collecte.** Aucun SDK réseau/analytics/tracking/Crashlytics.
  Le tutoriel est 100 % local. La **seule** « sortie » est l'ouverture de l'écran **système** des
  réglages de notifications (un simple `Intent` Android) : **rien n'est envoyé, rien n'est journalisé**.
- **DIGIHARMONY n'envoie AUCUNE notification.** Le but du tuto est d'aider l'ado à **réduire les
  notifications des AUTRES apps** (Instagram, jeux, etc.), pas celles de DIGIHARMONY. Ne **jamais**
  laisser entendre que l'app enverrait des notifications, ni proposer un « réglage de nos notifs ».
- **AUCUNE permission ajoutée.** Ouvrir `Settings.ACTION_NOTIFICATION_SETTINGS` /
  `ACTION_APP_NOTIFICATION_SETTINGS` est un simple `Intent` **sans permission requise**.
  La SEULE permission du projet reste `PACKAGE_USAGE_STATS` (et **elle n'est pas utilisée ici**).
  **N'ajoute aucune autre permission, aucun SDK, aucune dépendance pub.**
- **Pas de nouvelle dépendance pub.** `app_settings` n'est **PAS** au pubspec (vérifié) → **ne pas
  l'ajouter**. L'ouverture des réglages se fait via un **MethodChannel maison minimal**
  `digiharmony/notification_settings` (calqué sur le pattern `digiharmony/usage_access` de
  `temps-ecran.md`), **sans** dépendance ni permission. `url_launcher` (déjà présent) **ne peut pas**
  lancer un `Intent` système arbitraire de façon fiable → écarté pour l'ouverture des réglages (DEC-TN-02).
- **Tutoriel = contenu STATIQUE.** Aucune lecture Drift, aucune écriture Drift. **Aucun HydratedBloc**
  (pas de flag, pas d'état persistant). C'est un écran de lecture pure (DEC-TN-04).
- **Bloc-only SI un état est nécessaire** (Cubit interdit, règle `1-bloc-only-no-cubit`). Ici l'état
  utile est **minimal** (plateforme supportée ? résultat de l'ouverture des réglages). → **V1 :
  StatelessWidget + façade `ServiceReglagesNotifs` injectée** ; **pas de Bloc** (DEC-TN-05). Si un
  reviewer impose un Bloc, le squelette `TutoNotifsBloc` (2 events, enum `status`) est décrit en
  **§4.3 (option B)** pour rester conforme sans réécriture lourde.
- **i18n obligatoire** : aucune chaîne FR/EN en dur. Toutes les clés `tutoNotifs*` (§8) ajoutées dans
  les **8** ARB, `fr`+`en` réels, repli `en` (TODO) pour `el/it/ro/tr/es/mk`. Puis `flutter gen-l10n`.
- **a11y reduced-motion** : toute animation (halo) désactivable via `MediaQuery.disableAnimations`.
  Tap ≥ 48×48 dp. Contraste AA. `HapticFeedback.lightImpact()` au tap du CTA (pas de permission `VIBRATE`).
- **Couleurs via le design system** (`AppColors`/thème) — **aucun hex en dur**. `MoodColors`
  **interdit** ici (cet écran n'est pas un écran d'humeur). Espacements `AppSpacing`, rayons `AppRadii`.
- **Public mineur, ton bienveillant** (DEC-003 + design-system §garde-fous éthiques) : **pas de
  culpabilisation, pas de FOMO, pas de score, pas de comparaison/classement, pas de streak**. Le tuto
  explique **pourquoi** réduire les notifications aide à se sentir mieux, **sans** faire la morale.
- **Nommage FRANÇAIS** : dossier `lib/pages/tuto_notifs/`, classes `TutoNotifsPage`/`TutoNotifsView`/
  (`TutoNotifsBloc`/`TutoNotifsState`/`TutoNotifsEvent` si option B). Structure imposée (règle
  `0-flutter-pages-structure`) : `lib/pages/tuto_notifs/{views,widgets,services}` (+`bloc` si option B).
  Méthode de route `AppRouter.versTutoNotifs(context)`. Scaffolding technique reste anglais.
- **Android : `minify`/`shrinkResources = false`** (déjà acté Fondations) — ne rien faire qui suppose
  le contraire.

---

## 1. Contexte & objectif de la page

| Élément | Valeur |
|---|---|
| **But** | Aider l'ado à **réduire/désactiver les notifications des autres apps** de son téléphone, via un **tutoriel bienveillant** (pourquoi + comment, en quelques étapes claires) et un **CTA** qui l'amène directement à l'écran **réglages notifications du système**. Objectif bien-être : moins de sur-sollicitation, plus de calme. |
| **Accès** | Aucune auth (app sans compte). Aucune permission. Écran **empilé** (`push`, retour possible). |
| **Point d'entrée (V1 retenu)** | **Lien tertiaire sur l'Accueil**, ajouté **à côté** du lien « Mon temps d'écran » (`accueil_view.dart`, zone ~L130-151), libellé `tutoNotifsAccueilLien` (« Réduire mes notifications »), icône `Icons.notifications_off_outlined`. → `AppRouter.versTutoNotifs(context)`. **Append-only** (ajout d'un widget sœur, pas de modif d'un existant — §9). |
| **Point d'entrée (secondaire, futur)** | CTA « Réduire mes notifications » **depuis la page « Mon temps d'écran »** (`temps-ecran.md`). **Différé** : cette page est encore `proposition_a_valider` (non implémentée). À câbler quand Temps d'écran sera livré (dépendance d'intégration, §9 + Q-TN-1). 🟡 |
| **Route** | Pas de GoRouter (cohérent `AppRouter`, DEC-FND-07). Nouvelle méthode `AppRouter.versTutoNotifs(context)` en **`push`**, calquée sur `versSoutien` (pas de dépendance à transmettre : le tuto ne lit pas la DB → pas de `RepositoryProvider<AppDatabase>`). |
| **Retour** | Toolbar : chevron `Icons.chevron_left` → `Navigator.pop`. Bouton « Compris » / « Retour » en bas → `Navigator.pop`. Toolbar présente (DEC-003 : toolbar partout **sauf** splash/accueil). |
| **Périmètre plateforme** | **V1 = Android d'abord** (DEC-TN-03), cohérent projet. iOS = **état dégradé bienveillant** : le **tutoriel reste affiché** (étapes pédagogiques génériques), mais le CTA d'ouverture des réglages se comporte en best-effort (ouvre les réglages de l'app via `openAppSettings` natif, sinon message neutre). Jamais de crash. |

---

## 2. Contrainte structurante n°1 — ouverture des réglages NOTIFICATIONS (DEC-TN-02)

### 2.1 Le problème

Ouvrir un écran système précis (réglages notifications) **n'est pas** réalisable de façon fiable avec
`url_launcher` : il faut lancer un **`Intent` Android** (`Settings.ACTION_*`), ce que `url_launcher`
ne fait pas pour des intents système arbitraires. Deux options « sans nouvelle dépendance » :

| Option | Mécanisme | Permission | Dépendance | Verdict |
|---|---|---|---|---|
| **(A) MethodChannel maison `digiharmony/notification_settings`** | Code Kotlin minimal lançant l'`Intent` système | **Aucune** | **Aucune** | ✅ **RETENU** |
| (B) package `app_settings` (pub.dev) | wrapper `AppSettings.openAppSettings(type: notification)` | Aucune | **AJOUTE une dépendance** | ❌ viole « pas de nouvelle dépendance » (Q-TN-2) |
| (C) `url_launcher` + schéma intent | `app-settings:` / `android-app://` | Aucune | déjà présent | ❌ **non fiable** (pas garanti selon ROM, pas d'écran *notifications* précis) |

**Décision DEC-TN-02 : option (A)** — MethodChannel maison minimal `digiharmony/notification_settings`,
**sans dépendance ni permission**, **cohérent avec le pattern déjà acté** `digiharmony/usage_access`
(`temps-ecran.md` DEC-TE-02). Code Kotlin minuscule dans la `MainActivity` **active**.

> ⚠️ **MainActivity active = `com.creappi.digiharmony`** (namespace/applicationId = `com.creappi.digiharmony`,
> `android/app/build.gradle.kts` L17/L32 — **vérifié**). Le fichier
> `kotlin/com/creappi/digiharmony/MainActivity.kt` est celui réellement compilé.
> Le doublon `kotlin/com/creappi/digiharmony_app/MainActivity.kt` est **stale** (ne pas y câbler le channel).

### 2.2 API native du MethodChannel (option A)

Channel : `digiharmony/notification_settings`, **deux** méthodes :

- `Future<void> ouvrirReglagesNotifications()` → côté Kotlin :
  - **Préférence** : `Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)` ciblant **le téléphone en
    général** n'existe pas tel quel ; pour **toutes les apps**, l'écran le plus proche est
    `Settings.ACTION_NOTIFICATION_SETTINGS` (liste/réglages globaux de notifications, API 22+).
  - **Implémentation** : tenter `Settings.ACTION_NOTIFICATION_SETTINGS` ; en cas d'`ActivityNotFoundException`,
    **fallback** sur `Settings.ACTION_APP_NOTIFICATION_SETTINGS` (réglages notifs de DIGIHARMONY, avec
    `EXTRA_APP_PACKAGE = packageName`) ; ultime fallback `Settings.ACTION_SETTINGS` (réglages généraux).
    Toujours `addFlags(FLAG_ACTIVITY_NEW_TASK)`. Retourne normalement, ou **lève une `PlatformException`**
    si **aucun** réglage ne s'ouvre (très rare).
- `bool get plateformeSupportee` (côté Dart, **pas** un appel natif) → `Platform.isAndroid`.

> **Important (objectif du tuto)** : on veut amener l'ado vers les réglages **globaux** de notifications
> (`ACTION_NOTIFICATION_SETTINGS`), d'où il peut **choisir n'importe quelle app** et couper ses notifs.
> `ACTION_APP_NOTIFICATION_SETTINGS` (notifs de DIGIHARMONY) n'est qu'un **fallback** technique, pas le
> but — d'autant que DIGIHARMONY n'émet aucune notification. À garder cohérent avec le contenu du tuto.

### 2.3 iOS (DEC-TN-03)

- iOS ne permet pas d'ouvrir l'écran **global** des notifications d'un coup ; on peut au mieux ouvrir
  les **réglages de l'app** (`UIApplication.openSettingsURLString`). Comme DIGIHARMONY n'envoie pas de
  notifs, cet écran serait peu utile.
- **V1 iOS** : le **tutoriel reste affiché** (les étapes « Réglages → Notifications → choisir l'app →
  couper » sont génériques et pédagogiques) ; le CTA tente `openReglagesApp()` (best-effort) et, si non
  pertinent/échec, affiche le message neutre `tutoNotifsReglagesIndisponibles`. **Jamais de crash.**
  Le détail iOS est **hors V1** d'un point de vue fonctionnel (Android-first), mais l'écran **ne doit
  pas casser** sur un build iOS (le dossier `ios/` existe dans le projet).

---

## 3. Données affichées & sources

| Donnée | Source | Persistance |
|---|---|---|
| Textes du tutoriel (pourquoi + 3 étapes) | **i18n statique** (`tutoNotifs*`, §8) | — (jamais persisté) |
| Plateforme supportée (Android/iOS) | `Platform.isAndroid` (façade `ServiceReglagesNotifs`) | — |
| Résultat de l'ouverture des réglages | MethodChannel `digiharmony/notification_settings` | — (jamais persisté) |

- **DEC-TN-04 (zéro collecte / zéro persistance)** : l'écran **ne lit ni n'écrit** Drift, **n'utilise
  pas** HydratedBloc. Aucune donnée utilisateur, aucun flag. Le contenu est **statique** (i18n).
  Justification : c'est un tutoriel ; aucune raison de stocker quoi que ce soit, et zéro-collecte par
  absence de traitement.
- **Pas de Drift** : aucun modèle relationnel, aucune historisation → Drift **interdit ici** (cohérent
  CLAUDE.md : Drift = journal/conseils/agrégats uniquement). **Pas de codegen** à lancer.

---

## 4. Architecture & état (V1 sans Bloc — DEC-TN-05)

### 4.1 Façade plateforme — `ServiceReglagesNotifs` (injectée, testable)

Pour isoler la plateforme et tester sans `MethodChannel` réel (mockable via `mocktail`) :

```dart
abstract interface class ServiceReglagesNotifs {
  /// Ouvre l'écran système des réglages de notifications (Android :
  /// ACTION_NOTIFICATION_SETTINGS, fallback ACTION_APP_NOTIFICATION_SETTINGS).
  /// iOS : best-effort réglages app. Lève si rien ne s'ouvre.
  Future<void> ouvrirReglagesNotifications();

  /// True si la plateforme cible Android (ouverture des réglages globaux pertinente).
  bool get plateformeSupportee;
}
```

Implémentation concrète `ServiceReglagesNotifsImpl` :
- `ouvrirReglagesNotifications()` → `MethodChannel('digiharmony/notification_settings')
  .invokeMethod<void>('ouvrirReglagesNotifications')`.
- `plateformeSupportee` → `Platform.isAndroid` (via `dart:io`).

> Injection : `RepositoryProvider<ServiceReglagesNotifs>` fourni au moment du `push` (frontière de
> route, calqué sur `temps-ecran.md` §7). Voir §7.

### 4.2 Vue (V1) — StatelessWidget, pas de Bloc

L'écran est **statique** : le seul comportement dynamique est « au tap du CTA → appeler
`service.ouvrirReglagesNotifications()` et gérer l'erreur par SnackBar ». Cela ne justifie **pas** un
Bloc (pas de flux d'états, pas de chargement, pas de données à charger). → **V1 = `StatelessWidget`**
qui lit `ServiceReglagesNotifs` via `context.read`. **DEC-TN-05.**

Gestion du tap CTA (dans la View, méthode privée `_ouvrirReglages(context)`):
1. `HapticFeedback.lightImpact()`.
2. `try { await service.ouvrirReglagesNotifications(); }`
3. `catch (_) { ScaffoldMessenger.showSnackBar(tutoNotifsReglagesIndisponibles) }` — message neutre,
   non alarmant. **Jamais de crash.**
4. (iOS / `!plateformeSupportee`) : le CTA reste affiché mais tente le best-effort ; en cas d'échec →
   même SnackBar neutre. (Variante : masquer le CTA et afficher `tutoNotifsIndisponiblePlateforme` —
   Q-TN-3.)

### 4.3 Option B (SI un Bloc est imposé par la revue) — squelette minimal

Conserver la conformité `1-bloc-only-no-cubit` sans surcoût :

```
enum TutoNotifsStatus { pret, ouvertureEnCours, erreurOuverture }

TutoNotifsState extends Equatable { TutoNotifsStatus status; }

TutoNotifsEvent (sealed):
  - TutoNotifsDemarre              // restartable — pose status: pret (+ détecte plateforme)
  - TutoNotifsOuvrirReglages       // droppable  — appelle le service, status: ouvertureEnCours
                                   //              succès -> pret ; exception -> erreurOuverture
```

> **Recommandation : option A (sans Bloc)**. Un Bloc à 2 events pour un écran statique est du
> sur-engineering ; la façade `ServiceReglagesNotifs` suffit à la testabilité. Trancher en revue (Q-TN-4).

---

## 5. Vue(s) — structure visuelle (🟡 design Banani non confirmé)

> **Aucun hex en dur** : toutes les teintes = `AppColors`/`Theme.of(context)`. **`MoodColors` interdit
> ici.** Espacements `AppSpacing`, rayons `AppRadii`. Ton bienveillant, **jamais culpabilisant**.

### 5.1 `TutoNotifsView` — squelette

```
Scaffold (backgroundColor: AppColors.background)
 ├─ AppBar (toolbar DEC-003)
 │   ├─ leading : IconButton chevron-left (Icons.chevron_left) → Navigator.pop  (≥ 48×48)
 │   ├─ title  : logo (logo_digiharmony_square.png, hauteur réduite) centré (cohérent app)
 │   └─ actions: SizedBox d'équilibre (pas de menu agressif ici)
 └─ Stack
     ├─ HaloRespirant (décor de fond, common/widgets/halo_respirant.dart ; OFF si reduced motion)
     └─ SafeArea > SingleChildScrollView > Padding(AppSpacing.lg) > Column (crossAxis stretch)
          ├─ Icône ronde douce (Icons.notifications_off_outlined ~64px, teinte AppColors.primary)
          ├─ SizedBox(AppSpacing.lg)
          ├─ Text(tutoNotifsTitre)        titleLarge, AppColors.text, centré
          ├─ SizedBox(AppSpacing.sm)
          ├─ Text(tutoNotifsSousTitre)    bodyLarge, AppColors.textMuted, centré
          ├─ SizedBox(AppSpacing.xl)
          ├─ _BlocPourquoi()              // « Pourquoi réduire ? » (carte surface)
          ├─ SizedBox(AppSpacing.lg)
          ├─ _EtapeTuto(numero:1, ...)    // étapes « comment faire »
          ├─ _EtapeTuto(numero:2, ...)
          ├─ _EtapeTuto(numero:3, ...)
          ├─ SizedBox(AppSpacing.xl)
          ├─ ElevatedButton.icon(CTA tutoNotifsCtaOuvrirReglages) → _ouvrirReglages(context)
          ├─ SizedBox(AppSpacing.md)
          ├─ TextButton(tutoNotifsCtaRetour) → Navigator.pop      // « Compris »
          ├─ SizedBox(AppSpacing.lg)
          └─ Text(tutoNotifsRassurance)   bodySmall, AppColors.textMuted, centré
```

### 5.2 `_BlocPourquoi` (carte « pourquoi réduire »)

- Carte `AppColors.surface`, rayon `AppRadii.card`, padding `AppSpacing.md`.
- Titre `tutoNotifsPourquoiTitre` (« Pourquoi réduire les notifications ? ») + corps
  `tutoNotifsPourquoiCorps` (bienveillant : « Chaque notification capte ton attention. En réduire le
  nombre t'aide à rester concentré·e, à mieux dormir et à te sentir plus serein·e. » — **jamais** « tu
  es accro », **jamais** de FOMO).
- Icône douce optionnelle (`Icons.self_improvement` ou `Icons.spa`).

### 5.3 `_EtapeTuto` (widget réutilisable — une étape numérotée)

- Ligne : pastille numéro (cercle `AppColors.primary` atténué, texte `AppColors.text`) + colonne
  (titre `titleMedium` + corps `bodyMedium`, `AppColors.textMuted`).
- Étapes (contenu générique, valable Android/iOS — **à valider** §13) :
  - **Étape 1** `tutoNotifsEtape1*` : « Ouvre les réglages de notifications » (le CTA en bas t'y amène).
  - **Étape 2** `tutoNotifsEtape2*` : « Choisis une app qui te dérange » (réseaux, jeux…).
  - **Étape 3** `tutoNotifsEtape3*` : « Désactive ou limite ses notifications » (coupe le son, les
    bannières, ou tout).
- a11y : `Semantics(label: "Étape <n> : <titre>")`.

### 5.4 CTA principal `tutoNotifsCtaOuvrirReglages`

- `ElevatedButton.icon` (`Icons.settings`), style rempli `AppColors.primary`, rayon `AppRadii.button`.
- Tap → `_ouvrirReglages(context)` (§4.2) : `HapticFeedback` + `service.ouvrirReglagesNotifications()`
  + gestion d'erreur SnackBar. Zone ≥ 48×48.
- **iOS / plateforme non supportée** (Q-TN-3) : soit le CTA tente le best-effort (réglages app) et
  retombe sur SnackBar neutre en cas d'échec, soit on **remplace** le CTA par une ligne
  `tutoNotifsIndisponiblePlateforme`. **Décision V1 par défaut** : garder le CTA (best-effort) + SnackBar
  neutre, pour ne pas dégrader l'UX Android et rester simple. 🟡

### 5.5 Footer rassurance `tutoNotifsRassurance`

- `bodySmall`, `AppColors.textMuted`, centré : « DIGIHarmony ne t'envoie aucune notification. Ce
  réglage concerne tes autres applications. » → renforce le garde-fou « l'app n'émet pas de notifs ».

### 5.6 `HaloRespirant` & reduced motion

- Réutiliser `common/widgets/halo_respirant.dart` (déjà a11y-aware dans le projet). Si
  `MediaQuery.disableAnimations == true` → halo **statique** (pas de boucle). Ne **jamais**
  `pumpAndSettle()` en test (piège connu — wrapper `MediaQuery(disableAnimations: true)`).

---

## 6. États de la page (synthèse)

| État | Déclencheur | Rendu |
|---|---|---|
| **nominal (Android)** | ouverture de la page sur Android | tuto complet + CTA actif |
| **réglages indisponibles** | exception MethodChannel au tap CTA | SnackBar `tutoNotifsReglagesIndisponibles` (pas de crash) |
| **iOS / plateforme non supportée** | `!plateformeSupportee` | tuto affiché ; CTA best-effort OU ligne `tutoNotifsIndisponiblePlateforme` (Q-TN-3) |
| **reduced motion** | `MediaQuery.disableAnimations == true` | halo statique, reste inchangé |

- **Pas d'état « chargement »** (contenu statique, rien à charger). **Pas d'état « vide »** ni
  « erreur » bloquant. L'écran n'a pas de dépendance distante.

---

## 7. Navigation

- **Entrée** : `AppRouter.versTutoNotifs(context)` (nouvelle méthode, `push`).
- **Sortie** : chevron toolbar → `Navigator.pop` ; « Compris » (`tutoNotifsCtaRetour`) → `Navigator.pop`.
- Pas de GoRouter (DEC-FND-07).

`app_router.dart` à ajouter (calqué sur `versSoutien`, mais fournissant `ServiceReglagesNotifs` au
sous-arbre — pas de DB à transmettre) :

```dart
/// Ouvre le tutoriel « Réduire mes notifications » (empilé, retour possible).
///
/// Fournit [ServiceReglagesNotifs] au sous-arbre (frontière de route).
/// Pas de GoRouter (DEC-FND-07). Le tuto ne lit pas la base.
static Future<void> versTutoNotifs(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => RepositoryProvider<ServiceReglagesNotifs>(
        create: (_) => ServiceReglagesNotifsImpl(),
        child: const TutoNotifsPage(),
      ),
    ),
  );
}
```

> `TutoNotifsPage.route()` peut encapsuler ce `MaterialPageRoute` ; `AppRouter.versTutoNotifs` reste le
> point d'entrée canonique. Alternative : fournir le service au bootstrap si d'autres écrans le
> consomment (V1 = local à la route, mince — Q-TN-5).

---

## 8. i18n (clés ARB — 8 langues, repli `en`)

> Ajouter dans **les 8** `lib/l10n/arb/app_<lang>.arb` (template `app_en.arb`), `fr`+`en` réels,
> repli `en` (TODO traduction) pour `el/it/ro/tr/es/mk`. Puis `flutter gen-l10n`.
> **Aucune clé existante réutilisée** (vérifié : pas de libellé « notifications » réutilisable). Le
> wordmark « DigiHarmony » reste **non traduit**.

| Clé | FR (référence) | EN |
|---|---|---|
| `tutoNotifsTitre` | « Réduire mes notifications » | "Reduce my notifications" |
| `tutoNotifsSousTitre` | « Moins d'interruptions, plus de calme. » | "Fewer interruptions, more calm." |
| `tutoNotifsPourquoiTitre` | « Pourquoi les réduire ? » | "Why reduce them?" |
| `tutoNotifsPourquoiCorps` | « Chaque notification capte ton attention. En recevoir moins t'aide à rester concentré·e, à mieux dormir et à te sentir plus serein·e. » | "Every notification grabs your attention. Getting fewer helps you stay focused, sleep better and feel calmer." |
| `tutoNotifsEtape1Titre` | « Ouvre les réglages de notifications » | "Open notification settings" |
| `tutoNotifsEtape1Corps` | « Le bouton ci-dessous t'y amène directement. » | "The button below takes you straight there." |
| `tutoNotifsEtape2Titre` | « Choisis une appli qui te dérange » | "Pick an app that bothers you" |
| `tutoNotifsEtape2Corps` | « Réseaux sociaux, jeux, messageries… commence par celles qui sonnent le plus. » | "Social media, games, messaging… start with the noisiest ones." |
| `tutoNotifsEtape3Titre` | « Désactive ou limite ses notifications » | "Turn off or limit its notifications" |
| `tutoNotifsEtape3Corps` | « Coupe le son, masque les bannières, ou désactive tout. Tu peux revenir en arrière quand tu veux. » | "Mute the sound, hide banners, or turn everything off. You can undo it anytime." |
| `tutoNotifsCtaOuvrirReglages` | « Ouvrir les réglages de notifications » | "Open notification settings" |
| `tutoNotifsCtaRetour` | « Compris » | "Got it" |
| `tutoNotifsIndisponiblePlateforme` | « L'ouverture directe des réglages n'est disponible que sur Android pour le moment. » | "Opening settings directly is only available on Android for now." |
| `tutoNotifsReglagesIndisponibles` | « Impossible d'ouvrir les réglages depuis l'appli. Tu peux les trouver dans les réglages de ton téléphone. » | "Couldn't open settings from the app. You can find them in your phone's settings." |
| `tutoNotifsRassurance` | « DigiHarmony ne t'envoie aucune notification. Ce réglage concerne tes autres applications. » | "DigiHarmony never sends you notifications. This setting is about your other apps." |
| `tutoNotifsAccueilLien` | « Réduire mes notifications » | "Reduce my notifications" |

- Ton de **tous** les libellés : bienveillant, **jamais** culpabilisant (garde-fou §0). Pas de « tu es
  accro », pas de FOMO, pas de jugement.
- `tutoNotifsTitre` et `tutoNotifsAccueilLien` ont la même valeur FR/EN mais des **rôles distincts**
  (titre in-page vs libellé du lien Accueil) — garder deux clés pour découpler (cohérent avec le choix
  `temps-ecran.md` Q-TE-7). 🟡 harmoniser si une seule clé est préférée.

---

## 9. Fichiers à créer / modifier

> **Fourni par Fondations / existant (NE PAS recréer)** : `theme.dart` (`AppColors`/`AppSpacing`/
> `AppRadii`), `app_router.dart`, `common/placeholder_screen.dart` (`ouvrirPlaceholder`),
> `common/widgets/halo_respirant.dart`, `l10n/`. **Aucune dépendance pub** (rien à ajouter au pubspec).

**Créer (propre à `tuto_notifs`)** :
- `lib/pages/tuto_notifs/views/tuto_notifs_page.dart` (`TutoNotifsPage` + `route()` ; fournit la View ;
  + `BlocProvider<TutoNotifsBloc>` **uniquement si option B**).
- `lib/pages/tuto_notifs/views/tuto_notifs_view.dart` (`TutoNotifsView` : toolbar + halo + contenu tuto
  + CTA ; lit `ServiceReglagesNotifs` via `context.read`).
- `lib/pages/tuto_notifs/services/service_reglages_notifs.dart` (interface `ServiceReglagesNotifs` +
  impl `ServiceReglagesNotifsImpl` ; MethodChannel `digiharmony/notification_settings`).
- `lib/pages/tuto_notifs/widgets/etape_tuto.dart` (`_EtapeTuto` / `EtapeTuto` numérotée).
- `lib/pages/tuto_notifs/widgets/bloc_pourquoi.dart` (`_BlocPourquoi` / `BlocPourquoi`).
- *(option B uniquement)* `lib/pages/tuto_notifs/bloc/tuto_notifs_bloc.dart` / `_event.dart` /
  `_state.dart`.

**Modifier** :
- `lib/app/routing/app_router.dart` : **+** `versTutoNotifs(context)` (append-only, §7) + import de
  `TutoNotifsPage` et `ServiceReglagesNotifs`.
- `lib/pages/accueil/views/accueil_view.dart` : **ajouter un lien tertiaire sœur** sous le lien « Mon
  temps d'écran » (~après L150) — un `TextButton.icon` (icône `Icons.notifications_off_outlined`,
  label `l10n.tutoNotifsAccueilLien`, couleur `AppColors.textMuted`) → `AppRouter.versTutoNotifs(context)`.
  > ⚠️ **Dépendance d'intégration (Accueil #2)** : `accueil_view.dart` appartient au lot Accueil.
  > **Append-only** (nouveau widget, on ne touche pas l'existant). Recâbler après merge Accueil, ou
  > patch d'intégration coordonné (cf. DEC-TE-10 / DEC-SH-010 pour le précédent).
- `android/app/src/main/kotlin/com/creappi/digiharmony/MainActivity.kt` : **+** `configureFlutterEngine`
  enregistrant le `MethodChannel('digiharmony/notification_settings')` avec `ouvrirReglagesNotifications`
  (Intent système, fallbacks §2.2). **AUCUNE permission, AUCUNE dépendance.** ⚠️ **ce** fichier (package
  `com.creappi.digiharmony`), **pas** le doublon `digiharmony_app`.
- `android/app/src/main/AndroidManifest.xml` : **AUCUNE modif** (aucune permission requise).
- 8 × `lib/l10n/arb/app_<lang>.arb` : clés §8, puis `flutter gen-l10n`.
- `aidd_docs/tasks/_registry.md` : ligne `tuto-notifs` (§12).

> **N'ajouter AUCUNE dépendance pub.** **Pas de codegen Drift** (aucune modif de schéma — DEC-TN-04).

---

## 10. Conformité contraintes projet (garde-fous)

- ✅ Zéro backend / Firebase / SDK réseau / analytics / Crashlytics. Tuto 100 % local.
- ✅ **Aucune permission ajoutée** (ouverture des réglages = `Intent`, sans permission). `PACKAGE_USAGE_STATS` non utilisée ici.
- ✅ **Aucune dépendance pub ajoutée** (`app_settings` écarté ; MethodChannel maison, DEC-TN-02).
- ✅ **Pas de Drift, pas de HydratedBloc** (contenu statique, DEC-TN-04).
- ✅ Bloc-only **si** état nécessaire : V1 sans Bloc (StatelessWidget + façade) justifié (DEC-TN-05) ; option B Bloc-conforme décrite si imposée.
- ✅ i18n 8 langues, repli `en`, aucune chaîne en dur ; wordmark « DigiHarmony » non traduit.
- ✅ a11y : `MediaQuery.disableAnimations` (halo), tap ≥ 48×48, `Semantics` sur les étapes.
- ✅ Couleurs via `AppColors`/thème (jamais hex en dur) ; `MoodColors` **interdit** (pas un écran d'humeur).
- ✅ Ton bienveillant : pas de score/objectif/FOMO/comparaison/streak/culpabilisation (DEC-003).
- ✅ **DIGIHARMONY n'émet aucune notification** : le tuto cible les notifs des autres apps (footer rassurance).
- ✅ Vibration via `HapticFeedback` (pas de permission `VIBRATE`).
- ✅ Android `minify`/`shrinkResources = false` ; iOS = état dégradé bienveillant (pas de crash, DEC-TN-03).
- ✅ MethodChannel câblé dans la **bonne** MainActivity (`com.creappi.digiharmony`).

---

## 11. User Stories (dépendance — À CRÉER via Erwin)

> **Aucune US n'existe** pour cette page (Erwin non joignable en arrière-plan ; à créer et valider).

- **US-TN-01 « Apprendre à réduire mes notifications »** (milestone **Phase 2** 🟡), couvrant : lien
  Accueil → page, contenu pédagogique (pourquoi + 3 étapes), ton bienveillant, footer « l'app n'émet
  pas de notifs », a11y, i18n 8 langues.
- **US-TN-02 « Ouvrir les réglages notifications du système »**, couvrant : CTA → écran système
  notifications (Android `ACTION_NOTIFICATION_SETTINGS`, fallbacks), gestion d'échec bienveillante,
  comportement iOS dégradé, **aucune permission ajoutée**.

**Critères d'acceptation à inscrire (source des tests Kent — Step 5)** :
- AC1 : ouverture de la page (Android) → tuto complet rendu (titre, sous-titre, « pourquoi », 3 étapes, CTA, retour, rassurance).
- AC2 : tap CTA → `ServiceReglagesNotifs.ouvrirReglagesNotifications` appelé (vérifiable via mock).
- AC3 : exception à l'ouverture → SnackBar `tutoNotifsReglagesIndisponibles`, **pas de crash**.
- AC4 : **iOS / plateforme non supportée** → écran rendu sans crash ; comportement CTA dégradé conforme à Q-TN-3.
- AC5 : « Compris » et chevron → `Navigator.pop` (retour Accueil).
- AC6 : **zéro persistance** : aucune écriture/lecture Drift ni HydratedBloc (vérifier qu'aucune table/clé n'est touchée).
- AC7 : **ton non culpabilisant** : aucun libellé FOMO/score/objectif/jugement ; footer rassurance présent (« l'app n'envoie pas de notifs »).
- AC8 : `disableAnimations == true` → halo statique, écran lisible.
- AC9 : libellés traduits 8 langues (repli `en`) ; wordmark « DigiHarmony » non traduit ; aucune chaîne en dur.
- AC10 : lien Accueil « Réduire mes notifications » → `AppRouter.versTutoNotifs` (et non `ouvrirPlaceholder`).
- AC11 : a11y — étapes annoncées (`Semantics`), cibles ≥ 48×48.
- AC12 : **aucune permission ajoutée** au manifeste (test garde-fou : le manifeste ne contient que `PACKAGE_USAGE_STATS`).

---

## 12. Registry & coordination

- Ajouter dans `aidd_docs/tasks/_registry.md` :
  `| [tuto-notifs.md](./tuto-notifs.md) | Réduire mes notifications (tutoriel in-app + CTA réglages système, MethodChannel digiharmony/notification_settings) | US-TN-01/02 (à créer) | Phase 2 🟡 | Fondations (#3), Accueil (#2), [Temps d'écran (entrée secondaire)] | tuto-notifs.tests.md ⏳ | proposition_a_valider |`
- **Composants consommés** : `AppTheme`/`AppColors`/`AppSpacing`/`AppRadii`, `AppRouter`,
  `HaloRespirant`, `ouvrirPlaceholder`, `HapticFeedback`. **Introduit ici (réutilisable)** :
  `ServiceReglagesNotifs` (façade plateforme), `EtapeTuto` (widget étape numérotée).
- **Coordination** :
  - `accueil_view.dart` = ajout d'un lien sœur **append-only**, après merge Accueil (#2) — même pattern
    que DEC-TE-10 / DEC-SH-010 (`noter-humeur`/`temps-ecran`).
  - `app_router.dart` = ajout `versTutoNotifs` **append-only**.
  - `MainActivity.kt` (`com.creappi.digiharmony`) = ajout `configureFlutterEngine` + channel. **Risque
    de collision** si `temps-ecran.md` (channel `digiharmony/usage_access`) câble aussi cette
    MainActivity : **les deux channels doivent cohabiter** dans le **même** `configureFlutterEngine`
    (1 override, N channels). Le premier des deux plans implémenté crée `configureFlutterEngine` ;
    le second **ajoute** son channel sans réécrire (append-only). **Flag de coordination DEC-TN-06.**
  - **Pas de collision Drift** (aucune modif schéma). **Pas de collision pubspec** (aucune dépendance).

---

## 13. Questions à valider

> ✅ **TRANCHÉES (2026-06-06) — plan `valide`** (scope confirmé par l'utilisateur) :
> - **Q-TN-1** : V1 = entrée **depuis l'Accueil** (lien sœur de « Mon temps d'écran ») ; entrée depuis la
>   page Temps d'écran = câblage différé append-only quand elle sera livrée.
> - **Q-TN-3** (iOS) : CTA **best-effort** + SnackBar si indisponible (pas de masquage).
> - **Q-TN-4** : V1 **sans Bloc** (`StatelessWidget` + façade `ServiceReglagesNotifs` mockable).
> - **Q-TN-6** : cible = notifs des **AUTRES apps** (réglages **globaux** `ACTION_NOTIFICATION_SETTINGS`) ;
>   DIGIHARMONY n'envoie aucune notif.
> - **Q-TN-7** : contenu pédagogique (étapes + « pourquoi ») = **placeholders i18n marqués à valider**
>   par les partenaires (public mineur) ; design dérivé de la mémoire.
> ⚠️ **Socle natif partagé** : le MethodChannel doit être câblé dans la **MainActivity active**
> (`com.creappi.digiharmony`) — pas le doublon stale — et **cohabiter** avec celui de Temps d'écran
> dans un seul `configureFlutterEngine` (DEC-TN-02/06).

### Historique des questions (résolues — traçabilité)

> Banani (design) et Erwin (US) **non joignables en mode arrière-plan** → ces points sont des
> **hypothèses raisonnables** dérivées de la mémoire projet, à confirmer avant implémentation.

- **Q-TN-1 (point d'entrée)** : V1 retenu = **lien tertiaire sur l'Accueil** (sœur de « Mon temps
  d'écran »). L'entrée **« Réduire mes notifications » depuis la page Temps d'écran** est **différée**
  (page non implémentée). Confirmer : Accueil seul en V1 ? ou attendre/aussi câbler depuis Temps d'écran ?
- **Q-TN-2 (mécanisme d'ouverture des réglages)** : retenu = **MethodChannel maison
  `digiharmony/notification_settings`** (option A), **sans dépendance ni permission**, cohérent avec
  `digiharmony/usage_access`. OK pour ajouter ~15 lignes de Kotlin dans `MainActivity` ? (alternative
  `app_settings` rejetée car nouvelle dépendance — confirmer ce rejet).
- **Q-TN-3 (comportement iOS / CTA)** : V1 par défaut = **CTA gardé** (best-effort `openSettings`) +
  SnackBar neutre si échec. Alternative : **masquer le CTA** sur iOS et afficher
  `tutoNotifsIndisponiblePlateforme`. Lequel préfères-tu ? (Android-first acté ; iOS ne doit pas crasher.)
- **Q-TN-4 (Bloc ou pas)** : V1 par défaut = **StatelessWidget + façade** (pas de Bloc, écran statique,
  DEC-TN-05). La revue préfère-t-elle un `TutoNotifsBloc` minimal (option B) pour homogénéité avec les
  autres pages, malgré l'absence de flux d'états ?
- **Q-TN-5 (portée du provider `ServiceReglagesNotifs`)** : V1 = fourni **local à la route**. Le remonter
  au bootstrap si d'autres écrans l'utilisent. OK local V1 ?
- **Q-TN-6 (cible exacte de l'Intent)** : retenu = `ACTION_NOTIFICATION_SETTINGS` (réglages **globaux**
  de notifs, d'où on choisit n'importe quelle app) avec fallback `ACTION_APP_NOTIFICATION_SETTINGS`.
  Confirmer que l'objectif est bien les notifs des **autres** apps (et pas celles de DIGIHARMONY, qui
  n'en émet pas).
- **Q-TN-7 (contenu pédagogique)** : nombre d'étapes (3 proposées), formulations, et la carte
  « pourquoi » sont des **propositions** (à valider, surtout vis-à-vis du **public mineur** Erasmus+ —
  ton, exactitude des étapes selon versions Android). Le design Banani exact n'a pas été récupéré.
- **Q-TN-8 (milestone)** : supposé **Phase 2** 🟡 (cohérent avec Temps d'écran). À confirmer pour le registre.
- **Q-TN-9 (deux clés titre/lien)** : `tutoNotifsTitre` et `tutoNotifsAccueilLien` ont la même valeur.
  Garder 2 clés (découplage) ou n'en garder qu'une ?

---

## 14. Décisions tranchées (DEC-TN)

| ID | Décision |
|---|---|
| DEC-TN-01 | Écran = **tutoriel in-app statique** (pourquoi + étapes) **+ CTA** ouvrant les réglages notifications système. Aucune lecture de données d'usage, aucune notification émise par l'app. |
| DEC-TN-02 | Ouverture des réglages via **MethodChannel maison `digiharmony/notification_settings`** (option A), **sans dépendance pub ni permission**. `app_settings` rejeté (nouvelle dépendance) ; `url_launcher` rejeté (intents système non fiables). Câblé dans `MainActivity` package **`com.creappi.digiharmony`** (active). |
| DEC-TN-03 | **V1 Android-first** : `ACTION_NOTIFICATION_SETTINGS` (+ fallbacks `ACTION_APP_NOTIFICATION_SETTINGS` → `ACTION_SETTINGS`). iOS = **état dégradé bienveillant** (tuto affiché, CTA best-effort, jamais de crash). |
| DEC-TN-04 | **Zéro persistance** : pas de Drift, pas de HydratedBloc, pas de flag. Contenu 100 % statique (i18n). |
| DEC-TN-05 | **V1 sans Bloc** : `StatelessWidget` + façade `ServiceReglagesNotifs` injectée (mockable). Écran statique → un Bloc serait du sur-engineering. Option B (Bloc minimal 2 events) décrite si la revue l'impose (Q-TN-4). |
| DEC-TN-06 | **Coordination MainActivity** : si `temps-ecran.md` câble aussi un channel dans la même `MainActivity`, les deux channels **cohabitent** dans un **unique** `configureFlutterEngine` (append-only, premier plan implémenté crée la méthode). |
| DEC-TN-07 | Présentation **non culpabilisante** (DEC-003) : pas de FOMO/score/objectif/streak ; footer rassurance « l'app n'émet aucune notification ». |
| DEC-TN-08 | Navigation `AppRouter.versTutoNotifs` en `push` (DEC-FND-07, pas de GoRouter). Entrée V1 = lien Accueil sœur de « Mon temps d'écran » (append-only). Entrée depuis Temps d'écran = différée (page non livrée). |
| DEC-TN-09 | **Aucune permission, aucune dépendance pub ajoutée.** Manifeste inchangé. |

---

## 15. Auto-challenge (points signalés)

- ✅ **`app_settings` n'est PAS au pubspec** (vérifié) → option (A) MethodChannel maison confirmée
  comme la seule conforme à « pas de nouvelle dépendance ». DEC-TN-02.
- ✅ **MainActivity active = `com.creappi.digiharmony`** (namespace/applicationId vérifiés dans
  `build.gradle.kts`). Le doublon `com.creappi.digiharmony_app/MainActivity.kt` est **stale** → ne pas
  y câbler le channel (erreur silencieuse garantie sinon).
- ⚠️ **Collision potentielle `MainActivity`** avec le channel `digiharmony/usage_access` de
  `temps-ecran.md` → résolue par DEC-TN-06 (un seul `configureFlutterEngine`, channels additifs).
- ⚠️ **`ACTION_NOTIFICATION_SETTINGS` ouvre les réglages GLOBAUX** (pas l'app) — c'est **voulu** (but =
  notifs des autres apps). Bien distinguer du fallback app-spécifique (Q-TN-6).
- ⚠️ **iOS réellement déclaré** (dossier `ios/` présent) → l'état dégradé n'est pas théorique : le CTA
  **doit** gérer `!Platform.isAndroid` sans crash (DEC-TN-03).
- ⚠️ **Tests + halo animé** : `HaloRespirant` (boucle) → ne **jamais** `pumpAndSettle()` (piège
  testing.md) ; wrapper `MediaQuery(disableAnimations: true)`.
- ⚠️ **Tester l'ouverture des réglages** sans natif : mocker `ServiceReglagesNotifs` (façade) — ne pas
  invoquer le vrai `MethodChannel` en test widget (AC2/AC3).
- 🟡 **Design + US + contenu pédagogique non confirmés** : tout le §13 reste ouvert ; ce plan est
  `proposition_a_valider`. Contenu sensible (public mineur) → relecture humaine du ton et des étapes.
- 🔁 **Réutilisations** : `HaloRespirant`, `ouvrirPlaceholder`, toolbar (calquée app), pattern
  d'injection de dépendance à travers la route et façade plateforme (calqués `temps-ecran.md`).
  Channel calqué sur `digiharmony/usage_access`. Pas de duplication injustifiée.
