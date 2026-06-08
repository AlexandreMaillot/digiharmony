# Journal d'exécution — Kaio (DIGIHARMONY)

Run du 2026-06-05, branche `nathan`. Exécution **séquentielle** (mode dégradé : aucun
tool de sous-agent / Martin / Erwin disponible dans l'environnement → pas de
parallélisme N=4 possible ; martin = `flutter analyze` + `build_runner` + `flutter test`
lancés directement ; aucune US rattachée → aucune transition Erwin).

## Phase 1 — Fondations (martin VERT)
- core_package : pubspec (+flutter +equatable), 6 modèles (BubbleCategory, BreathingSession,
  GroundingExercise, StretchRoutine, DetoxAmbiance/DetoxDuration, DetoxSession), barrel export,
  analysis_options (public_member_api_docs off). Test models_test (8) + core (1).
- app : AppTheme + tokens (bubbleBackground #16213C, primary, success, sensesAccent, detoxSea,
  surface, muted, foreground, hubBackground) + fontFamily DM Sans (repli système, .ttf absent),
  DigiToolbar (back+titre+trailing+showMenu), AppBackground (background + halos),
  wellbeing_shared/ (AudioHint, RestartButton, ExitSessionDialog, CelebrationLayout),
  VoiceoverCubit (lib/voiceover/) + VoiceoverButton, AppDatabase Drift + WellbeingStats +
  DriftWellbeingStatsRepository (+ build_runner), bootstrap (HydratedBloc.storage +
  JustAudioBackground.init + AppDependencies), app.dart (providers + home: BubblesPage),
  bubbles_routes, ~130 clés i18n FR+EN + repli EN sur el/it/ro/tr/es/mk (8 ARB) + gen-l10n.
  Android manifest (service/receiver just_audio_background + FOREGROUND_SERVICE_MEDIA_PLAYBACK),
  iOS Info.plist (UIBackgroundModes audio). Retrait feature counter VGC + tests boilerplate.
  Test wellbeing_stats_repository (2) + app_test (1).

## Phase 2 — Pages (séquentiel)
- choisis-ta-bulle [OK] — implementer: kaio (direct) — version minimale fonctionnelle (grille 4
  bulles, haptique, navigation) ; design/animations enrichies non finalisées — tests: app_test
- respiration [OK] — US: — implemented — BreathingBloc (ticker 4-2-6 x5), BreathingAudioController
  (just_audio, fallback gracieux), vue (PopScope + dialog + célébration + cycle dots), route
  branchée — tests: breathing_bloc_test (3 : complète 1x, quit sans incrément, restart reset)
- les-sens [OK] — US: — implemented — SensesBloc (progression manuelle 5-4-3-2-1, sans timer),
  SensesAudioController, vue (indicateur, récap chips, instruction, précédent/suivant), route —
  tests: senses_bloc_test (4) + smoke
- detox-config [OK] — US: — implemented — DetoxSetupCubit (HydratedBloc, défauts Mer+15, repli
  robuste fromJson), vue (grille ambiances, sélecteur durées, récap live, CTA), DetoxRoutes,
  route — tests: detox_setup_cubit_test (4) + smoke
- detox-player [OK] — US: — implemented — DetoxPlayerBloc (timer → progress/bloom), DetoxPlayer
  Controller (just_audio_background, SEUL écran), DetoxBloomPainter (fleur 8 pétales + arc),
  vue (badge ambiance, barre, conseil avion statique, dialog sortie), args — tests:
  detox_player_bloc_test (3 : complète 1x, sortie anticipée 0 incrément, progress dérivé)
- etirement [OK] — US: — implemented — StretchBloc (ticker multi-segments 200ms, 4 segments),
  StretchAudioController, vue (guide, liste segments pilotée ticker, temps global, pause au tap),
  route — tests: stretch_bloc_test (3)

## Phase 3 — Merge + vérif globale (martin VERT)
- Pas de merge de worktree (exécution directe sur `nathan`).
- martin full : app analyze **No issues**, app test **22 passed** ; core analyze **No issues**,
  core test **9 passed**. Total 31 tests verts. build_runner Drift OK. gen-l10n OK.
- Review code (auto) : conformité contraintes dures vérifiée — zéro dep réseau/analytics/Firebase,
  aucun google_fonts, HapticFeedback uniquement (aucun package vibration), just_audio_background
  cantonné à bootstrap + detox player controller, JustAudioBackground.init unique, home: BubblesPage.

## Score de complétude (lot 1)
- Respiration / Les sens / Détox-config / Détox-player / Étirement : ~95 % (logique métier,
  états, audio fallback, Drift, i18n, reduceMotion respecté côté painters/celebration, tests
  bloc verts). Reste : polish visuel/animations fines vs mockups, audio binaires absents
  (fallback en place), relecture native el/ro/tr/mk.
- Choisis ta bulle : ~70 % (fonctionnel mais design/animations float+shimmer non finalisés).
- Global lot 1 : ~90 %.

---

# Lot 2 — 4 écrans hors-bulles (run du 2026-06-05, branche `nathan`)

Exécution **séquentielle** (mode dégradé : aucun tool de sous-agent / worktree / Martin /
Erwin exposé ; martin = `flutter analyze` + `build_runner` + `flutter test` lancés directement ;
aucune US rattachée → aucune transition Erwin). Aligné sur le **CODE RÉEL FR** (pas les plans
rédigés en anglais avant le renommage).

## Phase 1 — Fondation LangueCubit (martin VERT)
- core_package : modèle `LangueApp` + `kLanguesSupportees` (8 locales, autonymes NON traduits)
  + modèles lot 2 (`EmotionNegative`/`ConseilEmotion`/`CatalogueConseils`,
  `PlateformeGuide`/`EtapeGuideNotifications`/`CatalogueGuideNotifications`,
  `ResumeTempsEcran`/`UsageJour`), barrel exporté. Test lot2_models (9).
- app : `LangueCubit` (HydratedCubit<Locale>, défaut = langue device si supportée sinon en,
  garde-fou 8 locales, persistant). Câblé app.dart (MultiBlocProvider + BlocBuilder +
  MaterialApp.locale). Helper test pump_app étendu (paramètre langueCubit). Test langue_cubit (5).

## Phase 2 — 4 écrans (séquentiel)
- conseils [OK] — ConseilsView (PageView viewportFraction 0.86 + PointsCarrousel barre couleur
  émotion + ControlesCarrousel prev/sep/next désactivés aux bornes), CarteConseil (accent +
  à-faire/à-éviter + CTA respiration → RespirationPage), CTA « J'applique » = haptique + SnackBar
  + pop (0 Drift). ArgsConseils{idEmotionInitiale} repli 1re carte. Tokens thème angerRed + alias.
  Tests : conseils_view_test (4). i18n advice* (39 clés).
- guide-notifications [OK] — GuideNotificationsPage (StatefulWidget, plateforme injectable),
  EnteteMarque (header dédié, ne touche PAS BarreOutils ; logo asset local + fallback gracieux,
  zéro réseau), CarteEtapeGuide, BandeauConseilGuide (sun sensesAccent), LienAutreTelephone
  (bascule android↔ios + haptique). Menu hamburger no-op TODO. Fond hubBackground. Tests :
  guide_notifications_page_test (2, bascule 2 sens). i18n notifGuide* (29 clés, jeux Android + Ios).
- temps-ecran [OK] — TempsEcranCubit (5 états, court-circuit non-Android avant channel),
  DepotTempsEcran + DepotTempsEcranMethodChannel (canal MAISON digiharmony/screen_time, zéro dep
  tierce), MainActivity Kotlin (AppOps OPSTR_GET_USAGE_STATS, ACTION_USAGE_ACCESS_SETTINGS,
  queryUsageStats agrégé lun→dim), JaugeTempsEcranPainter (arc 8h réf) + HistogrammeSemainePainter,
  re-fetch au resume (WidgetsBindingObserver), bannière confidentialité, actions → DetoxConfigPage /
  GuideNotificationsPage. AUCUN stockage. PACKAGE_USAGE_STATS déjà au manifeste. Tests :
  temps_ecran_cubit_test (5) + temps_ecran_view_test (3). i18n screenTime* (25 clés).
- parametres [OK] — ParametresView (sélecteur 8 langues → LangueCubit.setLocale LIVE + persistance,
  ligne cochée = état Cubit), CarteConfidentialite (shield), TuileLienExterne (GitHub/site via
  LegalUrls + ouvrirLienExterne url_launcher externalApplication, fallback silencieux),
  BandeauErasmus (🇪🇺), footer AppInfo.version. Autonymes hors ARB. Tests : parametres_view_test (3,
  dont bascule live FR→EN). i18n settings* (12 clés).

## Phase 3 — Merge + vérif globale (martin VERT)
- Pas de merge de worktree (exécution directe sur `nathan`).
- martin full : app analyze **No issues**, app test **44 passed** ; core analyze **No issues**,
  core test **18 passed**. Total **62 tests verts**. build_runner Drift OK (191 outputs). gen-l10n OK.
- Review code (auto) : contraintes dures vérifiées — zéro cached_network_image/Image.network/
  google_fonts/app_usage/usage_stats dans lib (seules occurrences = commentaires de négation),
  aucun package vibration (HapticFeedback only), MethodChannel maison (conformité zéro-réseau),
  aucune permission ajoutée au manifeste (PACKAGE_USAGE_STATS déjà présent).

## Score de complétude (lot 2)
- Conseils : ~90 % (carrousel/dots/contrôles/CTA fonctionnels, catalogue source de vérité, i18n
  FR/EN, reduceMotion sobre par construction). Reste : polish déco (peek/particules/glow non
  implémentés — volontairement, info conservée), couleurs émotions à valider visuellement, hook
  Journal « J'applique » documenté non câblé (Journal non planifié).
- Guide notifications : ~95 % (100 % statique, bascule plateforme, fallback logo). Reste : déposer
  l'asset logo réel ; menu global défini avec Home (no-op TODO).
- Temps d'écran : ~90 % côté Dart (Cubit 5 états, repository mockable, painters, resume, i18n).
  Kotlin écrit mais NON exécuté/validé sur device (pas de build APK ici) — à tester sur Android réel
  (permission spéciale + agrégation queryUsageStats). Convention semaine = 7 jours glissants
  ordonnés lun→dim.
- Paramètres : ~95 % (bascule langue LIVE + persistance, liens externes, version). Reste :
  package_info_plus optionnel (constante retenue), relecture native des traductions.
- i18n : 6 langues el/it/ro/tr/es/mk remplies en repli EN (à traduire). ARB reformatés (indent 4)
  par le script d'injection — diff cosmétique sur l'existant, contenu inchangé.
- Global lot 2 : ~92 % (logique/états/tests complets ; reste polish visuel + validation native
  Android + traductions).
