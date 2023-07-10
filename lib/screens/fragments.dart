import 'package:flutter/material.dart';
import 'package:myapp/screens/medicine_schedule_page.dart';
import 'package:myapp/screens/documents_page.dart';
import 'package:myapp/screens/memories_page.dart';
import 'package:myapp/screens/HomePage.dart';

class Fragments extends StatelessWidget {
  const Fragments({Key? key}) : super(key: key);

  Future<void> _navigateToPage(BuildContext context, Widget page) async {
    await Future.delayed(Duration(milliseconds: 100)); // Add a slight delay before navigation
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.teal, // Set the background color to teal
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  _navigateToPage(context, HomePage());
                },
                child: Column(
                  children: [
                    Icon(Icons.home),
                    const SizedBox(height: 5),
                    const Text('Home'),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  _navigateToPage(context, MedicineSchedulePage());
                },
                child: Column(
                  children: [
                    Icon(Icons.medical_services),
                    const SizedBox(height: 5),
                    const Text('Medications'),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  _navigateToPage(context, DocumentsPage());
                },
                child: Column(
                  children: [
                    Icon(Icons.folder),
                    const SizedBox(height: 5),
                    const Text('Documents'),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  _navigateToPage(context, MemoriesPage());
                },
                child: Column(
                  children: [
                    Icon(Icons.book),
                    const SizedBox(height: 5),
                    const Text('Memories'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
