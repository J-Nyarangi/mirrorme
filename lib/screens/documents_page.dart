import 'package:flutter/material.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({Key? key}) : super(key: key);

  @override
  _DocumentsPageState createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  List<String> documents = [];

  void _addDocument() async {
    final String? newDocument = await showDialog<String>(
      context: context,
      builder: (context) {
        String? documentName;

        return AlertDialog(
          title: const Text('Add New Document'),
          content: TextField(
            onChanged: (value) {
              documentName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(documentName);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (newDocument != null) {
      setState(() {
        documents.add(newDocument);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Documents'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _addDocument,
            child: const Text('Add New Document'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(documents[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
