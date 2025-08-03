import 'package:flutter/material.dart';
import 'package:quran/core/extensions/context_extensions.dart';

class NotesActionBar extends StatelessWidget {
  final VoidCallback onDiscard;
  final VoidCallback onSave;
  final bool isEditingExisting;

  const NotesActionBar({
    super.key,
    required this.onDiscard,
    required this.onSave,
    required this.isEditingExisting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed: onDiscard,
            icon: const Icon(Icons.close, color: Colors.red),
            label: const Text('Discard', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.red[50],
              padding: const EdgeInsets.symmetric(vertical: 13),
              minimumSize: Size(150, 30),
            ),
          ),
          FilledButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save),
            label: Text(isEditingExisting ? 'Update' : 'Save'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              minimumSize: Size(150, 30),
            ),
          ),
        ],
      ),
    );
  }
}