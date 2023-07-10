import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'menu.dart';
import 'fragments.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

   @override
  void initState() {
    super.initState();
    fetchMedicineList();
  }

  Future<void> fetchMedicineList() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('medicine').get();
      List<Medicine> fetchedMedicineList = [];

      snapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        fetchedMedicineList.add(Medicine.fromMap(doc.id, data));
      });

      setState(() {
        medicineList = fetchedMedicineList;
      });
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to fetch medicine list.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

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
            onPressed: () async {
              final newMedicine = Medicine(
                id: '', // Empty id for now, will be set after adding to Firestore
                healthIssue: healthIssue,
                dosage: dosage,
                medicationTime: DateTime.now().add(Duration(hours: selectedTime?.hour ?? 0, minutes: selectedTime?.minute ?? 0)),
              );

              try {
                DocumentReference docRef = await FirebaseFirestore.instance.collection('medicine').add(
                  newMedicine.toMap(),
                );

                newMedicine.id = docRef.id;

                setState(() {
                  medicineList.add(newMedicine);
                });

                Navigator.of(context).pop();
              } catch (error) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Failed to add medicine.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}


  void _deleteMedicine(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Medicine'),
          content: const Text('Are you sure you want to delete this medicine?'),
          actions: [
            TextButton(
              onPressed: () async {
                final medicine = medicineList[index];

                try {
                  await FirebaseFirestore.instance.collection('medicine').doc(medicine.id).delete();

                  setState(() {
                    medicineList.removeAt(index);
                  });

                  Navigator.of(context).pop();
                } catch (error) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Failed to delete medicine.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _updateMedicine(int index) {
    final medicine = medicineList[index];

    String updatedHealthIssue = medicine.healthIssue;
    String updatedDosage = medicine.dosage;
    DateTime? updatedMedicationTime = medicine.medicationTime;

    final healthIssueController = TextEditingController(text: updatedHealthIssue);
  final dosageController = TextEditingController(text: updatedDosage);

    showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Update Medicine'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Health Issue'),
                  controller: healthIssueController,
                  onChanged: (value) {
                    setState(() {
                      updatedHealthIssue = value;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Dosage'),
                  controller: dosageController,
                  onChanged: (value) {
                    setState(() {
                      updatedDosage = value;
                    });
                  },
                ),
                ElevatedButton(
  onPressed: () async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(updatedMedicationTime!),
    );
    if (pickedTime != null) {
      setState(() {
        updatedMedicationTime = DateTime(
          updatedMedicationTime!.year,
          updatedMedicationTime!.month,
          updatedMedicationTime!.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  },
  child: const Text('Select Medication Time'),
),
                if (updatedMedicationTime != null)
                  Text('Selected Medication Time: ${formatTimeOfDay(TimeOfDay.fromDateTime(updatedMedicationTime!))}'),
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
                onPressed: () async {
                  final updatedMedicine = Medicine(
                    id: medicine.id,
                    healthIssue: updatedHealthIssue,
                    dosage: updatedDosage,
                    medicationTime: updatedMedicationTime!,
                  );

                  try {
                    await FirebaseFirestore.instance
                        .collection('medicine')
                        .doc(medicine.id)
                        .update(updatedMedicine.toMap());

                    setState(() {
                      medicineList[index] = updatedMedicine;
                    });

                    Navigator.of(context).pop();
                  } catch (error) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Failed to update medicine.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      );
    },
  );
}

  int getWeekOfMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final firstDayOfWeek = (firstDayOfMonth.weekday + 6) % 7; // Convert Sunday (7) to 0
    final offset = (date.day + firstDayOfWeek - 1) ~/ 7;
    return offset + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          'Medicine Schedule',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          GestureDetector(
            onTap: _addMedicine,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(12),
                color: Colors.teal.shade700,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.add,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      drawer: AppMenu(),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2021, 1, 1),
            lastDay: DateTime.utc(2023, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: _calendarFormat,
            availableCalendarFormats: {
              CalendarFormat.week: 'Week',
              CalendarFormat.month: 'Month',
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
            ),
            calendarBuilders: CalendarBuilders(
              // Display the week number in the cell
              defaultBuilder: (context, date, _) {
                final weekNumber = getWeekOfMonth(date);
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${DateFormat.E().format(date)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$weekNumber',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
  child: ListView.builder(
    itemCount: medicineList.length,
    itemBuilder: (context, index) {
      final medicine = medicineList[index];
      return Card(
        child: ListTile(
          title: Text('Health Issue: ${medicine.healthIssue}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dosage: ${medicine.dosage}'),
              Text('Time: ${formatTimeOfDay(TimeOfDay.fromDateTime(medicine.medicationTime))}'),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteMedicine(index);
            },
          ),
          onTap: () {
            _updateMedicine(index);
          },
        ),
      );
    },
  ),
),

          Fragments(), // Add the Fragments widget here
        ],
      ),
    );
  }
}

class Medicine {
  String id;
  final String healthIssue;
  final String dosage;
  final DateTime medicationTime;

  Medicine({
    required this.id,
    required this.healthIssue,
    required this.dosage,
    required this.medicationTime,
  });

  factory Medicine.fromMap(String id, Map<String, dynamic> map) {
    return Medicine(
      id: id,
      healthIssue: map['healthIssue'],
      dosage: map['dosage'],
      medicationTime: map['medicationTime'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'healthIssue': healthIssue,
      'dosage': dosage,
      'medicationTime': medicationTime,
    };
  }
}


String formatTimeOfDay(TimeOfDay? timeOfDay) {
  if (timeOfDay == null) return '';
  final hour = timeOfDay.hourOfPeriod;
  final minute = timeOfDay.minute.toString().padLeft(2, '0');
  final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}
