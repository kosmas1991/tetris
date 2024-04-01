import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tetris/screens/gamescreen.dart';
import 'package:tetris/screens/login_screen.dart';

class LobbyScreen extends StatefulWidget {
  final User user;
  const LobbyScreen({super.key, required this.user});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  @override
  void initState() {
    fetchUserdetails();
    super.initState();
  }

  FirebaseFirestore fire = FirebaseFirestore.instance;
  String name = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            children: [
              Row(
                children: [
                  Text('Hello ${name}!'),
                  TextButton(onPressed: () {
                     logout();
                  }, child: Text('Log out')),
                ],
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => GameScreen(),
                    ));
                  },
                  child: Text('Play offline')),
              ElevatedButton(
                  onPressed: () {
                   
                  },
                  child: Text('Create a sofa')),
              ElevatedButton(
                  onPressed: () {}, child: Text('Search for a sofa')),
            ],
          ),
        ),
      ),
    );
  }

  fetchUserdetails() async {
    await fire.collection('users').doc(widget.user.uid).get().then((value) {
      setState(() {
        name = value.data()!['name'];
      });
    });
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => LoginPage(title: 'Login'),
    ));
  }
}