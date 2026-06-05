import 'package:digiharmony_app/app/app.dart';
import 'package:digiharmony_app/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
