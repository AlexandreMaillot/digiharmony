import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/soutien/modeles/ressource_ligne_ecoute.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bloc conditionnel ligne d'ecoute.
///
/// Affiche uniquement si [tableRessources] contient une entree pour
/// la locale courante. Sinon, rendu vide (masque). (DEC-SO-007)
///
/// Ouverture via url_launcher (tel:/https:).
/// Echec -> SnackBar neutre, pas de crash, pas de log distant.
/// Aucun numero reel hardcode.
class BlocLigneEcoute extends StatelessWidget {
  /// Cree le bloc conditionnel de ligne d'ecoute.
  const BlocLigneEcoute({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final ressource = tableRessources[locale.languageCode];

    if (ressource == null) return const SizedBox.shrink();

    final l10n = context.l10n;

    return Card(
      color: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.cardRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.phone, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '${l10n.soutienLignePrefix}${ressource.nom}',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${l10n.soutienLigneDispoPrefix}${ressource.disponibilite}',
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _ouvrirRessource(context, ressource),
                icon: Icon(
                  ressource.type == TypeRessourceEcoute.telephone
                      ? Icons.phone
                      : Icons.open_in_new,
                  color: AppColors.primary,
                ),
                label: Text(
                  ressource.nom,
                  style: const TextStyle(color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.buttonRadius,
                  ),
                  minimumSize: const Size(48, 48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _ouvrirRessource(
    BuildContext context,
    RessourceLigneEcoute ressource,
  ) async {
    final Uri uri;
    if (ressource.type == TypeRessourceEcoute.telephone) {
      uri = Uri(scheme: 'tel', path: ressource.cible);
    } else {
      uri = Uri.parse(ressource.cible);
    }

    bool succes;
    try {
      final peutOuvrir = await canLaunchUrl(uri);
      if (!peutOuvrir) {
        succes = false;
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        succes = true;
      }
    } on Exception {
      succes = false;
    }

    if (!succes && context.mounted) {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.soutienErreurLien),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
