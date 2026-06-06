import 'package:digiharmony_app/pages/temps_ecran/services/screen_time_ios_channel.dart';
import 'package:flutter_test/flutter_test.dart';

/// Couvre le mapping `String (canal natif) → StatutAutorisationIos`, qui est le
/// contrat avec le code Swift. Le garde-fou `Platform.isIOS` empêche d'exercer
/// `statutAutorisation`/`demanderAutorisation` sur l'hôte de test, d'où le test
/// direct de `parseStatut` (exposé `@visibleForTesting`). Une régression du
/// mapping serait sinon invisible (finding review #1).
void main() {
  group('ScreenTimeIosChannel.parseStatut', () {
    test('nonDemande → StatutAutorisationIos.nonDemande', () {
      expect(
        ScreenTimeIosChannel.parseStatut('nonDemande'),
        StatutAutorisationIos.nonDemande,
      );
    });

    test('refuse → StatutAutorisationIos.refuse', () {
      expect(
        ScreenTimeIosChannel.parseStatut('refuse'),
        StatutAutorisationIos.refuse,
      );
    });

    test('accorde → StatutAutorisationIos.accorde', () {
      expect(
        ScreenTimeIosChannel.parseStatut('accorde'),
        StatutAutorisationIos.accorde,
      );
    });

    test('null → indisponible (fallback)', () {
      expect(
        ScreenTimeIosChannel.parseStatut(null),
        StatutAutorisationIos.indisponible,
      );
    });

    test('valeur inconnue → indisponible (fallback)', () {
      expect(
        ScreenTimeIosChannel.parseStatut('valeur_inattendue'),
        StatutAutorisationIos.indisponible,
      );
    });

    test('chaîne vide → indisponible (fallback)', () {
      expect(
        ScreenTimeIosChannel.parseStatut(''),
        StatutAutorisationIos.indisponible,
      );
    });
  });
}
