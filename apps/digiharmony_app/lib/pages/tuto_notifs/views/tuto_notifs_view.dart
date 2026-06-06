import 'dart:io';

import 'package:digiharmony_app/common/widgets/halo_respirant.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/tuto_notifs/modeles/etape_tuto_modele.dart';
import 'package:digiharmony_app/pages/tuto_notifs/widgets/carte_encouragement.dart';
import 'package:digiharmony_app/pages/tuto_notifs/widgets/carte_etape.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Plateforme cible des étapes affichées.
enum CibleOs {
  /// Étapes iOS.
  ios,

  /// Étapes Android.
  android,
}

/// Vue du tutoriel « Réduire mes notifications » (statique, OS-aware).
///
/// Aucun Bloc, aucun code natif (RÉVISION 2026-06-06) : le seul état dynamique
/// est la bascule OS, portée localement (`StatefulWidget`).
class TutoNotifsView extends StatefulWidget {
  /// Crée la vue.
  ///
  /// [osInitial] permet de forcer la plateforme en test ; en prod elle est
  /// détectée via `Platform.isIOS`.
  const TutoNotifsView({this.osInitial, super.key});

  /// OS initial (override de test). Si `null`, détecté à l'`initState`.
  final CibleOs? osInitial;

  @override
  State<TutoNotifsView> createState() => _TutoNotifsViewState();
}

class _TutoNotifsViewState extends State<TutoNotifsView> {
  late CibleOs _os;

  @override
  void initState() {
    super.initState();
    _os = widget.osInitial ?? (Platform.isIOS ? CibleOs.ios : CibleOs.android);
  }

  void _basculerOs() {
    setState(() {
      _os = _os == CibleOs.ios ? CibleOs.android : CibleOs.ios;
    });
  }

  List<EtapeTutoModele> _etapes(AppLocalizations l10n) {
    if (_os == CibleOs.ios) {
      return [
        EtapeTutoModele(
          icone: Icons.settings,
          titre: l10n.tutoNotifsIosEtape1Titre,
          corps: l10n.tutoNotifsIosEtape1Corps,
        ),
        EtapeTutoModele(
          icone: Icons.notifications,
          titre: l10n.tutoNotifsIosEtape2Titre,
          corps: l10n.tutoNotifsIosEtape2Corps,
        ),
        EtapeTutoModele(
          icone: Icons.smartphone,
          titre: l10n.tutoNotifsIosEtape3Titre,
          corps: l10n.tutoNotifsIosEtape3Corps,
        ),
        EtapeTutoModele(
          icone: Icons.notifications_off,
          titre: l10n.tutoNotifsIosEtape4Titre,
          corps: l10n.tutoNotifsIosEtape4Corps,
        ),
        EtapeTutoModele(
          icone: Icons.check_circle,
          titre: l10n.tutoNotifsIosEtape5Titre,
          corps: l10n.tutoNotifsIosEtape5Corps,
        ),
      ];
    }
    return [
      EtapeTutoModele(
        icone: Icons.settings,
        titre: l10n.tutoNotifsAndroidEtape1Titre,
        corps: l10n.tutoNotifsAndroidEtape1Corps,
      ),
      EtapeTutoModele(
        icone: Icons.grid_view,
        titre: l10n.tutoNotifsAndroidEtape2Titre,
        corps: l10n.tutoNotifsAndroidEtape2Corps,
      ),
      EtapeTutoModele(
        icone: Icons.smartphone,
        titre: l10n.tutoNotifsAndroidEtape3Titre,
        corps: l10n.tutoNotifsAndroidEtape3Corps,
      ),
      EtapeTutoModele(
        icone: Icons.notifications_off,
        titre: l10n.tutoNotifsAndroidEtape4Titre,
        corps: l10n.tutoNotifsAndroidEtape4Corps,
      ),
      EtapeTutoModele(
        icone: Icons.bedtime,
        titre: l10n.tutoNotifsAndroidEtape5Titre,
        corps: l10n.tutoNotifsAndroidEtape5Corps,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final etapes = _etapes(l10n);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Image.asset(
          'assets/images/logo_digiharmony_square.png',
          height: 32,
        ),
        centerTitle: true,
        // SizedBox symétrique pour centrer le logo (pas de burger).
        actions: const [SizedBox(width: 48)],
      ),
      body: Stack(
        children: [
          const Positioned(
            top: -40,
            left: -60,
            child: HaloRespirant(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.tutoNotifsTitre,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.tutoNotifsIntro,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  for (var i = 0; i < etapes.length; i++)
                    CarteEtape(numero: i + 1, etape: etapes[i]),
                  const SizedBox(height: AppSpacing.sm),
                  const CarteEncouragement(),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: TextButton(
                      onPressed: _basculerOs,
                      child: Text(l10n.tutoNotifsAutreTelephone),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.tutoNotifsRassurance,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
