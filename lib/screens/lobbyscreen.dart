import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tetris/screens/couchscreen.dart';
import 'package:tetris/screens/gamescreen.dart';
import 'package:tetris/screens/login_screen.dart';
import 'package:tetris/screens/searchcouchscreen.dart';
import 'package:tetris/variables/vars.dart';

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
                  TextButton(
                      onPressed: () {
                        logout();
                      },
                      child: Text('Log out')),
                ],
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => GameScreen(
                        couchID: '',
                        iAmHost: false,
                        isOnline: false,
                      ),
                    ));
                  },
                  child: Text('Play offline')),
              ElevatedButton(
                  onPressed: () {
                    createCouch();
                  },
                  child: Text('Create a couch')),
              ElevatedButton(
                  onPressed: () {
                    searchCouch();
                  },
                  child: Text('Search for a couch')),
            ],
          ),
        ),
      ),
    );
  }

  void fetchUserdetails() async {
    await fire
        .collection('users')
        .doc(widget.user.uid)
        .snapshots()
        .listen((value) {
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

  void createCouch() async {
    List<int> hostTable = tableTo1DList(table);
    List<int> guestTable = tableTo1DList(table);
    await fire.collection('couches').doc(widget.user.uid).set({
      'hostname': widget.user.email,
      'host': widget.user.uid,
      'guest': '',
      'ready': false,
      'endHostWon': false,
      'endGuestWon': false,
    });
    await fire
        .collection('couches')
        .doc(widget.user.uid)
        .collection('smallTables')
        .doc('hostTable')
        .set({
      'hostTable': hostTable,
    });
    await fire
        .collection('couches')
        .doc(widget.user.uid)
        .collection('smallTables')
        .doc('guestTable')
        .set({
      'guestTable': guestTable,
    });

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CouchScreen(couchID: widget.user.uid),
    ));
  }

  //nested lists are not allowed by firestore
  List<int> tableTo1DList(List<List<int>> table) {
    List<int> list = [];
    for (int i = 0; i < 20; i++) {
      for (int y = 0; y < 10; y++) {
        list.add(table[i][y]);
      }
    }

    return list;
  }

  void searchCouch() async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SearchCouchScreen(),
    ));
  }
}
