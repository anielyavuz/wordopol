import 'package:flutter/material.dart';

class PlayPage extends StatefulWidget {
  final List wordsForPlay;

  //Note: statefull'a parametre göndermek için gerekli
  const PlayPage({Key? key, required this.wordsForPlay}) : super(key: key);

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
            child: Container(
              child: Text("PlayPage"),
            ),
          ),
          Container(
            child: Text(widget.wordsForPlay.toString()),
          ),
          RawMaterialButton(
              fillColor: Color.fromARGB(255, 33, 39, 120),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              splashColor: Color(0xff77A830),
              textStyle: TextStyle(color: Colors.white),
              child: Text("Back",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 15,
                    fontFamily: 'Times New Roman',
                    // fontWeight: FontWeight.bold
                  )),
              onPressed: () async {
                Navigator.pop(context);
                // (Route<dynamic> route) => false);
              }),
        ],
      )),
    );
  }
}
