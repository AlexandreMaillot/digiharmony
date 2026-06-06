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
///   - Citation 2 lignes (ligne 2 en accent) + sous-texte atténué
///   - Do's (3 puces ✓, accent) + Don'ts (2 puces ✗, gris)
///
/// Clés ARB : `<cle>Tag`, `<cle>Citation1`, `<cle>Citation2`,
///            `<cle>SousTexte`, `<cle>Do1..3`, `<cle>Dont1..2`.
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
    final dos = resoudreLignes(l10n, cle, 'Do', 3);
    final donts = resoudreLignes(l10n, cle, 'Dont', 2);

    // Citation (26 px) — taille réduite pour cohabiter avec les Do's/Don'ts
    // dans la carte pleine hauteur sans écraser les listes.
    // Conforme maquette new_screen13.
    const tailleCitation = 26.0;

    // Maquette : Column `justify-between` en 3 zones :
    //   1. Tag
    //   2. Citation + sous-texte
    //   3. Do's + Don'ts
    return ContenuCarte(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Zone haute : tag
          TagCarte(
            label: tag,
            accent: accent,
            icone: iconeTagPourCle(cle),
          ),
          // Zone médiane : citation + sous-texte
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                citation1,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: tailleCitation,
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                ),
              ),
              if (citation2.isNotEmpty)
                Text(
                  citation2,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: tailleCitation,
                    color: accent,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                ),
              if (sousTexte.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
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
            ],
          ),
          // Zone basse : Do's + Don'ts
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dos.isNotEmpty) ...[
                ...dos.map((d) => PuceDo(texte: d, accent: accent)),
                const SizedBox(height: AppSpacing.xs),
              ],
              if (donts.isNotEmpty) ...donts.map((d) => PuceDont(texte: d)),
            ],
          ),
        ],
      ),
    );
  }
}
