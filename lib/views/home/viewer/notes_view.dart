import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/assets/fonts.gen.dart';
import 'package:quran/models/quran/ayah_model.dart';
import 'package:quran/providers/global/global_provider.dart';
import 'package:quran/repositories/quran/static_quran_data.dart';

class SelectedAyahWidget extends StatelessWidget {
  final Ayah ayah;

  const SelectedAyahWidget({super.key, required this.ayah});

  @override
  Widget build(BuildContext context) {
    final ayahReference =
        'Surah ${StaticQuranData.getSurah(ayah.surah).englishName}, Ayah ${ayah.ayah}';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
      child: Column(
        children: [
          Text(ayahReference, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          SizedBox(height: 10),
          Text(
            ayah.text,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 22,
              fontFamily: FontFamily.uthmanicHafs,
              color: Colors.black,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late QuillController _quillController;
  late FocusNode _editorFocusNode;
  late ScrollController _editorScrollController;

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

  @override
  Widget build(BuildContext context) {
    return Consumer(
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

        return Column(
          children: [
            // Selected Ayah Display
            SelectedAyahWidget(ayah: selectedAyah),

            // Notes section header
            Container(
              padding: EdgeInsets.all(8),
              child: Text(
                "Notes",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              ),
            ),

            // Quill Toolbar - Simple configuration for note-taking
            Container(
              decoration: BoxDecoration(color: Colors.white),
              child: QuillSimpleToolbar(
                controller: _quillController,
                config: QuillSimpleToolbarConfig(
                  // Show only essential formatting options
                  showBoldButton: true,
                  showItalicButton: true,
                  showUnderLineButton: true,
                  showStrikeThrough: false,
                  showColorButton: false,
                  showBackgroundColorButton: false,
                  showClearFormat: true,

                  // List formatting
                  showListNumbers: true,
                  showListBullets: true,
                  showListCheck: false,

                  // Text alignment
                  showAlignmentButtons: false,
                  showDirection: false,

                  // Advanced features - disabled for simple note-taking
                  showCodeBlock: false,
                  showQuote: false,
                  showIndent: false,
                  showLink: false,
                  showSearchButton: false,
                  showSubscript: false,
                  showSuperscript: false,
                  showInlineCode: false,
                  showFontSize: false,
                  showFontFamily: false,
                  showHeaderStyle: false,
                  showClipboardPaste: false,
                  showClipboardCut: false,
                  showClipboardCopy: false,
                  showRedo: true,
                  showUndo: true,

                  // Disable multirow to keep toolbar compact
                  multiRowsDisplay: false,

                  buttonOptions: QuillSimpleToolbarButtonOptions(
                    base: QuillToolbarBaseButtonOptions(
                      iconSize: 12,
                      afterButtonPressed: () {
                        _editorFocusNode.requestFocus();
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Quill Editor - Using exact structure from working example
            Expanded(
              child: QuillEditor(
                focusNode: _editorFocusNode,
                scrollController: _editorScrollController,
                controller: _quillController,
                config: QuillEditorConfig(
                  placeholder: 'Start writing your notes here...',

                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
