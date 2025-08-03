import 'package:equatable/equatable.dart';

import 'multi_language_model.dart';

class Tafsir extends Equatable {
  final String url;
  final MultiLanguageModel name;
  final MultiLanguageModel description;
  final String fileName;
  final double size;
  final String tafsir;

  const Tafsir({
    required this.url,
    required this.name,
    required this.description,
    required this.fileName,
    required this.size,
    this.tafsir = '',
  });

  String get fileNameZip => '$fileName.zip';

  @override
  List<Object?> get props => [fileName];

  factory Tafsir.fromJson(Map<String, dynamic> json) {
    return Tafsir(
      url: json['url'] as String? ?? '',
      name: MultiLanguageModel.fromJson(json['name'] ?? {}),
      description: MultiLanguageModel.fromJson(json['description'] ?? {}),
      fileName: json['file'] as String? ?? '',
      size: (json['size'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'name': name.toJson(),
      'description': description.toJson(),
      'file': fileName,
      'size': size,
    };
  }

  Tafsir copyWith({
    String? url,
    MultiLanguageModel? name,
    MultiLanguageModel? description,
    String? fileName,
    double? size,
    String? tafsir,
  }) {
    return Tafsir(
      url: url ?? this.url,
      name: name ?? this.name,
      description: description ?? this.description,
      fileName: fileName ?? this.fileName,
      size: size ?? this.size,
      tafsir: tafsir ?? this.tafsir,
    );
  }
}
