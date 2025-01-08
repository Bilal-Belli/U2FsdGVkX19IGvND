import 'package:flutter/material.dart'; // Importing Flutter material design package.
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Cloud Firestore package for database operations.

class AddThemePage extends StatefulWidget {
  const AddThemePage({super.key}); // Constructor for AddThemePage with a super key.

  @override
  AddThemePageState createState() => AddThemePageState(); // Creating state for AddThemePage.
}

class AddThemePageState extends State<AddThemePage> {
  final TextEditingController _themeController = TextEditingController(); // Controller for theme input.

  // Method to add a new theme to the Firestore collection.
  Future<void> _addTheme() async {
    final String theme = _themeController.text.trim(); // Get the trimmed theme input.
    if (theme.isNotEmpty) {
      await FirebaseFirestore.instance.collection('themes').doc(theme).set({'theme': theme}); // Add theme to Firestore.
      Navigator.pop(context); // Navigate back to the previous screen.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Theme', style: TextStyle(color: Colors.white)), // App bar title.
        centerTitle: true, // Center the title.
        backgroundColor: Colors.pinkAccent, // Background color for the app bar.
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the body.
        child: Column(
          children: [
            TextField(
              controller: _themeController, // Controller for theme input.
              decoration: const InputDecoration(labelText: 'Theme Name'), // Input decoration for theme name.
            ),
            const SizedBox(height: 20), // Space between elements.
            ElevatedButton(
              onPressed: _addTheme, // Handle button press.
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent, // Button background color.
                minimumSize: const Size(140, 40), // Minimum size for the button.
              ),
              child: const Text('Add Theme', style: TextStyle(color: Colors.white)), // Button label.
            ),
          ],
        ),
      ),
    );
  }
}