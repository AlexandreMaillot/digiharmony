import 'dart:async';

import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/rappel/rappel_bloc.dart';
import 'package:digiharmony_app/services/rappel/service_rappel.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Vue de la page priming pré-permission.
///
/// Explique pourquoi le rappel est utile et comment ça fonctionne avant de
/// demander la permission native. La permission n'est JAMAIS demandée au
/// montage — uniquement au tap du bouton CTA explicite
/// (DEC-R-05 / critère d'acceptation M6).
///
/// Flux :
///  - Tap « Activer » → demande permission → accordée → dispatch
///    [RappelActivationDemandee] + pop. Refusée → dispatch
///    [RappelPermissionRefusee] + pop.
///  - Tap « Plus tard » → pop sans rien activer.
class RappelPrimingView extends StatelessWidget {
  /// Crée la vue priming.
  const RappelPrimingView({super.key});

  Future<void> _onActiver(BuildContext context) async {
    final service = context.read<ServiceRappel>();
    final bloc = context.read<RappelBloc>();
    final navigator = Navigator.of(context);

    final accorde = await service.demanderPermission();
    if (accorde) {
      bloc.add(const RappelActivationDemandee());
    } else {
      bloc.add(const RappelPermissionRefusee());
    }
    // Retour à l'écran précédent (Paramètres ou invitation sheet).
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.text),
          iconSize: 32,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Icône illustrative (cloche)
              Semantics(
                excludeSemantics: true,
                child: const Icon(
                  Icons.notifications_outlined,
                  size: 72,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Titre
              Text(
                l10n.primingTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Corps
              Text(
                l10n.primingBody,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Note de confidentialité
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      l10n.primingPrivacyNote,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // CTA principal — permission demandée UNIQUEMENT ici (tap)
              Semantics(
                button: true,
                label: l10n.primingActiverCta,
                child: FilledButton(
                  onPressed: () => unawaited(_onActiver(context)),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(l10n.primingActiverCta),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // CTA secondaire — ferme sans activer
              Semantics(
                button: true,
                label: l10n.primingPlusTardCta,
                child: TextButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: AppColors.textMuted,
                  ),
                  child: Text(l10n.primingPlusTardCta),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
