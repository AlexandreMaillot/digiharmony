import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

/// Storage HydratedBloc mocké pour les tests (aucun disque réel).
class MockStorage extends Mock implements Storage {}

/// Installe un [MockStorage] vide comme `HydratedBloc.storage`.
///
/// À appeler dans un `setUp`. Retourne le mock pour configurer `read`/`write`.
MockStorage initMockHydratedStorage() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final storage = MockStorage();
  when(() => storage.read(any())).thenReturn(null);
  when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
  when(() => storage.delete(any())).thenAnswer((_) async {});
  when(storage.clear).thenAnswer((_) async {});
  HydratedBloc.storage = storage;
  return storage;
}
