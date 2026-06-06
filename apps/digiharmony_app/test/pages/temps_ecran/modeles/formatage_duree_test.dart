import 'package:digiharmony_app/l10n/gen/app_localizations.dart';
import 'package:digiharmony_app/pages/temps_ecran/modeles/formatage_duree.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations l10nFr;
  late AppLocalizations l10nEn;

  setUpAll(() async {
    l10nFr = await AppLocalizations.delegate.load(const Locale('fr'));
    l10nEn = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('formaterDuree (AC12)', () {
    test('>= 1h → heures + minutes (fr)', () {
      expect(
        formaterDuree(l10nFr, const Duration(hours: 3, minutes: 12)),
        '3 h 12 min',
      );
    });

    test('< 1h → minutes seules (fr)', () {
      expect(formaterDuree(l10nFr, const Duration(minutes: 42)), '42 min');
    });

    test('minutes = reste après heures', () {
      expect(
        formaterDuree(l10nEn, const Duration(hours: 1, minutes: 5)),
        '1 h 5 min',
      );
    });

    test('zéro → 0 min', () {
      expect(formaterDuree(l10nEn, Duration.zero), '0 min');
    });
  });
}
