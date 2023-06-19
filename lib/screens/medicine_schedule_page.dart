import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    tz.initializeTimeZones();

    return MaterialApp(
      title: 'Medicine App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MedicineSchedulePage(),
    );
  }
}

class MedicineSchedulePage extends StatefulWidget {
  const MedicineSchedulePage({Key? key}) : super(key: key);

  @override
  _MedicineSchedulePageState createState() => _MedicineSchedulePageState();
}

class _MedicineSchedulePageState extends State<MedicineSchedulePage> {
  List<Medicine> medicineList = [];

  void _addMedicine() {
    showDialog(
      context: context,
      builder: (context) {
        String healthIssue = '';
        String dosage = '';
        TimeOfDay? selectedTime;

        return AlertDialog(
          title: const Text('Add Medicine'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Health Issue'),
                onChanged: (value) {
                  healthIssue = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Dosage'),
                onChanged: (value) {
                  dosage = value;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null && pickedTime != selectedTime) {
                    setState(() {
                      selectedTime = pickedTime;
                    });
                  }
                },
                child: const Text('Select Medication Time'),
              ),
              if (selectedTime != null)
                Text('Selected Medication Time: ${formatTimeOfDay(selectedTime)}'),
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
                setState(() {
                  medicineList.add(
                    Medicine(
                      healthIssue: healthIssue,
                      dosage: dosage,
                      medicationTime: DateTime.now().add(Duration(hours: selectedTime?.hour ?? 0, minutes: selectedTime?.minute ?? 0)),
                    ),
                  );
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMedicine(int index) {
    setState(() {
      medicineList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Schedule'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _addMedicine,
            child: const Text('Add Medicine'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: medicineList.length,
              itemBuilder: (context, index) {
                final medicine = medicineList[index];
                return ListTile(
                  title: Text('${medicine.healthIssue} - ${medicine.dosage}'),
                  subtitle: Text('Time: ${formatTimeOfDay(TimeOfDay.fromDateTime(medicine.medicationTime))}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteMedicine(index);
                    },
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

class Medicine {
  final String healthIssue;
  final String dosage;
  final DateTime medicationTime;

  Medicine({
    required this.healthIssue,
    required this.dosage,
    required this.medicationTime,
  });
}

String formatTimeOfDay(TimeOfDay? timeOfDay) {
  if (timeOfDay == null) return '';
  final hour = timeOfDay.hourOfPeriod;
  final minute = timeOfDay.minute.toString().padLeft(2, '0');
  final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}