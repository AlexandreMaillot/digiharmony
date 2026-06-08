import 'package:digiharmony_app/pages/temps_ecran/services/screen_time_ios_channel.dart';
import 'package:digiharmony_app/pages/temps_ecran/services/service_temps_ecran_ios.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockChannel extends Mock implements ScreenTimeIosChannel {}

/// Couvre la façade iOS réelle (auparavant non testée — finding review #1) :
/// le passage statut → `aLAcces`, la délégation de `ouvrirReglagesAcces`, et
/// les invariants `usageDuJour == []` / `rapportEmbarque == true`
/// (zéro-collecte iOS, DEC-TE-13/DEC-TE-12). `ScreenTimeIosChannel` injecté
/// mocké.
void main() {
  late _MockChannel channel;
  late ServiceTempsEcranIos service;

  setUp(() {
    channel = _MockChannel();
    service = ServiceTempsEcranIos(channel: channel);
  });

  group('ServiceTempsEcranIos.aLAcces', () {
    test('statut accorde → true', () async {
      when(channel.statutAutorisation)
          .thenAnswer((_) async => StatutAutorisationIos.accorde);
      expect(await service.aLAcces(), isTrue);
    });

    test('statut nonDemande → false', () async {
      when(channel.statutAutorisation)
          .thenAnswer((_) async => StatutAutorisationIos.nonDemande);
      expect(await service.aLAcces(), isFalse);
    });

    test('statut refuse → false', () async {
      when(channel.statutAutorisation)
          .thenAnswer((_) async => StatutAutorisationIos.refuse);
      expect(await service.aLAcces(), isFalse);
    });

    test('statut indisponible → false', () async {
      when(channel.statutAutorisation)
          .thenAnswer((_) async => StatutAutorisationIos.indisponible);
      expect(await service.aLAcces(), isFalse);
    });
  });

  test('ouvrirReglagesAcces délègue à demanderAutorisation', () async {
    when(channel.demanderAutorisation)
        .thenAnswer((_) async => StatutAutorisationIos.accorde);
    await service.ouvrirReglagesAcces();
    verify(channel.demanderAutorisation).called(1);
  });

  test('usageDuJour retourne toujours [] (chiffres non lus côté Dart)',
      () async {
    expect(await service.usageDuJour(), isEmpty);
    // Aucun appel canal : les chiffres ne traversent jamais vers Dart.
    verifyNever(channel.statutAutorisation);
  });

  test('rapportEmbarque == true (PlatformView, pas la jauge Android)', () {
    expect(service.rapportEmbarque, isTrue);
  });

  test('plateformeSupportee == kScreenTimeIosActif', () {
    expect(service.plateformeSupportee, kScreenTimeIosActif);
  });
}
