import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:wordopol/pages/checkAuth.dart';
import 'package:wordopol/services/authFunctions.dart';
import 'package:wordopol/services/firebaseFunctions.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late Box box;
  TextEditingController _turkceTextFieldController = TextEditingController();
  AuthService _authService = AuthService();

  @override
  void initState() {
    box = Hive.box("wordopolHive");

    //LOGOYU BELLİ SURE GOSTEREN KOD BURASIYDI YORUMA ALINDI
//     Future.delayed(const Duration(milliseconds: 1500), () {
// // Here you can write your code
//     });
    // rootControl();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: Container(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("WELCOME"),
            TextField(
              inputFormatters: [
                LengthLimitingTextInputFormatter(40),
                FilteringTextInputFormatter.deny("%"),
              ],
              autofocus: true,
              onChanged: (value2) {},
              controller: _turkceTextFieldController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                isCollapsed: true,
                filled: true,
                fillColor: Color.fromARGB(255, 216, 255, 161),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Colors.green,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Colors.purple,
                    width: 2.0,
                  ),
                ),
                hintText: "Username",
                hintStyle: TextStyle(color: Color.fromARGB(75, 21, 9, 35)),
              ),
            ),
            RawMaterialButton(
                fillColor: Color.fromARGB(255, 33, 39, 120),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                splashColor: Color(0xff77A830),
                textStyle: TextStyle(color: Colors.white),
                child: Text("Next",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 15,
                      fontFamily: 'Times New Roman',
                      // fontWeight: FontWeight.bold
                    )),
                onPressed: () async {
                  var a = await _authService
                      .anonymSignIn(_turkceTextFieldController.text);
                }),
          ],
        )),
      )),
    );
  }
}
