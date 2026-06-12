# Règle : Permissions minimales / zéro collecte

Principe directeur du projet (confiance n°1) : **aucune permission superflue, zéro collecte,
zéro identification.** Toute nouvelle permission doit être justifiée par une feature du CDC.

## Permissions autorisées

| Permission | Usage | Note |
| --- | --- | --- |
| `PACKAGE_USAGE_STATS` (Android) | « Mon temps d'écran » (best-effort) | Permission **protégée** → `tools:ignore="ProtectedPermissions"`, octroyée via l'écran système `ACTION_USAGE_ACCESS_SETTINGS`. Jamais bloquant : repli message + alternative. iOS = pas de Family Controls → repli. |
| `POST_NOTIFICATIONS` (Android 13+) | Rappel quotidien d'humeur (notification locale) | 100 % local, zéro réseau. Demandée à l'activation du rappel (DEC-R-04). |
| `SCHEDULE_EXACT_ALARM` (Android 12+) | Rappel quotidien **à l'heure pile** | Permission **fonctionnelle, zéro collecte** (DEC-010). « Alarmes et rappels » demandée à l'activation ; repli automatique inexact si refusée. |

## Interdits (sauf décision explicite)

- **Pas de `VIBRATE`** : vibration via `HapticFeedback` natif (0 dépendance, 0 permission).
- **Notifications** : limitées au **rappel quotidien local** (DEC-R-04 + DEC-010) — aucun push réseau, aucun serveur. Tout le reste reste en bandeau in-app.
- **Aucune permission de données personnelles**, aucun SDK de tracking/analytics/Crashlytics.

## Conséquence

Toute PR ajoutant une permission, un SDK réseau ou de la collecte doit être refusée ou
remontée comme décision (DEC-XXX), car elle casse la conformité RGPD-par-absence-de-traitement.
