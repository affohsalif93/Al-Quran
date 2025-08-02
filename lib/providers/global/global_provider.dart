import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/models/quran/ayah_model.dart';
import 'package:quran/providers/global/global_controller.dart';

final selectedAyahProvider = Provider<Ayah>((ref) {
  return ref.watch(globalControllerProvider).selectedAyah;
});