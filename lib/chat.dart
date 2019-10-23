import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';



class ChatPage extends StatefulWidget {
  final String peerId;
  final String userName;
  final String specifictoken;

  ChatPage({Key key, @required this.peerId, @required this.userName, @required this.specifictoken}) : super(key: key);

  // ChatPage(this._userName);
  // final String _userName;

  @override
  _ChatPageState createState() => new _ChatPageState(peerId: peerId, userName: userName, specifictoken: specifictoken);
}

class _ChatPageState extends State<ChatPage> {

  _ChatPageState({Key key, @required this.peerId, @required this.userName, @required this.specifictoken});


  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    imageUrl = '';
    readLocal();

     
  }
  final String userName;
  final String peerId;
  final String specifictoken;

  String id;
  SharedPreferences prefs;
  String groupChatId;

  File imageFile;
  String imageUrl;
  String urlOfImage = "";

  String nameOfTheSender;

  //prefs = await SharedPreferences.getInstance();

  


  readLocal()async{

    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    nameOfTheSender = prefs.getString('nickname') ?? '';

    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }

  }

  Future getImage() async {

    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    urlOfImage = await storageTaskSnapshot.ref.getDownloadURL();

    String emptyMessage = "hi";
    _handleSubmit(emptyMessage, 1);
    

  }


  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: new Text("chat page"),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: <Widget>[
            Flexible(
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                        .collection("bmk_messages")
                        .document(groupChatId)
                        .collection(groupChatId)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                builder: (context, snapshot){
                  if(!snapshot.hasData) return Container();
                  return new ListView.builder(
                      padding: new EdgeInsets.all(8.0),
                      reverse: true,
                      itemBuilder: (_, int index){
                        DocumentSnapshot document = snapshot.data.documents[index];

                          if(document['idFrom'] == id){

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                //Icon(Icons.person), 
                                
                                  // Column(
                                  //   crossAxisAlignment: CrossAxisAlignment.center,
                                  //   //mainAxisAlignment: MainAxisAlignment.end,
                                  //   children: <Widget>[
                                  //     SizedBox(height: 10.0,),
                                  //     Padding(padding: EdgeInsets.all(12.0),),
                                  //     Text(document['content']),
                                    
                                  //     //Text(message),
                                  //   ],
                                  // ),
                                  // Icon(Icons.person),

                                document['type'] == 0 
                                
                                ? Container (
                                    // crossAxisAlignment: CrossAxisAlignment.center,
                                    // //mainAxisAlignment: MainAxisAlignment.end,
                                    // children: <Widget>[
                                    //   SizedBox(height: 10.0,),
                                    //   Padding(padding: EdgeInsets.all(12.0),),
                                    //   Text(document['content']),

                                    
                                    //   //Text(message),
                                    // ],

                                    child: Text(
                                      document['content'],
                                      //style: TextStyle(color: primaryColor)
                                    ),

                                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                                    width: 200.0,
                                    decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(8.0)),
                                    margin: EdgeInsets.all(5.0),
                                  ) : 
                                  Container(
                                    // crossAxisAlignment: CrossAxisAlignment.center,
                                    // children: <Widget>[
                                    //   new Container(
                                    //     child: Image.network(document['urlOfImage'], width: 200, height: 200)
                                    //   )
                                      
                                    // ],

                                    child: Material(
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) => Container(
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                          ),
                                          width: 200.0,
                                          height: 200.0,
                                          padding: EdgeInsets.all(70.0),

                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8.0)
                                            )
                                          )
                                        ), 
                                        
                                        imageUrl: document['urlOfImage'],
                                        width: 200.0,
                                        height: 200.0,
                                        fit: BoxFit.cover, 
                                       //document['urlOfImage']
                                      ),

                                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    margin: EdgeInsets.all(5.0),
                                  )
                                  
                                  

                               
                                ],
                            );

                          }
                          else  {
                            return Row(
                              children: <Widget>[
                               // Icon(Icons.person),

                                document['type'] == 0 
                                ? Container(
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    // children: <Widget>[
                                    //   SizedBox(height: 10.0,),
                                    //   Padding(padding: EdgeInsets.all(12.0),),
                                    //   Text(document['content'],),
                                     
                                    //   //Text(message),
                                    // ],

                                    child: Text(document['content'],),

                                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                                    width: 200.0,
                                    decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(8.0)),
                                    margin: EdgeInsets.all(5.0),
                                  
                                  )
                                  
                                   : Container(
                                      child: Material(
                                        child: CachedNetworkImage(
                                          placeholder: (context, url) => Container(
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                            ),
                                            width: 200.0,
                                            height: 200.0,
                                            padding: EdgeInsets.all(70.0),

                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8.0)
                                              )
                                            )
                                          ), 
                                          
                                          imageUrl: document['urlOfImage'],
                                          width: 200.0,
                                          height: 200.0,
                                          fit: BoxFit.cover, 
                                        ),

                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                        clipBehavior: Clip.hardEdge,
                                      ),
                                      margin: EdgeInsets.all(5.0),
                                  )
                                    
                              ],
                            );

                          }
                      },
                      itemCount: snapshot.data.documents.length,
                  );
                },
              ),
              
            ),
            new Divider(height: 1.0),
            Container(
              margin: EdgeInsets.only(bottom: 20.0, right: 10.0, left: 10.0),
              child: Row(
                children: <Widget>[
                  Material(
                    child: new Container(
                      margin: new EdgeInsets.symmetric(horizontal: 1.0),
                      child: new IconButton(
                        icon: new Icon(Icons.image),
                        onPressed: getImage,
                        color: Colors.red,
                        padding: EdgeInsets.all(5.0),
                      ),
                    ),
                    color: Colors.white,
                  ),
                  new Flexible(
                      child: new TextField(
                        controller: _controller,
                        //onSubmitted: _handleSubmit,
                        decoration: new InputDecoration.collapsed(
                          hintText: "send message"),
                    ),
                  ),
                  new Container(
                    child: new IconButton(
                      icon: new Icon(Icons.send, color: Colors.blue,),
                      onPressed: () {
                        _handleSubmit(_controller.text, 0);
                      }
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ) ,
    );
  }

  // Widget _ownMessage(String message) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.end,
  //     children: <Widget>[
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: <Widget>[
  //           SizedBox(height: 10.0,),
  //          // Text(username),
  //           Text(message),
  //         ],
  //       ),
  //       Icon(Icons.person),
  //     ],
  //   );
  // }

  // Widget _message(String message) {
  //   return Row(
  //     children: <Widget>[
  //       Icon(Icons.person),
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: <Widget>[
  //           SizedBox(height: 10.0,),
  //           //Text(username),
  //           Text(message),
  //         ],
  //       )
  //     ],
  //   );
  // }

  _handleSubmit(String content, int type) {

    if(content.trim() != ''){
      _controller.clear();

      var documentReference = Firestore.instance
          .collection('bmk_messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(documentReference, 
        {
          'idFrom' : id,
          'idTo' : peerId,
          'user_Name': userName,
          'timestamp' :  DateTime.now().millisecondsSinceEpoch.toString(),
          'content': content,
          'type': type,
          'urlOfImage' : urlOfImage,
          'specifictoken' : specifictoken,


        });
      });

      var db = Firestore.instance;
      db.collection("notify_messages").add({
        "user_name" : nameOfTheSender,
        'content': content,
        'specifictoken' : specifictoken,
      });
    } 


    // _controller.text = "";
    // var db = Firestore.instance;
    // db.collection("messages").document(peerId).collection(peerId)
    // .add({
    //   "user_name": widget.userName,
    //   "message": message,
    //   "created_at": DateTime.now()
    // }).then((val) {
    //   print("success");
    // }).catchError((err) {
    //   print(err);
    // });
  }

  
  
}