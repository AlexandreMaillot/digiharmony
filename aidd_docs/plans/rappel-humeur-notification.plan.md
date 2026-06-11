---
objective: Permettre à l'utilisateur de recevoir une notification locale quotidienne, paramétrable (heure + activation), pour lui rappeler de noter son humeur — 100 % locale, zéro collecte, zéro réseau — avec opt-in explicite (page priming avant permission native), invitation one-shot à la 1re saisie, et skip des jours déjà notés (dérivé de Drift).
success_condition: >
  Depuis apps/digiharmony_app/ : `dart run build_runner build --delete-conflicting-outputs`
  régénère sans conflit (modèle Drift touché en M1), `flutter gen-l10n` génère sans erreur,
  `flutter analyze` passe à 0 warning/info (very_good_analysis + bloc_lint), et
  `flutter test` est vert. Critères vérifiables :
  (1) Section « Rappel » dans Paramètres : toggle activer/désactiver + time picker (visible/actif si activé) ;
  (2) quand activé + permission accordée, une notification locale quotidienne à l'heure choisie ; son tap ouvre la saisie d'humeur (AppRouter.versSaisieHumeur) ;
  (3) skip si l'humeur du jour est déjà notée (dérivé Drift), replanification au lendemain ; replanification déclenchée au démarrage/résumé app, après saisie réussie, et au changement de réglage ;
  (4) aucun rappel planifié tant que non explicitement activé (désactivé par défaut, pas d'activation à l'install) ;
  (5) invitation one-shot à la 1re saisie réussie uniquement (flag persistant HydratedBloc) ;
  (6) page UI priming maison affichée AVANT la demande de permission native ; permission demandée seulement après action explicite ;
  (7) refus permission → pas de crash, toggle reflète l'état réel, message bienveillant guidant vers les réglages OS ;
  (8) réglages (activé + heure) persistés via HydratedBloc, jamais Drift, jamais dupliqués ; « déjà noté » reste dérivé de Drift ;
  (9) aucune chaîne UI en dur (clés rappel*/priming* fr+en réels, repli en pour el/it/ro/tr/es/mk) ;
  (10) aucun SDK réseau/analytics ajouté ; seules deps `flutter_local_notifications` + `timezone` ; permission POST_NOTIFICATIONS (Android 13+) + autorisation iOS via plugin ; build Android release inchangé (minify/shrinkResources restent false) ;
  (11) service de notifications abstrait derrière une interface mockable (aucune dépendance OS réelle en test ; storage HydratedBloc mocké comme dans les tests existants).
iteration: 0
created_at: 2026-06-11
source: aidd_docs/specs/rappel-humeur.spec.md
---

# Plan exécutable — « Rappel quotidien d'humeur » (notification locale paramétrable)

> Source de vérité : `aidd_docs/specs/rappel-humeur.spec.md` (status: drafted). Ce plan ne
> ré-invente rien ; il ordonne l'implémentation en milestones livrables et testables. Les
> critères d'acceptation du frontmatter de la spec **font loi**. Les décisions produit (spec
> §« Décisions produit validées ») sont honorées telles quelles et **ne sont pas rediscutées**.

## État des dépendances (vérifié sur disque, branche `main`)

| Dépendance | Attendu | Présent ? | Emplacement |
| --- | --- | --- | --- |
| `flutter_local_notifications` + `timezone` (pubspec) | à AJOUTER | ⛔ absents (`grep` pubspec = 0) | M0 |
| Permission `POST_NOTIFICATIONS` (AndroidManifest) | à AJOUTER | ⛔ absente (perms actuelles : `PACKAGE_USAGE_STATS`, `WAKE_LOCK`, `FOREGROUND_SERVICE*`) | M0 |
| Clés notif iOS / init Darwin | à CONFIG via plugin | ⛔ `Info.plist` n'a aucune clé notif (`UIBackgroundModes` présent pour l'audio uniquement) | M0 |
| Pattern HydratedBloc (`fromJson`/`toJson`) | modèle à copier | ✅ | `lib/locale/locale_bloc.dart:14` (+ `_event.dart`/`_state.dart`) |
| Injection bloc (MultiBlocProvider) | point d'ajout | ✅ | `lib/app/view/app.dart:27` (BlocProvider empilés) |
| Bootstrap storage HydratedBloc + hooks injectables | point d'init notif | ✅ | `lib/bootstrap.dart` (`storageBuilder`/`databaseBuilder`/`audioInit` injectables — même mécanisme pour `notifInit`) |
| Page Paramètres (sections empilées) | point d'ajout section | ✅ | `lib/pages/parametres/views/parametres_view.dart:72` (Column de sections) |
| Pattern d'une section Paramètres | modèle à copier | ✅ | `lib/pages/parametres/widgets/section_langue.dart` (BlocBuilder + titre + corps) |
| Toggle/switch existant | aucun | ⛔ absent → **définir le pattern** | M5 |
| `SaisieHumeurBloc` émet `EnregistrementReussi` après UPSERT | hook one-shot | ✅ | `lib/pages/saisie_humeur/bloc/saisie_humeur_bloc.dart:80` (état `EnregistrementReussi` `:47` du state) |
| Route saisie (tap notif → saisie) | cible deeplink | ✅ | `AppRouter.versSaisieHumeur` `lib/app/routing/app_router.dart:48` |
| `observerDerniereHumeurDuJour()` (réactif) | base du « déjà noté » | ✅ | `lib/data/local/app_database.dart:387` (bornes `[minuit, minuit+1j)`, borne haute exclue) |
| Méthode « humeur du jour déjà notée ? » (lecture seule ponctuelle) | à AJOUTER | ⛔ absente (seul `aDeclencherSoutien()` renvoie `Future<bool>`) | M1 |
| i18n 8 langues (ARB + gen-l10n) | infra existante | ✅ | `lib/l10n/arb/app_*.arb`, conso `context.l10n` |

**Écart bloquant : aucun.** L'infra de notifications est absente (attendu) ; tout le reste
(HydratedBloc, bootstrap injectable, point d'injection, hook saisie, route saisie, lecture Drift
du jour) est en place. Une seule lecture Drift ponctuelle manque (« déjà noté ? ») → ajoutée en M1,
**en lecture seule, sans bump de schéma**.

---

## M — MUST (périmètre V1, font loi)

- **Dépendances** : `flutter_local_notifications` + `timezone` ajoutés (local-only). Init timezone
  + plugin dans `bootstrap.dart` via un hook **injectable** (no-op en test). Permission
  `POST_NOTIFICATIONS` déclarée (Android 13+) ; iOS via `DarwinInitializationSettings`.
- **Build Android release inchangé** : `minify`/`shrinkResources` restent `false` (CLAUDE.md).
- **Service notifications abstrait** derrière une interface (`ServiceRappel` / `RappelPort`)
  mockable ; l'implémentation réelle enveloppe `flutter_local_notifications`. Aucune dépendance OS
  réelle en test.
- **Lecture Drift « déjà noté »** : méthode lecture seule `humeurDuJourEstNotee({DateTime? jour})`
  (dérivée des bornes existantes), **sans** duplication dans HydratedBloc, **sans** bump de schéma.
- **`RappelBloc` (HydratedBloc)** : état `{ actif: bool (défaut false), heure: TimeOfDay/{hh,mm}
  (défaut raisonnable), permissionRefusee: bool, invitationDejaProposee: bool }`. `fromJson`/`toJson`
  calqués sur `LocaleBloc`. Bloc-only (jamais Cubit). Réglages **jamais** dans Drift.
- **Désactivé par défaut**, aucune planification à l'install. Activation uniquement après opt-in
  explicite passant par la **page priming** puis la permission native.
- **Page priming maison** (route empilée) affichée **avant** toute demande de permission native ;
  bouton explicite déclenchant la demande. Pas de permission silencieuse.
- **Section « Rappel » dans Paramètres** : toggle activer/désactiver + time picker (natif), visible/
  actif quand activé. Reflète toujours l'état réel (y compris permission refusée).
- **Planification + skip si déjà noté** : mécanisme OS choisi = **one-shot replanifié à fenêtre
  glissante d'1 jour** (voir « Décision DEC-R-04 » ci-dessous). Replanification déclenchée au
  minimum : démarrage/résumé app, après saisie réussie, au changement de réglage (toggle/heure).
- **Tap notification → saisie d'humeur** : payload/route → `AppRouter.versSaisieHumeur`.
- **Invitation one-shot** : à la 1re saisie réussie de la vie de l'app **uniquement** (flag
  persistant `invitationDejaProposee`), proposer (une seule fois) d'activer le rappel → renvoie vers
  la page priming.
- **Gestion du refus** : permission refusée/révoquée → pas de crash, toggle revient/affiche
  désactivé, `permissionRefusee = true`, message bienveillant expliquant comment réactiver via les
  réglages OS. Pas de boucle.
- **i18n** : toutes les chaînes en clés ARB ; `rappel*`/`priming*`/`rappelInvitation*` fr + en réels,
  repli `en` pour `el/it/ro/tr/es/mk`.
- **Tests** : interface notif mockée (aucun canal OS réel), storage HydratedBloc mocké (comme
  `test/locale/locale_bloc_test.dart`), Drift en mémoire pour `humeurDuJourEstNotee`.

## C — COULD (souhaitable, non bloquant si M complet)

- Note discrète « rappel 100 % local & privé » sur la page priming et/ou la section Paramètres.
- a11y : `Semantics` sur le toggle et le sélecteur d'heure, cibles ≥ 48dp, respect reduced-motion
  pour toute animation de la page priming (rendu statique par défaut).
- Affichage de l'heure formatée locale-aware (`MaterialLocalizations.formatTimeOfDay`).

## D — DON'T (interdits absolus — CLAUDE.md + DEC-001/002 + spec « Hors périmètre »)

- ❌ Aucun SDK réseau/analytics/tracking/Crashlytics, aucun FCM, aucun push distant, aucune
  planification serveur. Notifications **100 % locales**.
- ❌ Aucune permission au-delà de `POST_NOTIFICATIONS` (et autorisation iOS via plugin). Pas de
  `VIBRATE`, pas de `RECEIVE_BOOT_COMPLETED` ajouté sans nécessité (voir DEC-R-04 : non requis).
- ❌ `minify`/`shrinkResources` ne passent **jamais** à `true` (R8 strippe Drift/sqlite3 natif).
- ❌ Réglages (activé/heure) **jamais** dans Drift ni dupliqués ; « déjà noté » **jamais** dupliqué
  dans HydratedBloc — toujours dérivé de Drift (DEC-001/002).
- ❌ Aucune activation par défaut / silencieuse ; aucune demande de permission **avant** la page
  priming.
- ❌ Aucune invitation répétée : strictement one-shot à la 1re saisie (flag persistant).
- ❌ Pas de rappels multiples / horaires multiples / jours de semaine sélectionnables (1 rappel/jour).
- ❌ Pas de notifications riches (actions/images), pas de son/canal custom au-delà du minimum requis.
- ❌ Pas de refonte de la page `tuto_notifs` existante (sans rapport).
- ❌ Aucune chaîne FR/EN en dur dans les widgets.
- ❌ Cubit interdit (`1-bloc-only-no-cubit`) — `HydratedBloc<Event, State>` / `Bloc`.
- ❌ Aucune écriture Drift par cette feature (lecture seule de l'humeur du jour).

---

## Table de règles projet applicables

| Règle | Application dans cette feature | Vérification |
| --- | --- | --- |
| Zéro collecte / zéro réseau | Seules deps `flutter_local_notifications` + `timezone` (local) ; aucun import réseau/analytics | review imports + pubspec diff |
| Permissions minimales | Seule `POST_NOTIFICATIONS` ajoutée ; iOS via plugin ; pas de `VIBRATE`/`BOOT` | diff `AndroidManifest.xml` / `Info.plist` |
| Android release inchangé | `minify`/`shrinkResources` restent `false` | diff `android/app/build.gradle(.kts)` |
| HydratedBloc pour état léger | `RappelBloc extends HydratedBloc` ; modèle `LocaleBloc` ; réglages persistés là | review `fromJson`/`toJson` ; test hydratation |
| Journal/agrégats jamais hors Drift | « déjà noté » dérivé de `humeurDuJourEstNotee` ; rien dupliqué dans le state hydraté | review state ; review absence de copie |
| Bloc-only + transformers explicites | `RappelBloc` ; transformers (`sequential`/`restartable`/`droppable` selon event) | `bloc_lint` ; review imports `bloc_concurrency` |
| Couche données en français | Méthode `humeurDuJourEstNotee` ; conventions `observer*`/lecture | review noms |
| i18n obligatoire (gen-l10n, 8 langues) | Toute chaîne via ARB ; `rappel*`/`priming*` fr+en réels, repli `en` pour 6 langues | `grep` littéraux ; `flutter gen-l10n` OK |
| Service abstrait/mockable | Interface `ServiceRappel` ; impl. réelle enveloppe le plugin ; mock en test | review ; tests sans canal OS |
| Bootstrap : storage AVANT runApp | `RappelBloc` hydraté → storage déjà affecté ; init notif via hook injectable | review `bootstrap.dart` ordre |
| Pages `lib/pages/<page>/{bloc,views,widgets}` + `page()`/`route()` | Page priming dans une page dédiée ; section Paramètres en widget | review structure |
| Lints stricts 0 warning/info | `very_good_analysis` + `bloc_lint` | `flutter analyze` |
| Codegen avant tests | `build_runner` après ajout de `humeurDuJourEstNotee` (DataClass regen sûr) | commande M1 |
| reduced-motion (si animation priming) | `MediaQuery.disableAnimations` → rendu statique | test widget |

---

## Décisions de planification (font foi pour l'implémentation)

- **DEC-R-01 — Emplacement** : `lib/rappel/` pour le `RappelBloc` (+ `_event.dart`/`_state.dart`,
  calqué sur `lib/locale/`) ; `lib/services/rappel/` pour l'interface `ServiceRappel` + son
  implémentation `ServiceRappelNotifications` (enveloppe `flutter_local_notifications`). Page priming
  dans `lib/pages/rappel_priming/` (structure `views/`/`widgets/`). Section Paramètres dans
  `lib/pages/parametres/widgets/section_rappel.dart`.
- **DEC-R-02 — Réglages en HydratedBloc, jamais Drift** (spec décision 7 + DEC-002). Le state
  hydraté ne contient **que** `actif`, `heure`, `permissionRefusee`, `invitationDejaProposee`. Le
  « déjà noté » n'est jamais stocké : il est lu à la demande via Drift.
- **DEC-R-03 — Hook one-shot dans la couche UI saisie, pas dans `SaisieHumeurBloc`** : un
  `BlocListener<SaisieHumeurBloc>` sur `EnregistrementReussi` déclenche (si
  `!invitationDejaProposee`) l'invitation, puis pose le flag. Garde `SaisieHumeurBloc` inchangé
  (séparation des responsabilités ; pas de couplage notif dans le bloc saisie).
- **DEC-R-04 — Mécanisme de récurrence + skip = one-shot replanifié (fenêtre glissante 1 jour)**.
  Justification : `zonedSchedule` avec `DateTimeComponents.time` (daily-repeat natif) **ne sait pas
  sauter conditionnellement** un jour déjà noté ; annuler/replanifier un daily-repeat est fragile et
  dépendant de l'OS. Le **one-shot replanifié** est le plus fiable et le plus simple à honorer
  « skip si déjà noté » : à chaque point de replanification (démarrage/résumé app, après saisie
  réussie, au changement toggle/heure), on **annule** la notif en attente puis on **planifie une
  seule** notif à la prochaine occurrence pertinente — c.-à-d. aujourd'hui à l'heure choisie si
  l'humeur du jour n'est pas encore notée **et** l'heure n'est pas passée, sinon demain à l'heure
  choisie. Au résumé d'app suivant, on re-planifie de nouveau. Cela **évite** d'avoir besoin de
  `RECEIVE_BOOT_COMPLETED` (la replanification au démarrage couvre le cas reboot) et reste
  entièrement local. Le `ServiceRappel` expose `planifierProchainRappel({required heure, required
  dejaNoteAujourdhui})` et `annulerTout()`.
- **DEC-R-05 — Forme de l'invitation one-shot et de la page priming** : invitation = `bottom sheet`
  modale (non bloquante, dismiss = ne rien activer) renvoyant vers la **page priming empilée**
  (`AppRouter.versRappelPriming`). La permission native n'est demandée **que** depuis la page priming,
  via bouton explicite. (Cohérent spec décision 5.)
- **DEC-R-06 — Toggle reflète l'état réel** : activer le toggle déclenche le flux priming→permission ;
  si refus, `actif` repasse à `false` et `permissionRefusee = true` (message OS-settings). Désactiver
  le toggle → `annulerTout()` + `actif = false`. À chaque ouverture de Paramètres / résumé app, on
  reconcilie l'état du plugin (permission OS réelle) avec le state pour éviter un toggle « activé »
  alors que la permission a été révoquée côté OS.

---

## Phases (milestones)

Ordre d'implémentation sûr : deps/plateforme → données → service+state → bootstrap/injection →
i18n → UI priming → UI Paramètres → invitation one-shot → a11y/polish + validation globale.
Chaque milestone est un commit logique. **`flutter analyze` + `flutter test` doivent rester verts
à chaque milestone.**

### M0 — Dépendances + configuration plateforme

**Objectif** : ajouter les deux deps locales et déclarer les permissions/init plateforme, sans logique.

**Fichiers touchés**
- `apps/digiharmony_app/pubspec.yaml` (ajout `flutter_local_notifications`, `timezone`)
- `apps/digiharmony_app/android/app/src/main/AndroidManifest.xml` (ajout `<uses-permission POST_NOTIFICATIONS>`)
- `apps/digiharmony_app/ios/Runner/Info.plist` (si requis par le plugin ; sinon init via Darwin settings)
- `apps/digiharmony_app/android/app/build.gradle` ou `build.gradle.kts` (**vérifier** que `minify`/`shrinkResources` restent `false` — ne pas modifier la valeur)
- `pubspec.lock` racine (régénéré par `flutter pub get`)

**Travail**
- Ajouter les deps (versions compatibles Flutter du projet, resolution workspace).
- Déclarer `POST_NOTIFICATIONS` (Android 13+).
- Confirmer R8 désactivé (lecture seule, ne pas changer).

**Critères d'acceptation**
- `flutter pub get` résout sans conflit ; seules ces 2 deps ajoutées, aucune dep réseau/analytics.
- `POST_NOTIFICATIONS` présent, aucune autre permission ajoutée.
- `minify`/`shrinkResources` toujours `false`.

**Validation** (depuis `apps/digiharmony_app/`)
```
flutter pub get
flutter analyze
```

### M1 — Couche données : lecture « humeur du jour déjà notée »

**Objectif** : exposer un booléen lecture seule, dérivé des bornes Drift existantes.

**Fichiers touchés**
- `apps/digiharmony_app/lib/data/local/app_database.dart` (ajout `humeurDuJourEstNotee`)
- `apps/digiharmony_app/test/data/local/app_database_test.dart` (ou fichier de test Drift existant)

**Travail**
- `Future<bool> humeurDuJourEstNotee({DateTime? jour})` : bornes `[minuit, minuit+1j)` du jour donné
  (défaut `DateTime.now()`), `isBiggerOrEqualValue(start) & isSmallerThanValue(end)`, borne haute
  **exclue**, sans post-filtrage, `LIMIT 1` → `true` si une entrée existe. Mêmes conventions exactes
  que `observerDerniereHumeurDuJour` (`app_database.dart:387`). Docstring français.
- **Aucun** changement de version de schéma (lecture seule).

**Critères d'acceptation**
- Jour avec entrée → `true` ; jour sans entrée → `false` ; entrée à `minuit` incluse, entrée à
  `minuit+1j` exclue. Aucun bump de schéma.

**Validation** (depuis `apps/digiharmony_app/`)
```
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test test/data/local/app_database_test.dart
```

### M2 — Service notifications abstrait (interface + impl mockable)

**Objectif** : isoler le plugin OS derrière une interface mockable ; aucune dépendance OS en test.

**Fichiers touchés**
- `apps/digiharmony_app/lib/services/rappel/service_rappel.dart` (interface)
- `apps/digiharmony_app/lib/services/rappel/service_rappel_notifications.dart` (impl `flutter_local_notifications` + `timezone`)
- `apps/digiharmony_app/test/services/rappel/service_rappel_test.dart` (mock de l'interface ; vérifie le contrat, pas le plugin)

**Travail**
- Interface `ServiceRappel` :
  - `Future<bool> demanderPermission()` (renvoie l'état accordé/refusé)
  - `Future<bool> permissionAccordee()` (réconciliation état OS réel)
  - `Future<void> planifierProchainRappel({required TimeOfDay heure, required bool dejaNoteAujourdhui})`
    (one-shot prochaine occurrence pertinente, DEC-R-04 ; calcule aujourd'hui/demain)
  - `Future<void> annulerTout()`
  - `Future<void> initialiser()` (timezone + init plugin + Darwin settings + handler de tap → payload route saisie)
- Impl. `ServiceRappelNotifications` enveloppe le plugin ; canal minimal, pas de son/canal custom élaboré.
- Tap notif → payload identifiant la route saisie ; le routage effectif est branché en M4/bootstrap.

**Critères d'acceptation**
- L'interface est entièrement mockable (aucun `import` OS dans les tests via le mock).
- Contrat testé : `planifierProchainRappel(dejaNoteAujourdhui: true)` cible **demain** ;
  `false` + heure non passée cible **aujourd'hui** ; `false` + heure passée cible **demain**
  (testé sur le calcul de date, pas sur le canal OS).
- `annulerTout` documenté comme annulant toute notif en attente.

**Validation**
```
flutter analyze
flutter test test/services/rappel/service_rappel_test.dart
```

### M3 — `RappelBloc` (HydratedBloc) : state, events, persistance

**Objectif** : orchestrer activation/heure/permission/invitation + appels au `ServiceRappel`.

**Fichiers touchés**
- `apps/digiharmony_app/lib/rappel/rappel_bloc.dart`
- `apps/digiharmony_app/lib/rappel/rappel_event.dart`
- `apps/digiharmony_app/lib/rappel/rappel_state.dart`
- `apps/digiharmony_app/test/rappel/rappel_bloc_test.dart`

**Travail**
- `RappelState` (Equatable) : `actif` (bool, défaut `false`), `heure` (sérialisable `{hh,mm}`, défaut
  raisonnable ex. 20:00), `permissionRefusee` (bool, défaut `false`), `invitationDejaProposee` (bool,
  défaut `false`). `copyWith` + `props`. `fromJson`/`toJson` calqués sur `LocaleBloc` (`locale_bloc.dart:33-42`).
- `RappelEvent` (sealed) :
  - `RappelActivationDemandee` (depuis priming, après permission accordée) → `actif=true`, replanifie.
  - `RappelDesactive` → `actif=false`, `annulerTout()`.
  - `RappelHeureChangee(TimeOfDay)` → maj heure, replanifie si actif.
  - `RappelPermissionRefusee` → `actif=false`, `permissionRefusee=true`.
  - `RappelReplanificationDemandee` (démarrage/résumé/après saisie) → lit `humeurDuJourEstNotee` puis
    `planifierProchainRappel(...)` si actif & permission OK ; réconcilie permission OS.
  - `RappelInvitationProposee` → pose `invitationDejaProposee=true` (one-shot).
- Le bloc reçoit `ServiceRappel` + un lecteur Drift (`humeurDuJourEstNotee`) par injection (mockés en test).
- Transformers explicites (`sequential` pour mutations d'état, `droppable`/`restartable` selon besoin).
- Erreur service → ne pas crasher ; le state reste cohérent.

**Critères d'acceptation**
- Hydratation : `toJson`→`fromJson` round-trip préserve `actif`/`heure`/`permissionRefusee`/`invitationDejaProposee` (storage mocké comme `test/locale/locale_bloc_test.dart`).
- Défaut à froid : `actif=false`, `invitationDejaProposee=false` (pas d'activation install).
- `RappelActivationDemandee` → `actif=true` + `planifierProchainRappel` appelé.
- `RappelDesactive` → `actif=false` + `annulerTout` appelé.
- `RappelHeureChangee` (actif) → replanification appelée avec la nouvelle heure.
- `RappelPermissionRefusee` → `actif=false`, `permissionRefusee=true`, pas de crash.
- `RappelReplanificationDemandee` avec `humeurDuJourEstNotee=true` → planifie pour **demain** (via service).
- `RappelInvitationProposee` → `invitationDejaProposee=true` (idempotent : 2e appel = no-op visible).
- Aucun « déjà noté » stocké dans le state.

**Validation**
```
flutter analyze
flutter test test/rappel/rappel_bloc_test.dart
```

### M4 — Bootstrap (init notif injectable) + injection bloc + tap→route

**Objectif** : brancher l'init notif (hook injectable, no-op en test), fournir le `RappelBloc` à l'app, router le tap.

**Fichiers touchés**
- `apps/digiharmony_app/lib/bootstrap.dart` (ajout hook `notifInit` injectable, comme `audioInit`)
- `apps/digiharmony_app/lib/app/view/app.dart` (ajout `BlocProvider<RappelBloc>` + provider `ServiceRappel` ; dispatch `RappelReplanificationDemandee` au démarrage/résumé via observer de cycle de vie)
- `apps/digiharmony_app/lib/app/routing/app_router.dart` (`versRappelPriming`; cible tap = `versSaisieHumeur` déjà existante)
- `apps/digiharmony_app/test/bootstrap_test.dart` et/ou `test/app/view/app_test.dart` (init mockée, no-op)

**Travail**
- Ajouter `Future<void> Function()? notifInit` à `bootstrap` ; défaut = `ServiceRappelNotifications().initialiser()` ; en test → no-op (comme `audioInit`). Storage HydratedBloc reste affecté **avant** `runApp` (le `RappelBloc` est hydraté).
- Injecter `ServiceRappel` (impl réelle en prod, mock en test) + `BlocProvider<RappelBloc>`.
- Observer le cycle de vie (`AppLifecycleState.resumed`) → dispatch `RappelReplanificationDemandee`.
- Tap notif → payload → `AppRouter.versSaisieHumeur` (via navigatorKey/route handler).

**Critères d'acceptation**
- En test, `bootstrap` n'initialise aucun canal OS (hook no-op injecté) ; l'app construit.
- `RappelBloc` disponible dans l'arbre (Paramètres + saisie + priming y accèdent).
- Au résumé d'app, `RappelReplanificationDemandee` est dispatché.
- Tap notif route vers la saisie (test du handler de payload, sans canal OS réel).

**Validation**
```
flutter analyze
flutter test test/bootstrap_test.dart test/app/
```

### M5 — i18n : clés `rappel*` / `priming*` / `rappelInvitation*`

**Objectif** : zéro chaîne en dur ; clés réelles fr+en, repli en pour les 6 autres.

**Fichiers touchés**
- `apps/digiharmony_app/lib/l10n/arb/app_fr.arb`
- `apps/digiharmony_app/lib/l10n/arb/app_en.arb`
- `app_el.arb`, `app_it.arb`, `app_ro.arb`, `app_tr.arb`, `app_es.arb`, `app_mk.arb` (repli `en`)

**Travail**
- Ajouter les clés nécessaires (liste indicative) :
  section Paramètres (`rappelSectionTitle`, `rappelToggleLabel`, `rappelHeureLabel`,
  `rappelHeurePickerTitle`, `rappelPermissionRefuseeMessage`, `rappelOuvrirReglagesOsCta`),
  page priming (`primingTitle`, `primingBody`, `primingPrivacyNote`, `primingActiverCta`,
  `primingPlusTardCta`), invitation one-shot (`rappelInvitationTitle`, `rappelInvitationBody`,
  `rappelInvitationActiverCta`, `rappelInvitationPlusTardCta`), notification
  (`rappelNotificationTitre`, `rappelNotificationCorps`).
- fr + en réels (ton bienveillant, public mineur). Repli `en` verbatim dans les 6 langues.
- Pas de doublon de clés existantes.

**Critères d'acceptation**
- `flutter gen-l10n` génère sans erreur ; ICU valides si placeholders.
- Toutes les clés présentes dans les 8 ARB ; fr ≠ en (réels), 6 langues = repli en.

**Validation**
```
flutter gen-l10n
flutter analyze
```

### M6 — Page priming (pré-permission) + route

**Objectif** : expliquer pourquoi/comment avant la demande native ; déclencher la permission seulement sur action explicite.

**Fichiers touchés**
- `apps/digiharmony_app/lib/pages/rappel_priming/views/rappel_priming_view.dart`
- `apps/digiharmony_app/lib/pages/rappel_priming/views/rappel_priming_page.dart` (`page()`/`route()`)
- `apps/digiharmony_app/lib/app/routing/app_router.dart` (`versRappelPriming`, déjà ajouté M4 si fait)
- `apps/digiharmony_app/test/pages/rappel_priming/views/rappel_priming_view_test.dart`

**Travail**
- Page empilée : titre/corps rassurants (`primingTitle`/`primingBody`), note privacy
  (`primingPrivacyNote`), bouton **explicite** `primingActiverCta` → `ServiceRappel.demanderPermission()` :
  - accordée → `RappelActivationDemandee` + pop (revient à Paramètres avec toggle ON).
  - refusée → `RappelPermissionRefusee` + pop + message dans Paramètres.
  - `primingPlusTardCta` → pop sans rien activer.
- Aucune demande de permission au `initState`/build (uniquement sur tap CTA).

**Critères d'acceptation**
- La permission native n'est jamais demandée avant le tap CTA (test : aucun appel `demanderPermission` au montage).
- Accord → `actif=true` ; refus → `actif=false` + `permissionRefusee=true`, pas de crash.
- Aucune chaîne en dur.

**Validation**
```
flutter analyze
flutter test test/pages/rappel_priming/
```

### M7 — Section « Rappel » dans Paramètres (toggle + time picker)

**Objectif** : exposer le réglage, refléter l'état réel, brancher priming/permission/refus.

**Fichiers touchés**
- `apps/digiharmony_app/lib/pages/parametres/widgets/section_rappel.dart` (nouveau — **définit le pattern toggle/switch**, calqué sur `section_langue.dart`)
- `apps/digiharmony_app/lib/pages/parametres/views/parametres_view.dart` (insertion `SectionRappel` dans la Column de sections, `:72`)
- `apps/digiharmony_app/test/pages/parametres/widgets/section_rappel_test.dart`
- `apps/digiharmony_app/test/pages/parametres/views/parametres_view_test.dart` (présence de la section)

**Travail**
- `BlocBuilder<RappelBloc, RappelState>` : titre `rappelSectionTitle`, `Switch` `rappelToggleLabel`,
  ligne heure `rappelHeureLabel` + `showTimePicker` (visible/actif si `actif`).
- Activer le toggle → `AppRouter.versRappelPriming` (puis la page gère permission). Désactiver →
  `RappelDesactive`.
- Si `permissionRefusee` → message `rappelPermissionRefuseeMessage` + CTA `rappelOuvrirReglagesOsCta`
  (ouvre réglages OS). Pas de boucle.
- Changer l'heure → `RappelHeureChangee` (replanifie si actif).
- À l'ouverture de Paramètres : réconciliation permission OS réelle (DEC-R-06) → toggle cohérent.

**Critères d'acceptation**
- Toggle off par défaut ; activer → passe par la page priming (pas de permission directe).
- Time picker visible/actif quand activé ; changement d'heure → replanification.
- Permission refusée → toggle off + message + CTA réglages OS, pas de crash, pas de boucle.
- Heure affichée locale-aware ; aucune chaîne en dur.

**Validation**
```
flutter analyze
flutter test test/pages/parametres/
```

### M8 — Invitation one-shot à la 1re saisie réussie

**Objectif** : proposer (une seule fois) d'activer le rappel après la 1re saisie réussie.

**Fichiers touchés**
- `apps/digiharmony_app/lib/pages/saisie_humeur/views/saisie_humeur_view.dart` (ajout `BlocListener<SaisieHumeurBloc>` sur `EnregistrementReussi`, DEC-R-03 — **ne pas** modifier `saisie_humeur_bloc.dart`)
- `apps/digiharmony_app/lib/pages/rappel_priming/widgets/rappel_invitation_sheet.dart` (bottom sheet)
- `apps/digiharmony_app/test/pages/saisie_humeur/views/saisie_humeur_view_test.dart` (one-shot : 1re fois affiche, 2e fois non)

**Travail**
- `BlocListener` : sur `EnregistrementReussi`, si `!invitationDejaProposee` → afficher
  `rappel_invitation_sheet` (textes `rappelInvitation*`) puis dispatch `RappelInvitationProposee`
  (pose le flag). CTA « activer » → `AppRouter.versRappelPriming` ; « plus tard » → ferme.
- Garde `SaisieHumeurBloc` strictement inchangé.

**Critères d'acceptation**
- 1re saisie réussie (flag `false`) → sheet affichée + flag posé.
- 2e saisie réussie (flag `true`) → **aucune** sheet (one-shot respecté, persistant entre lancements).
- Dismiss sans activer → rien n'est planifié.
- Aucune chaîne en dur.

**Validation**
```
flutter analyze
flutter test test/pages/saisie_humeur/
```

### M9 — Skip « déjà noté » de bout en bout + a11y/polish + validation globale

**Objectif** : garantir le comportement skip aux 3 points de replanification, finaliser a11y et valider tout.

**Fichiers touchés**
- `apps/digiharmony_app/lib/app/view/app.dart` (dispatch replanification : démarrage + résumé)
- `apps/digiharmony_app/lib/rappel/rappel_bloc.dart` (chemin replanification → lecture `humeurDuJourEstNotee`)
- Widgets `section_rappel.dart` / `rappel_priming_view.dart` (a11y : `Semantics`, ≥ 48dp, reduced-motion)
- Suite de tests complète (`test/rappel/`, `test/services/rappel/`, intégration replanification)

**Travail**
- Vérifier les 3 déclencheurs de replanification : **démarrage/résumé app** (lifecycle), **après saisie
  réussie** (le `BlocListener` saisie dispatch aussi `RappelReplanificationDemandee`), **changement
  de réglage** (toggle/heure). À chaque fois : lire `humeurDuJourEstNotee` → si `true`, planifier
  demain ; sinon aujourd'hui (heure non passée) / demain (heure passée).
- a11y : `Semantics` sur toggle + time picker + CTA priming ; cibles ≥ 48dp ; toute animation priming
  gardée par `MediaQuery.disableAnimations` (rendu statique par défaut).

**Critères d'acceptation**
- Test bloc/service : `humeurDuJourEstNotee=true` au moment de la replanification → cible **demain**
  aux 3 déclencheurs.
- Après une saisie réussie (humeur du jour notée) → la replanification cible demain.
- Toute la suite verte ; lints 0 warning/info ; `gen-l10n` OK ; codegen sans conflit.

**Validation finale (avant commit complet, depuis `apps/digiharmony_app/`)**
```
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test
```

---

## Couverture des critères d'acceptation de la spec → milestones

| Critère d'acceptation (spec frontmatter) | Couvert par |
| --- | --- |
| Section « Rappel » (toggle + time picker) dans Paramètres | M7 |
| Notif quotidienne à l'heure choisie + tap ouvre saisie | M2 (planif), M4 (tap→route), M7 |
| Skip si humeur du jour déjà notée + replanification lendemain | M1 (lecture), M3 (logique), M9 (3 déclencheurs) |
| Aucun rappel sans activation explicite (off par défaut) | M3 (défaut `false`), M6 (priming d'abord) |
| Invitation one-shot à la 1re saisie réussie | M8 (+ flag M3) |
| Page priming AVANT permission native | M6 |
| Refus permission → pas de crash, toggle réel, message guide | M3, M6, M7 |
| Réglages persistés via HydratedBloc (jamais Drift/dupliqués) | M3 (hydratation), DEC-R-02 |
| i18n fr+en réels, repli en | M5 |
| Aucun SDK réseau/analytics ; perms minimales ; build release inchangé | M0 |

## Hors périmètre V1 (→ V1.1)

Rappels multiples / horaires multiples / jours de semaine ; notifications riches (actions/images) ;
son/canal custom élaboré ; `RECEIVE_BOOT_COMPLETED` (replanification au démarrage suffit, DEC-R-04) ;
traductions réelles `el/it/ro/tr/es/mk` ; refonte de la page `tuto_notifs`.
