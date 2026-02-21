import 'package:flutter/material.dart';
import 'features/welcome/welcome_page.dart';
import 'features/criar_videos/criar_videos.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Treinamento',
      theme: ThemeData(useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/criar_videos': (context) => const CriarVideos(),
      },
    );
  }
}
