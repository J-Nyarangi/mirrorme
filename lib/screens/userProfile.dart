import 'package:flutter/material.dart';
import 'package:myapp/profiles/edit_profile_page.dart';
import 'package:myapp/profiles/change_password_page.dart';
import 'package:myapp/profiles/delete_profile_page.dart';

class UserProfilePage extends StatelessWidget {
  final String displayName;
  final String email;
  final String photoURL;

  UserProfilePage({
    required this.displayName,
    required this.email,
    required this.photoURL,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(photoURL),
              radius: 50,
            ),
            SizedBox(height: 16),
            Text(
              displayName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              email,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Change Password'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
