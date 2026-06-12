# Règle : Notifications locales planifiées Android (flutter_local_notifications)

Pour qu'une notification **planifiée** (`zonedSchedule`) se poste réellement quand
l'app est en arrière-plan/fermée, l'app **doit déclarer elle-même** le receiver dans
`android/app/src/main/AndroidManifest.xml` :

```xml
<receiver
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"
    android:exported="false" />
```

## Pourquoi

Le plugin `flutter_local_notifications` **ne déclare PAS** ce receiver dans son
manifest (seulement `VIBRATE` + `POST_NOTIFICATIONS`). Sans cette déclaration,
l'alarme exacte se déclenche bien (les wakeups AlarmManager sont comptés) mais le
broadcast cible un composant inexistant et **tombe dans le vide** → aucune notif.

**Piège qui masque le bug** : `show()` (notif immédiate) ne passe PAS par ce receiver
et fonctionne, donnant l'impression que « les notifs marchent » alors que seules les
notifs planifiées sont cassées. Symptôme observé : `numEnqueuedByApp` ne bouge pas au
tir de l'alarme (`adb shell dumpsys notification`).

## À appliquer aussi (rappel quotidien d'humeur)

- **Canal importance HIGH** (`Importance.high` + `Priority.high`) pour une bannière
  heads-up visible. Android **verrouille l'importance d'un canal après création** :
  pour relever un canal déjà créé en `DEFAULT`, il faut **changer son `id`** (ex.
  `rappel_humeur` → `rappel_humeur_v2`), pas seulement le code.
- `enableVibration: false` sur le canal → conforme « zéro permission VIBRATE »
  (vibration uniquement via `HapticFeedback`, voir `permissions-zero-collecte`).
- **PAS** de `ScheduledNotificationBootReceiver` ni `RECEIVE_BOOT_COMPLETED`
  (DEC-R-04) : le rappel est replanifié au lancement de l'app, pas besoin de survivre
  au reboot.
- Heure **pile** = autorisation OS « Alarmes et rappels » (`SCHEDULE_EXACT_ALARM`,
  demandée à l'activation) ; sinon repli `inexactAllowWhileIdle` qui **retarde** la
  notif (fenêtre de plusieurs minutes).

> Vérifié au runtime sur émulateur Android 16 (API 36) : sans le receiver, 0 notif
> planifiée ; avec, `numPostedByApp` incrémente et la bannière s'affiche app fermée.
> Indépendant de la version du plugin (reproduit en v18 et v21).
