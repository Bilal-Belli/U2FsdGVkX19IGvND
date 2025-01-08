import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'ResultPage.dart';
import 'package:http/http.dart' as http;

class QuizPage extends StatefulWidget {
  final Map<String, dynamic> theme;

  const QuizPage({super.key, required this.theme});

  @override
  QuizPageState createState() => QuizPageState();
}

class QuizPageState extends State<QuizPage> {
  late List<dynamic> questions;
  int currentQuestionIndex = 0;
  List<String?> answers = [];
  String? imageUrl;
  AudioPlayer audioPlayer = AudioPlayer();
  String? winSoundUrl;
  String? loseSoundUrl;

  @override
  void initState() {
    super.initState();
    questions = _getRandomQuestions(widget.theme['questions']);
    answers = List.filled(min(10, questions.length), null);
    _loadImage();
    _loadSounds();
  }

  Future<void> _loadImage() async {
    try {
      final String cloudinaryBaseUrl = "https://res.cloudinary.com/dxqcqtzo2/image/upload";
      String themeImageUrl = "$cloudinaryBaseUrl/v1736286567/${widget.theme['theme']}.png";
      String defaultImageUrl = "$cloudinaryBaseUrl/v1736286567/quiz.png";

      // Attempt to load the theme-specific image
      final themeImageResponse = await http.head(Uri.parse(themeImageUrl));

      // Check if the theme image exists
      if (themeImageResponse.statusCode == 200) {
        setState(() {
          imageUrl = themeImageUrl;
        });
      } else {
        // Fallback to default image
        setState(() {
          imageUrl = defaultImageUrl;
        });
      }
    } catch (e) {
      // Fallback to default image in case of error
      setState(() {
        imageUrl = "https://res.cloudinary.com/dxqcqtzo2/image/upload/v1736286567/quiz.png";
      });
    }
  }

  Future<void> _loadSounds() async {
    try {
      final String cloudinaryBaseUrl = "https://res.cloudinary.com/dxqcqtzo2/video/upload";
      String winSoundPath = "$cloudinaryBaseUrl/v1736286421/trueAnswer.wav";
      String loseSoundPath = "$cloudinaryBaseUrl/v1736286421/falseAnswer.wav";

      // Check if the sound files exist
      final winResponse = await http.head(Uri.parse(winSoundPath));
      final loseResponse = await http.head(Uri.parse(loseSoundPath));

      setState(() {
        winSoundUrl = winResponse.statusCode == 200 ? winSoundPath : null;
        loseSoundUrl = loseResponse.statusCode == 200 ? loseSoundPath : null;
      });
    } catch (e) {
      // Handle errors gracefully
      setState(() {
        winSoundUrl = null;
        loseSoundUrl = null;
      });
    }
  }


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
            builder: (context) => ResultPage(score: score, totalQuestions: questions.length),
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

  Future<void> _playSound(bool isCorrect) async {
    if (isCorrect && winSoundUrl != null) {
      await audioPlayer.play(UrlSource(winSoundUrl!));
    } else if (!isCorrect && loseSoundUrl != null) {
      await audioPlayer.play(UrlSource(loseSoundUrl!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];
    final userAnswer = answers[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.theme['theme']}",style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              if (imageUrl != null)
                Image.network(
                  imageUrl!,
                  height: 150,
                  fit: BoxFit.cover,
                )
              else
                CircularProgressIndicator(),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  currentQuestion['questionText'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: userAnswer == null
                            ? null
                            : (userAnswer == "True" && currentQuestion['isCorrect'] == true)
                                ? Colors.green
                                : (userAnswer == "True" && currentQuestion['isCorrect'] == false)
                                    ? Colors.red
                                    : null,
                        minimumSize: const Size(130, 50),
                        side: userAnswer == null ? const BorderSide(color: Colors.pinkAccent) : BorderSide.none,
                      ),
                      onPressed: userAnswer == null ? () => _submitAnswer(true) : () {},
                      child: Text("True",
                        style: TextStyle(
                          color: userAnswer == null ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: userAnswer == null
                            ? null
                            : (userAnswer == "False" && currentQuestion['isCorrect'] == false)
                                ? Colors.green
                                : (userAnswer == "False" && currentQuestion['isCorrect'] == true)
                                    ? Colors.red
                                    : null,
                        minimumSize: const Size(130, 50),

                        side: userAnswer == null ? const BorderSide(color: Colors.pinkAccent) : BorderSide.none,
                      ),
                      onPressed: userAnswer == null ? () => _submitAnswer(false) : () {},
                      child: Text("False",
                        style: TextStyle(
                          color: userAnswer == null ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: currentQuestionIndex > 0
                        ? () {
                            setState(() {
                              currentQuestionIndex--;
                            });
                          }
                        : null,
                    label: Text("Previous", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      minimumSize: const Size(140, 40),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: currentQuestionIndex < 9
                        ? () {
                            setState(() {
                              currentQuestionIndex++;
                            });
                          }
                        : null,
                    label: Text("Next", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      minimumSize: const Size(140, 40),
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