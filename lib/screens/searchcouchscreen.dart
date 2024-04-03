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
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: fire.collection('couches').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!.docs;
                    return ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> couch = data[index].data();
                        return InkWell(
                          onTap: () {

                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  CouchScreen(couchID: data[index].id),
                            ));
                          },
                          child: Card(
                            margin: EdgeInsets.all(10),
                            elevation: 10,
                            child: Text(couch['hostname']),
                          ),
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
    );
  }
}
