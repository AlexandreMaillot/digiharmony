---
name: branch
description: VCS branch naming convention template
argument-hint: N/A
scope: all
---

# Versioning Control System (VCS) Guidelines

- Main Branch: `main`
- Platform: GitHub — `https://github.com/AlexandreMaillot/digiharmony` (public)
- CLI: `gh` (authentifié `AlexandreMaillot`)
- License: GNU GPLv3 (`LICENSE` racine)

## Secrets — NE JAMAIS committer

- Exclus via `.gitignore` racine : `*.jks`, `*.keystore`, `**/key.properties`, `*.env`, `.env`
- Jamais de keystore ni de mots de passe dans le VCS (repo public)

## Tooling `.claude/` — politique de versionnement

- **Versionnés** (config projet partagée) : `.claude/rules/`, `.claude/agents/`, `.claude/commands/`,
  `.claude/skills/`.
- **Ignorés** (local) : `.specstory/` (logs de session) et `.claude/settings.local.json` + tout autre
  fichier `.claude/` non listé ci-dessus.
- `.gitignore` : `.claude/*` puis exceptions `!.claude/rules/` `!.claude/agents/` `!.claude/commands/`
  `!.claude/skills/`. (Ne jamais re-déversionner les règles : `CLAUDE.md` les référence.)

## Branching Strategy

- Convention : branche unique `main` pour l'instant ; pas de process PR formalisé
- Format de branche (convention) : `type/short-description`

| Prefix       | Usage                     |
| ------------ | ------------------------- |
| `feat/`      | New feature               |
| `fix/`       | Bug fix                   |
| `docs/`      | Documentation only        |
| `refactor/`  | Code change (no feat/fix) |
| `chore/`     | Build, config, deps       |
| `test/`      | Add/update tests          |
| `hotfix/`    | Urgent production fix     |

## Commit Convention

- Conventional Commits — `type(scope): description` (ex. `chore: ...`, `feat: ...`)
- Trailer `Co-Authored-By` pour les commits assistés

### Types

| Type       | Usage                        |
| ---------- | ---------------------------- |
| `feat`     | New feature                  |
| `fix`      | Bug fix                      |
| `docs`     | Documentation only           |
| `refactor` | Code change (no feat/fix)    |
| `perf`     | Performance improvement      |
| `test`     | Add/update tests             |
| `chore`    | Build, config, deps          |
| `style`    | Formatting (no logic change) |
| `ci`       | CI/CD configuration          |
| `revert`   | Revert previous commit       |

### Description rules

- Imperative mood : "add" not "added"
- Lowercase, no period
- Max 72 chars

### Examples

```text
feat(auth): add OAuth2 login
fix(api): handle null user responses
chore: init monorepo DIGIHARMONY
```

### Breaking Change

```text
feat(api): redesign authentication flow

BREAKING CHANGE: JWT tokens now expire after 1h instead of 24h.
```
