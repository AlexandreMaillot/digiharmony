import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/soutien/modeles/ressource_ligne_ecoute.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bloc conditionnel ligne d'ecoute.
///
/// Affiche l'entree correspondant a la locale courante dans [tableRessources].
/// Fallback : si la locale courante est absente, utilise l'entree 'fr'.
/// Se masque uniquement si aucune entree (y compris 'fr') n'existe.
/// (DEC-SO-007)
///
/// Rendu : carte arrondie entierement tappable (icone tel verte + nom + numero
/// / disponibilite + icone ouverture verte). Ouverture via url_launcher
/// (tel:/https:). Echec -> SnackBar neutre i18n, pas de crash, pas de log
/// distant. Aucune chaine UI en dur.
class BlocLigneEcoute extends StatelessWidget {
  /// Cree le bloc conditionnel de ligne d'ecoute.
  const BlocLigneEcoute({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final ressource =
        tableRessources[locale.languageCode] ?? tableRessources['fr'];

    if (ressource == null) return const SizedBox.shrink();

    final l10n = context.l10n;

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadii.cardRadius,
      child: InkWell(
        borderRadius: AppRadii.cardRadius,
        onTap: () => _ouvrirRessource(context, ressource),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const Icon(
                Icons.phone,
                color: AppColors.vertAppel,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.soutienLigneTitre,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${ressource.cible} — ${l10n.soutienLigneDispo}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Icon(
                Icons.open_in_new,
                color: AppColors.vertAppel,
                size: 20,
              ),
            ],
          ),
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

    // On NE gate PAS sur canLaunchUrl : sur Android 11+ il renvoie false
    // (« component name is null ») meme quand launchUrl reussit. On tente
    // l'ouverture directe et on ne signale l'echec que si launchUrl jette
    // ou renvoie false.
    bool succes;
    try {
      succes = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      succes = false;
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
