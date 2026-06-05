# Decision: Base de données locale = Drift

| Field   | Value          |
| ------- | -------------- |
| ID      | DEC-001        |
| Date    | 2026-06-05     |
| Feature | Persistance locale |
| Status  | Accepted       |

## Context

L'app est 100 % locale, sans backend ni Firebase (zéro collecte). Le journal d'humeur daté,
l'historique des conseils et les agrégats semaine/mois doivent être stockés de façon
relationnelle, requêtable et réactive (`watch()` pour calendrier/stats live), avec une
solution maintenue et compatible avec l'exigence Android **page 16 Ko** (R6 du CDC).

## Decision

Utiliser **Drift** (SQLite type-safe) comme base de données locale, avec
`sqlite3_flutter_libs` (`0.6.0+eol`, compatible 16 Ko).

## Alternatives Considered

| Alternative | Pros | Cons | Rejected because |
| ----------- | ---- | ---- | ---------------- |
| Isar | rapide, simple | abandon de l'auteur, NDK obsolète | non maintenu / risque 16 Ko |
| Hive | léger, simple | non relationnel, pas de requêtes/`watch` riches | inadapté au journal + stats |

## Consequences

- ✅ Requêtes relationnelles + réactivité (`watch`) pour calendrier/stats et le compteur
  « 7 émotions négatives consécutives » (dérivé, non dupliqué).
- ✅ Compatible exigence Android 16 Ko.
- ⚠️ Nécessite `build_runner` (codegen) et impose `minify`/`shrinkResources` à `false` côté
  Android release pour ne pas que R8 strippe les libs natives (voir règle gradle).
