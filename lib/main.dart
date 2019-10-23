import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfirestore/mainscreen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'dart:async';


final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Stress Free App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String phoneNo;
  String smsCode;
  String verificationId;

  bool isLoading = false;
  SharedPreferences prefs;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  String userToken;
  FirebaseUser currentUser;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firebaseMessaging.getToken().then((token){
      setState(() {
       userToken = token; 
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.lightGreen,
      body: ListView(
        children: <Widget>[
          SizedBox(height: 30.0),
          Container(
            alignment: Alignment.center,
            height: 20.0,
            child: Text(
              "Stress Free Life",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
                fontFamily: "free-scpt"),
            ),
          ),
          SizedBox(height: 30.0),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              
              child: FlatButton(
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)
                ),
                child: Text(
                  'SIGN IN WITH GOOGLE',
                  style: TextStyle(fontSize: 16.0),
                ),
                color: Color(0xffdd4b39),
                highlightColor: Color(0xffff7f7f),
                splashColor: Colors.transparent,
                textColor: Colors.white,
                padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
                onPressed: () => _gSignin(),
              ),
               
            ),
          ),

          SizedBox(height: 5.0),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              child: FlatButton(
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)
                ),
                child: Text(
                  'SIGN IN WITH FACEBOOK',
                  style: TextStyle(fontSize: 16.0),
                ),
                color: Colors.blueAccent,
                highlightColor: Color(0xffff7f7f),
                splashColor: Colors.transparent,
                textColor: Colors.white,
                padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
                onPressed: () => _gSignin(),
              ),
               
            ),
          ),

          // Positioned(
          //   child: isLoading ? Container(
          //     child: Center(
          //       child: CircularProgressIndicator(
          //         valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
          //       ),
          //     ),

          //     color: Colors.white.withOpacity(0.8),
          //   )
          //   : Container()
          // )
        ],
      ),
    );
  }

  Future<void> _gSignin() async {

    // this.setState((){
    //   isLoading = true;
    // });
    
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication = 
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,);

      final FirebaseUser firebaseUser = await _auth.signInWithCredential(credential);

      prefs = await SharedPreferences.getInstance();
      // Future<String> token = _firebaseMessaging.getToken();
      

      if(firebaseUser != null){
         final QuerySnapshot result =
          await Firestore.instance.collection('users').where('id', isEqualTo: firebaseUser.uid).getDocuments();
         final List<DocumentSnapshot> documents = result.documents;

        if(documents.length == 0){
           Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({'nickname': firebaseUser.displayName, 'photoUrl': firebaseUser.photoUrl, 'id': firebaseUser.uid, 'specifictoken': userToken});

           Firestore.instance
            .collection('pushtokens')
            .document(firebaseUser.uid)
            .setData({'devtoken': userToken});
            

          currentUser = firebaseUser;
          await prefs.setString('id', currentUser.uid);
          await prefs.setString('nickname', currentUser.displayName);
          await prefs.setString('photoUrl', currentUser.photoUrl);
        }
        else {
          await prefs.setString('id', documents[0]['id']);
          await prefs.setString('nickname', documents[0]['nickname']);
          await prefs.setString('photoUrl', documents[0]['photoUrl']);
          await prefs.setString('aboutMe', documents[0]['aboutMe']);
        }

        
        // final snackBar = SnackBar(content: Text('SignIn Success'));
        // Scaffold.of(context).showSnackBar(snackBar);
       // userTokenId(firebaseUser.displayName, firebaseUser.uid);


        this.setState((){
          isLoading = false;
        });

        Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => MainScreen(currentUserId: firebaseUser.uid)),
        );

      }
      else{
        final snackBar = SnackBar(content: Text('SignIn Failed'));
        Scaffold.of(context).showSnackBar(snackBar);

        this.setState((){
          isLoading = false;
        });

      }

    return firebaseUser;
  }
  
}
