/// Design system DIGIHARMONY — « Navy & Halo » (mode foncé uniquement).
///
/// Source de vérité : `aidd_docs/memory/design-system.md` + DEC-003.
/// Toute couleur d'écran DOIT venir d'ici — aucune valeur hex en dur ailleurs.
///
/// `DM Sans` est **bundlé** comme asset (4 graisses dans `assets/fonts/`) —
/// pas de `google_fonts` : zéro réseau, zéro collecte.
library;

import 'package:flutter/material.dart';

/// Palette « chrome » — habillage de l'app (jamais les couleurs d'émotion).
abstract final class AppColors {
  /// Fond principal (navy du logo).
  static const Color background = Color(0xFF1F2C49);

  /// Fond profond : splash et variantes immersives.
  static const Color backgroundDeep = Color(0xFF16213C);

  /// Surface : cartes, blocs, conseil du jour.
  static const Color surface = Color(0xFF283A5E);

  /// Primaire cyan : titres, accents, actions, icônes actives.
  static const Color primary = Color(0xFF3FB8E6);

  /// Primaire clair : états secondaires, ondes, soulignés.
  static const Color primaryLight = Color(0xFF8FD8F0);

  /// Accent or : lignes orbitales, accents fins.
  static const Color accentGold = Color(0xFFE0B24A);

  /// Texte clair sur fond foncé.
  static const Color text = Color(0xFFF2F6FB);

  /// Texte atténué : sous-titres, légendes, placeholders.
  static const Color textMuted = Color(0xFFA7B6CE);

  /// Vert d'action « appeler » — distinct de la palette émotions [MoodColors],
  /// interdite sur l'écran soutien.
  static const Color vertAppel = Color(0xFF34C759);

  /// Dégradé signature (cyan → lime → or).
  ///
  /// RÉSERVÉ aux moments de marque (splash, halo). Jamais sur le journal.
  static const List<Color> signatureGradient = <Color>[
    Color(0xFF3FB8E6),
    Color(0xFFA8D24E),
    Color(0xFFF0C84A),
  ];

  // ─── Tokens exercices bien-être (portés depuis nathan) ───────────────────

  /// Vert vif « succès / validation » — glow cycles respiration, points Étirement.
  ///
  /// Alias de [signatureGradient]\[1\] (lime A8D24E).
  static const Color successVert = Color(0xFFA8D24E);

  /// Or « accent Sens » — barre progression, icône des sens 5-4-3-2-1.
  ///
  /// Alias de [signatureGradient]\[2\] (or F0C84A).
  static const Color sensesAccentOr = Color(0xFFF0C84A);
}

/// Palette catégorielle des 7 émotions.
///
/// RÉSERVÉE au codage émotionnel (saisie, journal, calendrier, stats, reflet
/// d'accueil). Ne JAMAIS réutiliser ces teintes pour le chrome ou
/// le sémantique.
abstract final class MoodColors {
  static const Color angry = Color(0xFFE5392B); // Colère — rouge
  static const Color happy = Color(0xFFF4C20D); // Joie — jaune
  static const Color dynamic = Color(0xFFF57C1F); // Dynamique — orange
  static const Color sad = Color(0xFF3B6FE0); // Tristesse — bleu
  static const Color nervous = Color(0xFF8A3FD1); // Nerveux — violet
  static const Color calm = Color(0xFF2FAE5F); // Calme — vert
  static const Color tired = Color(0xFF8A93A6); // Fatigue — gris

  /// Accès par clé d'émotion (alignée sur le futur enum métier `core_package`).
  static const Map<String, Color> byKey = <String, Color>{
    'angry': angry,
    'happy': happy,
    'dynamic': dynamic,
    'sad': sad,
    'nervous': nervous,
    'calm': calm,
    'tired': tired,
  };
}

/// Échelle d'espacement : 4 / 8 / 16 / 24 / 32.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Rayons : boutons ~12, cartes/bulles ~24 (esthétique « bulle »).
abstract final class AppRadii {
  static const double button = 12;
  static const double card = 24;

  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(button),
  );
  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(card),
  );
}

/// Thème applicatif central (foncé uniquement).
abstract final class AppTheme {
  /// Famille de police bundlée (à déclarer dans `pubspec.yaml`).
  static const String fontFamily = 'DMSans';

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.backgroundDeep,
      secondary: AppColors.primaryLight,
      tertiary: AppColors.accentGold,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      surfaceContainerLowest: AppColors.backgroundDeep,
      surfaceContainerHighest: AppColors.surface,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: fontFamily,
      splashColor: AppColors.primary.withValues(alpha: 0.12),
      highlightColor: AppColors.primary.withValues(alpha: 0.08),
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.backgroundDeep,
          minimumSize: const Size(48, 48), // a11y : tap 48×48 dp min.
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
        ),
      ),
    );
  }

  /// Titres en cyan primaire, corps en texte clair (~16 sp).
  static TextTheme _textTheme(TextTheme base) {
    return base
        .apply(bodyColor: AppColors.text, displayColor: AppColors.text)
        .copyWith(
          headlineLarge: base.headlineLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: base.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: base.bodyLarge?.copyWith(
            color: AppColors.text,
            fontSize: 16,
          ),
        );
  }
}
