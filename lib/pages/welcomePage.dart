import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  TextEditingController _turkceTextFieldController = TextEditingController();
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
                child: Text("Button",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 15,
                      fontFamily: 'Times New Roman',
                      // fontWeight: FontWeight.bold
                    )),
                onPressed: () {}),
          ],
        )),
      )),
    );
  }
}
