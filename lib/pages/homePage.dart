import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordopol/pages/checkAuth.dart';
import 'package:wordopol/services/authFunctions.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _userInfo;
  AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    if ((Provider.of<QuerySnapshot> != null &&
        Provider.of<DocumentSnapshot> != null)) {
      _userInfo = Provider.of<DocumentSnapshot>(context).data();
    }
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
                child: Center(
                    child:
                        Text("Home Page " + _userInfo['userName'].toString()))),
            RawMaterialButton(
                fillColor: Color.fromARGB(255, 33, 39, 120),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                splashColor: Color(0xff77A830),
                textStyle: TextStyle(color: Colors.white),
                child: Text("Sign Out",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 15,
                      fontFamily: 'Times New Roman',
                      // fontWeight: FontWeight.bold
                    )),
                onPressed: () async {
                  var a = await _authService.signOutAndDeleteUser(
                      _userInfo['id'], _userInfo['registerType']);
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => CheckAuth()),
                      (Route<dynamic> route) => false);
                }),
          ],
        ),
      ),
    );
  }
}
