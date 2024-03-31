import 'package:flutter/material.dart';
import 'package:tetris/widgets/gridpanel.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SafeArea(
        child: Column(children: [
          //grid
          GridPanel(),
        ]),
      ),
    );
  }
}
