import 'package:flutter/material.dart';

class MemoriesPage extends StatelessWidget {
  const MemoriesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memories'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Memories Page',
              style: TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              onPressed: () {
                _showAddAttachmentDialog(context);
              },
              child: const Text('Add Attachment'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAttachmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Attachment'),
          content: const Text('Choose a picture to add.'),
          actions: [
            TextButton(
              onPressed: () {
                // Add attachment functionality here
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
