import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:intl/intl.dart';
import 'package:social_app/views/search_delegate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';
    final dateTime = timestamp.toDate();
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }

  buildAwesomeDialog(String title, String desc) {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: title,
      desc: desc,
      btnOkIcon: Icons.info_outline,
      btnOkColor: Colors.blueGrey,
      btnCancelOnPress: () {},
      btnCancelText: 'Close',
      btnCancelColor: Colors.red,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: PostSearchDelegate());
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                user?.displayName ?? 'Guest',
                style: const TextStyle(fontSize: 18),
              ),
              accountEmail: Text(user?.email ?? 'No Email'),
              decoration: const BoxDecoration(color: Colors.blueGrey),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            const SizedBox(height: 6),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Tasks'),
              onTap: () => Navigator.pushReplacementNamed(context, '/task'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () {
          Navigator.pushNamed(context, '/add_post');
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('posts')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No posts yet"));
          }

          final posts = snapshot.data!.docs;
          final currentUser = FirebaseAuth.instance.currentUser;
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final data = post.data() as Map<String, dynamic>;
              final Timestamp? createdAt = data['timestamp'];
              final List likes = data['likes'] ?? [];
              final bool isLiked = likes.contains(currentUser?.uid);
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(child: Icon(Icons.person)),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['userName'] ?? 'Unknown User',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                data['userEmail'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (data['base64Image'] != null &&
                          data['base64Image'].toString().isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(data['base64Image']),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        data['postText'] ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Posted on: ${_formatTimestamp(createdAt)}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : Colors.grey,
                            ),
                            onPressed: () async {
                              final postRef = FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(post.id);
                              if (isLiked) {
                                await postRef.update({
                                  'likes': FieldValue.arrayRemove([
                                    currentUser?.uid,
                                  ]),
                                });
                              } else {
                                await postRef.update({
                                  'likes': FieldValue.arrayUnion([
                                    currentUser?.uid,
                                  ]),
                                });
                              }
                            },
                          ),
                          Text("${likes.length} likes"),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.comment, color: Colors.grey),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/comments',
                                arguments: {'postId': post.id},
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          Text("${data['commentsCount'] ?? 0} comments"),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
