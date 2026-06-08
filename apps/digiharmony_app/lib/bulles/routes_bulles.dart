import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/detox/view/detox_config_page.dart';
import 'package:digiharmony_app/etirement/view/etirement_page.dart';
import 'package:digiharmony_app/respiration/view/respiration_page.dart';
import 'package:digiharmony_app/sens/view/sens_page.dart';
import 'package:flutter/material.dart';

/// Mapping `IdCategorieBulle` -> Route vers la page dediee.
abstract final class RoutesBulles {
  /// Construit la route de navigation pour une categorie de bulle.
  static Route<void> pourCategorie(IdCategorieBulle id) {
    return switch (id) {
      IdCategorieBulle.respiration => MaterialPageRoute<void>(
        builder: (_) => const RespirationPage(),
      ),
      IdCategorieBulle.senses => MaterialPageRoute<void>(
        builder: (_) => const SensPage(),
      ),
      IdCategorieBulle.stretch => MaterialPageRoute<void>(
        builder: (_) => const EtirementPage(),
      ),
      IdCategorieBulle.detox => MaterialPageRoute<void>(
        builder: (_) => const DetoxConfigPage(),
      ),
    };
  }
}
