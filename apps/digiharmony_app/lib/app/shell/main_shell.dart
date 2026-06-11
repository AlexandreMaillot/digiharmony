import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/pages/accueil/views/accueil_page.dart';
import 'package:digiharmony_app/pages/bulles/view/bulles_page.dart';
import 'package:digiharmony_app/pages/conseils/views/conseils_page.dart';
import 'package:digiharmony_app/pages/journal/views/journal_page.dart';
import 'package:digiharmony_app/pages/parametres/views/parametres_page.dart';
import 'package:digiharmony_app/theme/theme.dart';
import 'package:flutter/material.dart';

/// Onglets principaux de la navigation par bottom bar.
///
/// L'ordre des valeurs = ordre gauche→droite dans la barre, et sert d'index
/// pour l'[IndexedStack] (DEC-NAV-2026 : bottom bar, plus de retour entre
/// sections).
enum OngletPrincipal { accueil, journal, conseils, bulles, parametres }

/// Permet aux descendants (ex. cartes/raccourcis de l'Accueil) de basculer
/// vers un onglet sans empiler de route.
///
/// `maybeOf` est nullable : hors shell (prévisualisation `main_development`,
/// tests isolés), les écrans retombent sur l'ancien `Navigator.push`.
class ShellScope extends InheritedWidget {
  /// Crée le scope exposant le sélecteur d'onglet.
  const ShellScope({
    required this.allerVers,
    required super.child,
    super.key,
  });

  /// Bascule la bottom bar vers l'onglet donné.
  final void Function(OngletPrincipal onglet) allerVers;

  /// Récupère le scope le plus proche, ou `null` si l'écran n'est pas monté
  /// sous un [MainShell].
  static ShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellScope>();

  @override
  bool updateShouldNotify(ShellScope oldWidget) =>
      allerVers != oldWidget.allerVers;
}

/// Coquille de navigation principale : bottom bar + [IndexedStack].
///
/// Les cinq sections vivent dans un seul sous-arbre (état préservé au
/// changement d'onglet). Les dépendances partagées (`AppDatabase`,
/// `LocaleBloc`) sont déjà fournies au-dessus de `MaterialApp` (bootstrap),
/// donc chaque page lit son provider racine sans réinjection.
class MainShell extends StatefulWidget {
  /// Crée la coquille.
  const MainShell({super.key});

  /// Route impérative (remplace l'écran de démarrage). Pas de GoRouter
  /// (DEC-FND-07).
  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const MainShell());

  @override
  State<MainShell> createState() => _MainShellState();
}

/// Pages des onglets, dans l'ordre de [OngletPrincipal].
const List<Widget> _pagesOnglets = [
  AccueilPage(),
  JournalPage(),
  ConseilsPage(),
  BullesPage(),
  ParametresPage(),
];

class _MainShellState extends State<MainShell> {
  OngletPrincipal _onglet = OngletPrincipal.accueil;

  /// Onglets déjà visités (chargement paresseux) : un onglet n'instancie son
  /// arbre (et donc son Bloc + ses requêtes Drift) qu'à la première visite.
  /// Évite de lancer cinq lectures au démarrage et de réveiller des écrans
  /// dont les dépendances ne sont pas encore pertinentes.
  late final Set<int> _visites = {_onglet.index};

  void _allerVers(OngletPrincipal onglet) {
    if (onglet == _onglet) return;
    setState(() {
      _onglet = onglet;
      _visites.add(onglet.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ShellScope(
      allerVers: _allerVers,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _onglet.index,
          children: [
            for (var i = 0; i < _pagesOnglets.length; i++)
              if (_visites.contains(i))
                _pagesOnglets[i]
              else
                const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _onglet.index,
          onTap: (i) => _allerVers(OngletPrincipal.values[i]),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.backgroundDeep,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home_rounded),
              label: l10n.navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book_outlined),
              activeIcon: const Icon(Icons.menu_book_rounded),
              label: l10n.navJournal,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.lightbulb_outline),
              activeIcon: const Icon(Icons.lightbulb_rounded),
              label: l10n.navTips,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bubble_chart_outlined),
              activeIcon: const Icon(Icons.bubble_chart_rounded),
              label: l10n.navBubbles,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings_rounded),
              label: l10n.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
