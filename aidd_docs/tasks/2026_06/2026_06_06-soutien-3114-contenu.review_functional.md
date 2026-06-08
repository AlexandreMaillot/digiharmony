---
name: review_functional
description: Functional review report template
argument-hint: N/A
---

# Functional Review for Soutien / Super conseil — contenu + 3114 + fix déclenchement

- **Plan**: `aidd_docs/plans/soutien-super-conseil.plan.md`
- **Diff scope**: `5183e2e...HEAD`
- **Date**: 2026-06-06

## Verdict

**PARTIAL** — Le fix de déclenchement et le contenu Confiance sont conformes et prouvés, mais le bloc ligne d'écoute introduit une **régression i18n bloquante** (libellés FR en dur) qui contredit le critère « aucune chaîne UI en dur » du plan (§5(5), M6 §398) ; et le passage du 3114 réel en fallback toutes-langues s'écarte du DON'T d'origine (§151 « aucun numéro réel hardcodé ») — écart assumé/tracé mais à acter formellement.

## Scoring Matrix

| Criterion | Files | Status | Severity | Notes |
| --------- | ----- | ------ | -------- | ----- |
| C1 — Bloc ligne d'écoute affiché si ressource présente, masqué sinon | `bloc_ligne_ecoute.dart:25-28` | Met | — | Fallback `fr` + masquage si `null`. Conforme DEC-SO-007 (évolué : fallback `fr` au lieu de masquage strict). |
| C2 — Aucune chaîne UI en dur (plan §5(5)) | `ressource_ligne_ecoute.dart:56,59` | **Unmet** | **Blocker** | « Ligne d'écoute » / « Disponible 24h/24 » en dur dans le modèle, rendus par `bloc_ligne_ecoute.dart:51,58`. Clés ARB `soutienLignePrefix`/`soutienLigneDispoPrefix` **supprimées**. Non-FR via fallback voit du FR. |
| C3 — Aucun hex en dur, tokens uniquement (plan §154) | `theme.dart:39`, `bloc_ligne_ecoute.dart:42,69` | Met | — | `vertAppel` dans `theme.dart`, consommé via `AppColors`. 0 `0xFF` dans `lib/pages/soutien/`. |
| C4 — Numéro réel : DON'T d'origine = « pas de 3114 » (plan §151) | `ressource_ligne_ecoute.dart:55-60` | Partial | Major | Écart assumé : 3114 ajouté (numéro FR validé partenaires). Tracé (TODO l.48-50, DEC-SO-007). Mais montré aux 7 locales non-FR via fallback → risque produit public mineur. |
| C5 — Garde-fou « aucun AUTRE numéro réel » (SO-RES-3) | `ressource_ligne_ecoute_test.dart:59-127` | Met | — | Liste noire ARB efficace + assertion stricte `fr.cible=='3114'`. ARB sans numéro. |
| C6 — Ouverture via url_launcher (tel:/https:), échec → SnackBar neutre | `bloc_ligne_ecoute.dart:80-113` | Met | — | `canLaunchUrl`/`launchUrl(externalApplication)`, `on Exception` → SnackBar i18n `soutienErreurLien`. Pas de crash, pas de log distant. |
| C7 — ConfiancePage : pistes bienveillantes via i18n, retour pop, zéro collecte | `confiance_page.dart:19-25,33` | Met | — | 5 pistes via `soutienConfiancePiste01..05` (clés i18n), `Navigator.pop`, aucun formulaire/réseau. |
| C8 — Fix séquence : compteur évalué AVANT navigation, Navigator capturé | `demarrage_view.dart:113-153` | Met | — | Capture `navigator`/`db`/`soutienBloc` avant tout await ; `await compteur` ; `unawaited(pushReplacement)`. Corrige l'ancien `await versAccueil` qui ne se résolvait jamais. |
| C9 — NAV-S : compteur≥7 → SoutienMontre + SoutienPage (échouerait sans fix) | `demarrage_navigation_test.dart:178-334` | Met | — | NAV-S-1 vérifie `add(SoutienMontre)` + `find(SoutienPage)` ; NAV-S-2 `<7→rien` ; NAV-S-3 déjàMontré→pas de re-push ; NAV-S-4 réarmement. |
| C10 — Anti-relance, montré une fois par épisode, réarmé sous seuil | `demarrage_view.dart:126-153` | Met | — | `SoutienReinitialise` si `compteur<seuil && dejaMontre` ; `doitDeclencher` pur. |
| C11 — Aucune entrée manuelle prod vers SoutienPage | `demarrage_view.dart` (seul appel) | Met | — | Push soutien uniquement dans le hook auto post-splash. |
| C12 — Ton non alarmant, aucune relance, zéro collecte (url_launcher seul) | `confiance_page.dart`, `bloc_ligne_ecoute.dart` | Met | — | Aucun SDK réseau/analytics ; pas de minuterie/notif. |
| C13 — a11y : cibles ≥48dp, reduced-motion | `confiance_page.dart:37`, `demarrage_view.dart:45,55` | Partial | Minor | Chevron 48×48 ✅, carte InkWell ≥48dp ✅, reduced-motion ✅. Manque : pas de `Semantics` explicite sur la carte d'appel ; label vocal = concat FR figée (conséquence C2). |
| C14 — Caveat 3114 fallback toutes langues documenté/tracé | `ressource_ligne_ecoute.dart:11-14,41-50`, plan « Hors périmètre V1 » | Met | — | DEC-SO-007 + TODO partenaires + section Hors périmètre. Réserve actée. |

## Missing Behaviors

Critères d'acceptation sans trace conforme dans le diff.

- [ ] **C2 — « aucune chaîne UI en dur »** : les libellés `soutienLigneTitre`/`soutienLigneDispo` (ex-`soutienLignePrefix`/`soutienLigneDispoPrefix`) ne sont plus dans les ARB ; le rendu passe par des chaînes FR codées en dur. Comportement attendu par le plan (M6 §398) absent.

## Unplanned Behaviors

Changements présents dans le diff non tracés à un critère d'acceptation d'origine (à confirmer avec l'auteur — la spec d'origine interdisait le 3114).

- [ ] **3114 hardcodé dans `tableRessources['fr']`** : le plan d'origine imposait `tableRessources` **vide** (`const {}`) tant que les partenaires n'avaient rien validé (§123, §151). L'ajout du 3114 est un **changement de décision** (DEC-SO-007 évolué) — légitime si validé partenaires, mais hors du périmètre du plan initial. À acter formellement comme amendement de décision.
- [ ] **Token `AppColors.vertAppel`** (`theme.dart:39`) : nouveau token de couleur d'action non prévu par le plan (qui mappait l'accent sur `primary`). Cohérent avec `design-system.md` (vert succès distinct), mais ajout non planifié — confirmer scope.
- [ ] **Refonte maquette `BlocLigneEcoute`** (icônes `phone`/`open_in_new`, carte tappable Material/InkWell) : évolution UI au-delà du « carte + prefix » du plan. Non bloquant, cohérent.

## Flow / Edge-case Gaps

Lacunes surfacées en confrontant chaque critère au diff.

- [ ] **Fallback `fr` → utilisateur non-FR** : un mineur en locale `el/tr/it/ro/es/mk/en` voit le bloc « Ligne d'écoute — 3114 — Disponible 24h/24 » entièrement en français, avec un numéro non opérant dans son pays. Double problème : i18n (C2) + pertinence du numéro (C4). Le comportement DEC-SO-007 d'origine (« bloc masqué si absente ») aurait évité les deux ; le passage au fallback `fr` réintroduit le risque.
- [ ] **`launchUrl` sur exception** : feedback UX présent (SnackBar) mais pas de `developer.log` (règle `7-catch-silencieux` recommande log + feedback). Tolérable en zéro-collecte mais signalé.
- [ ] **Test `SO-RES-2` verrouille la régression** : `ressource_ligne_ecoute_test.dart:38-43` assert `fr.nom == "Ligne d'écoute"`, gravant la chaîne FR en dur comme comportement attendu. Le correctif i18n devra mettre à jour ce test.

## Summary

- **Criteria covered**: 11/14 Met, 2 Partial, 1 Unmet.
- **Blockers**: 1 (C2 — régression i18n / texte en dur).
- **Follow-up actions**:
  1. Restaurer les libellés ligne d'écoute en clés i18n (8 ARB) ; `BlocLigneEcoute` les consomme via `context.l10n` ; ne garder que `cible`/`type` dans le modèle.
  2. Trancher le sort du 3114 hors France (masquer le bloc locales non-FR, ou garde locale `fr`) et acter l'amendement DEC-SO-007.
  3. Mettre à jour `SO-RES-2` (ne plus figer `fr.nom`).
  4. (Optionnel) `Semantics` sur la carte d'appel ; `developer.log` sur échec `launchUrl`.
- **Additional notes**: Le fix de déclenchement est solide et réellement prouvé par NAV-S-1..4 (l'ancien `await versAccueil`/`pushReplacement` ne se résolvait jamais → branche soutien morte au runtime). Garde-fous anti-numéro (SO-RES-3) intacts. Le bloquant est strictement l'i18n du bloc ligne d'écoute, pas la mécanique de déclenchement ni la sensibilité du contenu Confiance.
