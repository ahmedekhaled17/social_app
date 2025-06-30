import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterServices {
  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your email";
    } else if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
        .hasMatch(value.trim())) {
      return "Please enter a valid email";
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your password";
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{6,}$')
        .hasMatch(value)) {
      return "Password must be at least 6 characters,\ninclude upper, lower case letters and numbers.";
    }
    return null;
  }

  static Future<void> registerUser({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required String username,
    required String email,
    required String password,
  }) async {
    if (formKey.currentState!.validate()) {
      try {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: email,
              password: password,
            );

        await credential.user!.updateDisplayName(username);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account created for ${credential.user!.email}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pushReplacementNamed('/login');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          _showMessage(context, 'Password is too weak.');
        } else if (e.code == 'email-already-in-use') {
          _showMessage(context, 'Email is already in use.');
        } else {
          _showMessage(context, e.message ?? 'Unknown error');
        }
      } catch (e) {
        _showMessage(context, e.toString());
      }
    }
  }

  static void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }
}
