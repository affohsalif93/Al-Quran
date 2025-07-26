import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/models/quran/ayah_model.dart';
import 'package:quran/models/quran/word.dart' show Word;
import 'package:quran/providers/global/global_controller.dart';

class SelectedAyahWidget extends StatelessWidget {
  final Ayah selectedAyah;

  const SelectedAyahWidget({super.key, required this.selectedAyah});

  @override
  Widget build(BuildContext context) {
    return Text(
      selectedAyah.text,
      style: TextStyle(
        fontSize: 16,
        fontFamily: Word.fontFamilyForPage(selectedAyah.pageNumber),
        color: Colors.black,
      ),
    );
  }
}

class NotesView extends ConsumerWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalState = ref.watch(globalControllerProvider);

    // render selectedAyah if available

    return Container(
      decoration: BoxDecoration(color: Colors.grey),
      padding: EdgeInsets.fromLTRB(10, 20, 5, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Text('Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 10),
          Expanded(child: Container(child: Text("No notes available yet."))),
        ],
      ),
    );
  }
}
