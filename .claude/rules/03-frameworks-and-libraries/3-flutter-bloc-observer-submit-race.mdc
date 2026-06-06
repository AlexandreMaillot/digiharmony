---
description: Un submit qui suit immédiatement une mutation Firebase Auth (linkWithCredential, signin OTP, conversion anonyme→identifié) NE PEUT PAS se fier au cache enrichi par un observer. Lookup direct synchrone au moment critique.
globs:
  - "apps/**/lib/**/bloc/**/*.dart"
  - "apps/**/lib/pages/**/widgets/*envoyer*.dart"
  - "apps/**/lib/pages/**/widgets/*submit*.dart"
alwaysApply: false
---

# Flutter — race condition observer Auth vs submit immédiat

## Pourquoi

Pattern fréquent : un `Bloc` observe les changements Firebase Auth
(`userChanges()`) et **enrichit** le cache `UtilisateurAuth` via un fetch
Firestore secondaire (ex. `utilisateurs/{uid}.nom + prenom + idClient`).

Le cache est correct **à terme**. Mais entre une mutation Auth
(`linkWithCredential` au signin OTP, conversion anonyme→identifié, etc.) et
le **submit immédiat** qui suit, il y a une fenêtre où :
- la mutation Auth est terminée (event Firebase émis)
- l'observer reçoit l'event et lance le fetch Firestore async
- le submit reprend, lit le cache **pré-enrichissement** → données rancies

Cas vécu PR #807 :
1. User invité tape « Envoyer la demande » → modal OTP s'ouvre
2. User complète OTP step 3 → `linkWithCredential` + crée
   `utilisateurs/{uid}` avec profil
3. Modal ferme, submit reprend
4. Submit lit `auth.utilisateur` = `UtilisateurAuth` **non enrichi**
   (l'observer n'a pas encore fini son fetch)
5. Demande envoyée avec fallback téléphone au lieu du vrai nom

Le bug est **invisible aux tests unitaires** (le test ne reproduit pas le
timing réel de la fermeture modale). Détecté uniquement par paiement réel.

## Règle

Pour tout submit qui dépend d'un état Firestore dérivé d'une mutation Auth
récente :

1. **Faire un lookup direct synchrone** (try/catch) sur le doc Firestore
   pertinent **juste avant** la construction du payload submit.
2. Le profil Firestore = **source de vérité** au moment du submit.
3. Le cache `UtilisateurAuth` (enrichi par observer) sert pour
   l'affichage UI continu, mais **pas pour un submit critique**.
4. Erreur lookup → **fallback gracieux** sur le cache + log developer.
   Ne **pas** bloquer le submit.

## Exemple — `BoutonEnvoyerDemande` (réf. DEC-102)

```dart
Future<void> _onTapEnvoyer() async {
  // ... validation, recalcul pricing, etc.

  // Lookup SYNCHRONE direct juste avant submit — bypass intentionnel du
  // cache observer (race condition possible si signin OTP vient de
  // terminer dans la modale).
  final profil = await _tryLireProfil(utilisateur.uid);
  final utilisateurFinal = _enrichirAvecProfil(utilisateur, profil);

  // Construction du payload avec valeurs FRAÎCHES.
  final demande = DemandeClient.depuisCourseEtDetail(
    utilisateur: utilisateurFinal,
    nomClient: '${utilisateurFinal.prenom} ${utilisateurFinal.nom}',
    idClientLien: utilisateurFinal.idClient,
    // ...
  );
  await depot.creer(demande);
}

Future<Profil?> _tryLireProfil(String uid) async {
  try { return await depotProfil.lire(uid: uid); }
  on Object catch (e) { developer.log('profil lookup KO', error: e); return null; }
}
```

## Bypass acceptables

- Submit qui ne dépend **pas** d'un état post-mutation Auth (ex. action
  passive qui ne touche pas au profil).
- Cache déjà observé via un stream synchrone fiable (rare).

## Anti-pattern à éviter

- ❌ Attendre `auth.stream.firstWhere((u) => u.prenom != null)` avant
  submit : fragile (timeout si profil n'arrive jamais).
- ❌ Bloquer le submit jusqu'à propagation de l'enrichissement : UX floue.

## Référence

- DEC-102 — formalisation
- PR #806 (enrichissement observer) puis PR #807 (lookup synchrone fix)
