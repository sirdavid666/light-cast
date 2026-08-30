class Scripture {
  final int? id;
  final String reference;
  final String text;

  Scripture({
    this.id,
    required this.reference,
    required this.text,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reference': reference,
      'text': text,
    };
  }

  factory Scripture.fromMap(Map<String, dynamic> map) {
    return Scripture(
      id: map['id'] as int?,
      reference: map['reference'] as String,
      text: map['text'] as String,
    );
  }

  Scripture copyWith({
    int? id,
    String? reference,
    String? text,
  }) {
    return Scripture(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      text: text ?? this.text,
    );
  }

  @override
  String toString() => 'Scripture(id: $id, reference: $reference)';
}
