import 'package:digiharmony_app/common/placeholder_screen.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/conseils/modeles/carte_conseil.dart';
import 'package:digiharmony_app/pages/conseils/widgets/_carte_shell.dart';
import 'package:digiharmony_app/pages/saisie_humeur/modeles/emotion_canonique.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Carte « Émotion » du deck Conseils.
///
/// Headline contextuel : « Quand tu te sens {émotion}… »
/// Do's (✓ rond accent) + Don'ts (✗ rond gris).
/// CTA « Essayer la respiration » → STUB (ouvrirPlaceholder).
/// Couleur accent = `MoodColors.byKey[codeEmotion]` (jamais hex — DEC-CO-07).
class CarteEmotionWidget extends StatelessWidget {
  /// Crée la carte émotion.
  const CarteEmotionWidget({
    required this.carte,
    required this.accent,
    super.key,
  });

  /// Données de la carte.
  final CarteEmotion carte;

  /// Couleur d'accent résolue (`MoodColors.byKey[codeEmotion]`).
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cle = carte.cleContenu;
    final emotion = libelleEmotion(l10n, carte.codeEmotion);

    final dos = resoudreLignes(l10n, cle, 'Do', 3);
    final donts = resoudreLignes(l10n, cle, 'Dont', 2);

    return ContenuCarte(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag « Émotion »
          TagCarte(
            label: l10n.conseilsTagEmotion,
            accent: accent,
            icone: Icons.favorite_border,
          ),
          const SizedBox(height: AppSpacing.md),
          // Headline contextuel
          Text(
            l10n.conseilsEmotionHeadline(emotion),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Do's
          if (dos.isNotEmpty) ...[
            ...dos.map((d) => PuceDo(texte: d, accent: accent)),
            const SizedBox(height: AppSpacing.xs),
          ],
          // Don'ts
          if (donts.isNotEmpty)
            ...donts.map((d) => PuceDont(texte: d)),
          const SizedBox(height: AppSpacing.md),
          // CTA respiration (STUB — DEC-J-02 / DEC-CO-09 : pas d'écriture)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: AppColors.backgroundDeep,
                minimumSize: const Size(48, 44),
              ),
              onPressed: () => ouvrirPlaceholder(
                context,
                l10n.conseilsEmotionRespirationBientot,
              ),
              child: Text(l10n.conseilsEmotionCta),
            ),
          ),
        ],
      ),
    );
  }
}
