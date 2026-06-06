import 'package:digiharmony_app/pages/temps_ecran/modeles/resume_temps_ecran.dart';
import 'package:digiharmony_app/pages/temps_ecran/services/screen_time_ios_channel.dart';
import 'package:digiharmony_app/pages/temps_ecran/services/service_temps_ecran.dart';

/// Implémentation iOS de [ServiceTempsEcran] via FamilyControls /
/// DeviceActivity (DEC-TE-14).
///
/// - `plateformeSupportee` est `true` lorsque `kScreenTimeIosActif` est actif.
/// - `aLAcces` lit silencieusement le statut FamilyControls via
///   `ScreenTimeIosChannel.statutAutorisation` (pas de pop-up système).
/// - `ouvrirReglagesAcces` déclenche `requestAuthorization`
///   (à n'appeler qu'après CTA explicite — DEC-TE-15).
/// - `usageDuJour` retourne toujours `[]` : les chiffres d'usage iOS ne
///   traversent JAMAIS vers Dart (rendus par l'extension — DEC-TE-13).
/// - `rapportEmbarque` est `true` : la View affiche la PlatformView
///   DeviceActivityReport et non la jauge custom Android (DEC-TE-12).
class ServiceTempsEcranIos implements ServiceTempsEcran {
  /// Crée le service iOS.
  ///
  /// [channel] est injectable pour les tests (remplace le vrai MethodChannel).
  ServiceTempsEcranIos({ScreenTimeIosChannel? channel})
    : _channel = channel ?? ScreenTimeIosChannel();

  final ScreenTimeIosChannel _channel;

  @override
  bool get plateformeSupportee => kScreenTimeIosActif;

  @override
  bool get rapportEmbarque => true;

  /// Lit silencieusement le statut FamilyControls.
  ///
  /// Retourne `true` si le statut est [StatutAutorisationIos.accorde].
  /// Ne déclenche jamais de pop-up système.
  @override
  Future<bool> aLAcces() async {
    final statut = await _channel.statutAutorisation();
    return statut == StatutAutorisationIos.accorde;
  }

  /// Déclenche `requestAuthorization(for: .individual)`.
  ///
  /// À n'appeler qu'après que l'utilisateur a explicitement tapé le CTA
  /// (principe d'octroi validé, DEC-TE-15).
  @override
  Future<void> ouvrirReglagesAcces() => _channel.demanderAutorisation();

  /// Toujours `[]` : les chiffres d'usage iOS ne traversent pas vers Dart
  /// (contrainte API Apple, DEC-TE-13).
  @override
  Future<List<UsageAppVue>> usageDuJour() async => const [];
}
