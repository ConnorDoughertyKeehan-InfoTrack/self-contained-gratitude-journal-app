import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:self_contained_gratitude/calendar_page/add_gratitude_dialog.dart';
import 'package:self_contained_gratitude/calendar_page/edit_gratitude_dialog.dart';
import 'package:self_contained_gratitude/calendar_page/import_export_dialog.dart';
import 'package:self_contained_gratitude/models/journal_entry.dart';
import 'package:self_contained_gratitude/utils/database_helper.dart';
import 'package:self_contained_gratitude/utils/journal_database_helper.dart';
import 'package:self_contained_gratitude/utils/notification_helper.dart';

import '../utils/csv_helper.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
   List<JournalEntry> _journalEntries = [];
   bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }

  void _loadJournalEntries() async {
    await DatabaseHelper.instance.waitForDbReady(); // Ensure DB is ready
    _journalEntries = await DatabaseHelper.instance.readAllEntries();
    setState(() {
      isLoading = false;
    });
  }

  void _addGratitudeItem(String bodyText) async {
    final newEntry = JournalEntry(
      dateCreated: DateTime.now().toIso8601String(),
      lastDateShown: DateTime.now().toIso8601String(),
      bodyText: bodyText,
    );
    await DatabaseHelper.instance.createEntry(newEntry);
    _loadJournalEntries();
  }

  void _editGratitudeItem(JournalEntry entry, String updatedText) async {
    final updatedEntry = JournalEntry(
      id: entry.id,
      dateCreated: entry.dateCreated,
      lastDateShown: DateTime.now().toIso8601String(),
      bodyText: updatedText,
    );
    await DatabaseHelper.instance.updateEntry(updatedEntry);
    _loadJournalEntries();
  }

  void _deleteGratitudeItem(int id) async {
    await DatabaseHelper.instance.deleteEntry(id);
    _loadJournalEntries();
  }

  void _showAddGratitudeDialog() {
    showDialog(
      context: context,
      builder: (context) => AddGratitudeDialog(
        onAdd: (text) {
          if (text.isNotEmpty) {
            _addGratitudeItem(text);
          }
        },
      ),
    );
  }

  void _showEditGratitudeDialog(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (_) => EditGratitudeDialog(
        initialText: entry.bodyText,
        onUpdate: (updatedText) {
          // Once user hits "Save" in the dialog, call your update logic:
          _editGratitudeItem(entry, updatedText);
        },
      ),
    );
  }

  void _confirmDeleteGratitudeItem(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Gratitude Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteGratitudeItem(entry.id!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _showTimePicker() async {
    var hasNotificationPermissions = await NotificationHelper.instance.requestNotificationPermissions();

    if (!hasNotificationPermissions) {
      // Show a message or a dialog directing user to enable permissions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enable notifications to allow setting notification time'),
        ),
      );
      return;
    }

    final currentScheduledTime = await NotificationHelper.instance.getNotificationTime();
    // Otherwise, permission is granted; proceed to show time picker and schedule
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: currentScheduledTime,
      helpText: "Set reminder time"
    );

    if (selectedTime != null) {
      // Store and schedule the notification
      await NotificationHelper.instance.storeNotificationTime(selectedTime);
      await NotificationHelper.instance.scheduleDailyNotification();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notifications scheduled for ${selectedTime.format(context)}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void importComplete() {
    setState(() {

    });
  }

   void _showImportExportDialog() {
     showDialog(
       context: context,
       builder: (_) => ImportExportDialog(
         journalEntries: _journalEntries,
         importComplete: importComplete,
       ),
     );
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // You can also set a background color here or in the body’s Container
      appBar: AppBar(
        title: const Text('Gratitude Journal'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.file_copy_outlined),
          tooltip: 'Import/Export',
          onPressed: _showImportExportDialog,
        ),
        actions: [
          IconButton(
            icon: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.access_time,
                color: Colors.blue,
              ),
            ),
            onPressed: _showTimePicker,
          ),
        ]
      ),
      body: isLoading ? CircularProgressIndicator() : Container(
        // Adding a nice gradient background
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _journalEntries.isEmpty ? const Center(child: Text('No gratitude items yet.')) :
            ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                itemCount: _journalEntries.length,
                itemBuilder: (context, index) {
                  final entry = _journalEntries[index];
                  final formattedDate = DateFormat.yMMMMd().format(
                    DateTime.parse(entry.dateCreated),
                  );
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        entry.bodyText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showEditGratitudeDialog(entry);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _confirmDeleteGratitudeItem(entry);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGratitudeDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}