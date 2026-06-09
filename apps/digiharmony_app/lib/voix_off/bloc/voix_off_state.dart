part of 'voix_off_bloc.dart';

/// État immuable du [VoixOffBloc].
class VoixOffEtat extends Equatable {
  /// {@macro voix_off_etat}
  const VoixOffEtat({required this.active});

  /// `true` si la voix off est activée.
  final bool active;

  /// Copie modifiée.
  VoixOffEtat copyWith({bool? active}) =>
      VoixOffEtat(active: active ?? this.active);

  @override
  List<Object?> get props => <Object?>[active];
}
