# Registre des plans — DIGIHARMONY

> Index des page plans de `aidd_docs/tasks/`. Statut : `proposition_a_valider` → `valide` → `implemente`.
> Ordre d'implémentation : **Fondations d'abord**, puis Splash et Accueil (qui en dépendent).

| Plan | Page / Rôle | US (GitHub) | Milestone | Dépend de | Tests | Statut |
|---|---|---|---|---|---|---|
| [foundations-bootstrap.md](./foundations-bootstrap.md) | Socle technique (thème, Drift, HydratedBloc, LocaleCubit, routing, assets, splash natif) | [#3](https://github.com/AlexandreMaillot/digiharmony/issues/3) (US-FND-01) | Phase 1 | — | `foundations-bootstrap.tests.md` ✅ | **implemente** |
| [splash-screen.md](./splash-screen.md) | Splash Screen (route `/`) | [#1](https://github.com/AlexandreMaillot/digiharmony/issues/1) | Phase 1 | Fondations | `splash-screen.tests.md` ✅ | **implemente** |
| [accueil-home.md](./accueil-home.md) | Accueil (route `/accueil`) | [#2](https://github.com/AlexandreMaillot/digiharmony/issues/2) | Phase 1 | Fondations | `accueil-home.tests.md` ✅ | **implemente** |
| [noter-humeur.md](./noter-humeur.md) | Noter mon humeur (saisie 1-tap, `SaisieHumeurPage` empilée) | Noter mon humeur (Erwin) | Phase 1 | Fondations (#3), Accueil (#2) | `noter-humeur.tests.md` ⏳ | **valide** |
| [soutien.md](./soutien.md) | Écran de soutien (« Super conseil », `SoutienPage` empilée, déclenchée à l'ouverture) | Écran de soutien (Erwin) | Phase 1 | Noter mon humeur (#6), Fondations (#3) | `soutien.tests.md` ⏳ | **valide** |
| [temps-ecran.md](./temps-ecran.md) | Mon temps d'écran (`TempsEcranPage` empilée, lecture **native Android** via `app_usage` + MethodChannel `digiharmony/usage_access` + historique Drift schéma v3) | [#12](https://github.com/AlexandreMaillot/digiharmony/issues/12) (US-TE-01), [#13](https://github.com/AlexandreMaillot/digiharmony/issues/13) (US-TE-02) | Phase 2 | Fondations (#3), Accueil (#2) | bloc + view + modèles + db ✅ | **implemente** |
| [tuto-notifs.md](./tuto-notifs.md) | Réduire mes notifications (`TutoNotifsPage` empilée, **tutoriel statique OS-aware** — RÉVISION Banani 2026-06-06, **aucun natif / aucun MethodChannel / 0 permission / 0 dépendance**, US-TN-02 abandonnée) | [#14](https://github.com/AlexandreMaillot/digiharmony/issues/14) (US-TN-01) | Phase 2 | Fondations (#3), Accueil (#2) | view ✅ | **implemente** |
| [parametres.md](./parametres.md) | Paramètres (`ParametresPage` empilée — **choix langue 8 EN DIRECT via `LocaleBloc` existant** + carte confidentialité « zéro donnée » + liens projet open source/site via `url_launcher` + mention Erasmus+ ; **0 nouveau Bloc / 0 permission**, version **dynamique via `package_info_plus`**, lien site masqué V1) | US-PARAM-01/02 (à créer via Erwin) | Phase 2 | Fondations (#3 — LocaleBloc, LegalUrls), Accueil (#2 — icône réglages header) | parametres.tests.md ⏳ | **valide** |
| [conseils.md](./conseils.md) | Conseils (`ConseilsPage` empilée — **deck de cartes swipables** 3 types rappel/conseil/emotion ; **sélection DÉTERMINISTE par jour** (`% n`, comme `conseilDuJour`) + **carte émotion en tête selon l'humeur DU JOUR** (`observerDerniereHumeurDuJour`, couleur `MoodColors`) ; corpus = table `Conseils` **étendue** (schéma v4) ; CTA « J'applique » **sans persistance** ; CTA respiration = **stub** ; **contenu = placeholder à valider partenaires**) | US-CO-01/02 (à créer via Erwin) | Phase 2 🟡 | Fondations (#3), Noter mon humeur (#6 — humeur) | conseils.tests.md ✅ | **implemente** |

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
