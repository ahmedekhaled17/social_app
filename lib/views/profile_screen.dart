import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/feature/posts/profile_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final ProfileServices _services = ProfileServices();

  final TextEditingController _bioController = TextEditingController();

  bool _isEditingBio = false;
  bool _isUploadingImage = false;
  bool _isSavingBio = false;
  File? _newProfileImage;
  String? _profileImageBase64;

  Future<void> _loadUserData() async {
    final data = await _services.loadUserData();
    if (data.isNotEmpty) {
      _bioController.text = data['bio'] ?? '';
      _profileImageBase64 = data['profileImageBase64'];
      setState(() {});
    }
  }

  Future<void> _saveBio() async {
    setState(() => _isSavingBio = true);
    await _services.saveBio(_bioController.text);
    setState(() {
      _isSavingBio = false;
      _isEditingBio = false;
    });
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await _services.pickProfileImage();
    if (pickedFile != null) {
      setState(() {
        _newProfileImage = pickedFile;
        _isUploadingImage = true;
      });
      try {
        final base64Str = await _services.uploadProfileImageBase64(pickedFile);
        setState(() {
          _profileImageBase64 = base64Str;
          _isUploadingImage = false;
          _newProfileImage = null;
        });
      } catch (e) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? photoProvider;

    if (_newProfileImage != null) {
      photoProvider = Image.file(_newProfileImage!).image;
    } else if (_profileImageBase64 != null && _profileImageBase64!.isNotEmpty) {
      try {
        photoProvider = MemoryImage(base64Decode(_profileImageBase64!));
      } catch (_) {
        photoProvider = null;
      }
    } else if (user.photoURL != null) {
      photoProvider = NetworkImage(user.photoURL!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _services.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      photoProvider ??
                      const AssetImage('assets/default_avatar.png'),
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: InkWell(
                    onTap: _isUploadingImage ? null : _pickProfileImage,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blueGrey,
                      child:
                          _isUploadingImage
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              user.displayName ?? 'No Display Name',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(user.email ?? '', style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 16),

            Row(
              children: [
                const Text(
                  'Bio:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (!_isEditingBio)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        _isEditingBio = true;
                      });
                    },
                  ),
              ],
            ),
            _isEditingBio
                ? Column(
                  children: [
                    TextField(
                      controller: _bioController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Write something about yourself',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isSavingBio
                        ? const CircularProgressIndicator()
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isEditingBio = false;
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: _saveBio,
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                  ],
                )
                : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _bioController.text.isEmpty
                        ? 'No bio yet'
                        : _bioController.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Posts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),

            StreamBuilder<QuerySnapshot>(
              stream: _services.getUserPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No posts found');
                }
                final posts = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final postData =
                        posts[index].data()! as Map<String, dynamic>;
                    final postId = posts[index].id;
                    final postImageBase64 = postData['base64Image'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (postImageBase64.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  base64Decode(postImageBase64),
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              postData['postText'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            StreamBuilder<QuerySnapshot>(
                              stream: _services.getPostComments(postId),
                              builder: (context, commentSnapshot) {
                                if (commentSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (!commentSnapshot.hasData ||
                                    commentSnapshot.data!.docs.isEmpty) {
                                  return const Text('No comments');
                                }
                                final comments = commentSnapshot.data!.docs;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      comments.map((commentDoc) {
                                        final comment =
                                            commentDoc.data()!
                                                as Map<String, dynamic>;
                                        return ListTile(
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          leading: const Icon(
                                            Icons.comment,
                                            size: 18,
                                            color: Colors.grey,
                                          ),
                                          title: Text(
                                            comment['text'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          subtitle: Text(
                                            comment['userName'] ?? 'Anonymous',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
