class JournalEntry {
  final int? id;
  final String dateCreated;
  final String lastDateShown;
  final String bodyText;

  JournalEntry({
    this.id,
    required this.dateCreated,
    required this.lastDateShown,
    required this.bodyText,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date_created': dateCreated,
      'last_date_shown': lastDateShown,
      'body_text': bodyText,
    };
  }

  static JournalEntry fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      dateCreated: map['date_created'],
      lastDateShown: map['last_date_shown'],
      bodyText: map['body_text'],
    );
  }
}