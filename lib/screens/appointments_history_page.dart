import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'fragments.dart';

class Appointment {
  final String id;
  final String title;
  final String date;
  final String time;
  final String location;

  Appointment({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
  });

  Appointment copyWith({
    String? id,
    String? title,
    String? date,
    String? time,
    String? location,
  }) {
    return Appointment(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'time': time,
      'location': location,
    };
  }
}

class AppointmentsPage extends StatefulWidget {
  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  List<Appointment> appointments = [];

  TextEditingController titleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('appointments').get();

    setState(() {
      appointments = snapshot.docs.map((doc) {
        return Appointment(
          id: doc.id,
          title: (doc.data() as Map<String, dynamic>)['title'],
          date: (doc.data() as Map<String, dynamic>)['date'],
          time: (doc.data() as Map<String, dynamic>)['time'],
          location: (doc.data() as Map<String, dynamic>)['location'],
        );
      }).toList();
    });
  }

  Future<void> addAppointment() async {
    if (titleController.text.isEmpty ||
        dateController.text.isEmpty ||
        timeController.text.isEmpty ||
        locationController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please fill in all fields.'),
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
      return;
    }

    Appointment newAppointment = Appointment(
      id: '',
      title: titleController.text,
      date: dateController.text,
      time: timeController.text,
      location: locationController.text,
    );

    try {
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('appointments').add(
        newAppointment.toMap(),
      );

      newAppointment = newAppointment.copyWith(id: docRef.id);

      setState(() {
        appointments.add(newAppointment);
      });

      Navigator.pop(context);
    } catch (error) {
      print("Failed to add appointment: $error");
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to add appointment.'),
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
  }

  Future<void> updateAppointment(Appointment appointment) async {
    if (titleController.text.isEmpty ||
        dateController.text.isEmpty ||
        timeController.text.isEmpty ||
        locationController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please fill in all fields.'),
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
      return;
    }

    Appointment updatedAppointment = appointment.copyWith(
      title: titleController.text,
      date: dateController.text,
      time: timeController.text,
      location: locationController.text,
    );

    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointment.id)
          .update(updatedAppointment.toMap());

      setState(() {
        appointments[appointments.indexWhere((a) => a.id == appointment.id)] =
            updatedAppointment;
      });

      Navigator.pop(context);
    } catch (error) {
      print("Failed to update appointment: $error");
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to update appointment.'),
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
  }

  Future<void> deleteAppointment(Appointment appointment) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointment.id)
          .delete();

      setState(() {
        appointments.remove(appointment);
      });

      Navigator.pop(context);
    } catch (error) {
      print("Failed to delete appointment: $error");
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to delete appointment.'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Add Appointment',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FloatingActionButton(
                child: Icon(Icons.add),
                backgroundColor: Colors.teal,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Add Appointment'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: titleController,
                              decoration: InputDecoration(labelText: 'Title'),
                            ),
                            TextField(
                              controller: dateController,
                              decoration: InputDecoration(labelText: 'Date'),
                            ),
                            TextField(
                              controller: timeController,
                              decoration: InputDecoration(labelText: 'Time'),
                            ),
                            TextField(
                              controller: locationController,
                              decoration:
                                  InputDecoration(labelText: 'Location'),
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
                            onPressed: () {
                              addAppointment();
                            },
                            child: Text('Add'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                return AppointmentCard(
                  appointment: appointments[index],
                  onUpdate: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        titleController.text = appointments[index].title;
                        dateController.text = appointments[index].date;
                        timeController.text = appointments[index].time;
                        locationController.text = appointments[index].location;

                        return AlertDialog(
                          title: Text('Update Appointment'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: titleController,
                                decoration: InputDecoration(labelText: 'Title'),
                              ),
                              TextField(
                                controller: dateController,
                                decoration: InputDecoration(labelText: 'Date'),
                              ),
                              TextField(
                                controller: timeController,
                                decoration: InputDecoration(labelText: 'Time'),
                              ),
                              TextField(
                                controller: locationController,
                                decoration: InputDecoration(labelText: 'Location'),
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
                              onPressed: () {
                                updateAppointment(appointments[index]);
                              },
                              child: Text('Update'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Delete Appointment'),
                          content: Text('Are you sure you want to delete this appointment?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                deleteAppointment(appointments[index]);
                              },
                              child: Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Fragments(), // Call the Fragments widget here
        ],
      ),
    );
  }
}


class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const AppointmentCard({
    required this.appointment,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Date: ${appointment.date}'),
            SizedBox(height: 4),
            Text('Time: ${appointment.time}'),
            SizedBox(height: 4),
            Text('Location: ${appointment.location}'),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: onUpdate,
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appointments Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: AppointmentsPage(),
    );
  }
}
