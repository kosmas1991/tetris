import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/screens/gamescreen.dart';
import 'package:tetris/screens/signupscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return SafeArea(
      child: MaterialApp(
        title: 'Tetris Game',
        home: const GameScreen(),
      ),
    );
  }
}
