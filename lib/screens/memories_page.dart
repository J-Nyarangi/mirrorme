import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Memory {
  final String id;
  String title;
  String description;
  String imageURL;

  Memory({
    required this.id,
    required this.title,
    required this.description,
    required this.imageURL,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageURL': imageURL,
    };
  }
}

class MemoriesPage extends StatefulWidget {
  @override
  _MemoriesPageState createState() => _MemoriesPageState();
}

class _MemoriesPageState extends State<MemoriesPage> {
  List<Memory> memories = [];
  CollectionReference memoriesCollection =
      FirebaseFirestore.instance.collection('memories');

 Future<void> _addMemory() async {
  final picker = ImagePicker();
  final pickedImage = await picker.getImage(source: ImageSource.gallery);

  if (pickedImage != null) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController titleController = TextEditingController();
        TextEditingController descriptionController = TextEditingController();

        return AlertDialog(
          title: Text('Add Memory'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(
                File(pickedImage.path),
                fit: BoxFit.cover,
                height: 200,
              ),
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newMemory = Memory(
                  id: DateTime.now().toString(),
                  title: titleController.text,
                  description: descriptionController.text,
                  imageURL: '',
                );

                try {
                  final storageRef = FirebaseStorage.instance
                      .ref()
                      .child('memories/${newMemory.id}');
                  final uploadTask =
                      storageRef.putFile(File(pickedImage.path));
                  final TaskSnapshot uploadSnapshot =
                      await uploadTask.whenComplete(() {});

                  final imageUrl = await uploadSnapshot.ref.getDownloadURL();
                  newMemory.imageURL = imageUrl;

                  await memoriesCollection.doc(newMemory.id).set(newMemory.toMap());

                  setState(() {
                    memories.add(newMemory);
                  });

                  Navigator.pop(context);
                } catch (error) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Failed to add memory.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}


  Future<void> _updateMemory(Memory memory) async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      showDialog(
        context: context,
        builder: (context) {
          TextEditingController titleController =
              TextEditingController(text: memory.title);
          TextEditingController descriptionController =
              TextEditingController(text: memory.description);

          return AlertDialog(
            title: Text('Update Memory'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(
                  File(pickedImage.path),
                  fit: BoxFit.cover,
                  height: 200,
                ),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final storageRef = FirebaseStorage.instance
                        .ref()
                        .child('memories/${memory.id}');
                    final uploadTask =
                        storageRef.putFile(File(pickedImage.path));
                    final snapshot = await uploadTask.whenComplete(() {});

                    final imageURL = await snapshot.ref.getDownloadURL();

                    setState(() {
                      memory.title = titleController.text;
                      memory.description = descriptionController.text;
                      memory.imageURL = imageURL;
                    });

                    await memoriesCollection
                        .doc(memory.id)
                        .update(memory.toMap());

                    Navigator.pop(context);
                  } catch (error) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Error'),
                          content: Text('Failed to update memory.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('Update'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _deleteMemory(Memory memory) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Memory'),
          content: Text('Are you sure you want to delete this memory?'),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  final storageRef = FirebaseStorage.instance
                      .ref()
                      .child('memories/${memory.id}');
                  await storageRef.delete();

                  await memoriesCollection.doc(memory.id).delete();

                  setState(() {
                    memories.remove(memory);
                  });

                  Navigator.pop(context);
                } catch (error) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Failed to delete memory.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memories'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: memoriesCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final memories = snapshot.data!.docs
              .map((doc) => Memory(
                    id: doc.id,
                    title: doc['title'],
                    description: doc['description'],
                    imageURL: doc['imageURL'],
                  ))
              .toList();

          return ListView.builder(
            itemCount: memories.length,
            itemBuilder: (context, index) {
              return MemoryCard(
                memory: memories[index],
                onUpdate: () => _updateMemory(memories[index]),
                onDelete: () => _deleteMemory(memories[index]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
        onPressed: _addMemory,
      ),
    );
  }
}

class MemoryCard extends StatefulWidget {
  final Memory memory;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const MemoryCard({
    required this.memory,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  _MemoryCardState createState() => _MemoryCardState();
}

class _MemoryCardState extends State<MemoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 200,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (BuildContext context, Widget? child) {
                  return Transform.scale(
                    scale: 1.0 + (_scaleAnimation.value * 0.1),
                    child: Image.network(
                      widget.memory.imageURL,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.memory.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.memory.description,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: widget.onUpdate,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Memories App',
    theme: ThemeData(primarySwatch: Colors.teal),
    home: MemoriesPage(),
  ));
}
