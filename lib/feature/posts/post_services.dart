import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostServices {
  static Future<File?> pickImageFromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      return File(picked.path);
    }
    return null;
  }

  static Future<bool> submitPost({
    required BuildContext context,
    required String text,
    File? imageFile,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      String? base64Image;

      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String profileImageBase64 = '';
      if (userDoc.exists) {
        profileImageBase64 = userDoc.data()?['profileImageBase64'] ?? '';
      }

      await FirebaseFirestore.instance.collection('posts').add({
        'uid': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'userEmail': user.email,
        'postText': text,
        'base64Image': base64Image ?? '',
        'userProfileImageBase64': profileImageBase64,
        'likes': [],
        'timestamp': Timestamp.now(),
      });

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      return false;
    }
  }
}
