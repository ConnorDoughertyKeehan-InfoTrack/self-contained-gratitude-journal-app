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
  // Export CSV (unchanged)
  Future<void> _exportCsv() async {
    await exportEntriesToCsv(widget.journalEntries);
  }

  // Import CSV (unchanged)
  Future<void> _importCsv() async {
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

    widget.importComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 20,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade50, Colors.blue.shade50],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Section
              Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.grey.shade500),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.1),
                              blurRadius: 12,
                              spreadRadius: 4,
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.cloud_sync_rounded,
                          color: Colors.deepPurple[400],
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Manage Your Memories",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.deepPurple[800],
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Safeguard your gratitude journey\nwith seamless import/export",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Column(
                children: [
                  _buildActionButton(
                    context,
                    icon: Icons.download_rounded,
                    label: "Import Entries",
                    onPressed: _importCsv,
                    isPrimary: true,
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    icon: Icons.upload_rounded,
                    label: "Export Entries",
                    onPressed: _exportCsv,
                    isPrimary: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required Function() onPressed, required bool isPrimary}) {
    final colors = isPrimary
        ? [Colors.deepPurple, Colors.indigo]
        : [Colors.white, Colors.white];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: isPrimary
            ? [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          )
        ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: isPrimary ? Colors.white : Colors.deepPurple,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}