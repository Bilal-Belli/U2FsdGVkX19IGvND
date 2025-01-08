import 'package:flutter/material.dart'; // Importing Flutter material design package.
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase authentication package.
import 'package:image_picker/image_picker.dart'; // Importing image picker package.
import 'dart:io'; // Importing Dart IO package for file handling.
import 'package:http/http.dart' as http; // Importing HTTP package for making network requests.
import 'dart:convert'; // Importing Dart convert package for JSON decoding.

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key}); // Constructor for ProfilePage with a super key.

  @override
  ProfilePageState createState() => ProfilePageState(); // Creating state for ProfilePage.
}

class ProfilePageState extends State<ProfilePage> {
  String? avatarUrl; // Variable to store the avatar URL.
  final ImagePicker _picker = ImagePicker(); // Instance of ImagePicker.
  final String cloudinaryUrl = "https://api.cloudinary.com/v1_1/dxqcqtzo2/image/upload"; // Cloudinary upload URL.
  final String uploadPreset = "tp3Firebase"; // Cloudinary upload preset.

  @override
  void initState() {
    super.initState();
    _loadAvatar(); // Load the avatar when the state is initialized.
  }

  // Method to load the user's avatar.
  Future<void> _loadAvatar() async {
    final user = FirebaseAuth.instance.currentUser; // Get the current user.
    if (user?.photoURL != null) {
      setState(() {
        avatarUrl = user!.photoURL; // Set the avatar URL.
      });
    }
  }

  // Method to pick an image and upload it to Cloudinary.
  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // Pick an image from the gallery.
    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      try {
        // Upload image to Cloudinary.
        final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
        request.fields['upload_preset'] = uploadPreset;
        request.files.add(await http.MultipartFile.fromPath('file', file.path));

        final response = await request.send();
        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          final jsonData = json.decode(responseData);
          final String newAvatarUrl = jsonData['secure_url'];

          // Update Firebase user's photoURL.
          await FirebaseAuth.instance.currentUser?.updatePhotoURL(newAvatarUrl);

          setState(() {
            avatarUrl = newAvatarUrl; // Set the new avatar URL.
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

  // Method to create the profile card widget.
  Widget _getProfileCard(BuildContext context, String? avatarUrl, String email, Color textColor) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16), // Padding for the container.
      margin: const EdgeInsets.only(top: 50), // Margin for the container.
      decoration: BoxDecoration(
        color: Colors.pinkAccent, // Background color for the container.
        borderRadius: BorderRadius.circular(16), // Rounded corners for the container.
        boxShadow: const [
          BoxShadow(
            color: Colors.black26, // Shadow color.
            blurRadius: 8, // Blur radius for the shadow.
            offset: Offset(2, 2), // Offset for the shadow.
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Set the main axis size to minimum.
        children: [
          const SizedBox(height: 60), // Space between elements.
          Text(
            email, // Display the user's email.
            style: TextStyle(
              color: Colors.white, // Text color.
              fontSize: 20, // Font size.
              fontWeight: FontWeight.bold, // Font weight.
            ),
          ),
          const SizedBox(height: 20), // Space between elements.
          ElevatedButton(
            onPressed: _pickAndUploadImage, // Handle button press.
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent, // Button background color.
              minimumSize: const Size(140, 40), // Minimum size for the button.
            ),
            child: const Text('Change Profile Picture', style: TextStyle(color: Colors.white)), // Button label.
          ),
        ],
      ),
    );
  }

  // Method to create the avatar widget.
  Widget _getAvatar(String? avatarUrl) {
    return CircleAvatar(
      radius: 70, // Avatar radius.
      backgroundColor: Colors.transparent, // Background color for the avatar.
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null, // Background image for the avatar.
      child: avatarUrl == null
          ? const Icon(Icons.person, size: 50) // Default icon if no avatar image is set.
          : ClipOval(
        child: Image.network(
          avatarUrl, // Avatar image URL.
          fit: BoxFit.cover, // Fit the image to cover the avatar.
          width: 140, // Width of the image.
          height: 140, // Height of the image.
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, size: 50, color: Colors.red); // Error icon if the image fails to load.
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // Get the current user.
    final textColor = Theme.of(context).textTheme.bodyMedium!.color!; // Get the text color from the theme.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)), // App bar title.
        centerTitle: true, // Center the title.
        backgroundColor: Colors.pinkAccent, // Background color for the app bar.
      ),
      body: Center(
        child: Stack(
          clipBehavior: Clip.none, // Allow overflow.
          children: [
            _getProfileCard(context, avatarUrl, user?.email ?? 'No email', textColor), // Display the profile card.
            Positioned(
              top: -50,
              left: 0,
              right: 0,
              child: _getAvatar(avatarUrl), // Display the avatar.
            ),
          ],
        ),
      ),
    );
  }
}