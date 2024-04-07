import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tetris/screens/lobbyscreen.dart';

class WinOrLoseScreen extends StatefulWidget {
  final bool isWin;
  const WinOrLoseScreen({super.key, required this.isWin});

  @override
  State<WinOrLoseScreen> createState() => _WinOrLoseScreenState();
}

class _WinOrLoseScreenState extends State<WinOrLoseScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  void initState() {
    Timer(Duration(seconds: 5), () {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => LobbyScreen(user: auth.currentUser!),
      ));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Image.asset(
            'assets/images/tetris.jpg',
            fit: BoxFit.fitHeight,
            height: double.infinity,
            width: double.infinity,
          ),
          Container(
            child: widget.isWin
                ? Image.asset('assets/images/winner.png')
                : Image.asset('assets/images/loser.png'),
          ),
        ]),
      ),
    );
  }
}
