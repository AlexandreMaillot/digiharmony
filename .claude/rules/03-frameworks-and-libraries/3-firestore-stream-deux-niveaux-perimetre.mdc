---
description: Un sous-stream Firestore qui alimente une info UI dérivée ne doit être ouvert QUE pour les statuts/conditions dont l'info est affichée à l'utilisateur (typiquement actifV1==true). Pas de pré-chargement spéculatif.
globs:
  - "apps/**/lib/**/bloc/**/*.dart"
  - "apps/**/lib/core/depots/**/*.dart"
alwaysApply: false
---

# Firestore — sous-stream 2-niveaux : restreindre au périmètre affiché

## Pourquoi

Le pattern **stream 2-niveaux** (DEC-090) est puissant : pour chaque doc du
stream parent, on ouvre un sous-stream filtré. Mais cher : **chaque sous-
stream actif = 1 listener Firestore permanent + N reads facturés à chaque
snapshot du doc enfant**, tant que la page est ouverte.

Anti-pattern observé (PR #803, DEC-101) : ouvrir le sous-stream pour
**tous** les statuts du doc parent qui pourraient théoriquement avoir un
enfant, y compris ceux dont l'info dérivée n'est **pas affichée** en V1
(badges outline grisés « bientôt disponible »).

User avec 30 courses `terminee` en historique : 30 listeners pour 0 valeur
UI.

## Règle

Dès qu'un bloc / dépôt implémente un stream 2-niveaux :

1. **Définir explicitement un `Set<Statut>`** (ou prédicat équivalent) des
   conditions parent qui justifient l'ouverture du sous-stream.
2. **Le set doit lister UNIQUEMENT les statuts dont l'info dérivée est
   effectivement consommée par l'UI affichée V1** (typiquement `actifV1 == true`).
3. Documenter dans un commentaire au-dessus du set :
   - quels statuts y figurent et **pourquoi** (= info affichée) ;
   - quels statuts en sont exclus et **pourquoi** (V1.1 différé).
4. Test bloc régression-guard obligatoire : « statut hors périmètre +
   condition de sous-stream remplie → 0 abonnement ouvert ».
5. Quand un statut passe de V1.1 différé à `actifV1`, **élargir le set en
   même temps** que le mapping UI qui utilise l'info dérivée.

## Exemple — `BlocMesTrajets` (réf. DEC-101)

```dart
/// `acceptee` (V1 actif) : info paiement AFFICHÉE par le badge
/// (bascule « À payer » → « Confirmée »).
/// `enCours` / `terminee` V1.1 différés (badge outline grisé) →
/// `paiement_statut` pas affiché → inutile d'ouvrir un listener.
const Set<StatutDemande> _statutsAvecCourse = <StatutDemande>{
  StatutDemande.acceptee,
};
```

## Bypass acceptables

- Sous-stream qui alimente une info **toujours affichée** → pas besoin de
  restriction.
- Pré-chargement *justifié* (cache offline déterministe) — à motiver par ADR.

## Référence

- DEC-090 — pattern stream 2-niveaux
- DEC-100 — application Mes trajets
- DEC-101 — règle de périmètre formalisée
