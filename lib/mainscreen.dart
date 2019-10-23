import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutterfirestore/chat.dart';

class MainScreen extends StatefulWidget {

  final String currentUserId;

  MainScreen({Key key, @required this.currentUserId}) : super(key: key);
  
  @override
  _MainScreenState createState() => _MainScreenState(currentUserId: currentUserId);
}

class _MainScreenState extends State<MainScreen> {

  _MainScreenState({Key key, @required this.currentUserId});

  final String currentUserId;

  String userName;

  
  Future<bool> addDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text('Add Data', style: TextStyle(fontSize: 15.0),),
          content: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(hintText: 'Enter user Name'),
                onChanged: (value){
                  this.userName = value;
                },

              ),
              SizedBox(height: 5.0),
            ],
          ),

          actions: <Widget>[
            FlatButton(
              child: Text('Add'),
              textColor: Colors.blue,
              onPressed: (){
                Navigator.of(context).pop();
                
              },
            )
          ],
        );
      }
    );
  }

  Future getPosts() async {
    //var firestore = Firestore.instance;

    QuerySnapshot result = 
      await Firestore.instance.collection('users').where('nickname', isEqualTo: userName).getDocuments();
      final List<DocumentSnapshot> documents = result.documents;

      return documents;
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text('Main Screen') ,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: (){
              addDialog(context);
            },
          )
        ],
      ),
      
      backgroundColor: Colors.grey,
      body: StreamBuilder(
        stream: Firestore.instance.collection("users").snapshots(),
        builder: (BuildContext  context,AsyncSnapshot snapshot){
          if(snapshot.hasData){
            return new ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.documents.length,
              padding: const EdgeInsets.only(top: 5.0),
              itemBuilder: (context, index){
                DocumentSnapshot ds = snapshot.data.documents[index];

                  if(ds['id'] == currentUserId){
                    return Container();
                  }
                  else {
                    return Container(
                      child: FlatButton(
                        child: Row(
                          children: <Widget>[
                            Material(
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                  ),
                                  width: 50.0,
                                  height: 50.0,
                                  padding: EdgeInsets.all(15.0),
                                ),
                                imageUrl: ds['photoUrl'],
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(25.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            Flexible(
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                        //'Nickname: ${ds['nickname']}',
                                        ds['nickname'],
                                        style: TextStyle(color: Colors.purple),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                                    ),
                                  ],
                                ),

                                margin: EdgeInsets.only(left: 20.0),
                              ),
                            ),
                          ],
                        ),

                        onPressed: (){
                          String userName = ds['nickname'];
                          String specifictoken = ds['specifictoken'];
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => ChatPage(peerId: ds.documentID, userName: userName, specifictoken: specifictoken),
                            )
                          );
                        },

                        color: Colors.white70,
                        padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),

                      margin: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),

                    );

                  }

              }
            );
          }
        },
      ),
      
      //body: Container(
        // child: FutureBuilder(
        //   future: getPosts(),
        //   builder: (_, snapshot){
        //     if(snapshot.connectionState == ConnectionState.waiting){
        //       return Center(
        //         child: Text('Loading.....'),
        //       );
        //     }
        //     else {
              
        //       // return ListView.builder(
        //       //   itemCount: snapshot.data.length,
        //       //   itemBuilder: (_, index){
                  
        //       //     return ListTile(
        //       //       title: Text(snapshot.data[index].data['nickname']),
        //       //     );
        //       //   },
        //       // );

        //     }
        //   },
        // ),
      //),

    );
  }
}

