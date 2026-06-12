# Decision: Langue par défaut = système si supportée, sinon anglais

| Field   | Value                  |
| ------- | ---------------------- |
| ID      | DEC-009                |
| Date    | 2026-06-12             |
| Feature | i18n / LocaleBloc      |
| Status  | Accepted               |

## Context

Sans choix de langue explicite (`LocaleState.locale == null`, suivi système),
`MaterialApp` résout via `basicLocaleListResolution`, qui **retombe sur le 1ᵉʳ
`supportedLocales`** quand la langue du téléphone n'est pas supportée. Or la liste
générée par gen-l10n est en **ordre alphabétique** → 1ᵉʳ = `el` (grec). Un téléphone
en langue non supportée (ex. allemand) affichait donc l'app en **grec**, alors que la
doc projet stipule « repli `en` ». Le repli anglais était documenté mais **non
appliqué**.

## Decision

Ajouter un `localeListResolutionCallback` sur le `MaterialApp` (`lib/app/view/app.dart`) :
suit la **1ʳᵉ langue du téléphone supportée** (match par `languageCode`), sinon repli
explicite `Locale('en')`. Couvre aussi le choix explicite (`preferredLocales` =
`[locale]`) et le cas `null`. Le sélecteur Paramètres reflète déjà la locale résolue
(`state.locale?.languageCode ?? Localizations.localeOf(context).languageCode`).

## Alternatives Considered

| Alternative | Pros | Cons | Rejected because |
| ----------- | ---- | ---- | ---------------- |
| Réordonner `supportedLocales` (en en 1ᵉʳ) | aucun code | ordre imposé par gen-l10n, fragile à la régénération | non garanti dans le temps |
| Forcer `Locale('en')` par défaut si `locale == null` | simple | casse le suivi automatique de la langue du téléphone | contredit « langue auto du téléphone » |

## Consequences

- ✅ App s'affiche dans la langue du téléphone si supportée, sinon anglais (jamais grec
  par accident). Vérifié runtime (es→es) + test `APP-7` (de→en, [de,fr]→fr, null→en).
- ✅ Aligne le comportement réel sur la doc « repli `en` ». [[architecture]]
