import 'package:digiharmony_app/theme/theme_application.dart';
import 'package:digiharmony_app/voix_off/bloc/voix_off_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bouton de bascule de la voix off, partagé par les exercices.
///
/// Affiche `volume_up` (ON) / `volume_off` (OFF) et envoie un événement
/// [VoixOffBasculee] au [VoixOffBloc] partagé. Les labels a11y sont fournis
/// par l'appelant (résolus depuis l'ARB spécifique à l'écran).
class BoutonVoixOff extends StatelessWidget {
  /// {@macro bouton_voix_off}
  const BoutonVoixOff({
    required this.onLabel,
    required this.offLabel,
    super.key,
  });

  /// Label d'accessibilité quand la voix off est active.
  final String onLabel;

  /// Label d'accessibilité quand la voix off est coupée.
  final String offLabel;

  @override
  Widget build(BuildContext context) {
    final active = context.watch<VoixOffBloc>().state.active;
    return IconButton(
      icon: Icon(active ? Icons.volume_up : Icons.volume_off),
      color: ThemeApplication.foreground,
      tooltip: active ? onLabel : offLabel,
      onPressed: () => context.read<VoixOffBloc>().add(const VoixOffBasculee()),
    );
  }
}
