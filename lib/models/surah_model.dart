class SurahModel {
  final int id;
  final String nameSimple;
  final String nameArabic;
  final int revelationOrder;
  final String revelationPlace;
  final int versesCount;

  SurahModel({
    required this.id,
    required this.nameSimple,
    required this.nameArabic,
    required this.revelationOrder,
    required this.revelationPlace,
    required this.versesCount,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      id: json['id'],
      nameSimple: json['name_simple'],
      nameArabic: json['name_arabic'],
      revelationOrder: json['revelation_order'],
      revelationPlace: json['revelation_place'],
      versesCount: json['verses_count'],
    );
  }
}
