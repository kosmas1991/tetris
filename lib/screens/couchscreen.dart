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
  @override
  void initState() {
    //check if host
    auth.currentUser!.uid == widget.couchID ? iAmHost = true : iAmHost = false;
    //
    fire.collection('couches').doc(widget.couchID).snapshots().listen((event) {
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
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Text('Couch id: ${widget.couchID}'),
            iAmHost
                ? Text('I am host and i just created this couch')
                : Text('Host: ${widget.couchID}'),
            iAmHost
                ? Text('Guest: ${guest}')
                : ElevatedButton(
                    onPressed: () async {
                      await fire
                          .collection('couches')
                          .doc(widget.couchID)
                          .update({
                        'guest': FirebaseAuth.instance.currentUser!.uid
                      });
                    },
                    child: Text('Sit on couch')),
            guestJoined
                ? ElevatedButton(
                    onPressed: () {
                      startPressed();
                    },
                    child: Text('start'))
                : Container(),
          ],
        ),
      ),
    );
  }

  void startPressed() {
    fire.collection('couches').doc(widget.couchID).update({'ready': true});
  }
}
