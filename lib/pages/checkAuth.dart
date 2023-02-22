import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordopol/pages/homePage.dart';
import 'package:wordopol/pages/welcomePage.dart';
import 'package:wordopol/services/authenticationStreamer.dart';

class CheckAuth extends StatefulWidget {
  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool _login = false;
  late User _user;
  String _uid = "";
  rootControl() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      // print(user?.uid);
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
        print(user.uid);

        // Navigator.pushAndRemoveUntil(
        //     context,
        //     MaterialPageRoute(
        //         builder: (BuildContext context) => HomePage(
        //               userID: user.uid,
        //             )),
        //     (Route<dynamic> route) => false);
        setState(() {
          _login = true;
          _uid = user.uid;
        });
      }
      // setState(() {
      //   _user = user!;
      // });
    });
  }

  @override
  void initState() {
    rootControl();

    //LOGOYU BELLİ SURE GOSTEREN KOD BURASIYDI YORUMA ALINDI
//     Future.delayed(const Duration(milliseconds: 1500), () {
// // Here you can write your code
//     });
    // rootControl();
  }

  @override
  Widget build(BuildContext context) {
    return (_login)
        ? HomePage(
            userID: _uid,
          )

        // MainPage()
        : WelcomePage();
  }
}
