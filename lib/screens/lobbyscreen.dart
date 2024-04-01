import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LobbyScreen extends StatelessWidget {
  final UserCredential cred;
  const LobbyScreen({super.key, required this.cred});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text('hello ${cred.user!.email}'),
        ),
      ),
    );
  }
}
