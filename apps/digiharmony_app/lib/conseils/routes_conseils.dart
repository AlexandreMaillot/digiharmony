import 'package:digiharmony_app/conseils/args_conseils.dart';
import 'package:digiharmony_app/conseils/view/conseils_page.dart';
import 'package:flutter/material.dart';

/// Route vers l'ecran Conseils (a brancher depuis Journal/Home quand planifie).
abstract final class RoutesConseils {
  /// Ouvre le carrousel de conseils, eventuellement sur une emotion donnee.
  static Route<void> carrousel({String? idEmotionInitiale}) {
    return MaterialPageRoute<void>(
      builder: (_) => ConseilsPage(
        args: ArgsConseils(idEmotionInitiale: idEmotionInitiale),
      ),
    );
  }
}
