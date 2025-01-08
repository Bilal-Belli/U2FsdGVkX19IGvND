import 'package:flutter/material.dart'; // Importing Flutter material design package.
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase authentication package.
import '../../main.dart'; // Importing main.dart from the project.
import 'SignUpPage.dart'; // Importing SignUpPage from the project.

class SignInPage extends StatefulWidget {
  const SignInPage({super.key}); // Constructor for SignInPage with a super key.

  @override
  SignInPageState createState() => SignInPageState(); // Creating state for SignInPage.
}

class SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController(); // Controller for email input.
  final TextEditingController _passwordController = TextEditingController(); // Controller for password input.
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance of FirebaseAuth.
  String? _errorMessage; // Variable to hold error messages.

  // Method to handle user sign-in.
  Future<void> _signIn() async {
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

    try {
      // Sign in user with email and password.
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Show success message and navigate to HomePage.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign In successful')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuth exceptions.
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'User not found';
            break;
          case 'wrong-password':
            _errorMessage = 'Password incorrect';
            break;
          case 'invalid-email':
            _errorMessage = 'Invalid Email';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In', style: TextStyle(color: Colors.white)), // App bar title.
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
              child: ElevatedButton(
                onPressed: _signIn, // Handle sign-in.
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent, // Button background color.
                  minimumSize: const Size(140, 40), // Minimum size for the button.
                ),
                child: const Text('Sign In', style: TextStyle(color: Colors.white)), // Button label.
              ),
            ),
            const SizedBox(height: 20), // Space between elements.
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the row contents.
              children: [
                const Text("Not yet registered? "), // Prompt text.
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpPage()), // Navigate to SignUpPage.
                    );
                  },
                  child: const Text('Create an account'), // TextButton label.
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}