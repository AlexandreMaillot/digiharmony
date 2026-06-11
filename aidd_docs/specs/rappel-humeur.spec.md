---
objective: Permettre à l'utilisateur de recevoir une notification locale quotidienne, paramétrable (heure + activation), pour lui rappeler de noter son humeur, sans aucune collecte ni réseau.
spec_status: drafted
created_at: 2026-06-11
source: conversation (demande client, session SDLC du 2026-06-11)
acceptance_criteria:
  - "Une section « Rappel » dans Paramètres permet d'activer/désactiver le rappel quotidien (toggle) et de choisir l'heure (time picker)."
  - "Quand le rappel est activé, une notification locale se déclenche chaque jour à l'heure choisie et son tap ouvre la saisie d'humeur."
  - "Le rappel n'est PAS notifié les jours où l'humeur du jour est déjà notée (replanification au lendemain)."
  - "Aucun rappel n'est planifié tant que l'utilisateur ne l'a pas explicitement activé (pas d'activation par défaut à l'installation)."
  - "À la toute première saisie d'humeur réussie, et une seule fois, une invitation à activer le rappel est proposée."
  - "Avant toute demande de permission native, une page UI d'explication (pourquoi/comment, rassurante) est affichée ; la permission native n'est demandée qu'après action explicite de l'utilisateur."
  - "Si la permission notification est refusée, l'app reste fonctionnelle, le toggle reflète l'état réel et un message guide l'utilisateur (pas de crash, pas de boucle)."
  - "Les réglages (activé + heure) persistent entre les lancements via HydratedBloc (jamais dans Drift, jamais dupliqués)."
  - "Aucune chaîne UI en dur : toutes les clés i18n présentes en fr + en (réels), repli en pour el/it/ro/tr/es/mk."
  - "Aucun SDK réseau/analytics/tracking ajouté ; seule la permission d'affichage de notifications (POST_NOTIFICATIONS Android 13+, autorisation iOS) est ajoutée. Build Android release inchangé (minify/shrinkResources restent false)."
---

# Spec — Rappel quotidien d'humeur (notification locale paramétrable)

## Contexte

Demande client : l'utilisateur doit pouvoir recevoir une **notification automatique quotidienne**
qui lui rappelle de noter son humeur. La notification est **paramétrable** (heure choisie par
l'utilisateur) et **activable/désactivable**. Le réglage vit dans **Paramètres**.

Contraintes structurantes du projet (font loi) :

- **Zéro collecte, zéro réseau, zéro Firebase.** Les notifications doivent être **100 % locales**.
  Le package `flutter_local_notifications` (+ `timezone`) est autorisé car il n'émet aucune donnée
  vers l'extérieur. Aucun SDK analytics/tracking/Crashlytics.
- **Public mineur (Erasmus+), privacy-first.** Opt-in explicite, ton rassurant, transparence sur le
  « pourquoi ».
- **Deux couches de persistance à ne pas mélanger.** Le réglage léger (activé + heure) → `HydratedBloc`.
  Le fait que l'humeur du jour soit notée → **dérivé de Drift** (jamais dupliqué).

## Objectif

> Permettre à l'utilisateur de recevoir une notification locale quotidienne, paramétrable
> (heure + activation), pour lui rappeler de noter son humeur, sans aucune collecte ni réseau.

## Périmètre fonctionnel (MUST)

1. **Réglage dans Paramètres** — nouvelle section « Rappel » :
   - Toggle activer/désactiver.
   - Sélecteur d'heure (time picker natif), visible/actif quand le rappel est activé.
   - État persistant (HydratedBloc), reflète toujours l'état réel (y compris permission refusée).
2. **Planification quotidienne** — quand activé, une notification locale se déclenche chaque jour
   à l'heure choisie. Le tap ouvre la **saisie d'humeur**.
3. **Skip si déjà noté** — les jours où l'humeur du jour est déjà enregistrée (Drift), **aucune
   notification** n'est présentée ; le rappel est replanifié pour le prochain jour pertinent.
   Replanification déclenchée au minimum : au démarrage/résumé de l'app, après une saisie d'humeur,
   et au changement de réglage.
4. **Invitation contextuelle (one-shot)** — à la **première** saisie d'humeur réussie de la vie de
   l'app, proposer (une seule fois) d'activer le rappel. Un flag persistant garantit l'unicité.
5. **Page priming pré-permission** — avant d'ouvrir le dialogue de permission natif, afficher une
   page UI explicative (pourquoi le rappel aide, comment ça marche, rappel « local & privé »), avec
   un bouton explicite déclenchant la demande native. Pas de demande de permission silencieuse.
6. **Gestion du refus** — si la permission est refusée (ou révoquée), pas de crash : le toggle
   revient/affiche désactivé, un message bienveillant explique comment réactiver (réglages OS).
7. **i18n** — toutes les chaînes en clés ARB, fr + en réels, repli en pour les 6 autres langues.

## Hors périmètre (NON — à ne pas faire)

- Pas de rappels multiples / horaires multiples / jours de la semaine sélectionnables (1 rappel/jour).
- Pas de notifications « riches » (actions, images), pas de son/canal custom élaboré au-delà du minimum requis.
- Pas de backend, push distant, FCM, ni planification serveur.
- Pas de modification de la posture « zéro collecte » : aucune donnée d'usage envoyée.
- Pas de refonte de la page `tuto_notifs` existante (tuto statique sans rapport).

## Décisions produit validées (session)

- **Dépendance** : `flutter_local_notifications` + `timezone` ajoutés (local-only). Permission
  `POST_NOTIFICATIONS` (Android 13+) + autorisation iOS via le plugin.
- **Activation par défaut** : désactivé à l'installation. Activation proposée à la 1re saisie (one-shot).
- **Logique « déjà noté »** : ne pas notifier si l'humeur du jour est déjà enregistrée → replanification.
- **Permission** : toujours précédée d'une page de priming maison.

## Critères d'acceptation

Voir le bloc `acceptance_criteria` du frontmatter (source de vérité testable).

## Points à trancher par le plan (laissés à l'architecte/planner)

- Mécanisme exact de récurrence + skip (ex. planification fenêtre N jours rafraîchie à l'ouverture,
  vs one-shot replanifié, vs daily repeat + annulation conditionnelle). Le planner choisit la
  solution la plus fiable côté OS pour honorer « skip si déjà noté ».
- Emplacement du `RappelBloc`/service de notifications (ex. `lib/rappel/` + `lib/services/`),
  initialisation dans `bootstrap.dart`, injection dans `MultiBlocProvider`.
- Forme de l'invitation one-shot (bottom sheet / dialog) et de la page priming (route empilée).
- Stratégie de test (le plugin notifications doit être mockable ; pas de dépendance OS réelle en test).
