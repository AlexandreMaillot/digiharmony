# Registre des plans — DIGIHARMONY

> Index des page plans de `aidd_docs/tasks/`. Statut : `proposition_a_valider` → `valide` → `implemente`.
> Ordre d'implémentation : **Fondations d'abord**, puis Splash et Accueil (qui en dépendent).

| Plan | Page / Rôle | US (GitHub) | Milestone | Dépend de | Tests | Statut |
|---|---|---|---|---|---|---|
| [foundations-bootstrap.md](./foundations-bootstrap.md) | Socle technique (thème, Drift, HydratedBloc, LocaleCubit, routing, assets, splash natif) | [#3](https://github.com/AlexandreMaillot/digiharmony/issues/3) (US-FND-01) | Phase 1 | — | `foundations-bootstrap.tests.md` ✅ | **implemente** |
| [splash-screen.md](./splash-screen.md) | Démarrage (Splash, route `/`) | [#1](https://github.com/AlexandreMaillot/digiharmony/issues/1) | Phase 1 | Fondations | `splash-screen.tests.md` ✅ | **implemente** |
| [accueil-home.md](./accueil-home.md) | Accueil / Home (route `/home`) | [#2](https://github.com/AlexandreMaillot/digiharmony/issues/2) | Phase 1 | Fondations | `accueil-home.tests.md` ✅ | **valide** |

## Composants partagés (fournis par Fondations)

`AppTheme` · `AppColors` · `MoodColors` · `AppSpacing` · `AppRadii` · `AppDatabase` (Drift) · `LocaleCubit` · `OnboardingCubit` · `AppRouter` · placeholders (Onboarding/Home).

## Décisions de validation (2026-06-05) — font foi

- **Émotions = 7 canoniques** (DEC-003) : `happy/calm/dynamic/sad/angry/nervous/tired` (clés `mood*` alignées dans le plan Accueil).
- **Logo carré** `logo_digiharmony_square.png` (969×969) pour splash central/header/splash natif/icône lanceur (`flutter_launcher_icons` dev-dependency). Rectangulaire conservé pour illustration ; `logo_eu_funding.png` = footer.
- **i18n V1** : `fr`+`en` réels, repli `en` (TODO) pour `el/it/ro/tr/es/mk`.
- **Conseils** : seed placeholder ~7 (fr+en), rotation déterministe.
- **`mood_entries`** : schéma minimal provisoire (lecture seule A/B), étendu plus tard.
- **Couche de données en FRANÇAIS** : tables/colonnes/DAO/entités/méthodes Drift en français (`EntreesHumeur`/`entrees_humeur`, `EntreeHumeur`, `Conseil`, `codeEmotion`, `creeLe`, `cleConseil`, `observerDerniereHumeurDuJour()`, `conseilDuJour()`). Voir `architecture.md`.
- **Features / pages en FRANÇAIS** : racine domaine FR + suffixes Flutter standard (`AccueilPage`/`AccueilBloc`/`AccueilView`/`AccueilState`), fichiers/dossiers FR (`lib/accueil/`). **Splash → Demarrage**, **Onboarding → Bienvenue**, **Home → Accueil**. Scaffolding technique (`AppTheme`/`AppDatabase`/`AppRouter`/`LocaleCubit`/`bootstrap`) reste en anglais.
- **Implémentation** : orchestrée par **Kaio**, branche `alexandre`, **une PR par lot** (Fondations → Splash → Accueil) vers `main`.

## Assets en place

`logo_digiharmony.png`, `logo_digiharmony_square.png`, `logo_eu_funding.png`, DM Sans (Regular/Medium/SemiBold/Bold) — installés et câblés au pubspec.
