import 'package:flutter/material.dart';

class AppointmentsHistoryPage extends StatefulWidget {
  const AppointmentsHistoryPage({Key? key}) : super(key: key);

  @override
  _AppointmentsHistoryPageState createState() =>
      _AppointmentsHistoryPageState();
}

class _AppointmentsHistoryPageState extends State<AppointmentsHistoryPage> {
  List<String> appointments = [];
  List<String> filteredAppointments = [];

  TextEditingController searchController = TextEditingController();

  void _filterAppointments(String keyword) {
    setState(() {
      filteredAppointments = appointments
          .where((appointment) =>
              appointment.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
      if (keyword.isEmpty) {
        filteredAppointments = List.from(appointments);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Mock data for appointments
    appointments = [
      'Appointment 1',
      'Appointment 2',
      'Appointment 3',
    ];
    filteredAppointments = List.from(appointments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments History'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterAppointments,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredAppointments.length,
              itemBuilder: (context, index) {
                final appointment = filteredAppointments[index];
                return Card(
                  child: ListTile(
                    title: Text(appointment),
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
