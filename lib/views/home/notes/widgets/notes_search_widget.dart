import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/models/note_model.dart';
import 'package:quran/providers/notes/notes_state.dart';
import 'package:quran/providers/quran/quran_notes_provider.dart' show notesControllerProvider;
import 'package:quran/views/home/notes/widgets/note_card_widget.dart';

class NotesSearchWidget extends StatefulWidget {
  final WidgetRef ref;
  final Function(Note) onEditNote;

  const NotesSearchWidget({
    super.key,
    required this.ref,
    required this.onEditNote,
  });

  @override
  State<NotesSearchWidget> createState() => _NotesSearchWidgetState();
}

class _NotesSearchWidgetState extends State<NotesSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Note> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final notesController = widget.ref.read(notesControllerProvider.notifier);
      final results = await notesController.searchNotes(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search notes...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: _performSearch,
          ),
        ),

        // Search results
        Expanded(
          child: _searchController.text.isNotEmpty
              ? _buildSearchResults()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'No notes found for "${_searchController.text}"',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final note = _searchResults[index];
        return NoteCardWidget(
          note: note,
          ref: widget.ref,
          onEdit: () => widget.onEditNote(note),
          showAyahReference: true,
        );
      },
    );
  }
}