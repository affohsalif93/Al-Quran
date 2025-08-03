import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:quran/i18n/strings.g.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConfirmDeleteDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.t.confirmDelete),
      content: Text(
        context.t.confirmDeleteMessage,
      ),
      actions: [
        TextButton(
          onPressed: context.pop,
          child: Text(context.t.cancel),
        ),
        FilledButton(
          onPressed: () {
            onConfirm();
            context.pop();
          },
          child: Text(context.t.confirmDelete),
        ),
      ],
    );
  }
}
