import 'dart:io';
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
import 'package:myapp/screens/userProfile.dart';
import 'package:myapp/screens/game.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';


class AppMenu extends StatefulWidget {
  const AppMenu({Key? key}) : super(key: key);

  @override
  _AppMenuState createState() => _AppMenuState();
}

class _AppMenuState extends State<AppMenu> {
  User? _user;
  String? _displayName;
  String? _email;
  String? _photoURL;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _user = currentUser;
        _displayName = currentUser.displayName;
        _email = currentUser.email;
        _photoURL = currentUser.photoURL;
      });
    }
  }

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

  Future<void> _selectProfilePicture() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      // Handle the selected profile picture
      setState(() {
        _photoURL = pickedImage.path;
      });
      // Update the user's profile picture in the database
      await _user?.updateProfile(photoURL: pickedImage.path);
    }
  }

  void _openUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePage(
          displayName: _displayName ?? '',
          email: _email ?? '',
          photoURL: _photoURL ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_displayName ?? ''), // Display user's display name if available
            accountEmail: Text(_email ?? ''), // Display user's email if available
            currentAccountPicture: GestureDetector(
              child: Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: _photoURL != null ? FileImage(File(_photoURL!)) : null,
                  child: _photoURL == null ? Icon(Icons.person) : null,
                ),
              ),
              onTap: _openUserProfile, // Open user profile when avatar is clicked
            ),
            decoration: BoxDecoration(
              color: Colors.teal,
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.error),
              title: const Text('Health issues'),
              onTap: () {
                _navigateToPage(context, HealthIssuesPage());
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.schedule),
              title: const Text('Medicine Schedule'),
              onTap: () {
                _navigateToPage(context, MedicineSchedulePage());
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.local_hospital),
              title: const Text('Medication Plan'),
              onTap: () {
                _navigateToPage(context, MedicationPlanPage());
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.people),
              title: const Text('Doctors'),
              onTap: () {
                _navigateToPage(context, DoctorsPage());
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.description),
              title: const Text('Documents'),
              onTap: () {
                _navigateToPage(context, DocumentsPage());
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.history),
              title: const Text('Appointments'),
              onTap: () {
                _navigateToPage(context, AppointmentsPage());
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.photo_library),
              title: const Text('Memories'),
              onTap: () {
                _navigateToPage(context, MemoriesPage());
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.photo_library),
              title: const Text('Memory Game'),
              onTap: () {
                _navigateToPage(context, MemoryGamePage());
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.chat),
              title: const Text('Chat'),
              onTap: () {
                _navigateToPage(context, ChatPage());
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                _signOut(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
