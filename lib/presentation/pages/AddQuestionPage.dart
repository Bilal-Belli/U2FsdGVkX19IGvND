import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddQuestionPage extends StatefulWidget {
  const AddQuestionPage({super.key});

  @override
  AddQuestionPageState createState() => AddQuestionPageState();
}

class AddQuestionPageState extends State<AddQuestionPage> {
  final TextEditingController _questionController = TextEditingController();
  bool _isCorrect = false;
  String? _selectedTheme;
  List<String> _themes = [];

  @override
  void initState() {
    super.initState();
    _loadThemes();
  }

  Future<void> _loadThemes() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('themes').get();
    setState(() {
      _themes = snapshot.docs.map((doc) => doc['theme'] as String).toList();
    });
  }

  Future<void> _addQuestion() async {
    final String questionText = _questionController.text.trim();
    if (questionText.isNotEmpty && _selectedTheme != null) {
      await FirebaseFirestore.instance
          .collection('themes')
          .doc(_selectedTheme)
          .collection('questions')
          .add({'questionText': questionText, 'isCorrect': _isCorrect});
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Question', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedTheme,
              hint: const Text('Select Theme'),
              items: _themes.map((theme) {
                return DropdownMenuItem(
                  value: theme,
                  child: Text(theme),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(labelText: 'Question Text'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Is Correct:'),
                Switch(
                  value: _isCorrect,
                  onChanged: (value) {
                    setState(() {
                      _isCorrect = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                minimumSize: const Size(140, 40),
              ),
              child: const Text('Add Question' , style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}