# Decision: Saisie d'humeur — sélection puis bouton « Valider » (fin du 1-tap auto-save)

| Field   | Value             |
| ------- | ----------------- |
| ID      | DEC-004           |
| Date    | 2026-06-06        |
| Feature | Noter mon humeur  |
| Status  | Accepted          |

## Context

La saisie initiale enregistrait l'humeur **dès le tap** sur une pastille (UPSERT immédiat),
avec un SnackBar « Annuler » (fenêtre undo ~5 s) puis un pop automatique vers l'Accueil. Retour
utilisateur : trop implicite, pas de confirmation explicite, le mécanisme undo est superflu pour
une action instantanée.

## Decision

**Découpler sélection et enregistrement.** Un tap ne fait que **sélectionner** (état visuel, aucune
écriture Drift) ; l'enregistrement n'a lieu qu'au tap sur un bouton **« Valider »**, qui UPSERT puis
**revient à l'Accueil**. Suppression du SnackBar/Undo. À l'ouverture, l'humeur déjà notée du jour est
**pré-sélectionnée** (édition). Bloc `SaisieHumeurBloc` : events `SaisieDemarree` / `EmotionSelectionnee`
/ `SaisieValidee` ; garde anti double-écriture (bloque aussi `EnregistrementReussi`, `droppable` seul
ne suffit pas si l'UPSERT est instantané).

## Alternatives Considered

| Alternative | Pros | Cons | Rejected because |
| ----------- | ---- | ---- | ---------------- |
| Conserver le 1-tap + undo | rapide, 1 geste | implicite, undo inutile (instantané) | manque de confirmation explicite |
| Auto-save + dialog de confirmation | confirme | friction, popup intrusive | bouton Valider plus simple |

## Consequences

- ✅ Flux explicite et conforme maquette (feedback « Tu as sélectionné : X » + coche).
- ✅ Retour Accueil après Valider ; la carte humeur se met à jour via Drift `watch()`.
- ✅ Édition naturelle (pré-sélection de l'humeur du jour).
- ⚠️ Supersede les décisions undo du page plan saisie (DEC-SH-004/005/007) ; clés i18n undo
  (`saisieHumeurAnnuler`, `saisieHumeurEnregistrementEnCours`) devenues inutilisées.
- 🔗 [[architecture]] (Drift = journal, jamais HydratedBloc), [[design-system]].
