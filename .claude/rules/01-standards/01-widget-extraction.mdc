---
description: EXTRAIRE les widgets helpers en StatelessWidget LORS de la création de méthodes retournant des widgets
globs: apps/*/lib/**/*_view.dart, apps/*/lib/**/*_page.dart, apps/*/lib/**/*_widget.dart
alwaysApply: true
---

Principe:

- Ne jamais créer de méthodes privées qui retournent des widgets (ex: `Widget _buildX()`)
- Extraire ces méthodes en widgets StatelessWidget séparés
- Améliorer les performances (const widgets, hot reload optimisé)
- Faciliter la réutilisabilité et la testabilité
- Séparer les responsabilités de manière claire

Interdictions:

- ❌ Méthodes comme `Widget _buildInfoRow(BuildContext context, String label, String value)`
- ❌ Méthodes comme `Widget _buildMontantCard(...)`
- ❌ Méthodes comme `Widget _buildTableRow(...)`
- ❌ Toute méthode privée retournant un Widget directement

Bonnes pratiques:

- ✅ Créer des classes StatelessWidget séparées pour chaque widget helper
- ✅ Utiliser des constructeurs avec paramètres nommés
- ✅ Nommer les widgets de manière explicite et descriptive
- ✅ Placer les widgets dans le même fichier si simple, ou fichier séparé si complexe
- ✅ Utiliser `const` constructors quand possible

Structure recommandée:

```dart
// ❌ MAUVAIS - Méthode helper retournant un widget
class DetailsFactureWidget extends StatelessWidget {
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(label, style: textTheme.bodyMedium),
        ),
        Expanded(
          child: Text(value, style: textTheme.bodyMedium),
        ),
      ],
    );
  }
}

// ✅ BON - Widget StatelessWidget séparé
class FactureInfoRow extends StatelessWidget {
  const FactureInfoRow({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

// Utilisation dans le widget parent
class DetailsFactureWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FactureInfoRow(
          label: localisation.factureFormId,
          value: '#${facture.id.valeur}',
        ),
        FactureInfoRow(
          label: localisation.factureFormClient,
          value: facture.client!.nom,
        ),
      ],
    );
  }
}
```

Organisation des fichiers:

- Pour des widgets simples et spécifiques à une vue: garder dans le même fichier
- Pour des widgets complexes ou réutilisables: créer des fichiers séparés
- Nommer les fichiers: `{nom}_widget.dart` ou `{feature}_{nom}_widget.dart`
- Exporter les widgets dans le barrel file si nécessaire

Avantages:

- Performance améliorée (widgets const, hot reload optimisé)
- Réutilisabilité des widgets
- Testabilité améliorée (widgets isolés)
- Séparation des responsabilités
- Code plus lisible et maintenable
- Facilité de debug (widgets nommés dans l'arbre)
- Meilleure optimisation par Flutter (widget tree immutable)

Exceptions:

- Les méthodes `build()` des StatefulWidget/StatelessWidget sont autorisées
- Les méthodes utilitaires qui ne retournent PAS de widgets sont autorisées
- Les méthodes de formatage (ex: `String _formatDate(DateTime date)`) sont autorisées
