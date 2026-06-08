# Registry des plans de page — DIGIHARMONY

Source de vérité des pages planifiées. Une ligne par page.

## Statut d'implémentation (Kaio, 2026-06-05)

### Lot 1 — 6 écrans bulles (renommés FR)

| Page | Statut | Tests |
| --- | --- | --- |
| Choisis ta bulle (BullesPage) | implemented (version minimale fonctionnelle) | app_test |
| Respiration (RespirationPage) | implemented + reviewed | respiration_bloc_test (3) |
| Les sens (SensPage) | implemented + reviewed | sens_bloc_test (4), smoke |
| Détox config (DetoxConfigPage) | implemented + reviewed | detox_setup_cubit_test (4), smoke |
| Détox lecteur (DetoxLecteurPage) | implemented + reviewed | detox_player_bloc_test (3) |
| Étirement (EtirementPage) | implemented + reviewed | stretch_bloc_test (3) |

### Lot 2 — 4 écrans hors-bulles (FR, 2026-06-05) — martin VERT

| Page | Statut | Tests |
| --- | --- | --- |
| Fondation LangueCubit (HydratedCubit<Locale>) | implemented | langue_cubit_test (5) + lot2_models (kLanguesSupportees) |
| Conseils (ConseilsPage) | implemented | conseils_view_test (4) + lot2_models (CatalogueConseils, 4) |
| Couper mes notifications (GuideNotificationsPage) | implemented | guide_notifications_page_test (2) + lot2_models (CatalogueGuideNotifications, 2) |
| Mon temps d'écran (TempsEcranPage) | implemented | temps_ecran_cubit_test (5) + temps_ecran_view_test (3) + lot2_models (ResumeTempsEcran, 1) |
| Paramètres (ParametresPage) | implemented | parametres_view_test (3) |

Lot 2 — martin VERT : app analyze **No issues** + app test **44 passed** ; core analyze
**No issues** + core test **18 passed** (total **62 verts**). build_runner Drift OK, gen-l10n OK
(+104 clés FR/EN, repli EN sur 6 langues). Voir `_execution.md` pour le détail.

### Noms FRANÇAIS retenus (lot 2)

- Fondation : `LangueCubit` (lib/langue/langue_cubit.dart), modèle core `LangueApp` +
  `kLanguesSupportees` (lib/src/langue/). Câblé dans app.dart (MultiBlocProvider + MaterialApp.locale).
- Conseils : `ConseilsPage`/`ConseilsView`, `ArgsConseils{idEmotionInitiale}`, `RoutesConseils`,
  widgets `CarteConseil`/`PointsCarrousel`/`ControlesCarrousel`. Core : `EmotionNegative`,
  `ConseilEmotion`, `ExerciceConseil`, `CatalogueConseils.all`. Thème : `angerRed` + alias émotions.
- Guide notifs : `GuideNotificationsPage`, widgets `EnteteMarque`/`CarteEtapeGuide`/
  `BandeauConseilGuide`/`LienAutreTelephone`. Core : `PlateformeGuide`, `EtapeGuideNotifications`,
  `CatalogueGuideNotifications`. Logo asset local + fallback gracieux (pas de réseau).
- Temps d'écran : `TempsEcranPage`/`TempsEcranView`, `TempsEcranCubit` (états Chargement/
  PermissionRequise/NonSupporte/Charge/Erreur), `DepotTempsEcran` + `DepotTempsEcranMethodChannel`
  (canal `digiharmony/screen_time`), painters `JaugeTempsEcranPainter`/`HistogrammeSemainePainter`,
  Kotlin MainActivity (com.creappi.digiharmony). Core : `ResumeTempsEcran`/`UsageJour`.
- Paramètres : `ParametresPage`/`ParametresView`, `AppInfo.version`, `ouvrirLienExterne`,
  widgets `SectionParametres`/`CarteParametres`/`TuileLangue`/`TuileLienExterne`/
  `CarteConfidentialite`/`BandeauErasmus`. Réutilise `LegalUrls` + url_launcher.

Fondations (Phase 1) : AppTheme + tokens, DigiToolbar, AppBackground, wellbeing_shared/,
VoiceoverCubit, AppDatabase Drift + WellbeingStats + repository, bootstrap (HydratedBloc +
JustAudioBackground.init), app.dart (home: BubblesPage), bubbles_routes, 6 modèles core_package,
~130 clés i18n FR+EN + repli EN sur 8 ARB. martin VERT (analyze + build_runner + 31 tests).

Voir `_execution.md` pour le détail par page.

- Choisis ta bulle: /bubbles (BubblesPage) — US: — aidd_docs/tasks/choisis-ta-bulle.md
  - shared_components: DigiToolbar, AppBackground, BubbleCard
  - cibles navigation: BreathingPage, SensesPage, StretchPage, DetoxPage (créées en parallèle)
- Respiration: /bubble/breathing (BreathingPage) — US: — aidd_docs/tasks/respiration.md
  - shared_components: DigiToolbar (étendu: trailing), AppBackground (étendu: background), AppTheme (tokens breathingBackground/success)
  - nouveaux: BreathingSession/BreathPhase (core_package), BreathingBloc, VoiceoverCubit (HydratedBloc), BreathingAudioController (just_audio assets), WellbeingStats + repository (Drift — fonde la DB locale)
  - parent: BubblesPage (cible navigation 'breathing' à brancher dans bubbles_routes.dart)
- Les sens: /bubble/senses (SensesPage) — US: — aidd_docs/tasks/les-sens.md
  - shared_components RÉUTILISÉS: DigiToolbar (trailing), AppBackground (background), AppTheme, VoiceoverCubit (flag partagé), WellbeingStatsRepository (Drift, exerciseId='senses')
  - nouveaux: GroundingExercise/GroundingStep/GroundingSense (core_package, technique 5-4-3-2-1 figée), SensesBloc (machine d'états MANUELLE, sans timer), SensesAudioController (just_audio assets)
  - refactor cross-page recommandé: renommer AppTheme.breathingBackground → bubbleBackground ; ajouter sensesAccent #F0C84A ; promouvoir VoiceoverCubit sous lib/voiceover/ (+ extraction VoiceoverButton partagé)
  - parent: BubblesPage (cible navigation 'senses' à brancher dans bubbles_routes.dart)
- Détox (config): /bubble/detox (DetoxSetupPage — étape de CONFIGURATION) — US: — aidd_docs/tasks/detox.md
  - shared_components RÉUTILISÉS: DigiToolbar (showMenu:false, trailing:null), AppBackground (background #16213C), AppTheme (tokens à ajouter: surface #283A5E, muted #A7B6CE, detoxSea #2FAE5F ; réutilise success #A8D24E + breathingBackground)
  - nouveaux: DetoxAmbiance/DetoxAmbianceId + DetoxDuration (core_package, listes statiques 4 ambiances + 3 durées 5/10/15), DetoxSetupCubit (HydratedBloc, sélection persistée — défauts Mer + 15 min), DetoxRoutes (builder vers lecteur)
  - audio: Détox = SEUL écran autorisé à just_audio_background, MAIS lecture réelle côté LECTEUR (pas ici). Assets locaux assets/audio/detox/{water,sea,white_noise,forest}.mp3
  - cible navigation (plan dédié): DetoxPlayerPage /bubble/detox/player → aidd_docs/tasks/detox-player.md. Contrat nav: {ambianceId, durationMinutes}
  - états: nominal uniquement (pas d'empty/error) ; retour direct au hub sans dialog
  - parent: BubblesPage (cible navigation 'detox' à brancher dans bubbles_routes.dart)
- Détox (lecteur): /bubble/detox/player (DetoxPlayerPage — écran de LECTURE audio « Ta pause ») — US: — aidd_docs/tasks/detox-player.md
  - shared_components RÉUTILISÉS: DigiToolbar (trailing = badge ambiance), AppBackground (background #16213C), AppTheme (bubbleBackground, success #A8D24E, sensesAccent #F0C84A, detoxSea #2FAE5F, muted #A7B6CE — tous déjà posés), WellbeingStatsRepository (Drift, exerciseId='detox', même AppDatabase)
  - nouveaux: DetoxSession (core_package, ambianceId+total ; réutilise DetoxAmbianceId/DetoxDuration de detox-setup), DetoxPlayerArgs (contrat nav entrant {ambianceId, durationMinutes}), DetoxPlayerBloc (timer → temps restant/barre/arc/fleur ; états playing|completed, PAS de paused), DetoxPlayerController (wrapper just_audio_background — 1er et SEUL usage projet, asset local bouclé), DetoxBloomPainter (CustomPainter fleur 8 pétales + arc de progression, piloté par progress/bloomProgress)
  - audio: SEUL écran à câbler just_audio_background (JustAudioBackground.init + service Android + UIBackgroundModes iOS). Assets locaux assets/audio/detox/{water,sea,white_noise,forest}.mp3, LoopMode.one, zéro réseau
  - fin naturelle (timer→0): célébration + audio.stop + WellbeingStats('detox') +1 (garde-fou statsPersisted) + HapticFeedback.lightImpact ; sortie anticipée « Terminer la pause »/chevron/back: selectionClick + dialog confirmation (PopScope), 0 incrément Drift
  - décoratif coupé si reduceMotion (shimmer conique, petal-breathe, particules, core-pulse) ; arc + épanouissement fleur CONSERVÉS (information, par paliers)
  - i18n: clés detoxPlayer* (FR+EN, repli EN) ; labels d'ambiance detoxAmbiance*Label RÉUTILISÉS de detox-setup (non redéfinis)
  - états: playing, completed/célébration, dialog sortie. Pas d'empty/error (asset manquant → fallback silencieux). Pas de VoiceoverCubit (pas de voix off ici)
  - parent: DetoxSetupPage (/bubble/detox) → brancher navigation « Lancer » → DetoxPlayerPage(args)
- Étirement: /bubble/stretch (StretchPage) — US: — aidd_docs/tasks/etirement.md
  - shared_components RÉUTILISÉS: DigiToolbar (trailing), AppBackground (background #16213C=bubbleBackground), AppTheme (réutilise success #A8D24E=primary écran, primary #3FB8E6, foreground ; ajouter muted #A7B6CE si absent), VoiceoverCubit (flag partagé), WellbeingStatsRepository (Drift, exerciseId='stretch' — même table/AppDatabase, pas de codegen)
  - nouveaux: StretchRoutine/StretchSegment/StretchSegmentId (core_package, routine 4 segments figés Ancrage→Cou&épaules→Mains→Reposer la vue, durées + clés i18n), StretchBloc (machine d'états TICKER multi-segments — proche BreathingBloc, PAS manuel comme SensesBloc), StretchAudioController (just_audio SIMPLE assets — PAS just_audio_background)
  - progression: AUTOMATIQUE MINUTÉE (ticker, barres+compteur global pilotés) ; pause optionnelle au tap sur le guide ; célébration etir-complete ; dialog « Quitter la séance ? » si en cours
  - visuel: guide animé / anneau conique / barres / timer-ring en CustomPainter + flutter_animate (PAS d'asset image, PAS de package tiers) ; reduceMotion désactive les boucles déco mais garde barres+compteur à jour
  - candidat refactor cross-page (4ᵉ bulle) : promouvoir kit partagé lib/wellbeing_shared/ (VoiceoverButton, AudioHint, RestartButton, ExitSessionDialog, CelebrationLayout) — non bloquant
  - parent: BubblesPage (cible navigation 'stretch' à brancher dans bubbles_routes.dart)
- Mon temps d'écran: /screen-time (ScreenTimePage) — US: — aidd_docs/tasks/temps-decran.md
  - ⭐ FEATURE PHARE — SEULE permission autorisée du projet: PACKAGE_USAGE_STATS (Android UsageStatsManager). Lecture 100% locale, zéro collecte, zéro réseau, AUCUN stockage (ni Drift ni HydratedBloc), lecture on-demand
  - shared_components RÉUTILISÉS: DigiToolbar (trailing:null), AppBackground (background=appBackground #1F2C49 — FOND STANDARD app, PAS le fond bulle #16213C), AppTheme (surface #283A5E, primary #3FB8E6, success #A8D24E, foreground, muted #A7B6CE ; AJOUTER token appBackground #1F2C49 si absent)
  - nouveaux: ScreenTimeSummary/DayUsage (core_package, donnée pure immuable, 7 jours lun→dim, AUCUN dart:io), ScreenTimeRepository (app, encapsule platform channel — interface mockable mocktail), MethodChannelScreenTimeRepository (impl Kotlin "digiharmony/screen_time"), ScreenTimeCubit (états loading/permissionRequired/unsupported/loaded/error), ScreenTimeGaugePainter + WeeklyHistogramPainter (CustomPainter, PAS de charts tiers, PAS d'asset)
  - permission spéciale (point sensible): PAS runtime classique → hasUsageAccess (AppOps OPSTR_GET_USAGE_STATS) ; CTA « Autoriser » → ACTION_USAGE_ACCESS_SETTINGS ; re-vérif au resume (AppLifecycleState.resumed → refresh). 3 états: permissionRequired / unsupported (iOS, court-circuit avant channel) / loaded
  - dépendance: MethodChannel MAISON privilégié (zéro dep tierce, conformité garantie) ; package pub usage (usage_stats/app_usage) = ALTERNATIVE À VALIDER/AUDITER (absence réseau/analytics) — non retenu par défaut
  - manifeste: <uses-permission PACKAGE_USAGE_STATS tools:ignore="ProtectedPermissions" /> SEULEMENT (pas de VIBRATE → HapticFeedback, pas d'INTERNET)
  - haptique: HapticFeedback.selectionClick sur 2 cartes-action + CTA autorisation
  - navigation: « Faire une pause » → /bubble/detox (DetoxSetupPage déjà planifié) ; « Couper mes notifications » → /notifications-guide (route logique, écran À PLANIFIER séparément — placeholder en attendant)
  - reduceMotion: jauge + halo + histogramme rendus statiques à leur valeur finale (déco coupé, information conservée)
  - i18n: clés screenTime* (FR+EN remplis, placeholders el/it/ro/tr/es/mk, repli en) ; bannière confidentialité = texte i18n STATIQUE (pierre angulaire RGPD)
  - candidat refactor: ScreenTimeActionCard → kit partagé lib/wellbeing_shared/ si 2ᵉ usage (non bloquant)
  - parent: Accueil/Home (point d'entrée à brancher ; masquage iOS = décision Home, non présumée)
- Couper mes notifications: /notifications-guide (NotificationGuidePage — guide/tutoriel STATIQUE 5 étapes) — US: — aidd_docs/tasks/notifications-guide.md
  - 🟢 ÉCRAN 100% STATIQUE: aucune donnée Drift, aucun HydratedBloc, AUCUNE permission, aucun audio, aucun réseau, aucune persistance. Seul état dynamique = plateforme affichée (local NON persistant)
  - shared_components RÉUTILISÉS: AppBackground (background=AppTheme.hubBackground #1F2C49 — fond STANDARD app, PAS bubbleBackground #16213C), AppTheme (hubBackground/surface/primary/sensesAccent #F0C84A/foreground/muted/radiusSmall — AUCUN nouveau token requis), DigiToolbar (rendu chevron retour réutilisé)
  - ⚠️ CORRECTION vs temps-decran.md: le token de fond #1F2C49 existe DÉJÀ sous AppTheme.hubBackground → NE PAS créer 'appBackground'. Icône sun jaune = sensesAccent (#F0C84A), PAS accent (#F5C842)
  - nouveaux core_package: NotificationGuidePlatform (enum android/ios), NotificationGuideStep (donnée pure Equatable: index + titleKey/bodyKey i18n + IconData Material), NotificationGuideCatalog (2 jeux statiques figés androidSteps/iosSteps + stepsFor) — style identique StretchRoutine/GroundingExercise
  - nouveaux app: DigiBrandHeader (toolbar app-shell: chevron + logo+label « DigiHarmony » + menu — Option A recommandée, ne touche PAS DigiToolbar), GuideStepCard, GuideTipBanner, OtherPhoneLink
  - VARIANTE PLATEFORME: lien « Voir pour un autre téléphone » bascule android↔ios (2 jeux i18n, suffixe Ios) + HapticFeedback.selectionClick ; plateforme initiale = Platform.isIOS (encapsulable/mockable) ; état NON persistant (StatefulWidget par défaut, sinon Cubit léger NON HydratedBloc)
  - logo = ASSET LOCAL assets/images/logo.png (À DÉPOSER + déclarer pubspec — aucune section assets: aujourd'hui) ; FALLBACK gracieux obligatoire (placeholder/label, ZÉRO réseau, JAMAIS cached_network_image — les URLs Banani/Firebase = export maquette only)
  - bouton MENU (hamburger): HORS-SCOPE → posé en no-op TODO (action définie avec écran Home/app-shell) ; alternative = le retirer (signalé, non tranché)
  - navigation retour: Navigator.maybePop → parent RÉEL non présumé (/screen-time via carte temps-decran.md, ou Home) ; câblage table de routes /notifications-guide à brancher côté app-shell
  - i18n: clés notifGuide* (FR+EN remplis, placeholders el/it/ro/tr/es/mk en repli en) ; 2 jeux étapes (Android défaut + variantes suffixe Ios) ; menu/sous-titre/conseil/lien
  - reduceMotion: contenu statique (AppBackground sans boucle) ; si apparition échelonnée ajoutée → neutralisée (cartes à l'état final, info conservée)
  - états: nominal + bascule plateforme. PAS d'empty/error/loading (statique)
  - candidats refactor cross-page (non bloquants): DigiBrandHeader (app-shell) + GuideStepCard → kit partagé lib/wellbeing_shared/ si 2ᵉ usage
  - parent: « Mon temps d'écran » /screen-time (cible navigation déjà référencée, jusqu'ici placeholder) — ou Home selon point d'entrée
- Conseils: /advice (AdvicePage) — carrousel de conseils par émotion — US: — aidd_docs/tasks/conseils.md
  - RÉCONCILIATION ARCHITECTURE: le CATALOGUE de conseils (contenu fixe par émotion) = DONNÉE DE RÉFÉRENCE STATIQUE dans core_package (AdviceCatalog.all, clés i18n) = SOURCE DE VÉRITÉ UNIQUE. PAS en Drift (éviterait duplication DEC-001/DEC-002). Seed Drift lecture-seule SEULEMENT si une feature SQL l'impose (non requis ici). Drift = uniquement faits dérivés (conseil appliqué, super-conseil), à câbler avec le Journal
  - shared_components RÉUTILISÉS: DigiToolbar (title + onBack, SANS trailing, showMenu=false → spacer 48px = design « pas de bouton à droite »), AppBackground (background=bubbleBackground #16213C), AppTheme
  - nouveaux core_package: NegativeEmotion enum (anger/sadness/fear/stress/loneliness) + EmotionAdvice (Equatable, clés i18n + Color + AdviceExercise) + AdviceCatalog.all (5 cartes const, byId/indexOf) — pattern BubbleCategory/StretchSegment
  - nouveaux AppTheme: angerRed #E5392B (du mockup) + alias émotions sadnessBlue(=primary)/fearViolet #9B7BE8/stressAmber(=sensesAccent)/lonelinessGreen(=success) — À VALIDER visuellement (seul le rouge colère vient du mockup) ; éventuel radiusCard=16
  - PAS de Bloc (état UI pur): PageController + index dans AdviceView (StatefulWidget). Réévaluer si bloc_lint impose un Bloc/page → AdviceCubit minimal (1 champ int index). Pas de Drift, pas de HydratedBloc sur cet écran
  - carrousel: PageView (viewportFraction ~0.86, peek via Stack) + _AdviceDots (actif = barre allongée couleur émotion #E5392B) + contrôles prev|sep|next (désactivés aux bornes) + swipe — TOUS synchronisés (même PageController)
  - contrat d'entrée OPTIONNEL: AdviceArgs{ String? initialEmotionId } — null=mode CATALOGUE (1re carte) ; fourni=ouvre sur l'émotion (mode contextuel futur Journal) ; inconnu=repli 1re carte. Pas de filtrage dur (carrousel complet parcourable)
  - actions: « Essayer la respiration » (CTA carte, fond couleur émotion, Icons.air) → /bubble/breathing (BreathingPage, respiration.md ; émotion en contexte optionnelle) ; « J'applique ce conseil » (CTA bas cyan #3FB8E6, Icons.check) → HapticFeedback + SnackBar confirmation + Navigator.maybePop, 0 Drift (callback onApply découplé)
  - POINTS D'EXTENSION (non implémentés): hook « J'applique » → écriture Drift via onApply quand Journal planifié ; SUPER-CONSEIL (7 émotions nég. consécutives DEC-001/DEC-002) → carte spéciale injectée en tête de carrousel via param List<EmotionAdvice> (défaut AdviceCatalog.all), compteur DÉRIVÉ de Drift jamais dupliqué ; seed Drift catalogue
  - haptique: HapticFeedback.selectionClick sur changement de carte (prev/next/swipe) + « Essayer la respiration » + « J'applique »
  - icônes Material only: chevron_left/right, favorite (heart), check, close (x), air (wind). AUCUN asset image (cartes empilées via Stack)
  - reduceMotion: coupe décoratif (swipe-hint, clouds, particules, emotion-glow, ptcl, cta-in, bg-card-peek) ; garde navigation + dots + affichage + listes
  - i18n: clés advice* (FR+EN remplis, placeholders el/it/ro/tr/es/mk repli en) ; transverses (adviceTitle/adviceEmotionLabel/adviceDoSectionLabel/adviceAvoidSectionLabel/adviceTryBreathing/advicePrev/adviceNext/adviceApply/adviceAppliedConfirmation) + par émotion adviceCardTitle{Emotion}/adviceDo{Emotion}1..3/adviceAvoid{Emotion}1..2
  - états: nominal + navigation. PAS d'empty/error (catalogue const non vide) ; repli si initialEmotionId inconnu → 1re carte
  - parent: Journal d'humeur / Home (PAS encore planifié) — chevron retour = Navigator.maybePop par nom de route, parent non présumé. DÉPENDANCE Journal signalée (mode contextuel + hook « appliqué » + super-conseil) — non bloquante
- Paramètres: /settings (SettingsPage) — langue + confidentialité + projet (open source/site/Erasmus+) + version — US: — aidd_docs/tasks/parametres.md
  - ⭐ PIÈCE MAÎTRESSE = SÉLECTEUR DE LANGUE: pilote la bascule LIVE de toute l'app via LocaleCubit PARTAGÉ (HydratedBloc). Tap langue → HapticFeedback.selectionClick + LocaleCubit.setLocale(Locale) → MaterialApp.locale rebuild instantané + persistance auto. Ligne cochée = état courant du Cubit
  - shared_components RÉUTILISÉS: DigiToolbar (trailing:null, showMenu=false → spacer 48px), AppBackground (background=hubBackground #1F2C49 = fond STANDARD app, halo cyan statique), AppTheme (hubBackground/surface/primary/foreground/muted/radiusSmall/Large/fontFamily), LegalUrls (lib/config/legal_urls.dart DÉJÀ présent: github=github.com/AlexandreMaillot/digiharmony, website=https://digiharmony.org)
  - ⚠️ TOKEN: le fond #1F2C49 réel s'appelle AppTheme.hubBackground (PAS appBackground comme dit ailleurs dans ce registry/temps-decran). Aligné sur le code. Radius 8/16 absents (présents 12/20/24) → mapper sur existant (12/24), ajouter radiusXSmall=8 seulement si divergence visible
  - ⚠️ LocaleCubit N'EXISTE PAS encore (vérifié): à FONDER (HydratedCubit<Locale>, pattern VoiceoverCubit) sous lib/locale/cubit/ + câbler dans app/view/app.dart (MultiBlocProvider à côté de VoiceoverCubit + MaterialApp.locale=state, actuellement absent). app.dart câble déjà AppTheme.themeData/VoiceoverCubit/WellbeingStatsRepository/home=BubblesPage
  - nouveaux core_package: AppLocale (donnée pure: code/flag emoji/autonym) + kSupportedAppLocales (8 locales ORDRE en/fr/el/it/ro/tr/es/mk = AppLocalizations.supportedLocales). AUTONYMES NON TRADUITS (constantes, JAMAIS dans ARB): English/Français/Ελληνικά/Italiano/Română/Türkçe/Español/Македонски. Drapeaux = emojis texte (🇬🇧 pour en), JAMAIS assets
  - nouveaux app: AppInfo.version (constante de build, défaut « 1.0 » → « DIGIHARMONY v1.0 » ; alternative package_info_plus 100% local conforme mais +1 dép + async → non retenu par défaut, à valider) ; widgets SettingsSection/SettingsCard/LanguageTile/ExternalLinkTile/PrivacyNoticeCard/ErasmusBanner
  - liens externes: url_launcher (DÉJÀ au pubspec ^6.3.2, dép acceptée) mode externalApplication = délégation OS, PAS de réseau applicatif/tracking → conforme zéro collecte. canLaunchUrl false → FALLBACK SILENCIEUX (pas de crash). URLs via LegalUrls (jamais en dur)
  - icônes Material only: Icons.verified_user (shield-check confidentialité), Icons.code (GitHub — PAS de package icônes de marque tiers ; asset SVG local si vrai logo exigé), Icons.public (globe), Icons.open_in_new (external-link). 🇪🇺 = emoji bandeau Erasmus+
  - haptique: HapticFeedback.selectionClick sur sélection langue (×8) + taps liens externes
  - MENU GLOBAL: /settings = cible documentée du hamburger global (cohérence avec notifications-guide/app-shell). Câblage du hamburger fait côté Home/app-shell, PAS recâblé ici (juste signalé)
  - i18n: clés settings* (FR+EN remplis, placeholders el/it/ro/tr/es/mk repli en): settingsTitle/SectionLanguage/SectionPrivacy/PrivacyNotice/SectionProject/OpenSourceTitle/OpenSourceSubtitle/WebsiteTitle/WebsiteSubtitle/ErasmusNotice/Version{version}. Note confidentialité + Erasmus+ = textes i18n STATIQUES (RGPD). Noms de langue = autonymes hors ARB
  - PAS de Bloc dédié à l'écran (seule donnée mutable = langue, déjà dans LocaleCubit partagé). PAS de Drift, PAS de permission. États: NOMINAL uniquement (pas d'empty/loading/error ; échec URL = fallback silencieux)
  - reduceMotion: écran quasi statique (AppBackground sans boucle). Si fade ajouté → neutralisé à l'état final
  - parent: Home/menu global — chevron retour = Navigator.pop par nom de route, parent non présumé
