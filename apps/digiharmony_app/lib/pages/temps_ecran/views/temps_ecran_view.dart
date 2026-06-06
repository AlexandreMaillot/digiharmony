import 'package:digiharmony_app/common/widgets/halo_respirant.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/temps_ecran/bloc/temps_ecran_bloc.dart';
import 'package:digiharmony_app/pages/temps_ecran/widgets/vue_etat_message.dart';
import 'package:digiharmony_app/pages/temps_ecran/widgets/vue_permission.dart';
import 'package:digiharmony_app/pages/temps_ecran/widgets/vue_resume.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Vue de l'écran « Mon temps d'écran ».
///
/// Toolbar : chevron · titre texte · SizedBox(48) pour centrage symétrique.
/// Halo de fond a11y-aware. Switch d'états piloté par [TempsEcranBloc].
/// Observe le cycle de vie pour basculer `permissionRequise → pret/vide`
/// au retour des réglages système (DEC-TE-07) — le Bloc ne porte pas de
/// listener (testabilité).
class TempsEcranView extends StatefulWidget {
  /// Crée la vue.
  const TempsEcranView({super.key});

  @override
  State<TempsEcranView> createState() => _TempsEcranViewState();
}

class _TempsEcranViewState extends State<TempsEcranView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<TempsEcranBloc>().add(const TempsEcranRevenuAuPremierPlan());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.homeScreenTime,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        // SizedBox symétrique pour centrer le titre (pas de burger).
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
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _Contenu(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Switch d'états (sans le footer commun, géré par la View).
class _Contenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<TempsEcranBloc, TempsEcranState>(
      builder: (context, state) {
        switch (state.status) {
          case TempsEcranStatus.chargement:
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.tempsEcranChargement,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            );
          case TempsEcranStatus.permissionRequise:
            return const Center(child: VuePermission());
          case TempsEcranStatus.pret:
            return VueResume(
              resume: state.resume!,
              historique: state.historique,
            );
          case TempsEcranStatus.vide:
            return VueEtatMessage(
              icone: Icons.hourglass_empty,
              message: l10n.tempsEcranAucuneDonnee,
              aide: l10n.tempsEcranAucuneDonneeAide,
              actionLabel: l10n.tempsEcranReessayer,
              onAction: () => context.read<TempsEcranBloc>().add(
                const TempsEcranReessaye(),
              ),
            );
          case TempsEcranStatus.indisponible:
            return VueEtatMessage(
              icone: Icons.phone_iphone,
              message: l10n.tempsEcranIndisponiblePlateforme,
            );
          case TempsEcranStatus.erreur:
            return VueEtatMessage(
              icone: Icons.error_outline,
              message: l10n.tempsEcranErreur,
              actionLabel: l10n.tempsEcranReessayer,
              onAction: () => context.read<TempsEcranBloc>().add(
                const TempsEcranReessaye(),
              ),
            );
          case TempsEcranStatus.initial:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
