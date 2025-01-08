import 'dart:math'; // Importing Dart math library for random number generation.
import 'package:audioplayers/audioplayers.dart'; // Importing audioplayers package for audio playback.
import 'package:flutter/material.dart'; // Importing Flutter material design package.
import 'ResultPage.dart'; // Importing ResultPage from the project.
import 'package:http/http.dart'
as http; // Importing http package for making HTTP requests.

class QuizPage extends StatefulWidget {
  final Map<String, dynamic> theme; // Final variable to store the theme.

  const QuizPage(
      {super.key,
        required this.theme}); // Constructor for QuizPage with required parameters.

  @override
  QuizPageState createState() =>
      QuizPageState(); // Creating state for QuizPage.
}

class QuizPageState extends State<QuizPage> {
  late List<dynamic> questions; // List to store the quiz questions.
  int currentQuestionIndex = 0; // Variable to track the current question index.
  List<String?> answers = []; // List to store user's answers.
  String? imageUrl; // Variable to store the image URL.
  AudioPlayer audioPlayer =
  AudioPlayer(); // Instance of AudioPlayer for playing sounds.
  String? winSoundUrl; // Variable to store the win sound URL.
  String? loseSoundUrl; // Variable to store the lose sound URL.

  @override
  void initState() {
    super.initState();
    questions = _getRandomQuestions(
        widget.theme['questions']); // Get random questions for the quiz.
    answers = List.filled(min(10, questions.length),
        null); // Initialize answers list with null values.
    _loadImage(); // Load the image for the quiz.
    _loadSounds(); // Load the sounds for the quiz.
  }

  // Method to load the image for the quiz.
  Future<void> _loadImage() async {
    try {
      final String cloudinaryBaseUrl =
          "https://res.cloudinary.com/dxqcqtzo2/image/upload";
      String themeImageUrl =
          "$cloudinaryBaseUrl/v1736286567/${widget.theme['theme']}.png";
      String defaultImageUrl = "$cloudinaryBaseUrl/v1736286567/quiz.png";

      // Attempt to load the theme-specific image.
      final themeImageResponse = await http.head(Uri.parse(themeImageUrl));

      // Check if the theme image exists.
      if (themeImageResponse.statusCode == 200) {
        setState(() {
          imageUrl = themeImageUrl;
        });
      } else {
        // Fallback to default image.
        setState(() {
          imageUrl = defaultImageUrl;
        });
      }
    } catch (e) {
      // Fallback to default image in case of error.
      setState(() {
        imageUrl =
        "https://res.cloudinary.com/dxqcqtzo2/image/upload/v1736286567/quiz.png";
      });
    }
  }

  // Method to load the sounds for the quiz.
  Future<void> _loadSounds() async {
    try {
      final String cloudinaryBaseUrl =
          "https://res.cloudinary.com/dxqcqtzo2/video/upload";
      String winSoundPath = "$cloudinaryBaseUrl/v1736286421/trueAnswer.wav";
      String loseSoundPath = "$cloudinaryBaseUrl/v1736286421/falseAnswer.wav";

      // Check if the sound files exist.
      final winResponse = await http.head(Uri.parse(winSoundPath));
      final loseResponse = await http.head(Uri.parse(loseSoundPath));

      setState(() {
        winSoundUrl = winResponse.statusCode == 200 ? winSoundPath : null;
        loseSoundUrl = loseResponse.statusCode == 200 ? loseSoundPath : null;
      });
    } catch (e) {
      // Handle errors gracefully.
      setState(() {
        winSoundUrl = null;
        loseSoundUrl = null;
      });
    }
  }

  // Method to get random questions for the quiz.
  List<dynamic> _getRandomQuestions(List<dynamic> allQuestions) {
    final random = Random();
    final List<dynamic> selectedQuestions = [];
    while (selectedQuestions.length < min(10, allQuestions.length)) {
      final question = allQuestions[random.nextInt(allQuestions.length)];
      if (!selectedQuestions.contains(question)) {
        selectedQuestions.add(question);
      }
    }
    return selectedQuestions;
  }

  // Method to submit user's answer.
  void _submitAnswer(bool userChoice) {
    setState(() {
      answers[currentQuestionIndex] = userChoice ? "True" : "False";
    });

    if (answers.every((a) => a != null)) {
      Future.delayed(const Duration(seconds: 4), () {
        int score = 0;
        for (int i = 0; i < answers.length; i++) {
          if ((answers[i] == "True" && questions[i]['isCorrect'] == true) ||
              (answers[i] == "False" && questions[i]['isCorrect'] == false)) {
            score++;
          }
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ResultPage(score: score, totalQuestions: questions.length),
          ),
        );
      });
    } else {
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          if (currentQuestionIndex < questions.length - 1) {
            currentQuestionIndex++;
          }
        });
      });
    }

    _playSound(userChoice == questions[currentQuestionIndex]['isCorrect']);
  }

  // Method to play sound based on the user's answer.
  Future<void> _playSound(bool isCorrect) async {
    if (isCorrect && winSoundUrl != null) {
      await audioPlayer.play(UrlSource(winSoundUrl!));
    } else if (!isCorrect && loseSoundUrl != null) {
      await audioPlayer.play(UrlSource(loseSoundUrl!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion =
    questions[currentQuestionIndex]; // Get the current question.
    final userAnswer = answers[
    currentQuestionIndex]; // Get the user's answer for the current question.

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.theme['theme']}",
            style: TextStyle(color: Colors.white)), // App bar title.
        centerTitle: true, // Center the title.
        backgroundColor: Colors.pinkAccent, // Background color for the app bar.
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding around the body.
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center, // Center the column contents.
            crossAxisAlignment:
            CrossAxisAlignment.stretch, // Stretch the column contents.
            children: [
              const Spacer(), // Spacer to push the content down.
              if (imageUrl != null)
                Image.network(
                  imageUrl!,
                  height: 150,
                  fit: BoxFit.cover,
                )
              else
                CircularProgressIndicator(), // Show a loading indicator if the image is not loaded.
              const SizedBox(height: 20), // Space between elements.
              Center(
                child: Text(
                  currentQuestion[
                  'questionText'], // Display the current question text.
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold), // Text style for the question.
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20), // Space between elements.
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceEvenly, // Evenly space the buttons.
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: userAnswer == null
                            ? null
                            : (userAnswer == "True" &&
                            currentQuestion['isCorrect'] == true)
                            ? Colors.green
                            : (userAnswer == "True" &&
                            currentQuestion['isCorrect'] == false)
                            ? Colors.red
                            : null,
                        minimumSize:
                        const Size(130, 50), // Minimum size for the button.
                        side: userAnswer == null
                            ? const BorderSide(color: Colors.pinkAccent)
                            : BorderSide.none,
                      ),
                      onPressed: userAnswer == null
                          ? () => _submitAnswer(true)
                          : () {}, // Handle button press.
                      child: Text(
                        "True",
                        style: TextStyle(
                          color:
                          userAnswer == null ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: userAnswer == null
                            ? null
                            : (userAnswer == "False" &&
                            currentQuestion['isCorrect'] == false)
                            ? Colors.green
                            : (userAnswer == "False" &&
                            currentQuestion['isCorrect'] == true)
                            ? Colors.red
                            : null,
                        minimumSize:
                        const Size(130, 50), // Minimum size for the button.

                        side: userAnswer == null
                            ? const BorderSide(color: Colors.pinkAccent)
                            : BorderSide.none,
                      ),
                      onPressed: userAnswer == null
                          ? () => _submitAnswer(false)
                          : () {}, // Handle button press.
                      child: Text(
                        "False",
                        style: TextStyle(
                          color:
                          userAnswer == null ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(), // Spacer to push the content up.
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly, // Evenly space the buttons.
                children: [
                  ElevatedButton.icon(
                    onPressed: currentQuestionIndex > 0
                        ? () {
                      setState(() {
                        currentQuestionIndex--;
                      });
                    }
                        : null, // Handle previous button press.
                    label: Text("Previous",
                        style: TextStyle(
                            color: Colors.white)), // Previous button label.
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      Colors.pinkAccent, // Button background color.
                      minimumSize:
                      const Size(140, 40), // Minimum size for the button.
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: currentQuestionIndex < 9
                        ? () {
                      setState(() {
                        currentQuestionIndex++;
                      });
                    }
                        : null, // Handle next button press.
                    label: Text("Next",
                        style: TextStyle(
                            color: Colors.white)), // Next button label.
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      Colors.pinkAccent, // Button background color.
                      minimumSize:
                      const Size(140, 40), // Minimum size for the button.
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}