import 'package:self_contained_gratitude/models/journal_entry.dart';
import 'package:self_contained_gratitude/utils/database_helper.dart';

extension JournalDatabaseHelper on DatabaseHelper {
  Future<int> createEntry(JournalEntry entry) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('journal_entries', entry.toMap());
  }

  Future<List<JournalEntry>> readAllEntries() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'journal_entries',
      orderBy: 'date_created DESC',
    );

    return result.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<int> updateEntry(JournalEntry entry) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'journal_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      'journal_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertIfNotDuplicate(JournalEntry entry) async {
    final db = await DatabaseHelper.instance.database;

    final duplicates = await db.query(
      'journal_entries',
      where: 'body_text = ? AND date(date_created) = date(?)',
      whereArgs: [entry.bodyText, entry.dateCreated],
    );

    if (duplicates.isEmpty) {
      // No duplicate found, so insert
      await db.insert('journal_entries', entry.toMap());
    } else {
      // Duplicate found; decide what to do. For example, skip or update.
      print('Skipping duplicate entry for body: ${entry.bodyText}');
    }
  }
}