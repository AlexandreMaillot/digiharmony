---
description: APPLIQUER cette approche LORS de la création de champs de date
globs: apps/*/lib/pages/**/widgets/text_date_*_input.dart, apps/*/lib/pages/**/widgets/*date*input.dart
alwaysApply: true
---

Champs de date obligatoires:

- Utiliser showDatePicker au lieu de TextField
- Interface native avec calendrier visuel
- Format d'affichage adapté à la locale, stockage ISO (YYYY-MM-DD)
- Limites de dates appropriées

Structure obligatoire:

```dart
import 'package:intl/intl.dart';

class DateInput extends StatefulWidget {
  @override
  State<DateInput> createState() => _DateInputState();
}

class _DateInputState extends State<DateInput> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _parseInitialDate();
  }

  void _parseInitialDate() {
    final dateString = context.read<MonBloc>().state.dateVisite.value;
    if (dateString.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(dateString);
      } on FormatException {
        _selectedDate = null;
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMd(Localizations.localeOf(context).toString()).format(date);
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: Localizations.localeOf(context),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      
      if (context.mounted) {
        context.read<MonBloc>().add(
          MonChampModifie(picked.toIso8601String().split('T')[0]),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final localisation = context.l10n;

    return BlocConsumer<MonBloc, MonState>(
      listener: (context, state) {
        // Synchroniser avec le state si nécessaire
        final dateString = state.dateVisite.value;
        if (dateString.isNotEmpty) {
          try {
            final stateDate = DateTime.parse(dateString);
            if (_selectedDate == null || _selectedDate != stateDate) {
              setState(() {
                _selectedDate = stateDate;
              });
            }
          } on FormatException {
            if (_selectedDate != null) {
              setState(() {
                _selectedDate = null;
              });
            }
          }
        } else if (_selectedDate != null) {
          setState(() {
            _selectedDate = null;
          });
        }
      },
      builder: (context, state) {
        return InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: localisation.formulaireAffaireDateVisite,
              hintText: localisation.formulaireAffaireDateVisiteHint,
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedDate != null 
                        ? _formatDate(_selectedDate!)
                        : localisation.formulaireAffaireDateVisiteHint,
                    style: TextStyle(
                      color: _selectedDate != null 
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

Règles strictes:

- JAMAIS utiliser TextField pour les dates
- OBLIGATOIRE : showDatePicker avec calendrier visuel
- OBLIGATOIRE : Format d'affichage adapté à la locale de l'utilisateur
- OBLIGATOIRE : Format ISO YYYY-MM-DD pour le stockage
- OBLIGATOIRE : Vérifier context.mounted avant d'utiliser le context
- OBLIGATOIRE : Utiliser Localizations.localeOf(context) pour la locale

Fonctionnalités obligatoires:

- Bouton cliquable affichant la date sélectionnée
- Gestion des erreurs de parsing de date
- Synchronisation avec le state du bloc
- Limites de dates appropriées au contexte

Bonnes pratiques:

- Utiliser FormatException pour la gestion d'erreurs spécifique
- Gérer les cas où la date est vide ou invalide
- Tester avec différentes locales
- Optimiser l'UX avec des dates par défaut appropriées
