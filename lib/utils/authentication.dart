import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/homepage.dart';
import 'package:myapp/screens/verifyscreen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:myapp/screens/signin.dart';


class Authentication {
static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static void signin(BuildContext context, String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter both email and password.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }).catchError((error) {
      String errorMessage = 'Sign in failed. Please try again.';

      if (error is FirebaseAuthException) {
        errorMessage = getSignInErrorMessage(error.code);
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign In Failed'),
          content: Text(
            errorMessage,
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
    });
  }

  static String getSignInErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'User not found. Please check your email and try again.';
      case 'wrong-password':
        return 'Wrong credentials. Please try again.';
      case 'invalid-email':
        return 'Invalid email address. Please enter a valid email.';
      case 'user-disabled':
        return 'Your account has been disabled. Please contact support.';
      default:
        return 'Sign in failed. Please try again.';
    }
  }
  static void signup(BuildContext context, String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter both email and password.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => VerifyScreen()),
      );
    }).catchError((error) {
      String errorMessage = 'Sign up failed. Please try again.';

      if (error is FirebaseAuthException) {
        errorMessage = _getSignUpErrorMessage(error.code);
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign Up Failed'),
          content: Text(
            errorMessage,
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
    });
  }

  static String _getSignUpErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'The email address is already in use by another account.';
      case 'invalid-email':
        return 'Invalid email address. Please enter a valid email.';
      case 'weak-password':
        return 'The password is too weak. Please enter a stronger password.';
      default:
        return 'Sign up failed. Please try again.';
    }
  }

  static Future<void> signout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sign Out'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false); // User canceled sign out
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true); // User confirmed sign out
          },
          child: const Text('Sign Out'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Signin()),
        (route) => false, // Clear the navigation stack
      );
    } catch (e) {
      print('Error signing out: $e');
      // Handle the sign-out error
    }
  }
}

  static void checkSignedIn(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  static void resetPassword(BuildContext context, String email) {
    final auth = FirebaseAuth.instance;
    auth.sendPasswordResetEmail(email: email).then((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Password Reset'),
          content: const Text('Password reset email has been sent.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }).catchError((error) {
      String errorMessage = 'Password reset failed';

      if (error is FirebaseAuthException) {
        errorMessage = getResetPasswordErrorMessage(error.code);
      } else {
        errorMessage = 'Password reset failed. Please try again.';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Password Reset Failed'),
          content: Text(
            errorMessage,
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
    });
  }

  static String getResetPasswordErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'User not found. Please check your email and try again.';
      case 'invalid-email':
        return 'Invalid email address. Please enter a valid email.';
      default:
        return 'Password reset failed. Please try again.';
    }
  }

  static Future<void> signinWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);

        if (userCredential.additionalUserInfo!.isNewUser) {
          // New user, proceed to account registration
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => VerifyScreen(),
              settings: RouteSettings(
                arguments: userCredential.user,
              ),
            ),
          );
        } else {
          // Existing user, proceed to home page
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign In Failed'),
          content: const Text('Failed to sign in with Google.'),
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

  static Future<bool> checkBiometrics() async {
    final LocalAuthentication localAuth = LocalAuthentication();
    bool isBiometricAvailable = false;

    try {
      isBiometricAvailable = await localAuth.canCheckBiometrics;
    } catch (e) {
      print('Error checking biometrics: $e');
    }

    return isBiometricAvailable;
  }

 static Future<void> signinWithBiometrics(BuildContext context) async {
    final LocalAuthentication localAuth = LocalAuthentication();
    bool isAuthenticated = false;

    try {
      isAuthenticated = await localAuth.authenticate(
        localizedReason: 'Authenticate to sign in',
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign In Failed'),
          content: const Text('Biometric authentication failed.'),
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

    if (isAuthenticated) {
      // Proceed with sign in
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }
}