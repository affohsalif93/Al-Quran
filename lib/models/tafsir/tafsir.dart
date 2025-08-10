class Tafsir {
  final String ayahKey;        // e.g., "1:1" 
  final String groupAyahKey;   // e.g., "1:1" (same as fromAyah formatted)
  final int surah;             // e.g., 1
  final int fromAyah;          // e.g., 1
  final int toAyah;            // e.g., 7
  final String ayahKeys;       // e.g., "1:1,1:2,1:3,1:4,1:5,1:6,1:7"
  final String text;           // HTML content

  const Tafsir({
    required this.ayahKey,
    required this.groupAyahKey,
    required this.surah,
    required this.fromAyah,
    required this.toAyah,
    required this.ayahKeys,
    required this.text,
  });

  factory Tafsir.fromMap(Map<String, dynamic> map) {
    // Parse surah and ayah from from_ayah string (e.g., "1:1")
    final fromAyahParts = (map['from_ayah'] as String).split(':');
    final surah = int.parse(fromAyahParts[0]);
    final fromAyah = int.parse(fromAyahParts[1]);
    
    // Parse toAyah from to_ayah string (e.g., "1:7")
    final toAyahParts = (map['to_ayah'] as String).split(':');
    final toAyah = int.parse(toAyahParts[1]);
    
    return Tafsir(
      ayahKey: map['ayah_key'] as String,
      groupAyahKey: map['group_ayah_key'] as String,
      surah: surah,
      fromAyah: fromAyah,
      toAyah: toAyah,
      ayahKeys: map['ayah_keys'] as String,
      text: map['text'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ayah_key': ayahKey,
      'group_ayah_key': groupAyahKey,
      'from_ayah': '$surah:$fromAyah',
      'to_ayah': '$surah:$toAyah',
      'ayah_keys': ayahKeys,
      'text': text,
    };
  }

  // Parse ayah key to get surah and ayah numbers
  (int surah, int ayah) get parsedAyahKey {
    final parts = ayahKey.split(':');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }

  // Parse from ayah to get surah and ayah numbers
  (int surah, int ayah) get parsedFromAyah {
    return (surah, fromAyah);
  }

  // Parse to ayah to get surah and ayah numbers
  (int surah, int ayah) get parsedToAyah {
    return (surah, toAyah);
  }

  // Get list of ayah keys covered by this tafsir entry
  List<String> get coveredAyahKeys {
    return ayahKeys.split(',').map((key) => key.trim()).toList();
  }

  // Check if this tafsir entry covers a specific ayah
  bool coversAyah(int surah, int ayah) {
    final targetKey = '$surah:$ayah';
    return coveredAyahKeys.contains(targetKey);
  }

  // Check if this is a range entry (covers multiple ayahs)
  bool get isRangeEntry {
    return coveredAyahKeys.length > 1;
  }

  @override
  String toString() {
    return 'Tafsir(ayahKey: $ayahKey, groupAyahKey: $groupAyahKey, surah: $surah, fromAyah: $fromAyah, toAyah: $toAyah, ayahKeys: $ayahKeys)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tafsir && 
           other.ayahKey == ayahKey &&
           other.groupAyahKey == groupAyahKey &&
           other.surah == surah &&
           other.fromAyah == fromAyah &&
           other.toAyah == toAyah &&
           other.ayahKeys == ayahKeys &&
           other.text == text;
  }

  @override
  int get hashCode {
    return ayahKey.hashCode ^
           groupAyahKey.hashCode ^
           surah.hashCode ^
           fromAyah.hashCode ^
           toAyah.hashCode ^
           ayahKeys.hashCode ^
           text.hashCode;
  }
}

// Tafsir book/source information
class TafsirBook {
  final String name;
  final String dbFileName;
  final String displayName;
  final String author;
  final String? description;
  // lang
  final String lang; // Optional: if you want to support multiple languages


  const TafsirBook({
    required this.name,
    required this.dbFileName,
    required this.displayName,
    required this.author,
    required this.lang,
    this.description,
  });

  @override
  String toString() {
    return 'TafsirBook(name: $name, displayName: $displayName, author: $author)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TafsirBook && 
           other.name == name &&
           other.dbFileName == dbFileName &&
           other.displayName == displayName &&
           other.author == author &&
           other.description == description;
  }

  get isArabic => lang.toLowerCase() == 'ar';

  @override
  int get hashCode {
    return name.hashCode ^
           dbFileName.hashCode ^
           displayName.hashCode ^
           author.hashCode ^
           description.hashCode;
  }
}