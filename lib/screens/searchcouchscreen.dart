import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tetris/screens/couchscreen.dart';

class SearchCouchScreen extends StatefulWidget {
  const SearchCouchScreen({super.key});

  @override
  State<SearchCouchScreen> createState() => _SearchCouchScreenState();
}

class _SearchCouchScreenState extends State<SearchCouchScreen> {
  FirebaseFirestore fire = FirebaseFirestore.instance;
  @override
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
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: fire.collection('couches').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data!.docs;
                      if (data.length == 0) {
                        return Center(
                          child: Text(
                            'No couches available!',
                            style: TextStyle(fontSize: 25),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: EdgeInsets.all(10),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          // Map<String, dynamic> couch = data[index].data();
                          return Column(
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                    side: MaterialStateProperty.all(
                                        BorderSide(width: 5)),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.yellow)),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        CouchScreen(couchID: data[index].id),
                                  ));
                                },
                                child: FutureBuilder(
                                  future: fetchUserData(data[index].id),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Text(
                                        snapshot.data!,
                                        style: TextStyle(fontSize: 30),
                                      );
                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          );
                        },
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }

  Future<String> fetchUserData(String guestID) async {
    String nameAndLastname = 'empty';
    await fire.collection('users').doc(guestID).get().then((value) {
      nameAndLastname = '${value.data()!['name']} ${value.data()!['lastname']}';
    });

    return nameAndLastname;
  }
}
