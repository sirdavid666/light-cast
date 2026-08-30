class Song {
  final int? id;
  final String title;
  final List<String> verses;

  Song({
    this.id,
    required this.title,
    required this.verses,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'verses': verses.join('\n\n'),
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] as int?,
      title: map['title'] as String,
      verses: (map['verses'] as String).split('\n\n'),
    );
  }

  Song copyWith({
    int? id,
    String? title,
    List<String>? verses,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      verses: verses ?? this.verses,
    );
  }

  @override
  String toString() => 'Song(id: $id, title: $title)';
}
