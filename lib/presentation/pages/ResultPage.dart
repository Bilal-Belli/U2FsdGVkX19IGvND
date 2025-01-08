import 'package:flutter/material.dart'; // Importing Flutter material design package.
import '../../main.dart'; // Importing main.dart from the project.

class ResultPage extends StatelessWidget {
  final int score; // Final variable to store the score.
  final int totalQuestions; // Final variable to store the total number of questions.

  const ResultPage({super.key, required this.score, required this.totalQuestions}); // Constructor for ResultPage with required parameters.

  // Method to get a comment based on the score percentage.
  String _getComment() {
    double percentage = (score / totalQuestions) * 100;
    if (percentage == 100) {
      return "Excellent!"; // Comment for a perfect score.
    } else if (percentage >= 70) {
      return "Well done"; // Comment for a good score.
    } else {
      return "Can do better"; // Comment for a lower score.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Results", style: TextStyle(color: Colors.white)), // App bar title.
        centerTitle: true, // Center the title.
        backgroundColor: Colors.pinkAccent, // Background color for the app bar.
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the column contents.
          children: [
            Text(
              "Score: $score / $totalQuestions", // Display the score.
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Text style for the score.
            ),
            const SizedBox(height: 20), // Space between elements.
            Text(
              _getComment(), // Display the comment based on the score.
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Text style for the comment.
            ),
            const SizedBox(height: 20), // Space between elements.
            ElevatedButton.icon(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()), // Navigate to HomePage.
                    (route) => false,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent, // Button background color.
                minimumSize: const Size(140, 40), // Minimum size for the button.
              ),
              icon: const Icon(Icons.arrow_back, color: Colors.white), // Icon for the button.
              label: const Text(
                "Home", // Button label.
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}