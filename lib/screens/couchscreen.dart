import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tetris/screens/gamescreen.dart';
import 'package:tetris/screens/register_screen.dart';

class CouchScreen extends StatefulWidget {
  final String couchID;
  const CouchScreen({super.key, required this.couchID});

  @override
  State<CouchScreen> createState() => _CouchScreenState();
}

class _CouchScreenState extends State<CouchScreen> {
  bool iAmHost = false;
  String guest = '(no guest yet)';
  bool guestJoined = false;
  FirebaseFirestore fire = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  StreamSubscription? test;
  bool sitOnCouchButtonPressed = false;
  @override
  void initState() {
    //check if host
    auth.currentUser!.uid == widget.couchID ? iAmHost = true : iAmHost = false;
    //
    test = fire
        .collection('couches')
        .doc(widget.couchID)
        .snapshots()
        .listen((event) {
      if (event['guest'].toString().isNotEmpty && iAmHost) {
        guestJoined = true;
        setState(() {
          guest = event['guest'].toString();
        });

        printError('guest joinned');
      }
      if (event['ready']) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => GameScreen(
            couchID: widget.couchID,
            iAmHost: iAmHost ? true : false,
            isOnline: true,
          ),
        ));
        test!.cancel();
      }
    });
    super.initState();
  }

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              //Text('Couch id: ${widget.couchID}'),
              iAmHost
                  ? guest == '(no guest yet)'
                      ? Text(
                          'Waiting for someone to join',
                          style: TextStyle(fontSize: 20),
                        )
                      : Container()
                  : sitOnCouchButtonPressed
                      ? Text(
                          'Waiting for the host to start the game...',
                          style: TextStyle(fontSize: 20),
                        )
                      : Text(
                          'Press the button to accept',
                          style: TextStyle(fontSize: 20),
                        ),
              iAmHost
                  ? guest == '(no guest yet)'
                      ? Column(
                          children: [
                            CircularProgressIndicator(
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                                style: ButtonStyle(
                                    side: MaterialStateProperty.all(
                                        BorderSide(width: 5)),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.yellow)),
                                onPressed: () async {
                                  await fire
                                      .collection('couches')
                                      .doc(widget.couchID)
                                      .delete();
                                  Navigator.of(context).pop();
                                },
                                child: Text('Delete couch')),
                          ],
                        )
                      : FutureBuilder(
                          future: fetchUserData(guest),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              printError(snapshot.data.toString());
                              String name = snapshot.data!;
                              return Text('Guest:  ${name}',
                                  style: TextStyle(fontSize: 20));
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        )
                  : ElevatedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(BorderSide(width: 5)),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.yellow)),
                      onPressed: () async {
                        setState(() {
                          sitOnCouchButtonPressed = true;
                        });

                        await fire
                            .collection('couches')
                            .doc(widget.couchID)
                            .update({
                          'guest': FirebaseAuth.instance.currentUser!.uid
                        });
                      },
                      child: Text(
                        'Sit on couch',
                        style: TextStyle(fontSize: 30),
                      )),
              guestJoined
                  ? ElevatedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(BorderSide(width: 5)),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.yellow)),
                      onPressed: () {
                        startPressed();
                      },
                      child: Text(
                        'start',
                        style: TextStyle(fontSize: 30),
                      ))
                  : Container(),
            ],
          ),
        ),
      ]),
    );
  }

  void startPressed() {
    fire.collection('couches').doc(widget.couchID).update({'ready': true});
  }

  Future<String> fetchUserData(String guestID) async {
    String nameAndLastname = 'empty';
    await fire.collection('users').doc(guestID).get().then((value) {
      nameAndLastname = '${value.data()!['name']} ${value.data()!['lastname']}';
    });

    return nameAndLastname;
  }
}
