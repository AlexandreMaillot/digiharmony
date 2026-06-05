# Decision: État léger persistant = HydratedBloc (journal exclu)

| Field   | Value          |
| ------- | -------------- |
| ID      | DEC-002        |
| Date    | 2026-06-05     |
| Feature | Persistance état UI |
| Status  | Accepted       |

## Context

Certains états légers doivent survivre au redémarrage : langue choisie, flags d'onboarding,
étapes de tuto cochées, dismiss de bandeau. Ils sont sérialisables et sans relation, donc
mal adaptés à Drift. `flutter_bloc`/`bloc`/`equatable` sont déjà fournis par very_good.

## Decision

Utiliser **HydratedBloc** pour l'état léger persistant (ex. `LocaleBloc` au-dessus de
`MaterialApp` pour la bascule de langue immédiate sans redémarrage). Le **journal d'humeur
n'est JAMAIS stocké dans HydratedBloc** — il reste dans Drift (DEC-001).

> **Bloc-only** : on utilise `HydratedBloc<Event, State>` (jamais `HydratedCubit`/`Cubit`) —
> voir règle `1-bloc-only-no-cubit`. Les suffixes anglais `Event`/`State` sont autorisés
> (dérogation actée 2026-06-05) ; le reste du nommage métier reste en français.

## Alternatives Considered

| Alternative | Pros | Cons | Rejected because |
| ----------- | ---- | ---- | ---------------- |
| Tout dans Drift | source unique | sur-ingénierie pour des flags | inutilement lourd pour de l'état UI |
| shared_preferences seul | simple | pas de réactivité bloc, sérialisation manuelle | gardé en repli ponctuel uniquement |

## Consequences

- ✅ Persistance automatique de la langue/flags, réactivité bloc native.
- ✅ Deux fichiers locaux distincts (Drift + HydratedBloc), tous deux 100 % sur l'appareil → cohérent zéro-collecte.
- ⚠️ Règle stricte : ne pas dupliquer le journal/agrégats dans HydratedBloc (toujours dérivés de Drift).
