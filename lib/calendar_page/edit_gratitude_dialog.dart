import 'package:flutter/material.dart';

class EditGratitudeDialog extends StatelessWidget {
  /// Callback for when the user saves/updates the entry.
  final Function(String) onUpdate;

  /// TextEditingController that is pre-filled with the existing text.
  final TextEditingController _controller;

  /// [initialText] is the existing gratitude text that will be displayed
  /// for editing in the TextField.
  EditGratitudeDialog({
    super.key,
    required this.onUpdate,
    required String initialText,
  })  : _controller = TextEditingController(text: initialText);

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
              Icon(Icons.edit, color: Theme.of(context).primaryColor, size: 40),
              const Text(
                'Edit Gratitude Item',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Update your gratitude entry',
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 3,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      final text = _controller.text.trim();
                      if (text.isNotEmpty) {
                        onUpdate(text);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
