class Entry {
  final String id;
  final DateTime date;
  final String text;
  final String? audioPath;
  final String? summary;

  Entry({
    required this.id,
    required this.date,
    required this.text,
    this.audioPath,
    this.summary,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'text': text,
        'audioPath': audioPath,
        'summary': summary,
      };

  factory Entry.fromJson(Map<String, dynamic> json) => Entry(
        id: json['id'],
        date: DateTime.parse(json['date']),
        text: json['text'],
        audioPath: json['audioPath'],
        summary: json['summary'],
      );

  Entry copyWith({
    String? text,
    String? audioPath,
    String? summary,
  }) {
    return Entry(
      id: id,
      date: date,
      text: text ?? this.text,
      audioPath: audioPath ?? this.audioPath,
      summary: summary ?? this.summary,
    );
  }
}
