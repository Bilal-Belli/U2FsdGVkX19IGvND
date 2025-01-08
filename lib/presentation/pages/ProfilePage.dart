import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String? avatarUrl;
  final ImagePicker _picker = ImagePicker();
  final String cloudinaryUrl = "https://api.cloudinary.com/v1_1/dxqcqtzo2/image/upload";
  final String uploadPreset = "tp3Firebase"; // Set up an unsigned upload preset in Cloudinary.

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.photoURL != null) {
      setState(() {
        avatarUrl = user!.photoURL;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      try {
        // Upload image to Cloudinary
        final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
        request.fields['upload_preset'] = uploadPreset;
        request.files.add(await http.MultipartFile.fromPath('file', file.path));

        final response = await request.send();
        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          final jsonData = json.decode(responseData);
          final String newAvatarUrl = jsonData['secure_url'];

          // Update Firebase user's photoURL
          await FirebaseAuth.instance.currentUser?.updatePhotoURL(newAvatarUrl);

          setState(() {
            avatarUrl = newAvatarUrl;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Avatar updated successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload avatar.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred during upload.')),
        );
      }
    }
  }

  Widget _getProfileCard(BuildContext context, String? avatarUrl, String email, Color textColor) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 50),
      decoration: BoxDecoration(
        color: Colors.pinkAccent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          Text(
            email,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickAndUploadImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              minimumSize: const Size(140, 40),
            ),
            child: const Text('Change Profile Picture', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _getAvatar(String? avatarUrl) {
    return CircleAvatar(
      radius: 70,
      backgroundColor: Colors.transparent,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      child: avatarUrl == null
          ? const Icon(Icons.person, size: 50)
          : ClipOval(
        child: Image.network(
          avatarUrl,
          fit: BoxFit.cover,
          width: 140,
          height: 140,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, size: 50, color: Colors.red);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final textColor = Theme.of(context).textTheme.bodyMedium!.color!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
      ),
      body: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _getProfileCard(context, avatarUrl, user?.email ?? 'No email', textColor),
            Positioned(
              top: -50,
              left: 0,
              right: 0,
              child: _getAvatar(avatarUrl),
            ),
          ],
        ),
      ),
    );
  }
}
