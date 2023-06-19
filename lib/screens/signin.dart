import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:myapp/utils/authentication.dart';
import 'package:myapp/screens/reset_password.dart';
import 'package:myapp/screens/signup.dart';

late String _email, _password;
String _emailErrorMessage = '';
String _passwordErrorMessage = '';
String _signinErrorMessage = '';

class Signin extends StatefulWidget {
  const Signin({Key? key}) : super(key: key);

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final LocalAuthentication localAuth = LocalAuthentication();

  void _resetErrorMessages() {
    setState(() {
      _emailErrorMessage = '';
      _passwordErrorMessage = '';
      _signinErrorMessage = '';
    });
  }

  void _signin(BuildContext context) {
    _resetErrorMessages();

    if (_email.isEmpty) {
      setState(() {
        _emailErrorMessage = 'Email cannot be empty.';
      });
      return;
    }

    if (_password.isEmpty) {
      setState(() {
        _passwordErrorMessage = 'Password cannot be empty.';
      });
      return;
    }

    try {
      Authentication.signin(context, _email, _password);
    } catch (error) {
      setState(() {
        _signinErrorMessage = 'Invalid email or password.';
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign In Failed'),
          content: Text(
            'Invalid email or password.',
            style: const TextStyle(color: Colors.red),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _authenticate(BuildContext context) async {
    bool isAuthenticated = false;

    try {
      isAuthenticated = await localAuth.authenticate(
        localizedReason: 'Authenticate to sign in',
      );
    } catch (e) {
      setState(() {
        _signinErrorMessage = 'Biometric authentication failed.';
      });
      return;
    }

    if (isAuthenticated) {
      try {
        Authentication.signinWithBiometrics(context);
      } catch (error) {
        setState(() {
          _signinErrorMessage = 'Biometric authentication failed.';
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sign In Failed'),
            content: Text(
              'Biometric authentication failed.',
              style: const TextStyle(color: Colors.red),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const Center(
                child: Text(
                  'Welcome',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Authentication.signinWithGoogle(context);
                },
                child: const Text('Sign in with Google'),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 2),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _email = value.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'example@gmail.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  errorText: _emailErrorMessage.isNotEmpty ? _emailErrorMessage : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _password = value.trim();
                  });
                },
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  errorText: _passwordErrorMessage.isNotEmpty ? _passwordErrorMessage : null,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ResetPassword()),
                  );
                },
                child: const Text(
                  'forgot password?',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  _signin(context);
                },
                child: const Text('Sign In'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _authenticate(context);
                },
                child: const Text('Fingerprint Sign In'),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Signup()),
                  );
                },
                child: const Text(
                  'Sign up here',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _signinErrorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
