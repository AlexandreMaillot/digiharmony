import 'package:digiharmony_app/app/app.dart';
import 'package:digiharmony_app/bootstrap.dart';
import 'package:digiharmony_app/bulles/view/bulles_page.dart';

Future<void> main() async {
  // 👇 ECRAN DE DEMARRAGE — change cette ligne pour previsualiser un autre
  //    ecran (ex. const RespirationPage(), const ParametresPage(), ...).
  const ecranInitial = BullesPage();

  await bootstrap(
    (deps) => App(dependencies: deps, ecranInitial: ecranInitial),
  );
}
