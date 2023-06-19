import 'package:flutter/material.dart';

class HealthIssuesPage extends StatefulWidget {
  const HealthIssuesPage({Key? key}) : super(key: key);

  @override
  _HealthIssuesPageState createState() => _HealthIssuesPageState();
}

class _HealthIssuesPageState extends State<HealthIssuesPage> {
  List<HealthIssue> healthIssues = [];
  List<HealthIssue> filteredHealthIssues = [];

  TextEditingController searchController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool _showForm = false;

  void _toggleForm() {
    setState(() {
      _showForm = !_showForm;
    });
  }

  void _addHealthIssue() {
    setState(() {
      final name = nameController.text.trim();
      final description = descriptionController.text.trim();

      if (name.isNotEmpty) {
        final healthIssue = HealthIssue(name: name, description: description);
        healthIssues.add(healthIssue);
        filteredHealthIssues = List.from(healthIssues);

        // Clear the text fields
        nameController.clear();
        descriptionController.clear();

        // Hide the form
        _toggleForm();
      }
    });
  }

  void _filterHealthIssues(String keyword) {
    setState(() {
      filteredHealthIssues = healthIssues
          .where((issue) => issue.name.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
      if (keyword.isEmpty) {
        filteredHealthIssues = List.from(healthIssues);
      }
    });
  }

  void _deleteHealthIssue(HealthIssue healthIssue) {
    setState(() {
      healthIssues.remove(healthIssue);
      filteredHealthIssues = List.from(healthIssues);
    });
  }

  @override
  void initState() {
    super.initState();
    filteredHealthIssues = List.from(healthIssues);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Health Issues'),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterHealthIssues,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_showForm)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  SizedBox(height: 12.0),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Clear the text fields
                          nameController.clear();
                          descriptionController.clear();
                        },
                        child: Text('Clear'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey[300],
                        ),
                      ),
                      SizedBox(width: 16.0),
                      ElevatedButton(
                        onPressed: _addHealthIssue,
                        child: Text('Add Issue'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _toggleForm,
            child: Text(_showForm ? 'Cancel' : 'Add New Health Issue'),
            style: ElevatedButton.styleFrom(
              primary: _showForm ? Colors.red : Colors.teal,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredHealthIssues.length,
              itemBuilder: (context, index) {
                final healthIssue = filteredHealthIssues[index];
                return Card(
                  color: Colors.blue.withOpacity(0.2), // Transparent blue color
                  child: ListTile(
                    title: Text(
                      healthIssue.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(healthIssue.description),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteHealthIssue(healthIssue),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HealthIssue {
  final String name;
  final String description;

  HealthIssue({required this.name, required this.description});
}
