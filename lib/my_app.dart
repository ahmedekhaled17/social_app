import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/views/addpost_screen.dart';
import 'package:social_app/views/comments_page.dart';
import 'package:social_app/views/home_screen.dart';
import 'package:social_app/views/login_screen.dart';
import 'package:social_app/views/profile_screen.dart';
import 'package:social_app/views/register_screen.dart';
import 'package:social_app/views/spalsh_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print("User is currentyl signed out!");
      } else {
        print("User is signed in");
      }
    });
    super.initState();
  }

  Widget checkUserState() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return HomeScreen();
    } else {
      return SplashScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: checkUserState(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/add_post': (context) => AddPostScreen(),
        '/profile': (context) => ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/comments') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => CommentsScreen(postId: args['postId']),
          );
        }
        return null;
      },
    );
  }
}
