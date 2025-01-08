import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../pages/QuizPage.dart';

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
      ),
      body: const ThemeSelectionPage(),
    );
  }
}

class ThemeSelectionPage extends StatefulWidget {
  const ThemeSelectionPage({super.key});
  @override
  ThemeSelectionPageState createState() => ThemeSelectionPageState();
}

class ThemeSelectionPageState extends State<ThemeSelectionPage> {
  List<Map<String, dynamic>> themes = [];
  @override
  void initState() {
    super.initState();
    _loadThemes();
  }
  Future<void> _loadThemes() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('themes').get();
    setState(() {
      themes = snapshot.docs.map((doc) {
        return {
          'theme': doc['theme'],
          'questions': doc.reference.collection('questions').get().then((questionsSnapshot) {
            return questionsSnapshot.docs.map((questionDoc) {
              return {
                'questionText': questionDoc['questionText'],
                'isCorrect': questionDoc['isCorrect'],
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
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: themes.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(
                  themes[index]['theme'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final questions = await themes[index]['questions'];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizPage(theme: {'theme': themes[index]['theme'], 'questions': questions}),
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