import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/conseils/modeles/carte_conseil.dart';
import 'package:digiharmony_app/pages/conseils/widgets/_carte_shell.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Carte « Conseil pratique » du deck Conseils.
///
/// Structure :
///   - Streak accent + clouds décoratifs
///   - Tag « Conseil pratique »
///   - Headline
///   - Do's (✓ rond accent) / Don'ts (✗ rond gris)
///
/// Clés ARB : `<cle>Tag`, `<cle>Headline`, `<cle>Do1..3`, `<cle>Dont1..2`.
/// Pas de CTA (DEC-CO-09 — aucune écriture).
class CarteConseilPratiqueWidget extends StatelessWidget {
  /// Crée la carte conseil pratique.
  const CarteConseilPratiqueWidget({
    required this.carte,
    required this.accent,
    super.key,
  });

  /// Données de la carte.
  final CarteConseilPratique carte;

  /// Couleur d'accent résolue (chrome uniquement — jamais violet).
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cle = carte.cleContenu;

    final tag = resoudreCleCorpus(l10n, '${cle}Tag');
    final headline = resoudreCleCorpus(l10n, '${cle}Headline');
    final dos = resoudreLignes(l10n, cle, 'Do', 3);
    final donts = resoudreLignes(l10n, cle, 'Dont', 2);

    return ContenuCarte(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TagCarte(
            label: tag.isEmpty ? l10n.conseilsTagConseilPratique : tag,
            accent: accent,
            icone: Icons.bolt,
          ),
          const SizedBox(height: AppSpacing.md),
          if (headline.isNotEmpty)
            Text(
              headline,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (headline.isNotEmpty) const SizedBox(height: AppSpacing.md),
          if (dos.isNotEmpty) ...[
            ...dos.map((d) => PuceDo(texte: d, accent: accent)),
            const SizedBox(height: AppSpacing.xs),
          ],
          if (donts.isNotEmpty) ...donts.map((d) => PuceDont(texte: d)),
        ],
      ),
    );
  }
}
