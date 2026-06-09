import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Identifiant de la PlatformView enregistrée côté Swift hôte.
///
/// Correspond à la clé passée à
/// `[registrar: registerViewFactory:withId:]` dans `AppDelegate.swift`
/// (à ajouter lors de l'activation — voir `ScreenTimeScaffold/README.md`).
const String kDeviceActivityReportViewType =
    'digiharmony/device_activity_report';

/// PlatformView côté Dart qui embarque le `DeviceActivityReport` SwiftUI
/// rendu par le système dans le process de l'extension.
///
/// INERTE tant que `kScreenTimeIosActif` est `false` (ce widget n'est
/// jamais instancié sur le chemin actif). Activer après :
///   1. Obtention de l'entitlement family-controls.
///   2. Création du target `DeviceActivityReportExtension` dans Xcode.
///   3. Ajout de `DeviceActivityReportViewFactory` au target Runner et
///      enregistrement dans `AppDelegate.swift`.
///   4. Mettre `kScreenTimeIosActif = true`.
///
/// Voir `ScreenTimeScaffold/README.md` pour le détail.
///
/// Contrainte API Apple : la vue est rendue par le système dans le process
/// sandboxé de l'extension — l'app hôte Flutter ne lit aucun chiffre
/// (DEC-TE-13).
class VueRapportIos extends StatelessWidget {
  /// Crée la vue de rapport iOS.
  const VueRapportIos({super.key});

  @override
  Widget build(BuildContext context) {
    // UiKitView enregistre la PlatformView côté iOS.
    // Elle est conditionnellement insérée dans l'arbre uniquement en
    // chemin iOS + état `pret` + `rapportEmbarque == true` (DEC-TE-12).
    return UiKitView(
      viewType: kDeviceActivityReportViewType,
      // Le rapport système porte sa propre a11y (non contrôlable — DEC-TE-16).
      // Le wrapper Flutter (écran d'autorisation, footer) respecte tap >= 48dp.
      layoutDirection: TextDirection.ltr,
      creationParamsCodec: const StandardMessageCodec(),
      // Diagnostic : confirme que la PlatformView native est bien instanciée.
      onPlatformViewCreated: (id) => debugPrint(
        '[ScreenTime] DeviceActivityReport PlatformView créée (id=$id)',
      ),
    );
  }
}
