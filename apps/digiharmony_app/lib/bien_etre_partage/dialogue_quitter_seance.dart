import 'package:flutter/material.dart';

/// Dialog de confirmation de sortie de seance, partage par les exercices.
///
/// Retourne `true` si l'utilisateur confirme la sortie, `false`/`null` sinon.
/// Tous les libelles sont fournis par l'appelant (resolus depuis l'ARB).
Future<bool?> showDialogueQuitterSeance(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  required String cancelLabel,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
