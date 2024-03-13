import 'package:flutter/material.dart';
import 'package:tetris/screens/gamescreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        title: 'Tetris Game',
        home: const GameScreen(),
      ),
    );
  }
}
