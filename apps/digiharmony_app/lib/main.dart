import 'package:digiharmony_app/app/app.dart';
import 'package:digiharmony_app/bootstrap.dart';
import 'package:digiharmony_app/bulles/view/bulles_page.dart';

/// Point d'entree par defaut (equivalent au flavor development).
Future<void> main() async {
  await bootstrap(
    (deps) => App(dependencies: deps, ecranInitial: const BullesPage()),
  );
}
