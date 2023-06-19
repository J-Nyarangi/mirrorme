import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/screens/signin.dart';
import 'package:myapp/screens/health_issues_page.dart';
import 'package:myapp/screens/medicine_schedule_page.dart';
import 'package:myapp/screens/medication_plan_page.dart';
import 'package:myapp/screens/doctors_page.dart';
import 'package:myapp/screens/documents_page.dart';
import 'package:myapp/screens/appointments_history_page.dart';
import 'package:myapp/screens/memories_page.dart';
import 'package:myapp/screens/chat_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Dismiss the dialog and return false
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Dismiss the dialog and return true
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Signin()),
        );
      } catch (e) {
        print('Error signing out: $e');
        // Display an error message or handle the error as needed
      }
    }
  }

  Future<void> _navigateToPage(BuildContext context, Widget page) async {
    await Future.delayed(Duration(milliseconds: 100)); // Add a slight delay before navigation
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('MirrorMe\'s App'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Health issues'),
                onTap: () {
                  _navigateToPage(context, HealthIssuesPage());
                },
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Medicine Schedule'),
                onTap: () {
                  _navigateToPage(context, MedicineSchedulePage());
                },
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Medication Plan'),
                onTap: () {
                  _navigateToPage(context, MedicationPlanPage());
                },
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Doctors'),
                onTap: () {
                  _navigateToPage(context, DoctorsPage());
                },
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Documents'),
                onTap: () {
                  _navigateToPage(context, DocumentsPage());
                },
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Appointments history'),
                onTap: () {
                  _navigateToPage(context, AppointmentsHistoryPage());
                },
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Memories'),
                onTap: () {
                  _navigateToPage(context, MemoriesPage());
                },
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Chat'),
                onTap: () {
                  _navigateToPage(context, ChatPage());
                },
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Chat'),
                onTap: () {
                  _navigateToPage(context, ChatPage());
                },
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Sign Out'),
                onTap: () {
                  _signOut(context);
                },
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'MirrorMe App',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Here you can find information and tools to help manage Alzheimer\'s disease.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.only(bottom: 0),
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black45),
                ),
                onPressed: () {
                  _signOut(context);
                },
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}