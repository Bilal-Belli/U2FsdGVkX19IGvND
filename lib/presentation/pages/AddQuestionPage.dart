import 'package:flutter/material.dart'; // Importing Flutter material design package.
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Cloud Firestore package for database operations.

class AddQuestionPage extends StatefulWidget {
  const AddQuestionPage({super.key}); // Constructor for AddQuestionPage with a super key.

  @override
  AddQuestionPageState createState() => AddQuestionPageState(); // Creating state for AddQuestionPage.
}

class AddQuestionPageState extends State<AddQuestionPage> {
  final TextEditingController _questionController = TextEditingController(); // Controller for question input.
  bool _isCorrect = false; // Variable to track if the answer is correct.
  String? _selectedTheme; // Variable to track the selected theme.
  List<String> _themes = []; // List to store available themes.

  @override
  void initState() {
    super.initState();
    _loadThemes(); // Load themes when the state is initialized.
  }

  // Method to load themes from Firestore.
  Future<void> _loadThemes() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('themes').get(); // Fetch themes from Firestore.
    setState(() {
      _themes = snapshot.docs.map((doc) => doc['theme'] as String).toList(); // Map Firestore documents to theme names.
    });
  }

  // Method to add a new question to the selected theme.
  Future<void> _addQuestion() async {
    final String questionText = _questionController.text.trim(); // Get the trimmed question text.
    if (questionText.isNotEmpty && _selectedTheme != null) {
      await FirebaseFirestore.instance
          .collection('themes')
          .doc(_selectedTheme)
          .collection('questions')
          .add({'questionText': questionText, 'isCorrect': _isCorrect}); // Add question to Firestore.
      Navigator.pop(context); // Navigate back to the previous screen.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Question', style: TextStyle(color: Colors.white)), // App bar title.
        centerTitle: true, // Center the title.
        backgroundColor: Colors.pinkAccent, // Background color for the app bar.
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the body.
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedTheme, // Value for the dropdown.
              hint: const Text('Select Theme'), // Hint text for the dropdown.
              items: _themes.map((theme) {
                return DropdownMenuItem(
                  value: theme, // Dropdown item value.
                  child: Text(theme), // Dropdown item text.
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value; // Update the selected theme.
                });
              },
            ),
            const SizedBox(height: 20), // Space between elements.
            TextField(
              controller: _questionController, // Controller for question input.
              decoration: const InputDecoration(labelText: 'Question Text'), // Input decoration for question text.
            ),
            const SizedBox(height: 20), // Space between elements.
            Row(
              children: [
                const Text('Is Correct:'), // Text for the switch.
                Switch(
                  value: _isCorrect, // Value for the switch.
                  onChanged: (value) {
                    setState(() {
                      _isCorrect = value; // Update the switch value.
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20), // Space between elements.
            ElevatedButton(
              onPressed: _addQuestion, // Handle button press.
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent, // Button background color.
                minimumSize: const Size(140, 40), // Minimum size for the button.
              ),
              child: const Text('Add Question', style: TextStyle(color: Colors.white)), // Button label.
            ),
          ],
        ),
      ),
    );
  }
}