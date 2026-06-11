part of 'rappel_bloc.dart';

/// État du [RappelBloc] : réglages du rappel quotidien d'humeur.
///
/// Persiste via HydratedBloc. Ne contient JAMAIS « déjà noté » (DEC-R-02,
/// DEC-001/002) — toujours dérivé de Drift à la demande.
final class RappelState extends Equatable {
  /// Crée l'état avec les valeurs par défaut ou fournies.
  const RappelState({
    this.actif = false,
    this.heureHeure = 20,
    this.heureMinute = 0,
    this.permissionRefusee = false,
    this.invitationDejaProposee = false,
  });

  /// Rappel activé (opt-in, false par défaut — DEC-R-02).
  final bool actif;

  /// Heure du rappel (heure, 0–23). Défaut : 20.
  final int heureHeure;

  /// Heure du rappel (minute, 0–59). Défaut : 0.
  final int heureMinute;

  /// `true` si la permission OS a été refusée ou révoquée (DEC-R-06).
  final bool permissionRefusee;

  /// `true` si l'invitation one-shot a déjà été proposée (DEC-R-03).
  final bool invitationDejaProposee;

  /// [TimeOfDay] reconstruit depuis [heureHeure] et [heureMinute].
  TimeOfDay get heure => TimeOfDay(hour: heureHeure, minute: heureMinute);

  /// Retourne une copie avec les champs modifiés.
  RappelState copyWith({
    bool? actif,
    int? heureHeure,
    int? heureMinute,
    bool? permissionRefusee,
    bool? invitationDejaProposee,
  }) {
    return RappelState(
      actif: actif ?? this.actif,
      heureHeure: heureHeure ?? this.heureHeure,
      heureMinute: heureMinute ?? this.heureMinute,
      permissionRefusee: permissionRefusee ?? this.permissionRefusee,
      invitationDejaProposee:
          invitationDejaProposee ?? this.invitationDejaProposee,
    );
  }

  @override
  List<Object> get props => [
    actif,
    heureHeure,
    heureMinute,
    permissionRefusee,
    invitationDejaProposee,
  ];
}
