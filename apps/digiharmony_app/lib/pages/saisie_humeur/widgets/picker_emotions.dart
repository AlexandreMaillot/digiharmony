import 'package:digiharmony_app/pages/saisie_humeur/bloc/saisie_humeur_bloc.dart';
import 'package:digiharmony_app/pages/saisie_humeur/modeles/emotion_canonique.dart';
import 'package:digiharmony_app/pages/saisie_humeur/widgets/pastille_emotion.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Grille des 7 pastilles d'émotion.
///
/// Réactif à l'état du [SaisieHumeurBloc] :
/// - Sélection courante → anneau sur la pastille correspondante.
/// - Post-saisie réussie → picker désactivé (DEC-SH-004).
/// - Post-annulation → picker réactivé.
class PickerEmotions extends StatelessWidget {
  const PickerEmotions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaisieHumeurBloc, SaisieHumeurState>(
      builder: (context, state) {
        final codeSelectionne = switch (state) {
          EnregistrementEnCours(:final codeEmotion) => codeEmotion,
          EnregistrementReussi(:final codeEmotion) => codeEmotion,
          _ => null,
        };
        // Picker verrouillé après une saisie réussie (DEC-SH-004).
        final desactive = state is EnregistrementReussi;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          alignment: WrapAlignment.center,
          children: emotionsCanoniques.map((emotion) {
            return PastilleEmotion(
              key: ValueKey(emotion.cle),
              emotion: emotion,
              selectionne: emotion.cle == codeSelectionne,
              desactive: desactive,
            );
          }).toList(),
        );
      },
    );
  }
}
