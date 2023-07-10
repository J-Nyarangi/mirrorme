import 'package:flutter/material.dart';
import 'menu.dart';
import 'fragments.dart';

class MedicationPlanPage extends StatefulWidget {
  const MedicationPlanPage({Key? key}) : super(key: key);

  @override
  _MedicationPlanPageState createState() => _MedicationPlanPageState();
}

class _MedicationPlanPageState extends State<MedicationPlanPage> {
  List<Medication> medications = [];
  List<Medication> filteredMedications = [];

  TextEditingController searchController = TextEditingController();

  void _addMedication() {
    setState(() {
      medications.add(Medication(
        name: 'New Medication',
        dosage: '',
        notes: '',
        schedule: '',
        startingDate: '',
        inventory: '',
      ));
      filteredMedications = List.from(medications);
    });
  }

  void _filterMedications(String keyword) {
    setState(() {
      filteredMedications = medications
          .where((medication) =>
              medication.name.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
      if (keyword.isEmpty) {
        filteredMedications = List.from(medications);
      }
    });
  }

  void _deleteMedication(Medication medication) {
    setState(() {
      medications.remove(medication);
      filteredMedications = List.from(medications);
    });
  }

  @override
  void initState() {
    super.initState();
    filteredMedications = List.from(medications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.teal,
        title: const Text('Medication Plan'),
      ),
      drawer: AppMenu(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterMedications,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addMedication,
            child: const Text('Add New Medication'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredMedications.length,
              itemBuilder: (context, index) {
                final medication = filteredMedications[index];
                return Card(
                  color: Colors.blue.withOpacity(0.2), // Transparent blue color
                  child: ListTile(
                    title: Text(
                      medication.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteMedication(medication),
                    ),
                  ),
                );
              },
            ),
          ),
          Fragments(),
        ],
      ),
    );
  }
}

class Medication {
  final String name;
  final String dosage;
  final String notes;
  final String schedule;
  final String startingDate;
  final String inventory;

  Medication({
    required this.name,
    required this.dosage,
    required this.notes,
    required this.schedule,
    required this.startingDate,
    required this.inventory,
  });
}
