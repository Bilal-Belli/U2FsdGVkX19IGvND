import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Cloud Firestore package for database operations.
import 'package:flutter/material.dart'; // Importing Flutter material design package.
import '../pages/QuizPage.dart'; // Importing QuizPage from the project.

class QuizApp extends StatelessWidget {
  const QuizApp({super.key}); // Constructor for QuizApp with a super key.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme', style: TextStyle(color: Colors.white)), // App bar title.
        centerTitle: true, // Center the title.
        backgroundColor: Colors.pinkAccent, // Background color for the app bar.
      ),
      body: const ThemeSelectionPage(), // Body of the scaffold containing ThemeSelectionPage.
    );
  }
}

class ThemeSelectionPage extends StatefulWidget {
  const ThemeSelectionPage({super.key}); // Constructor for ThemeSelectionPage with a super key.

  @override
  ThemeSelectionPageState createState() => ThemeSelectionPageState(); // Creating state for ThemeSelectionPage.
}

class ThemeSelectionPageState extends State<ThemeSelectionPage> {
  List<Map<String, dynamic>> themes = []; // List to hold themes.

  @override
  void initState() {
    super.initState();
    _loadThemes(); // Load themes when the state is initialized.
  }

  // Method to load themes from Firestore.
  Future<void> _loadThemes() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('themes').get(); // Fetching themes from Firestore.
    setState(() {
      themes = snapshot.docs.map((doc) {
        return {
          'theme': doc['theme'],
          'questions': doc.reference.collection('questions').get().then((questionsSnapshot) {
            return questionsSnapshot.docs.map((questionDoc) {
              return {
                'questionText': questionDoc['questionText'], // Question text.
                'isCorrect': questionDoc['isCorrect'], // Whether the answer is correct.
              };
            }).toList();
          }),
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the body.
        child: ListView.builder(
          itemCount: themes.length, // Number of items in the list.
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0), // Margin for the card.
              child: ListTile(
                title: Text(
                  themes[index]['theme'], // Theme title.
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Text style for the title.
                ),
                trailing: const Icon(Icons.arrow_forward_ios), // Trailing icon.
                onTap: () async {
                  final questions = await themes[index]['questions']; // Fetching questions for the theme.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizPage(theme: {'theme': themes[index]['theme'], 'questions': questions}), // Navigate to QuizPage.
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}