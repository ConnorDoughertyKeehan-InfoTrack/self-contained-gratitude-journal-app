import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:self_contained_gratitude/models/journal_entry.dart';
import '../utils/csv_helper.dart';

class ImportExportDialog extends StatefulWidget {
  final List<JournalEntry> journalEntries;
  final Function() importComplete;
  const ImportExportDialog({super.key, required this.journalEntries, required this.importComplete});

  @override
  State<ImportExportDialog> createState() => _ImportExportDialogState();
}

class _ImportExportDialogState extends State<ImportExportDialog> {
  // In your DatabaseHelper extension or wherever you handle CSV import
  Future<void> _exportCsv() async {
    await exportEntriesToCsv(widget.journalEntries);
  }

  Future<void> _importCsv() async {
    // 1. Let user pick a file
    print("we hitting this");
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    // 2. If they canceled or no file was picked, just return
    if (result == null) return;

    // 3. Extract the file path
    final pickedFilePath = result.files.single.path;
    if (pickedFilePath == null) return;

    // 4. Pass the path to your import method
    await importEntriesFromCsv(pickedFilePath);

    // 5. Refresh your local UI data (assuming you have a method like _loadJournalEntries)
    widget.importComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 300,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.file_copy_outlined, color: Theme.of(context).primaryColor, size: 40),
              ElevatedButton(
                onPressed: _importCsv,
                child: Text("Import"),
              ),
              ElevatedButton(
                onPressed: _exportCsv,
                child: Text("Export"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
