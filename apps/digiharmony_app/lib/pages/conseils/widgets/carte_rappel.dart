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

    // Citation (28 px de base ; agrandie à 40 px quand la carte n'a qu'une
    // seule ligne — tipDay01..07 sans Citation2/SousTexte — pour occuper
    // visiblement la carte pleine hauteur, conforme maquette new_screen13).
    final citationSeule = citation2.isEmpty && sousTexte.isEmpty;
    final tailleCitation = citationSeule ? 40.0 : 28.0;

    // Maquette : Column `justify-between` en 3 zones (tag / citation /
    // sous-texte). Quand Citation2 et SousTexte sont vides (rappels-citation),
    // la citation reste centrée verticalement dans la carte pleine hauteur
    // grâce à `spaceBetween` (carte intentionnelle, jamais « cassée »).
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
            icone: Icons.wb_sunny_outlined,
          ),
          // Zone médiane : citation (centrée verticalement)
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
            ],
          ),
          // Zone basse : sous-texte (SizedBox vide si absent → garde la
          // distribution `spaceBetween`).
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
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
