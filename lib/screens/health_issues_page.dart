import 'package:flutter/material.dart';
import 'menu.dart';
import 'fragments.dart';

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
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

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
      final fromDateText = fromDateController.text.trim();
      final toDateText = toDateController.text.trim();

      if (name.isNotEmpty && fromDateText.isNotEmpty && toDateText.isNotEmpty) {
        final DateTime fromDate = DateTime.parse(fromDateText);
        final DateTime toDate = DateTime.parse(toDateText);

        final healthIssue = HealthIssue(
          name: name,
          description: description,
          fromDate: fromDate,
          toDate: toDate,
        );

        healthIssues.add(healthIssue);
        filteredHealthIssues = List.from(healthIssues);

        // Clear the text fields
        nameController.clear();
        descriptionController.clear();
        fromDateController.clear();
        toDateController.clear();

        // Hide the form
        _toggleForm();
      } else {
        // Show an error message or handle the empty fields case
        print('Please fill in all the fields');
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
      drawer: AppMenu(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
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
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.0),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.0),
                    TextField(
                      controller: fromDateController,
                      decoration: InputDecoration(
                        labelText: 'From',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          fromDateController.text = picked.toString();
                        }
                      },
                    ),
                    SizedBox(height: 12.0),
                    TextField(
                      controller: toDateController,
                      decoration: InputDecoration(
                        labelText: 'To',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          toDateController.text = picked.toString();
                        }
                      },
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
                            fromDateController.clear();
                            toDateController.clear();
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
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(healthIssue.description),
                        Text('From: ${healthIssue.fromDate.toString()}'),
                        Text('To: ${healthIssue.toDate.toString()}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteHealthIssue(healthIssue),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HealthIssue {
  final String name;
  final String description;
  final DateTime fromDate;
  final DateTime toDate;

  HealthIssue({
    required this.name,
    required this.description,
    required this.fromDate,
    required this.toDate,
  });
}
