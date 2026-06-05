part of 'locale_bloc.dart';

/// Événements du [LocaleBloc].
sealed class LocaleEvent {
  const LocaleEvent();
}

/// Force une [locale] (doit être supportée, sinon ignorée par MaterialApp).
final class LocaleChange extends LocaleEvent {
  const LocaleChange(this.locale);

  /// Locale à activer.
  final Locale locale;
}

/// Remet le suivi de la langue système.
final class LocaleSysteme extends LocaleEvent {
  const LocaleSysteme();
}
