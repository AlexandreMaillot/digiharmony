import 'dart:io';

import 'package:digiharmony_app/database/tables/stats_bien_etre.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'base_de_donnees.g.dart';

/// Base de donnees locale UNIQUE de l'app (SQLite via Drift).
///
/// Seule base du projet — 100 % locale, zero collecte. Toutes les futures
/// tables (journal d'humeur, conseils) viennent ici, jamais une seconde DB.
@DriftDatabase(tables: [StatsBienEtre])
class BaseDeDonnees extends _$BaseDeDonnees {
  /// Cree la base avec une connexion native par defaut.
  BaseDeDonnees() : super(_openConnection());

  /// Cree la base avec un [executor] fourni (utile pour les tests en memoire).
  BaseDeDonnees.forTesting(super.e);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'digiharmony.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
