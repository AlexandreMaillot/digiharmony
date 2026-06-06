---
description: APPLIQUER cette structure LORS de la création d'un fichier view Flutter
globs: apps/*/lib/**/*_view.dart
alwaysApply: true
---

Structure obligatoire:
- Commencer par un Scaffold pour les pages classiques
- Commencer par un Dialog pour les pop-ups/modales
- Utiliser BlocBuilder pour écouter les changements d'état
- Implémenter les états de chargement, erreur, succès et vide
- Utiliser les extensions enum pour les conditions

États d'interface:
- État de chargement: CircularProgressIndicator.adaptive() avec message
- État d'erreur: Icon d'erreur avec message et bouton réessayer
- État vide: Icon inbox avec message informatif
- État de succès: Affichage des données avec ListView ou GridView

Gestion des états:
- Utiliser les getters booléens des extensions enum
- Exemple: `etat.status.estEnChargement`, `etat.status.estEnErreur`
- Éviter les comparaisons directes avec les enums
- Combiner avec des opérateurs logiques si nécessaire

Structure type - Page classique:
```dart
class MaView extends StatelessWidget {
  const MaView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final localisation = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(localisation.monTitre),
      ),
      body: BlocBuilder<MonBloc, MonState>(
        builder: (context, etat) {
          if (etat.status.estEnChargement && etat.donnees.isEmpty) {
            return const MonWidgetChargement();
          }

          if (etat.status.estEnErreur) {
            return const MonWidgetErreur();
          }

          if (etat.status.estVide) {
            return const MonWidgetVide();
          }

          return MonWidgetSucces(etat: etat);
        },
      ),
    );
  }

  Widget _buildChargement(L10n localisation) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator.adaptive(),
          const SizedBox(height: 15),
          Text(localisation.chargementMessage),
        ],
      ),
    );
  }
```

Structure type - Pop-up/Modal:
```dart
class MaModalView extends StatelessWidget {
  const MaModalView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final localisation = context.l10n;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localisation.monTitreModal,
              style: textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),
            BlocBuilder<MonBloc, MonState>(
              builder: (context, etat) {
                if (etat.status.estEnChargement) {
                  return _buildChargementModal(localisation);
                }

                if (etat.status.estEnErreur) {
                  return _buildErreurModal(localisation, context);
                }

                return _buildContenuModal(etat, theme, localisation);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChargementModal(L10n localisation) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator.adaptive(),
        const SizedBox(height: 15),
        Text(localisation.chargementMessage),
      ],
    );
  }

  Widget _buildErreur(L10n localisation, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60),
          const SizedBox(height: 15),
          Text(localisation.erreurMessage),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.read<MonBloc>().add(const MonEventRetry()),
            child: Text(localisation.actionReessayer),
          ),
        ],
      ),
    );
  }

  Widget _buildVide(L10n localisation) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 60),
          const SizedBox(height: 15),
          Text(localisation.videMessage),
        ],
      ),
    );
  }
}
```

Bonnes pratiques:
- Créer des widgets StatelessWidget séparés au lieu de méthodes retournant des widgets
- Utiliser des constantes pour les tailles d'icônes
- Maintenir la cohérence des espacements (multiples de 5)
- Tester tous les états possibles
- Utiliser la version .adaptive() pour tous les widgets qui la proposent
- Choisir Dialog pour les modales/pop-ups, Scaffold pour les pages
- Utiliser mainAxisSize.min pour les modales
- Préférer l'adaptabilité native aux widgets custom
