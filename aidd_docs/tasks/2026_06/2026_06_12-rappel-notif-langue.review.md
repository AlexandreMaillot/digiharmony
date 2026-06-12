# Code Review for Rappel notification (livraison planifiée) + Langue système

Revue du diff `git diff main` couvrant le correctif des notifications planifiées du
rappel quotidien (receiver manifest + canal HIGH + alarmes exactes), l'outillage de
debug, et la résolution automatique de la langue (système → repli anglais).

- Statuts: 🟢 **Résolu** (2026-06-12) — findings corrigés ci-dessous (voir « Résolution »)
- Confidence: Élevée (changements vérifiés au runtime + test `APP-7`)

## Résolution (2026-06-12)

- 🔴 **HIGH** `SCHEDULE_EXACT_ALARM` → **ratifié** par [DEC-010](../../internal/decisions/0010-alarmes-exactes-rappel.md) + tableau des permissions autorisées mis à jour (`rules/permissions-zero-collecte.md`) + commentaire manifest référence DEC-010. Précision « heure pile » conservée (demande utilisateur).
- 🟡 **MEDIUM** Outillage debug → **supprimé** : `planifierTestProche` + `afficherNotificationTest` (interface + impl + `_idNotifTest`), events `RappelTestDemande`/`RappelTestPlanifieDemande` + handlers, widget `_BoutonTestDebug` + import `foundation.dart`. Plus aucun code debug en release.
- 🟡 **LOW** Chaînes debug non i18n → disparues avec l'outillage.
- 🟡 **LOW** Appels `canScheduleExactNotifications()` → **conservés volontairement** : `demanderPermission` (éviter re-prompt) et `_modeAndroid` (choix exact/inexact à la planification) lisent l'état à des moments différents ; la valeur peut changer hors app (réglages système) → lecture à chaud nécessaire, pas un défaut.

Vérif : `flutter analyze` propre · **456 tests** au vert (dont `APP-7`).

---

- [Main expected Changes](#main-expected-changes)
- [Scoring](#scoring)
- [Code Quality Checklist](#code-quality-checklist)
- [Final Review](#final-review)

## Main expected Changes

- [x] Notif planifiée se poste app en arrière-plan (`ScheduledNotificationReceiver` au manifest)
- [x] Bannière heads-up visible (canal `rappel_humeur_v2`, importance HIGH)
- [x] Heure exacte quand « Alarmes et rappels » accordée (`exactAllowWhileIdle`)
- [x] Langue auto = téléphone si supportée, sinon anglais (`localeListResolutionCallback`)
- [ ] ⚠️ Retrait de l'outillage debug avant release
- [ ] ⚠️ Ratification de la permission `SCHEDULE_EXACT_ALARM` en décision

## Scoring

- [🔴] **Architecture / Décision non ratifiée** `android/app/src/main/AndroidManifest.xml:11-15` + `lib/services/rappel/service_rappel_notifications.dart` (`demanderPermission`, `_modeAndroid`) : ajout de la permission `SCHEDULE_EXACT_ALARM` et bascule vers `AndroidScheduleMode.exactAllowWhileIdle`. Cela **reverse le choix délibéré du plan** (commentaire supprimé « BLOCKER-2 : inexactAllowWhileIdle ne requiert aucune permission… ») et **enfreint la règle `permissions-zero-collecte`** (« aucune permission superflue ; toute PR ajoutant une permission → remontée comme décision DEC-XXX »). À résoudre : créer un **DEC-XXX** ratifiant le compromis « précision à l'heure vs permission sensible » (app pour mineurs), **ou** revenir au mode inexact. NB : l'ancien commentaire imputait l'interdiction à `DEC-R-01`, qui concerne en réalité l'**emplacement** des fichiers (plan §143) — l'attribution était erronée, mais le principe de minimalisme reste opposable.

- [🟡] **Outillage debug livré dans le binaire release** `lib/services/rappel/service_rappel.dart:60-66` (méthode `planifierTestProche` sur l'interface publique), `…/service_rappel_notifications.dart` (impl `planifierTestProche`), `lib/rappel/rappel_event.dart:72` (`RappelTestPlanifieDemande`), `lib/rappel/rappel_bloc.dart:189` (`_onTestPlanifieDemande`), `lib/pages/parametres/widgets/section_rappel.dart:255` (2e bouton debug). L'UI est protégée par `kDebugMode` (strippée en release), mais les méthodes/events restent du **code mort en release** et **polluent le contrat `ServiceRappel`**. Le commentaire dit déjà « À retirer une fois le diagnostic terminé » → action de suivi avant release (retirer ou isoler derrière `kDebugMode`/un service de test).

- [🟡] **Appels plateforme redondants** `…/service_rappel_notifications.dart` : `canScheduleExactNotifications()` est interrogé dans `demanderPermission` puis de nouveau à **chaque** `_modeAndroid()` (donc à chaque planification/replanification). Sans danger, mais multiplie les allers-retours MethodChannel ; envisageable de mémoriser le résultat ou de l'accepter tel quel (valeur peut changer si l'utilisateur révoque l'autorisation hors app — argument pour garder la lecture à chaud).

- [🟡] **Chaînes debug non i18n** `…/section_rappel.dart` : « Tester la notification maintenant (debug) », « Notif planifiée dans ~1 min (debug) » en dur. Acceptable car **debug-only**, mais à supprimer avec l'outillage (cf. finding debug).

- [🟢] **Refactor `_details` / `_androidDetails`** : les `NotificationDetails` triplicées sont factorisées en `const` partagées. Réduction de duplication, source unique de vérité pour l'importance/priorité.

- [🟢] **`localeListResolutionCallback`** `lib/app/view/app.dart:128` : couvre choix explicite (`[locale]`), langues système et `null` ; repli `Locale('en')` (template ARB, toujours présent). Comportement prouvé runtime (es→es) + test `APP-7` (de→en, [de,fr]→fr, null→en). Complexité O(n·m) négligeable (8 locales).

- [🟢] **Receiver manifest** `AndroidManifest.xml:70-79` : `android:exported="false"` (déclenché uniquement par le PendingIntent interne — pas de surface d'attaque), bien commenté, **sans** `ScheduledNotificationBootReceiver` ni `RECEIVE_BOOT_COMPLETED` (conforme DEC-R-04). Correctif racine correct.

- [🟢] **Gestion d'erreurs** : `try/catch` + `log()` sur toutes les opérations OS ; permission exacte en best-effort (pas d'échec si refusée). Cohérent avec le reste du service.

## Code Quality Checklist

### Standards Compliance
- [x] Conventions de nommage (FR métier / EN scaffolding) respectées
- [~] Règles projet : `permissions-zero-collecte` **enfreinte** par `SCHEDULE_EXACT_ALARM` (à ratifier) ; `enableVibration:false` respecte « pas de VIBRATE »

### Architecture
- [x] Séparation Widget → Bloc → Service → plugin maintenue
- [~] Contrat `ServiceRappel` élargi avec une méthode debug (à isoler)

### Code Health
- [x] Fonctions courtes, pas de nombres magiques (ids/canaux nommés)
- [x] Gestion d'erreurs complète (log + repli)
- [~] Code mort en release (outillage debug)

### Security
- [x] Receiver `exported=false` — pas de broadcast externe
- [x] Aucune donnée exposée, aucun réseau, aucun secret
- [x] `SCHEDULE_EXACT_ALARM` = permission fonctionnelle, **pas** de collecte (mais à ratifier côté gouvernance permissions)

### Frontend / State
- [x] États permission gérés (refusée → message + CTA réglages)
- [x] Feedback utilisateur (SnackBar debug, bannière notif)

### Error management
- [x] Tous les chemins OS encapsulés `try/catch` + `log`

## Final Review

- **Score**: 🟡 7.5/10 — implémentation correcte et vérifiée, mais 1 non-alignement gouvernance (HIGH) + nettoyage debug (MEDIUM).
- **Feedback**: Le correctif fonctionnel est solide (receiver manquant = vraie cause racine, prouvé runtime). Deux réserves : (1) `SCHEDULE_EXACT_ALARM` ajoute une permission contre le principe de minimalisme du projet et reverse le choix « inexact » du plan — à **ratifier en DEC-XXX** ou à reconsidérer (un rappel bien-être tolère souvent la minute près) ; (2) retirer l'outillage debug (`planifierTestProche` + events/boutons) avant release.
- **Follow-up Actions**:
  1. Créer `DEC-010` (ou DEC-R-xx) « Alarmes exactes pour le rappel : SCHEDULE_EXACT_ALARM + repli inexact » — ou revenir à inexact ; mettre à jour la règle `permissions-zero-collecte` (tableau des permissions autorisées).
  2. Retirer / isoler l'outillage debug (`planifierTestProche`, `RappelTestPlanifieDemande`, `_BoutonTestDebug` 2e bouton) avant build release ; envisager un `ServiceRappelTest` séparé plutôt que d'élargir l'interface prod.
  3. (Optionnel) mémoriser `canScheduleExactNotifications()` si les allers-retours deviennent un coût.
- **Additional Notes**: `flutter analyze` propre ; test `APP-7` au vert. La règle créée `aidd_docs/rules/android-notifications-scheduled.md` documente bien le receiver, mais **n'a pas** ratifié la permission exacte — cf. follow-up 1.

### Severity breakdown
- Critical: 0
- High: 1 (permission `SCHEDULE_EXACT_ALARM` non ratifiée / contre la règle permissions)
- Medium: 1 (outillage debug livré en release)
- Low: 2 (appels plateforme redondants, chaînes debug non i18n)
