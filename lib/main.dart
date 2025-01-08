import 'package:flutter/material.dart'; // Importing Flutter material design package.
import 'package:firebase_core/firebase_core.dart'; // Importing Firebase core package.
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase authentication package.
import 'package:tp3/presentation/pages/ProfilePage.dart'; // Importing ProfilePage from the project.
import 'presentation/pages/AddQuestionPage.dart'; // Importing AddQuestionPage from the project.
import 'presentation/pages/AddThemePage.dart'; // Importing AddThemePage from the project.
import 'presentation/pages/SignInPage.dart'; // Importing SignInPage from the project.
import 'presentation/pages/SignUpPage.dart'; // Importing SignUpPage from the project.
import 'presentation/screen/QuizApp.dart'; // Importing QuizApp from the project.
import 'firebase_options.dart'; // Importing Firebase options.

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensuring the binding is initialized.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Initializing Firebase with platform-specific options.
  );
  runApp(const MyApp()); // Running the MyApp widget.
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Constructor for MyApp with a super key.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Combined App', // Title of the application.
      theme: ThemeData(
        brightness: Brightness.light, // Light theme for the app.
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black), // Text color for light theme.
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark, // Dark theme for the app.
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white), // Text color for dark theme.
        ),
      ),
      themeMode: ThemeMode.system, // System default theme (light/dark).
      home: FirebaseAuth.instance.currentUser == null
          ? const WelcomePage() // If no user is signed in, show WelcomePage.
          : const HomePage(), // If user is signed in, show HomePage.
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key}); // Constructor for WelcomePage with a super key.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(color: Colors.white)), // App bar title.
        centerTitle: true, // Center the title.
        backgroundColor: Colors.pinkAccent, // Background color for the app bar.
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centering the column contents.
          children: [
            const SizedBox(height: 40), // Adding some vertical space.
            SizedBox(
              width: 300,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()), // Navigate to HomePage.
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent, // Button background color.
                ),
                child: const Text('Anonym Account', style: TextStyle(fontSize: 18, color: Colors.white)), // Button label.
              ),
            ),
            const SizedBox(height: 20), // Adding some vertical space.
            SizedBox(
              width: 300,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()), // Navigate to SignInPage.
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent, // Button background color.
                ),
                child: const Text('Sign In', style: TextStyle(fontSize: 18, color: Colors.white)), // Button label.
              ),
            ),
            const SizedBox(height: 20), // Adding some vertical space.
            SizedBox(
              width: 300,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()), // Navigate to SignUpPage.
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent, // Button background color.
                ),
                child: const Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white)), // Button label.
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key}); // Constructor for HomePage with a super key.

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // Get the current user.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page', style: TextStyle(color: Colors.white)), // App bar title.
        centerTitle: true, // Center the title.
        backgroundColor: Colors.pinkAccent, // Background color for the app bar.
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centering the column contents.
          children: [
            if (user == null) ...[
              {'title': 'Sign Up', 'page': const SignUpPage()},
              {'title': 'Sign In', 'page': const SignInPage()},
            ].map((item) {
              return Column(
                children: [
                  SizedBox(
                    width: 300,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => item['page'] as Widget), // Navigate to the respective page.
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent, // Button background color.
                      ),
                      label: Align(
                        alignment: Alignment.center,
                        child: Text(
                          item['title'] as String,
                          style: const TextStyle(fontSize: 18, color: Colors.white), // Button label.
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40), // Adding some vertical space.
                ],
              );
            }),
            ...[
              {'title': 'Take a Quiz', 'page': const QuizApp()},
              if (user != null) {'title': 'Add Theme', 'page': const AddThemePage()},
              if (user != null) {'title': 'Add Question', 'page': const AddQuestionPage()},
              if (user != null) {'title': 'My Profile', 'page': const ProfilePage()},
              if (user != null) {'title': 'Sign Out', 'page': null}, // Sign-Out Button.
            ].map((item) {
              return Column(
                children: [
                  SizedBox(
                    width: 300,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (item['page'] == null) {
                          FirebaseAuth.instance.signOut().then((_) { // Sign out the user.
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const WelcomePage()), // Navigate to WelcomePage.
                            );
                          });
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => item['page'] as Widget), // Navigate to the respective page.
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent, // Button background color.
                      ),
                      label: Align(
                        alignment: Alignment.center,
                        child: Text(
                          item['title'] as String,
                          style: const TextStyle(fontSize: 18, color: Colors.white), // Button label.
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40), // Adding some vertical space.
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}