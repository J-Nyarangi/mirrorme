import 'package:flutter/material.dart';
import 'menu.dart';
import 'fragments.dart';

class DoctorsPage extends StatelessWidget {
  const DoctorsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> doctorList = [
      'Doctor 1',
      'Doctor 2',
      'Doctor 3',
      // Add more doctors as needed
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Doctors'),
      ),
      drawer: AppMenu(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: doctorList.length,
              itemBuilder: (context, index) {
                final doctor = doctorList[index];
                return ListTile(
                  title: Text(doctor),
                  // Add more widgets or functionality related to each doctor
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
