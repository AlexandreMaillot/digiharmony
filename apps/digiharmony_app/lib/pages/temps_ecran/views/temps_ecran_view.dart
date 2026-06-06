import 'package:digiharmony_app/common/anim/anim_constants.dart';
import 'package:digiharmony_app/common/widgets/halo_respirant.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/temps_ecran/bloc/temps_ecran_bloc.dart';
import 'package:digiharmony_app/pages/temps_ecran/services/service_temps_ecran.dart';
import 'package:digiharmony_app/pages/temps_ecran/widgets/vue_autorisation_ios.dart';
import 'package:digiharmony_app/pages/temps_ecran/widgets/vue_etat_message.dart';
import 'package:digiharmony_app/pages/temps_ecran/widgets/vue_permission.dart';
import 'package:digiharmony_app/pages/temps_ecran/widgets/vue_rapport_ios.dart';
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
              child: _ContenuAvecTransition(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wrapper qui enveloppe [_Contenu] avec un crossfade doux lors des
/// transitions d'état (chargement → contenu, etc.).
/// En reduced-motion, le switch est direct (pas de fondu).
class _ContenuAvecTransition extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (disableAnimations) return _Contenu();

    return BlocBuilder<TempsEcranBloc, TempsEcranState>(
      buildWhen: (prev, curr) => prev.status != curr.status,
      builder: (context, state) => AnimatedSwitcher(
        duration: dureeEntree,
        switchInCurve: curveEntree,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey(state.status),
          child: _Contenu(),
        ),
      ),
    );
  }
}

/// Switch d'états (sans le footer commun, géré par la View).
///
/// Le différenciateur iOS/Android en état [TempsEcranStatus.pret] se fait
/// via [ServiceTempsEcran.rapportEmbarque] (DEC-TE-12) :
///   - iOS (`rapportEmbarque == true`) → [VueRapportIos] (PlatformView).
///   - Android (`rapportEmbarque == false`) → [VueResume] (jauge custom).
/// Le Bloc reste agnostique de la plateforme.
class _Contenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final service = context.read<ServiceTempsEcran>();

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
            // iOS : écran d'autorisation FamilyControls dédié (DEC-TE-15).
            // Android : écran d'accès PACKAGE_USAGE_STATS existant.
            return Center(
              child: service.rapportEmbarque
                  ? const VueAutorisationIos()
                  : const VuePermission(),
            );
          case TempsEcranStatus.pret:
            // iOS : PlatformView DeviceActivityReport (rapport système).
            // Android : jauge + historique custom.
            if (service.rapportEmbarque) {
              return Column(
                children: [
                  const Expanded(child: VueRapportIos()),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.tempsEcranIosDonneesSysteme,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              );
            }
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
