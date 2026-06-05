---
description: APPLIQUER des widgets StatelessWidget séparés LORS de la création d'UI complexes
globs: apps/*/lib/**/*_view.dart, apps/*/lib/**/*_page.dart
alwaysApply: true
---

Principe:

- Ne jamais créer de méthodes qui retournent des widgets
- Créer des widgets StatelessWidget séparés pour chaque partie de l'UI
- Améliorer la réutilisabilité et la testabilité
- Séparer les responsabilités de manière claire

Interdictions:

- ❌ Méthodes comme `Widget _buildChargement()`
- ❌ Méthodes comme `Widget _buildErreur()`
- ❌ Méthodes comme `Widget _buildSucces()`

Bonnes pratiques:

- ✅ Créer des classes StatelessWidget séparées
- ✅ Utiliser des constructeurs avec paramètres si nécessaire
- ✅ Nommer les widgets de manière explicite
- ✅ Placer les widgets dans des fichiers séparés si complexe

Structure recommandée:

```dart
class MaView extends StatelessWidget {
  const MaView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final localisation = context.l10n;

    return Scaffold(
      body: BlocBuilder<MonBloc, MonState>(
        builder: (context, etat) {
          if (etat.status.estEnChargement) {
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
}

// Widgets séparés

class MonWidgetChargement extends StatelessWidget {
  const MonWidgetChargement({super.key});

  @override
  Widget build(BuildContext context) {
    final localisation = context.l10n;
    
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
}

class MonWidgetErreur extends StatelessWidget {
  const MonWidgetErreur({super.key});

  @override
  Widget build(BuildContext context) {
    final localisation = context.l10n;
    
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
}

class MonWidgetVide extends StatelessWidget {
  const MonWidgetVide({super.key});

  @override
  Widget build(BuildContext context) {
    final localisation = context.l10n;
    
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

class MonWidgetSucces extends StatelessWidget {
  const MonWidgetSucces({super.key, required this.etat});

  final MonState etat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final localisation = context.l10n;
    
    return ListView.builder(
      itemCount: etat.donnees.length,
      itemBuilder: (context, index) {
        final item = etat.donnees[index];
        return Card(
          child: ListTile(
            title: Text(item.nom, style: textTheme.titleMedium),
            subtitle: Text(item.description, style: textTheme.bodyMedium),
          ),
        );
      },
    );
  }
}
```

Organisation des fichiers:

- Pour des widgets simples: garder dans le même fichier
- Pour des widgets complexes: créer des fichiers séparés
- Nommer les fichiers: `{nom}_widget.dart`
- Exporter les widgets dans le barrel file

Avantages:

- Réutilisabilité des widgets
- Testabilité améliorée
- Séparation des responsabilités
- Code plus lisible et maintenable
- Meilleure performance (widgets const)
- Facilité de debug
