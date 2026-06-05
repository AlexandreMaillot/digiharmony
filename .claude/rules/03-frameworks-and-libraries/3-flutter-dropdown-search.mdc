---
description: APPLIQUER cette approche LORS de la création de dropdowns avec recherche
globs: apps/*/lib/pages/**/widgets/dropdown_*_input.dart, apps/*/lib/widgets/dropdown_with_search.dart
alwaysApply: true
---

Dropdowns avec recherche:

- Créer un widget custom DropdownWithSearch natif
- Éviter les packages externes non maintenus (ex: dropdown_search)
- Interface native Flutter avec recherche en temps réel
- Personnalisable et réutilisable

Structure du widget custom:

```dart
class DropdownWithSearch<T> extends StatefulWidget {
  const DropdownWithSearch({
    required this.items,
    required this.onChanged,
    this.selectedItem,
    this.decoration,
    this.itemBuilder,
    this.searchHint,
  });

  final List<T> items;
  final ValueChanged<T?> onChanged;
  final T? selectedItem;
  final InputDecoration? decoration;
  final Widget Function(BuildContext, T)? itemBuilder;
  final String? searchHint;

  @override
  State<DropdownWithSearch<T>> createState() => _DropdownWithSearchState<T>();
}

class _DropdownWithSearchState<T> extends State<DropdownWithSearch<T>> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<T> _filteredItems = [];
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _fermerDropdown() {
    if (_isOpen) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          final itemText = item.toString().toLowerCase();
          return itemText.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _toggleDropdown() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _searchController.clear();
        _filteredItems = widget.items;
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _searchFocusNode.requestFocus();
          }
        });
      }
    });
  }

  void _selectItem(T item) {
    widget.onChanged(item);
    setState(() {
      _isOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) => _fermerDropdown(),
      child: Column(
        children: [
          // Champ de saisie avec bouton dropdown
          InkWell(
            onTap: _toggleDropdown,
            child: InputDecorator(
              decoration: widget.decoration ?? const InputDecoration(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.selectedItem?.toString() ?? '',
                      style: Theme.of(context).textTheme.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),
          
          // Liste déroulante avec recherche
          if (_isOpen) ...[
            Container(
              margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                children: [
                  // Champ de recherche
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: _filterItems,
                      decoration: InputDecoration(
                        hintText: widget.searchHint ?? 'Rechercher...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  
                  // Liste des éléments filtrés
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _filteredItems.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = item == widget.selectedItem;
                        
                        return InkWell(
                          onTap: () => _selectItem(item),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                                : null,
                            child: Row(
                              children: [
                                Expanded(
                                  child: widget.itemBuilder != null
                                      ? widget.itemBuilder!(context, item)
                                      : Text(
                                          item.toString(),
                                          style: TextStyle(
                                            color: isSelected
                                                ? Theme.of(context).colorScheme.primary
                                                : Theme.of(context).colorScheme.onSurface,
                                            fontWeight: isSelected 
                                                ? FontWeight.bold 
                                                : FontWeight.normal,
                                          ),
                                        ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

Fonctionnalités obligatoires:

- Recherche en temps réel dans la liste
- Interface native Flutter (pas de package externe)
- Personnalisable (itemBuilder, searchHint, etc.)
- Gestion des états (ouvert/fermé, sélectionné)
- Fermeture via TapRegion (tap en dehors du dropdown)
- Focus automatique sur le champ de recherche à l'ouverture
- Design cohérent avec le thème

Fermeture du dropdown:

- OBLIGATOIRE : Utiliser `TapRegion` avec `onTapOutside` pour fermer le dropdown
- INTERDIRE : Utiliser `FocusNode.addListener` pour détecter la perte de focus et fermer
- INTERDIRE : Utiliser `Future.delayed` avec un délai arbitraire pour fermer
- Le scroll dans la liste ne doit PAS fermer le dropdown
- Seul un tap en dehors de la zone du dropdown ferme la liste

Utilisation:

```dart
DropdownWithSearch<String>(
  items: ['Option 1', 'Option 2', 'Option 3'],
  selectedItem: selectedValue,
  onChanged: (value) => handleChange(value),
  searchHint: 'Rechercher...',
  decoration: InputDecoration(...),
)
```

Bonnes pratiques:

- Filtrer les éléments en temps réel lors de la saisie
- Envelopper tout le widget avec `TapRegion` pour gérer la fermeture
- Donner le focus au champ de recherche à l'ouverture
- Utiliser des constantes pour les listes d'options
- Tester la recherche avec des caractères spéciaux
- Optimiser les performances pour de grandes listes
- Ne jamais utiliser FocusNode listener pour fermer le dropdown (cause des bugs avec le scroll)
