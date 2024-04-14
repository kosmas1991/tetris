import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tetris/screens/couchscreen.dart';
import 'package:tetris/screens/gamescreen.dart';
import 'package:tetris/screens/login_screen.dart';
import 'package:tetris/screens/searchcouchscreen.dart';

class LobbyScreen extends StatefulWidget {
  final User user;
  const LobbyScreen({super.key, required this.user});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  List<List<int>> table = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  ];
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
      body: Stack(children: [
        Image.asset(
          'assets/images/tetris.jpg',
          fit: BoxFit.fitHeight,
          height: double.infinity,
          width: double.infinity,
        ),
        Container(
          height: double.infinity,
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hello ${name}!',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                  TextButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(BorderSide(width: 5)),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.redAccent)),
                      onPressed: () {
                        logout();
                      },
                      child: Text(
                        'Log out',
                        style: TextStyle(color: Colors.white),
                      )),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: ButtonStyle(
                            side:
                                MaterialStateProperty.all(BorderSide(width: 5)),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.yellow)),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => GameScreen(
                              couchID: '',
                              iAmHost: false,
                              isOnline: false,
                            ),
                          ));
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_off_outlined,
                              size: 30,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Play offline',
                              style: TextStyle(fontSize: 30),
                            ),
                          ],
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                            side:
                                MaterialStateProperty.all(BorderSide(width: 5)),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.yellow)),
                        onPressed: () {
                          createCouch();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              size: 30,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Create a couch',
                                style: TextStyle(fontSize: 30)),
                          ],
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                            side:
                                MaterialStateProperty.all(BorderSide(width: 5)),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.yellow)),
                        onPressed: () {
                          searchCouch();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search,
                              size: 30,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Search for a couch',
                                style: TextStyle(fontSize: 30)),
                          ],
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
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
      'punishHost': 0,
      'punishGuest': 0,
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
