# DIGIHARMONY — Vue d'ensemble projet

Application Flutter de bien-être / santé mentale (public mineur), projet Erasmus+.
**Aucun backend, aucun Firebase, zéro collecte, zéro identification** — RGPD par absence
de traitement. Hors-ligne intégral. Licence GNU GPLv3, dépôt GitHub `AlexandreMaillot/digiharmony`.

## Identité

| Élément | Valeur |
| --- | --- |
| Slug | `digiharmony` |
| ID Android / Bundle iOS | `com.creappi.digiharmony` (identique, sans underscore) |
| Plateformes | Android (prioritaire) puis iOS |
| Localisation projet | `~/StudioProjects/digiharmony` (monorepo Melos) |
| App | `apps/digiharmony_app` · package `packages/core_package` |

## Stack figée

| Domaine | Choix | Note |
| --- | --- | --- |
| DB locale | **Drift** (SQLite) | journal d'humeur, conseils, agrégats — voir DEC-001 |
| État léger persistant | **HydratedBloc** | langue + flags UI, **jamais** le journal — voir DEC-002 |
| Vibration | `HapticFeedback` natif | 0 dépendance, 0 permission |
| Audio (Detox) | `just_audio` + `just_audio_background` | wiring service/iOS à faire |
| Temps d'écran | `app_usage` | Android best-effort, iOS = repli |
| i18n | gen-l10n / ARB, 8 langues `en/fr/el/it/ro/tr/es/mk` (repli `en`) | el/ro/tr/mk = relecture native requise |
| Permissions | `PACKAGE_USAGE_STATS` uniquement | voir règle permissions-zero-collecte |

## Reste à faire (init → features)

- ARB : seul `counterAppBarTitle` scaffold → déposer le vrai bundle `digiharmony_i18n`.
- `lib/config/legal_urls.dart` : remplacer le placeholder `<org>` GitHub.
- `just_audio_background` : câbler service AndroidManifest + `UIBackgroundModes audio` iOS + `JustAudioBackground.init()` dans `main` (au moment de la feature Detox).

## Pages légales

Hébergées GitHub Pages / digiharmony.org, politique « zéro donnée » (exigée par Play même
sans collecte).
