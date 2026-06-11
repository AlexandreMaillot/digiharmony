import 'dart:async';

import 'package:digiharmony_app/app/routing/app_router.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/rappel/rappel_bloc.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Section « Rappel quotidien » dans l'écran Paramètres (DEC-R-01, M7).
///
/// Affiche un toggle d'activation et, quand activé, un sélecteur d'heure.
/// Reflète toujours l'état réel (y compris permission refusée). Calqué sur
/// la SectionLangue — BlocBuilder + titre + corps.
///
/// Règles :
/// - Activer le toggle → ouvre la page priming (jamais la permission directe).
/// - Désactiver → dispatch RappelDesactive.
/// - Changer l'heure → dispatch RappelHeureChangee (replanifie si actif).
/// - permissionRefusee → message bienveillant + CTA réglages OS.
class SectionRappel extends StatelessWidget {
  /// Crée la section rappel.
  const SectionRappel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<RappelBloc, RappelState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre de section
            Text(
              l10n.rappelSectionTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Ligne toggle
            _LigneToggle(actif: state.actif),
            // Ligne heure (visible/actif seulement si rappel activé)
            if (state.actif) ...[
              const SizedBox(height: AppSpacing.xs),
              _LigneHeure(heure: state.heure),
            ],
            // Message permission refusée
            if (state.permissionRefusee) ...[
              const SizedBox(height: AppSpacing.sm),
              _MessagePermissionRefusee(),
            ],
            // DEBUG : bouton de test (retiré en release).
            if (kDebugMode) ...[
              const SizedBox(height: AppSpacing.sm),
              const _BoutonTestDebug(),
            ],
          ],
        );
      },
    );
  }
}

/// Ligne toggle activer/désactiver le rappel.
class _LigneToggle extends StatelessWidget {
  const _LigneToggle({required this.actif});

  final bool actif;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Semantics(
      label: l10n.rappelToggleLabel,
      toggled: actif,
      child: SwitchListTile(
        value: actif,
        onChanged: (valeur) => _onToggle(context, valeur: valeur),
        title: Text(
          l10n.rappelToggleLabel,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.text,
          ),
        ),
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
        contentPadding: EdgeInsets.zero,
        // Cible ≥ 48dp : SwitchListTile garantit une hauteur minimale de 48dp.
      ),
    );
  }

  void _onToggle(BuildContext context, {required bool valeur}) {
    unawaited(HapticFeedback.selectionClick());
    if (valeur) {
      // Activer → page priming (jamais permission directe — DEC-R-05/06).
      unawaited(AppRouter.versRappelPriming(context));
    } else {
      context.read<RappelBloc>().add(const RappelDesactive());
    }
  }
}

/// Ligne de sélection de l'heure via time picker natif.
class _LigneHeure extends StatelessWidget {
  const _LigneHeure({required this.heure});

  final TimeOfDay heure;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final heureFormatee = MaterialLocalizations.of(context).formatTimeOfDay(
      heure,
    );

    return Semantics(
      label: '${l10n.rappelHeureLabel} : $heureFormatee',
      button: true,
      child: InkWell(
        borderRadius: AppRadii.buttonRadius,
        onTap: () => unawaited(_choisirHeure(context)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.rappelHeureLabel,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                ),
                Text(
                  heureFormatee,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _choisirHeure(BuildContext context) async {
    final nouvelleHeure = await showTimePicker(
      context: context,
      initialTime: heure,
      helpText: context.l10n.rappelHeurePickerTitle,
    );
    if (nouvelleHeure != null && context.mounted) {
      context.read<RappelBloc>().add(RappelHeureChangee(nouvelleHeure));
    }
  }
}

/// Message d'information quand la permission OS est refusée ou révoquée.
class _MessagePermissionRefusee extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: AppRadii.buttonRadius,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  l10n.rappelPermissionRefuseeMessage,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            button: true,
            label: l10n.rappelOuvrirReglagesOsCta,
            child: TextButton(
              onPressed: () => _ouvrirReglages(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 48),
                foregroundColor: AppColors.primary,
              ),
              child: Text(l10n.rappelOuvrirReglagesOsCta),
            ),
          ),
        ],
      ),
    );
  }

  void _ouvrirReglages(BuildContext context) {
    // Ouvrir les réglages app via url_launcher n'est pas disponible
    // nativement dans Flutter sans un package supplémentaire (interdit par
    // DEC-R-01). On affiche un message d'aide guidant l'utilisateur vers les
    // réglages système (MAJOR-3 / critère 7 : message d'aide, pas le CTA).
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.rappelPermissionRefuseeMessage),
      ),
    );
  }
}

/// DEBUG : bouton de diagnostic envoyant une notification immédiate.
///
/// Présent uniquement en mode debug (`kDebugMode`). Permet de vérifier que la
/// livraison OS fonctionne, indépendamment de la planification / du skip
/// « déjà noté ». À retirer une fois le diagnostic terminé.
class _BoutonTestDebug extends StatelessWidget {
  const _BoutonTestDebug();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        unawaited(HapticFeedback.selectionClick());
        context.read<RappelBloc>().add(const RappelTestDemande());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification test envoyée (debug)'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      icon: const Icon(Icons.notifications_active_outlined, size: 18),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(0, 48),
      ),
      label: const Text('Tester la notification maintenant (debug)'),
    );
  }
}
