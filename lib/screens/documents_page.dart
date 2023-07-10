import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'menu.dart';
import 'fragments.dart';
import 'package:open_file/open_file.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({Key? key}) : super(key: key);

  @override
  _DocumentsPageState createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  List<String> documents = [];
  List<String> descriptions = [];

  void _uploadFile() async {
  try {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final filePath = result.files.single.path!;
      final fileName = result.files.single.name;

      final documentAdded = await showDialog<bool>(
        context: context,
        builder: (context) {
          bool? addDocument;

          return AlertDialog(
            title: const Text('Add Document'),
            content: Text('Do you want to add the document?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );

      if (documentAdded == true) {
        setState(() {
          documents.add(fileName);
          descriptions.add(''); // Add an empty description for the new document
        });
      }
    }
  } on PlatformException catch (e) {
    print('Error while picking the file: $e');
  }
}

  void _viewDocument(int index) async {
  String documentPath = documents[index];

  // Open the document using the default system application
  final result = await OpenFile.open(documentPath);
  if (result.type == ResultType.done) {
    print('Document opened successfully');
  } else {
    print('Error opening document: ${result.message}');
  }
}



  void _deleteDocument(int index) {
    if (index >= 0 && index < documents.length && index < descriptions.length) {
      setState(() {
        documents.removeAt(index);
        descriptions.removeAt(index); // Remove the corresponding description
      });
    }
  }

  void _updateDocument(int index, String newName, String newDescription) {
    if (index >= 0 && index < documents.length && index < descriptions.length) {
      setState(() {
        documents[index] = newName;
        descriptions[index] = newDescription;
      });
    }
  }

  void _editDocument(int index) async {
    if (index >= 0 && index < documents.length && index < descriptions.length) {
      final editedName = await showDialog<String>(
        context: context,
        builder: (context) {
          String? newName;
          String? newDescription;

          return AlertDialog(
            title: const Text('Edit Document'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    newName = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    newDescription = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(newName);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (editedName != null && editedName.isNotEmpty) {
        _updateDocument(index, editedName, descriptions[index]);
      }
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.teal,
      title: const Text('Documents'),
    ),
    drawer: AppMenu(),
    body: Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        documents[index],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        descriptions[index],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          DropdownButton<String>(
                            icon: Icon(Icons.more_vert),
                            onChanged: (value) {
                              if (value == 'Edit') {
                                _editDocument(index);
                              } else if (value == 'Delete') {
                                _deleteDocument(index);
                              } else if (value == 'View') {
                                _viewDocument(index);
                              }
                            },
                            items: ['Edit', 'Delete', 'View']
                                .map<DropdownMenuItem<String>>(
                              (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              },
                            ).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _uploadFile,
            child: const Icon(Icons.file_upload),
            style: ElevatedButton.styleFrom(
              primary: Colors.teal, // Set the background color to teal
              shape: CircleBorder(),
            ),
          ),
        ),
        Fragments(),
      ],
    ),
  );
}
}






