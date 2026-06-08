# Architecture Decision Record (ADR)

This file contains the key architectural decisions made during the project, along with their context and consequences.

## Decision Log

| Date       | ID      | Title                                                          | Consequences                                              |
| ---------- | ------- | -------------------------------------------------------------- | --------------------------------------------------------- |
| 2026-06-05 | DEC-001 | [DB locale = Drift](./0001-db-locale-drift.md)                 | Relationnel + réactif, codegen, minify off requis         |
| 2026-06-05 | DEC-002 | [État léger = HydratedBloc](./0002-etat-hydratedbloc.md)       | Langue/flags persistés ; journal reste dans Drift         |
| 2026-06-05 | DEC-003 | [Design system « Navy & Halo »](./0003-design-system-navy-halo.md) | Thème foncé unique, theme.dart central, palette émotions cloisonnée |
| 2026-06-06 | DEC-004 | [Saisie : sélection + Valider](./0004-saisie-selection-valider.md) | Fin du 1-tap/undo ; UPSERT au Valider + retour Accueil ; pré-sélection |
| 2026-06-06 | DEC-005 | [Soutien : ligne d'écoute 3114](./0005-soutien-ligne-ecoute-3114.md) | 3114 réel FR + fallback FR temporaire ; token vertAppel ; garde-fous |
| 2026-06-06 | DEC-006 | [iOS Screen Time (FamilyControls + DeviceActivityReport)](./0006-ios-screen-time.md) | Dev sans approbation / distrib avec ; données non lisibles → rapport système, pas d'historique Drift iOS |
| 2026-06-06 | DEC-007 | [Identité d'app par flavor (production-only)](./0007-identite-app-flavor.md) | Icône adaptative + splash + nom via overrides `src/production` / configs Xcode prod ; dev/staging intacts ; iOS storyboard via variable de build |
