# Decision: Navigation par bottom bar (5 onglets) au lieu du hub-push

| Field   | Value                       |
| ------- | --------------------------- |
| ID      | DEC-008                     |
| Date    | 2026-06-10                  |
| Feature | Navigation principale       |
| Status  | Accepted                    |

## Context

La navigation était 100 % impérative (`Navigator.push`/`pushReplacement`, pas de
GoRouter — convention DEC-FND-07 conservée) : l'Accueil servait de **hub** dont les
cartes empilaient les écrans (Bulles, Conseils, Détox, Journal, Paramètres…), chaque
écran portant un chevron retour. Demande client : passer à une **bottom navigation
bar**, donc **plus de bouton retour** pour circuler entre les sections.

## Decision

Introduire une coquille `MainShell` (`lib/app/shell/main_shell.dart`) :

- **5 onglets** (ordre = `OngletPrincipal`) : **Accueil · Journal · Conseils · Bulles ·
  Paramètres**, rendus dans un `IndexedStack` (état préservé entre onglets).
- **Chargement paresseux** : un onglet n'instancie son arbre (Bloc + lecture Drift)
  qu'à sa **première visite** (`Set<int> _visites`, init `{0}`). Évite 5 lectures Drift
  au démarrage et n'éveille pas `JournalBloc`/`SectionLangue` tant que l'onglet n'est pas
  ouvert.
- **`ShellScope`** (InheritedWidget, `maybeOf` nullable) : les raccourcis internes
  (tuiles Accueil, icône Réglages, « voir le journal » de la carte humeur) **basculent
  l'onglet** au lieu d'empiler. Hors shell (prévisualisation `main_development`, tests),
  repli sur l'ancien `Navigator.push`.
- **Entrée** : `DemarrageView` fait `pushReplacement(MainShell.route())` (au lieu de
  `AccueilPage`). Le hook Soutien post-splash est inchangé (push par-dessus le shell).
- **Sections-onglets sans retour** : Journal/Paramètres/Conseils affichent leur chevron
  **conditionnellement à `Navigator.canPop()`** (false en racine ⇒ pas de retour) — même
  pattern que Bulles le faisait déjà.
- **Écrans de tâche** (respiration, sens, étirement, détox config+lecteur, saisie humeur,
  temps d'écran, soutien+confiance, tuto notifs) : **poussés plein écran** par-dessus le
  shell (bottom bar masquée), avec un **bouton Fermer (X)** au lieu du chevron. Pour
  `BarreOutils`, nouveau flag `fermer` (`Icons.close`) ; pour les AppBar simples,
  `Icons.close` + `closeButtonTooltip`.
- **i18n** : 5 clés courtes `navHome/navJournal/navTips/navBubbles/navSettings` dans les
  8 langues.

## Alternatives Considered

| Alternative | Pros | Cons | Rejected because |
| ----------- | ---- | ---- | ---------------- |
| Garder le hub-push + ajouter une bottom bar par-dessus | diff minimal | écrans empilés avec retour incohérent (double sortie) | contredit « plus de retour » |
| `IndexedStack` eager (5 onglets construits au démarrage) | code plus simple | 5 lectures Drift au lancement + Blocs éveillés inutilement ; cassait les tests (mocks Accueil-only) | coût runtime + régressions |
| Migrer vers GoRouter / `StatefulShellRoute` | shell idiomatique | rupture DEC-FND-07, refonte de toute la nav impérative | hors périmètre, risque élevé |

## Consequences

- ✅ `flutter analyze` propre ; **417 tests** au vert (3 tests d'icône mis à jour :
  saisie humeur → X, paramètres-onglet → sans retour, tuto notifs → Fermer).
- ✅ Bascule d'onglet instantanée, état conservé ; onglets chargés à la demande.
- ⚠️ `AppRouter.versAccueil`/`versBienvenue` deviennent du code mort (non appelés) —
  à supprimer ultérieurement.
- ⚠️ `iOS Family Controls` distribution : sans rapport avec la nav, mais bloque encore la
  diffusion iOS (cf. DEC-006). [[architecture]] [[codebase-map]]
