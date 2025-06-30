import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ProfileServices {
  final user = FirebaseAuth.instance.currentUser!;

  Future<Map<String, dynamic>> loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return doc.data()!;
    } else {
      return {};
    }
  }

  Future<void> saveBio(String bio) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'bio': bio.trim(),
    }, SetOptions(merge: true));
  }

  Future<File?> pickProfileImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      return File(picked.path);
    }
    return null;
  }

  Future<String?> uploadProfileImageBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64String = base64Encode(bytes);

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'profileImageBase64': base64String,
    }, SetOptions(merge: true));

    return base64String;
  }

  Stream<QuerySnapshot> getUserPosts() {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getPostComments(String postId) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
