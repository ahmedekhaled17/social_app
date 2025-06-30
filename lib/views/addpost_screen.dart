import 'dart:io';
import 'package:flutter/material.dart';
import 'package:social_app/feature/posts/post_services.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _postTextController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final image = await PostServices.pickImageFromGallery();
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _handleSubmit() async {
    final text = _postTextController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post content cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await PostServices.submitPost(
      context: context,
      text: text,
      imageFile: _selectedImage,
    );

    setState(() => _isLoading = false);

    if (success) {
      _postTextController.clear();
      setState(() => _selectedImage = null);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Post"),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
            else
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueGrey),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 50, color: Colors.blueGrey),
                        SizedBox(height: 10),
                        Text("Tap to add an image"),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            TextField(
              controller: _postTextController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                  onPressed: _handleSubmit,
                  icon: const Icon(Icons.send),
                  label: const Text("Post"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
