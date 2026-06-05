---
description: APPLIQUER cette structure LORS de la création des events et states Flutter Bloc
globs: apps/*/lib/**/*_event.dart, apps/*/lib/**/*_state.dart
alwaysApply: true
---

Structure des Events:
- Utiliser `sealed class` pour l'event de base
- Hériter de `Equatable` pour la comparaison
- Implémenter `props` avec les propriétés
- Nommer avec un suffixe explicite (Initialisee, Modifiee, Demandee)

Structure des States:
- Utiliser `final class` pour l'état
- Hériter de `Equatable` pour la comparaison
- Implémenter `copyWith` pour les mises à jour
- Créer un constructeur par défaut avec valeurs initiales

Events type:
```dart
part of 'mon_bloc.dart';

sealed class MonEvent extends Equatable {
  const MonEvent();

  @override
  List<Object> get props => [];
}

final class MonInitialisee extends MonEvent {
  const MonInitialisee();
}

final class MonModifiee extends MonEvent {
  const MonModifiee(this.valeur);

  final String valeur;

  @override
  List<Object> get props => [valeur];
}

final class MonDemandee extends MonEvent {
  const MonDemandee();
}
```

States type:
```dart
part of 'mon_bloc.dart';

enum MonStatus {
  initial,
  chargement,
  succes,
  vide,
  erreur,
}

extension MonStatusX on MonStatus {
  bool get estInitial => this == MonStatus.initial;
  bool get estEnChargement => this == MonStatus.chargement;
  bool get estSucces => this == MonStatus.succes;
  bool get estVide => this == MonStatus.vide;
  bool get estEnErreur => this == MonStatus.erreur;
}

final class MonState extends Equatable {
  const MonState({
    this.status = MonStatus.initial,
    this.donnees = const [],
    this.termeRecherche = '',
    this.messageCle = '',
    this.erreurCode = '',
  });

  final MonStatus status;
  final List<MaData> donnees;
  final String termeRecherche;
  final String messageCle;
  final String erreurCode;

  List<MaData> get donneesFiltrees {
    if (termeRecherche.trim().isEmpty) {
      return donnees;
    }

    final termeNormalise = termeRecherche.trim().toLowerCase();
    
    return donnees.where((item) {
      return item.nom.toLowerCase().contains(termeNormalise);
    }).toList();
  }

  MonState copyWith({
    MonStatus? status,
    List<MaData>? donnees,
    String? termeRecherche,
    String? messageCle,
    String? erreurCode,
  }) {
    return MonState(
      status: status ?? this.status,
      donnees: donnees ?? this.donnees,
      termeRecherche: termeRecherche ?? this.termeRecherche,
      messageCle: messageCle ?? this.messageCle,
      erreurCode: erreurCode ?? this.erreurCode,
    );
  }

  @override
  List<Object> get props => [
    status,
    donnees,
    termeRecherche,
    messageCle,
    erreurCode,
  ];
}
```

Bonnes pratiques:
- Toujours créer l'extension pour les enums de status
- Utiliser des getters calculés pour les données filtrées
- Implémenter copyWith pour tous les states
- Documenter les events complexes avec des commentaires
- Utiliser des noms explicites et cohérents
