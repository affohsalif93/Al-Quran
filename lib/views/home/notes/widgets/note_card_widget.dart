import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/models/note.dart';
import 'package:quran/providers/quran/quran_notes_provider.dart';
import 'package:quran/views/widgets/confirm_delete_dialog.dart';

class NoteCardWidget extends StatelessWidget {
  final Note note;
  final WidgetRef ref;
  final VoidCallback onEdit;
  final bool showAyahReference;

  const NoteCardWidget({
    super.key,
    required this.note,
    required this.ref,
    required this.onEdit,
    this.showAyahReference = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: context.colors.navBarBackground.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.content, 
            style: const TextStyle(fontSize: 14, height: 1.4),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Created: ${_formatDate(note.createdAt)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: onEdit,
                    color: Colors.blue,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: () => _deleteNote(context),
                    color: Colors.red,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _deleteNote(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        onConfirm: () async {
          try {
            final notesController = ref.read(notesControllerProvider.notifier);
            await notesController.deleteNote(note.id);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to delete note: $e'), backgroundColor: Colors.red),
              );
            }
          }
        },
      ),
    );
  }
}
