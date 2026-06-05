---
name: agent-orchestration
description: Leçons d'orchestration des agents/sous-agents dans ce harness (AIDD)
argument-hint: N/A
scope: internal
---

# Orchestration des agents — leçons (ce harness)

> Apprentissages process actés le 2026-06-05 après l'intégration Phase 1.
> But : éviter les corruptions git et le travail perdu vus pendant la session.

## Kaio inutilisable tel quel dans ce harness

- Kaio **ne peut pas paralléliser** : un sous-agent ne peut pas en lancer d'autres (pas de nesting). Sa promesse « N pages en parallèle » tombe → exécution séquentielle solo.
- Kaio **boucle sur des `Monitor`/tâches async** qui ne reviennent pas, et **termine son tour sans coder** (« awaiting the test monitor ») → il n'avance pas.
- Kaio crée des **worktrees cachés** (branches `kaio`/`martin` visibles dans l'IDE mais absentes de `git branch` du repo principal) et pousse/commite **en arrière-plan**, provoquant des changements de branche « sous toi ».
- **Préférer l'agent `implementer`** piloté séquentiellement (un seul à la fois) pour coder/merger/réparer. Il fait le flux complet (code → test → commit → push → PR) de façon fiable en solo.

## Règles de sécurité git avec agents background

- **Un seul agent qui touche le working tree/git à la fois.** Jamais d'agents concurrents sur le même tree (cause : commits qui apparaissent, `MERGE_HEAD` qui disparaît, branche qui change en plein merge).
- **Tuer (`TaskStop`) tout agent background AVANT** une opération git structurante (merge, rebase, checkout). `TaskList` peut mentir (un zombie peut tourner sans y figurer) → tenter `TaskStop` sur l'id connu par acquit de conscience.
- Ne pas lancer de validation Bash (build_runner/test) en parallèle d'un implementer qui finalise un commit.
- Les agents `martin`/`implementer` peuvent être **lents** (20–50 min) sans être morts ; ne pas conclure « mort » sur la seule absence de notification.

## Banani (MCP) — capture-first

- **Capturer la sélection soi-même** (`banani_get_selected_designs`) avant de lancer babidi, puis dire à l'utilisateur « tu peux sélectionner le suivant ». Un babidi background ne peut pas signaler « c'est capturé » en cours de route.
- **`flow.name` peut être erroné/obsolète** (a affiché « CMR Chantier » pour un écran DIGIHARMONY). Se fier au **`screenId`** (préfixe du flow DIGIHARMONY = `kh_4MGOGFJNA`) et au contenu/thème, pas au `flow.name`.
- babidi peut **no-op** (0 tool use, sortie parasite) → relancer.

## Divers

- Une image collée dans le chat n'est PAS écrivable sur disque sauf si le harness fournit un chemin de cache (`~/.claude/image-cache/...`) — alors `cp` possible.
- `.claude/` n'est pas suivi par git dans ce repo → les éditions de `.claude/rules/**` restent locales.
