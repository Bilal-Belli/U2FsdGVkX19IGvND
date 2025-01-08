import 'package:flutter/material.dart'; // Importing Flutter material design package.
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase authentication package.
import 'package:cloudinary_public/cloudinary_public.dart'; // Importing Cloudinary package for image uploads.
import 'package:image_picker/image_picker.dart'; // Importing image picker package.
import 'dart:io'; // Importing Dart IO package for file handling.
import '../../main.dart'; // Importing main.dart from the project.

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key}); // Constructor for SignUpPage with a super key.

  @override
  SignUpPageState createState() => SignUpPageState(); // Creating state for SignUpPage.
}

class SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController(); // Controller for email input.
  final TextEditingController _passwordController = TextEditingController(); // Controller for password input.
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance of FirebaseAuth.
  final ImagePicker _picker = ImagePicker(); // Instance of ImagePicker.
  File? _avatarFile; // File to hold the picked avatar image.
  String? _errorMessage; // Variable to hold error messages.

  // Initialize Cloudinary.
  final cloudinary = CloudinaryPublic('dxqcqtzo2', 'tp3Firebase', cache: false);

  // Method to handle user sign-up.
  Future<void> _signUp() async {
    setState(() {
      _errorMessage = null; // Reset the error message.
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validate inputs.
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email and password cannot be empty.';
      });
      return;
    }

    if (password.length < 4) {
      setState(() {
        _errorMessage = 'Password must contain at least 4 characters.';
      });
      return;
    }

    try {
      // Create user with email and password.
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (_avatarFile != null) {
        // Upload avatar image to Cloudinary.
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(_avatarFile!.path, folder: 'avatars'),
        );

        // Update user's photo URL with the Cloudinary image URL.
        await userCredential.user!.updatePhotoURL(response.secureUrl);
      }

      // Show success message and navigate to HomePage.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuth exceptions.
      setState(() {
        switch (e.code) {
          case 'email-already-in-use':
            _errorMessage = 'This email is already in use.';
            break;
          case 'invalid-email':
            _errorMessage = 'The provided email is not valid.';
            break;
          case 'weak-password':
            _errorMessage = 'The password is too weak.';
            break;
          default:
            _errorMessage = 'Error occurred: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error occurred.';
      });
    }
  }

  // Method to handle image picking.
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path); // Set the picked image file.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up', style: TextStyle(color: Colors.white)), // App bar title.
        centerTitle: true, // Center the title.
        backgroundColor: Colors.pinkAccent, // Background color for the app bar.
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the body.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start of the column.
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10), // Padding for the error message.
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red), // Error message text style.
                ),
              ),
            TextField(
              controller: _emailController, // Controller for email input.
              decoration: const InputDecoration(labelText: 'Email'), // Email input decoration.
              keyboardType: TextInputType.emailAddress, // Keyboard type for email input.
            ),
            const SizedBox(height: 20), // Space between inputs.
            TextField(
              controller: _passwordController, // Controller for password input.
              decoration: const InputDecoration(labelText: 'Password'), // Password input decoration.
              obscureText: true, // Obscure text for password input.
            ),
            const SizedBox(height: 20), // Space between inputs.
            Center(
              child: GestureDetector(
                onTap: _pickImage, // Handle image picking.
                child: CircleAvatar(
                  radius: 50, // Avatar radius.
                  backgroundImage: _avatarFile != null ? FileImage(_avatarFile!) : null, // Background image for the avatar.
                  child: _avatarFile == null ? const Icon(Icons.person, size: 50) : null, // Default icon if no image is picked.
                ),
              ),
            ),
            const SizedBox(height: 20), // Space between inputs.
            Center(
              child: ElevatedButton(
                onPressed: _signUp, // Handle sign-up.
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent, // Button background color.
                  minimumSize: const Size(140, 40), // Minimum size for the button.
                ),
                child: const Text('Sign Up', style: TextStyle(color: Colors.white)), // Button label.
              ),
            ),
          ],
        ),
      ),
    );
  }
}