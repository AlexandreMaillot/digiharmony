import 'package:flutter/material.dart';

/// Tokens design centralises de DIGIHARMONY (couleurs, radius, police).
///
/// La police `DM Sans` est declaree dans `pubspec.yaml` en asset local.
/// Si le `.ttf` n'est pas encore depose, Flutter retombe gracieusement sur
/// la police systeme (aucun crash, aucun reseau — pas de `google_fonts`).
abstract final class ThemeApplication {
  /// Famille de police de l'app (asset local, repli systeme si absent).
  static const String fontFamily = 'DM Sans';

  // --- Couleurs (tokens) ---

  /// Fond bleu nuit du hub.
  static const Color hubBackground = Color(0xFF1F2C49);

  /// Fond bleu nuit partage par les ecrans bulle (ex-`breathingBackground`).
  static const Color bubbleBackground = Color(0xFF16213C);

  /// Cyan primaire.
  static const Color primary = Color(0xFF3FB8E6);

  /// Jaune d'accent (hub).
  static const Color accent = Color(0xFFF5C842);

  /// Accent jaune fidele au mockup « Les sens ».
  static const Color sensesAccent = Color(0xFFF0C84A);

  /// Vert de validation / point cycle rempli / glow.
  static const Color success = Color(0xFFA8D24E);

  /// Vert « Mer » (Detox).
  static const Color detoxSea = Color(0xFF2FAE5F);

  /// Surface des cartes (Detox).
  static const Color surface = Color(0xFF283A5E);

  /// Texte attenue / sous-titres.
  static const Color muted = Color(0xFFA7B6CE);

  /// Texte principal clair.
  static const Color foreground = Color(0xFFF2F6FB);

  // --- Couleurs des emotions (carrousel Conseils) ---

  /// Rouge colere (fidele au mockup Conseils). Seule couleur emotion issue
  /// du mockup ; les autres sont des alias des tokens existants.
  static const Color angerRed = Color(0xFFE5392B);

  /// Bleu tristesse (alias de [primary]).
  static const Color sadnessBlue = primary;

  /// Violet peur (reutilise la teinte « senses »).
  static const Color fearViolet = Color(0xFF9B7BE8);

  /// Jaune stress (alias de [sensesAccent]).
  static const Color stressAmber = sensesAccent;

  /// Vert solitude (alias de [success]).
  static const Color lonelinessGreen = success;

  // --- Radius ---

  /// Petit radius.
  static const double radiusSmall = 12;

  /// Radius moyen.
  static const double radiusMedium = 20;

  /// Grand radius.
  static const double radiusLarge = 24;

  /// Theme Material de l'app (mode sombre, fond bleu nuit, DM Sans).
  static ThemeData get themeData {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: bubbleBackground,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        onPrimary: bubbleBackground,
        onSurface: foreground,
      ),
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: foreground,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: foreground,
        displayColor: foreground,
        fontFamily: fontFamily,
      ),
    );
  }
}
