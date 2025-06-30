import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginServices {
  static void showDialogMessage({
    required BuildContext context,
    required String title,
    required String desc,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: title,
      desc: desc,
      btnOkIcon: Icons.info_outline,
      btnOkColor: Colors.blueGrey,
      btnCancelText: 'Close',
      btnCancelColor: Colors.red,
      btnCancelOnPress: () {},
    ).show();
  }

  static Future<void> handleUserDoc(User user) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? '',
        'bio': '',
        'profileImageBase64': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
    required GlobalKey<FormState> formKey,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      showDialogMessage(
        context: context,
        title: 'Missing Fields',
        desc: 'Please fill in all fields.',
      );
      return;
    }

    if (formKey.currentState!.validate()) {
      try {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        final user = userCredential.user;
        if (user != null) {
          await handleUserDoc(user);
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        final errorMessages = {
          'user-not-found': 'No user found for that email.',
          'wrong-password': 'Wrong password provided.',
          'invalid-email': 'Invalid email format.',
        };
        showDialogMessage(
          context: context,
          title: 'Error',
          desc: errorMessages[e.code] ?? e.message ?? 'Something went wrong.',
        );
      } catch (_) {
        showDialogMessage(
          context: context,
          title: 'Error',
          desc: 'An unexpected error occurred.',
        );
      }
    }
  }

  static Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        await handleUserDoc(user);
      }

      showDialogMessage(
        context: context,
        title: "Success",
        desc: "Logged in with Google successfully.",
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      showDialogMessage(
        context: context,
        title: "Google Signin Error",
        desc: e.toString(),
      );
    }
  }

  static Future<void> resetPassword({
    required BuildContext context,
    required String email,
  }) async {
    if (email.isEmpty) {
      showDialogMessage(
        context: context,
        title: 'Error',
        desc: 'Please enter email to reset password',
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showDialogMessage(
        context: context,
        title: 'Success',
        desc: 'Password reset email sent successfully.',
      );
    } catch (error) {
      showDialogMessage(
        context: context,
        title: 'Error',
        desc: error.toString(),
      );
    }
  }
}
