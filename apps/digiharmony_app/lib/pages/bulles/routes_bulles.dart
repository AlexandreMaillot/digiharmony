import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:digiharmony_app/data/local/depot_stats_bien_etre.dart';
import 'package:digiharmony_app/pages/detox/view/detox_config_page.dart';
import 'package:digiharmony_app/pages/etirement/view/etirement_page.dart';
import 'package:digiharmony_app/pages/respiration/view/respiration_page.dart';
import 'package:digiharmony_app/pages/sens/view/sens_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Mapping `IdCategorieBulle` -> Route vers la page dédiée.
///
/// Chaque route crée un [RepositoryProvider]<[DepotStatsBienEtre]> pour
/// traverser la frontière de route (pattern DEC-FND-07).
abstract final class RoutesBulles {
  /// Construit la route de navigation pour une catégorie de bulle.
  static Route<void> pourCategorie(
    IdCategorieBulle id,
    AppDatabase database,
  ) {
    final depot = DepotDriftStatsBienEtre(database);
    return switch (id) {
      IdCategorieBulle.respiration => MaterialPageRoute<void>(
        builder: (_) => RepositoryProvider<DepotStatsBienEtre>.value(
          value: depot,
          child: const RespirationPage(),
        ),
      ),
      IdCategorieBulle.senses => MaterialPageRoute<void>(
        builder: (_) => RepositoryProvider<DepotStatsBienEtre>.value(
          value: depot,
          child: const SensPage(),
        ),
      ),
      IdCategorieBulle.stretch => MaterialPageRoute<void>(
        builder: (_) => RepositoryProvider<DepotStatsBienEtre>.value(
          value: depot,
          child: const EtirementPage(),
        ),
      ),
      IdCategorieBulle.detox => MaterialPageRoute<void>(
        builder: (_) => RepositoryProvider<DepotStatsBienEtre>.value(
          value: depot,
          child: const DetoxConfigPage(),
        ),
      ),
    };
  }
}
