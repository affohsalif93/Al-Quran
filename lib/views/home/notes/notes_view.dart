import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/models/quran/ayah.dart';
import 'package:quran/models/note.dart';
import 'package:quran/providers/global/global_provider.dart';
import 'package:quran/providers/notes/notes_state.dart';
import 'package:quran/providers/quran/quran_notes_provider.dart';
import 'package:quran/views/home/notes/widgets/selected_ayah_widget.dart';
import 'package:quran/views/home/notes/widgets/note_card_widget.dart';
import 'package:quran/views/home/notes/widgets/notes_editor_widget.dart';
import 'package:quran/views/home/notes/widgets/notes_action_bar.dart';
import 'package:quran/views/home/notes/widgets/notes_search_widget.dart';


class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late QuillController _quillController;
  late FocusNode _editorFocusNode;
  late ScrollController _editorScrollController;

  bool _isEditing = false;
  bool _isEditingExisting = false;
  Note? _editingNote;
  String? _lastLoadedAyah;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
    _editorFocusNode = FocusNode();
    _editorScrollController = ScrollController();
  }

  @override
  void dispose() {
    _quillController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  void _startEditing([Note? note]) {
    setState(() {
      _isEditing = true;
      _isEditingExisting = note != null;
      _editingNote = note;
      if (note != null) {
        // Load existing note content into editor
        _quillController.document = Document()..insert(0, note.content);
      } else {
        _quillController.clear();
      }
    });
  }

  void _saveNotes(WidgetRef ref, Ayah selectedAyah) async {
    final noteText = _quillController.document.toPlainText().trim();
    if (noteText.isEmpty) {
      _discardNotes();
      return;
    }

    try {
      final notesController = ref.read(notesControllerProvider.notifier);

      if (_isEditingExisting && _editingNote != null) {
        // Update existing note
        await notesController.updateNote(noteId: _editingNote!.id, content: noteText);
      } else {
        // Create new note
        await notesController.createNote(
          surah: selectedAyah.surah,
          ayah: selectedAyah.ayah,
          content: noteText,
        );
      }

      setState(() {
        _isEditing = false;
        _isEditingExisting = false;
        _editingNote = null;
      });
      _quillController.clear();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditingExisting ? 'Note updated successfully' : 'Note saved successfully',
            ),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _discardNotes() {
    setState(() {
      _isEditing = false;
      _isEditingExisting = false;
      _editingNote = null;
    });
    _quillController.clear();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer(
        builder: (context, ref, child) {
          final selectedAyah = ref.watch(selectedAyahProvider);

          if (selectedAyah == null) {
            return Center(
              child: Text(
                'No ayah selected. Click on an ayah number to start taking notes.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            );
          }

          // Load notes for the selected ayah only if it's different from the last loaded
          final currentAyahKey = '${selectedAyah.surah}_${selectedAyah.ayah}';
          if (_lastLoadedAyah != currentAyahKey) {
            _lastLoadedAyah = currentAyahKey;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(notesControllerProvider.notifier)
                  .loadNotesForAyah(selectedAyah.surah, selectedAyah.ayah);
            });
          }

          return Column(
            children: [
              SelectedAyahWidget(ayah: selectedAyah),

              Container(height: 10, color: context.colors.navBarBackground),

              Expanded(child: _buildNotesContent(ref, selectedAyah)),

              // Bottom action bar (only show when editing)
              if (_isEditing) NotesActionBar(
                onDiscard: _discardNotes,
                onSave: () => _saveNotes(ref, selectedAyah),
                isEditingExisting: _isEditingExisting,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotesContent(WidgetRef ref, Ayah selectedAyah) {
    if (_isEditing) {
      return NotesEditorWidget(
        controller: _quillController,
        focusNode: _editorFocusNode,
        scrollController: _editorScrollController,
      );
    }

    final notesState = ref.watch(notesControllerProvider);

    if (notesState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notesState.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text('Error loading notes', style: TextStyle(fontSize: 18, color: Colors.red[600])),
            const SizedBox(height: 8),
            Text(
              notesState.error!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(notesControllerProvider.notifier)
                    .loadNotesForAyah(selectedAyah.surah, selectedAyah.ayah);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (notesState.hasNotes) {
      return _buildNotesDisplayView(ref, notesState);
    } else {
      return _buildNoNotesView();
    }
  }

  Widget _buildNoNotesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add_outlined, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No notes for this ayah',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Add your thoughts and reflections',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _startEditing,
            icon: Icon(Icons.add),
            label: Text('Add Note'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesDisplayView(WidgetRef ref, NotesState notesState) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // Search functionality
          // Expanded(
          //   child: NotesSearchWidget(
          //     ref: ref,
          //     onEditNote: _startEditing,
          //   ),
          // ),

          Text("Notes", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[500])),

          SizedBox(height: 10),

          // Notes list
          Expanded(
            child: _buildNotesList(ref, notesState),
          ),

          // Add button
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => _startEditing(),
              icon: const Icon(Icons.add),
              label: const Text('Add Note'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildNotesList(WidgetRef ref, NotesState notesState) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: notesState.notes.length,
      itemBuilder: (context, index) {
        final note = notesState.notes[index];
        return NoteCardWidget(
          note: note,
          ref: ref,
          onEdit: () => _startEditing(note),
        );
      },
    );
  }


}
