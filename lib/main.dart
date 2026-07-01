import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const FaceWorkApp());
}

class FaceWorkApp extends StatelessWidget {
  const FaceWorkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FaceWork',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const HomePage(),
    );
  }
}
