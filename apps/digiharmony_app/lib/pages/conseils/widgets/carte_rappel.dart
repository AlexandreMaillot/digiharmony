import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/conseils/modeles/carte_conseil.dart';
import 'package:digiharmony_app/pages/conseils/widgets/_carte_shell.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Carte « Rappel » du deck Conseils.
///
/// Structure :
///   - Streak accent 4 px en haut
///   - Tag (icône + libellé)
///   - Citation 2 lignes (ligne 2 en accent)
///   - Sous-texte atténué
///
/// Clés ARB : `<cle>Tag`, `<cle>Citation1`, `<cle>Citation2`, `<cle>SousTexte`.
class CarteRappelWidget extends StatelessWidget {
  /// Crée la carte rappel.
  const CarteRappelWidget({
    required this.carte,
    required this.accent,
    super.key,
  });

  /// Données de la carte.
  final CarteRappel carte;

  /// Couleur d'accent résolue.
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cle = carte.cleContenu;

    final citation1 = resoudreCleCorpus(l10n, '${cle}Citation1');
    final citation2 = resoudreCleCorpus(l10n, '${cle}Citation2');
    final sousTexte = resoudreCleCorpus(l10n, '${cle}SousTexte');
    final tag = resoudreCleCorpus(l10n, '${cle}Tag');

    return ContenuCarte(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TagCarte(
            label: tag,
            accent: accent,
            icone: Icons.wb_sunny_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            citation1,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 28,
              color: AppColors.text,
              fontWeight: FontWeight.bold,
              height: 1.15,
            ),
          ),
          if (citation2.isNotEmpty)
            Text(
              citation2,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 28,
                color: accent,
                fontWeight: FontWeight.bold,
                height: 1.15,
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          if (sousTexte.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Text(
                sousTexte,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
