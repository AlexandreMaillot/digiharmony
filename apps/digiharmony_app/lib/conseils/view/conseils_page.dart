import 'dart:async';

import 'package:core_package/core_package.dart';
import 'package:digiharmony_app/conseils/args_conseils.dart';
import 'package:digiharmony_app/conseils/widgets/carte_conseil.dart';
import 'package:digiharmony_app/conseils/widgets/controles_carrousel.dart';
import 'package:digiharmony_app/conseils/widgets/points_carrousel.dart';
import 'package:digiharmony_app/l10n/l10n.dart';
import 'package:digiharmony_app/respiration/view/respiration_page.dart';
import 'package:digiharmony_app/theme/theme_application.dart';
import 'package:digiharmony_app/widgets/barre_outils.dart';
import 'package:digiharmony_app/widgets/fond_application.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Ecran « Conseils » — carrousel de cartes, une par emotion negative.
///
/// Etat purement UI (index de page) : pas de Bloc, `PageController` +
/// `StatefulWidget` (cf. plan §13). Lit uniquement `CatalogueConseils.all`.
class ConseilsPage extends StatelessWidget {
  /// {@macro conseils_page}
  const ConseilsPage({this.args, super.key});

  /// Contrat d'entree optionnel (emotion initiale).
  final ArgsConseils? args;

  @override
  Widget build(BuildContext context) {
    return ConseilsView(args: args);
  }
}

/// UI du carrousel de conseils.
class ConseilsView extends StatefulWidget {
  /// {@macro conseils_view}
  const ConseilsView({this.args, super.key});

  /// Contrat d'entree optionnel.
  final ArgsConseils? args;

  @override
  State<ConseilsView> createState() => _ConseilsViewState();
}

class _ConseilsViewState extends State<ConseilsView> {
  late final PageController _controller;
  late int _index;

  static const _viewportFraction = 0.86;

  @override
  void initState() {
    super.initState();
    final initial = CatalogueConseils.indexDe(widget.args?.idEmotionInitiale);
    _index = initial < 0 ? 0 : initial;
    _controller = PageController(
      initialPage: _index,
      viewportFraction: _viewportFraction,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    unawaited(HapticFeedback.selectionClick());
    setState(() => _index = index);
  }

  Future<void> _goTo(int target) async {
    if (target < 0 || target >= CatalogueConseils.all.length) return;
    await HapticFeedback.selectionClick();
    await _controller.animateToPage(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _onTryBreathing() async {
    await HapticFeedback.selectionClick();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RespirationPage()),
    );
  }

  Future<void> _onApply() async {
    await HapticFeedback.selectionClick();
    if (!mounted) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.adviceAppliedConfirmation),
          duration: const Duration(seconds: 2),
        ),
      );
    // Laisse le temps a la confirmation breve de s'afficher avant le retour.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    messenger.hideCurrentSnackBar();
    if (!mounted) return;
    await Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final conseils = List<ConseilEmotion>.of(CatalogueConseils.all);
    final total = conseils.length;
    final couleurCourante = conseils[_index].color;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: BarreOutils(
        title: l10n.adviceTitle,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: FondApplication(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: kToolbarHeight),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: PointsCarrousel(
                  current: _index,
                  total: total,
                  activeColor: couleurCourante,
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: total,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, i) {
                    final conseil = conseils[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: CarteConseil(
                        conseil: conseil,
                        onTryBreathing: _onTryBreathing,
                      ),
                    );
                  },
                ),
              ),
              ControlesCarrousel(
                index: _index,
                total: total,
                onPrev: () => unawaited(_goTo(_index - 1)),
                onNext: () => unawaited(_goTo(_index + 1)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _onApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeApplication.primary,
                      foregroundColor: ThemeApplication.bubbleBackground,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ThemeApplication.radiusLarge,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.check),
                    label: Text(l10n.adviceApply),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
