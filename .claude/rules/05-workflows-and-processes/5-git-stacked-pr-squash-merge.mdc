---
description: PR stacked (basé sur la branche d'un autre PR) + squash-merge du PR base avec `--delete-branch` → la branche base est supprimée, GitHub FERME automatiquement le PR stacked (ne le retarget PAS sur master). Pour éviter/récupérer ce cas lors du merge d'une pile de PRs.
globs:
alwaysApply: false
---
- **Contexte** : on stacke souvent PR-2 sur la branche de PR-1 (`gh pr create --base feat/pr-1`). Au merge de PR-1 en **squash** avec `--delete-branch`, la branche `feat/pr-1` disparaît → le PR-2 (dont la base était `feat/pr-1`) est **CLOSED** par GitHub, pas retargeté. Vécu 2026-05-27 (#966 fermé au merge de #964).
- **Éviter** : AVANT de merger le PR base, retarger le PR stacked sur `master` (`gh pr edit <stacked> --base master`). OU merger le base SANS `--delete-branch`, retarger, puis supprimer la branche.
- **Récupérer** (si déjà fermé) : le squash-merge du base a créé un commit NEUF sur master (≠ commits de la branche). Ne pas réutiliser la branche stacked telle quelle (elle re-contient les commits du base → conflit/doublon). À la place, **cherry-pick le(s) commit(s) propre(s) du PR stacked sur un master à jour** :
  ```bash
  git checkout master && git reset --hard master/master   # master après merge du base
  git checkout -b <feat>-rebased
  git cherry-pick <commit-du-pr-stacked>                   # souvent auto-mergé proprement
  flutter gen-l10n && flutter analyze && flutter test ...  # VÉRIFIER (auto-merge peut être faux)
  git push -u <remote> <feat>-rebased
  gh pr create --base master ...                           # nouveau PR (l'ancien est CLOSED)
  ```
- **Vérifier après cherry-pick** : un auto-merge sans conflit textuel peut être sémantiquement faux (deux PRs ont touché le même fichier sur des zones proches). Toujours relancer analyze + tests ciblés avant de merger.
- **Ordre de merge d'une pile** : merger d'abord les PRs indépendants, puis base → stacked, en revérifiant `mergeable` à chaque étape (GitHub recalcule en asynchrone — un `UNKNOWN` se résout en quelques secondes).
