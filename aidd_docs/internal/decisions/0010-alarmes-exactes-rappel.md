# Decision: Alarmes exactes pour le rappel quotidien (SCHEDULE_EXACT_ALARM)

| Field   | Value                          |
| ------- | ------------------------------ |
| ID      | DEC-010                        |
| Date    | 2026-06-12                     |
| Feature | Rappel quotidien d'humeur      |
| Status  | Accepted                       |

## Context

Le plan rappel (note « BLOCKER-2 ») avait choisi `inexactAllowWhileIdle` pour
**éviter toute permission** d'alarme, jugeant « la minute près » suffisante. À l'usage
(Android 12+/16), le mode inexact **retarde** la notification de plusieurs minutes (et
davantage sous Doze) — vérifié au runtime : une cible 10:18:15 toujours non délivrée à
10:19:32. La demande utilisateur explicite est un rappel **à l'heure précise**. Cela
ajoute la permission `SCHEDULE_EXACT_ALARM`, ce qui contredit la note du plan et la
règle `permissions-zero-collecte` (« toute permission ajoutée → décision explicite »).

## Decision

Déclarer `android.permission.SCHEDULE_EXACT_ALARM` et :

- demander « Alarmes et rappels » à l'**activation** du rappel
  (`requestExactAlarmsPermission`, best-effort, jamais bloquant) ;
- planifier en `exactAllowWhileIdle` **si** accordée (`canScheduleExactNotifications`),
  sinon **repli automatique** `inexactAllowWhileIdle` (aucune permission requise).

Permission **purement fonctionnelle** : zéro donnée, zéro réseau, zéro tracking — la
conformité « RGPD par absence de traitement » est intacte.

## Alternatives Considered

| Alternative | Pros | Cons | Rejected because |
| ----------- | ---- | ---- | ---------------- |
| Rester `inexactAllowWhileIdle` (plan initial) | aucune permission | notif retardée de plusieurs min, pas « à l'heure » | ne répond pas à la demande « heure précise » |
| `USE_EXACT_ALARM` (auto-accordée) | pas d'action utilisateur | réservée par Google Play aux apps alarme/agenda/rappel ; risque de refus de publication | politique Play trop risquée pour une app bien-être |

## Consequences

- ✅ Notification délivrée à l'heure pile quand l'autorisation est accordée (vérifié
  runtime : tir à 10:58:04 app en arrière-plan). Repli silencieux sinon.
- ⚠️ +1 permission au tableau « autorisées » de `permissions-zero-collecte` (mise à
  jour faite). Nécessite une action utilisateur (écran système) pour la précision.
- 🔗 Va de pair avec le `ScheduledNotificationReceiver` au manifest (règle
  `android-notifications-scheduled`) sans lequel **aucune** notif planifiée ne se poste.
  [[architecture]]
