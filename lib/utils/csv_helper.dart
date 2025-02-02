import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:self_contained_gratitude/utils/database_helper.dart';
import 'package:self_contained_gratitude/utils/journal_database_helper.dart';
import 'package:share_plus/share_plus.dart';
import '../models/journal_entry.dart';

Future<void> exportEntriesToCsv(List<JournalEntry> entries) async {
  // 1. Create rows for CSV (no 'id' column)
  List<List<dynamic>> rows = [
    ['date_created', 'last_date_shown', 'body_text'],
    ...entries.map((entry) => [
      entry.dateCreated,
      entry.lastDateShown,
      entry.bodyText,
    ]),
  ];

  // 2. Convert rows to CSV string
  final csv = const ListToCsvConverter().convert(rows);

  // 3. Write CSV file and share
  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/journal_entries.csv';
  final file = File(filePath);
  await file.writeAsString(csv);

  final xFile = XFile(
    filePath,
    mimeType: 'text/csv',
    name: 'journal_entries.csv',
  );

  await Share.shareXFiles(
    [xFile],
    subject: 'Exported Journal Entries',
    text: 'Here are my exported CSV entries.',
  );
}

Future<void> importEntriesFromCsv(String filePath) async {
  final file = File(filePath);
  if (!file.existsSync()) {
    throw Exception('CSV file not found at $filePath');
  }

  final csvString = await file.readAsString();
  final rows = const CsvToListConverter().convert(csvString, eol: '\n');

  // Skip header row (row[0]) if it exists
  for (int i = 1; i < rows.length; i++) {
    final row = rows[i];

    final entry = JournalEntry(
      // For example, if your columns are [date_created, last_date_shown, body_text]
      dateCreated: row[0] as String,
      lastDateShown: row[1] as String,
      bodyText: row[2] as String,
    );

    await DatabaseHelper.instance.insertIfNotDuplicate(entry);
  }
}