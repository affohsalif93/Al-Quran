import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quran/common_widgets/async_value_builder.dart';
import 'package:quran/models/tafsir_model.dart';
import 'package:quran/providers/quran/quran_repository.dart';
import 'single_tafsir_section.dart';
import 'tafsir_empty_section.dart';

final tafsirFutureProvider = FutureProvider.autoDispose
    .family<List<TafsirModel>, int>((ref, index) async {
  final tafsir =
      await ref.watch(quranRepositoryProvider).getTafsirFromIndex(index);
  return tafsir;
});

class TafsirSection extends ConsumerWidget {
  const TafsirSection({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AsyncValueBuilder(
          value: ref.watch(tafsirFutureProvider(index)),
          onRefresh: () => ref.refresh(tafsirFutureProvider(index)),
          data: (tafsirList) {
            if (tafsirList.isEmpty) {
              return TafsirEmptySection(index: index);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final tafsir in tafsirList) SingleTafsirSection(tafsir),
              ],
            );
          },
        ),
      ],
    );
  }
}
