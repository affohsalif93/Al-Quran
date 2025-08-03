import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:quran/core/extensions/context_extensions.dart';

class NotesEditorWidget extends StatelessWidget {
  final QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;

  const NotesEditorWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        
        // Quill Toolbar
        Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
          child: QuillSimpleToolbar(
            controller: controller,
            config: QuillSimpleToolbarConfig(
              // Show only essential formatting options
              showBoldButton: true,
              showItalicButton: true,
              showUnderLineButton: true,
              showStrikeThrough: false,
              showColorButton: false,
              showBackgroundColorButton: false,
              showClearFormat: true,
              showListNumbers: true,
              showListBullets: true,
              showListCheck: false,
              showAlignmentButtons: false,
              showDirection: false,
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
              multiRowsDisplay: false,
              buttonOptions: QuillSimpleToolbarButtonOptions(
                base: QuillToolbarBaseButtonOptions(
                  iconSize: 14,
                  afterButtonPressed: () {
                    focusNode.requestFocus();
                  },
                ),
              ),
            ),
          ),
        ),

        // Quill Editor
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.quranPageBackground,
            ),
            child: QuillEditor(
              focusNode: focusNode,
              scrollController: scrollController,
              controller: controller,
              config: QuillEditorConfig(
                autoFocus: true,
                placeholder: 'Start writing your notes here...',
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}