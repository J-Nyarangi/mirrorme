import 'package:flutter/material.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:myapp/screens/homepage.dart';
import 'package:myapp/screens/reset_password.dart';
import 'package:myapp/screens/signin.dart';
import 'package:myapp/screens/signup.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Initialize Firebase
  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Firebase initialization is in progress
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Error occurred during Firebase initialization
          return Text('Something went wrong');
        } else {
          // Firebase initialized successfully
          return MaterialApp(
            title: 'Flutter Firebase Authentication Tutorial',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const Signin(),
              '/signup': (context) => const Signup(),
              '/reset_password': (context) => const ResetPassword(),
              '/home': (context) => const HomePage(),
            },
          );
        }
      },
    );
  }
}
