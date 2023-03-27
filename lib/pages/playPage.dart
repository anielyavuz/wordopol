import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:wordopol/pages/homePage.dart';
import 'package:wordopol/services/firebaseFunctions.dart';

class PlayPage extends StatefulWidget {
  final List wordsForPlay;
  final String uid;
  final String userName;
  final int point;
  final String seasonNumber;

  //Note: statefull'a parametre göndermek için gerekli
  const PlayPage(
      {Key? key,
      required this.wordsForPlay,
      required this.userName,
      required this.uid,
      required this.point,
      required this.seasonNumber})
      : super(key: key);

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  List _alphabet0 = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"];
  List _alphabet1 = ["A", "S", "D", "F", "G", "H", "J", "K", "L"];
  List _alphabet2 = ["Z", "X", "C", "V", "B", "N", "M"];
  List _ekrandakiCevap = [];
  int _puan = 0;
  int _questionNumber = 0; //hangi soruda olunduğu
  bool _gameEnd = false;
  String _hint = "";
  TextEditingController _cevapTextFieldController = TextEditingController();

  late Timer _timer;
  int _geriSayilcakSure = 10000;

  late Timer _timer2;
  int _geriSayilcakSure2 = 2500;
  bool _cevapFieldVisible = false;

  ekraniCevapla() {
    _ekrandakiCevap = [];
    for (var item in widget.wordsForPlay[_questionNumber]["_answer"]
        .toString()
        .split("")) {
      _ekrandakiCevap.add(" ");
      print("AAAAAAAA");
    }
  }

  void geriSayacCevapSuresiBasla() {
    const oneSec = const Duration(seconds: 1);
    _timer2 = new Timer.periodic(
      oneSec,
      (Timer timer2) {
        if (_geriSayilcakSure2 == 0) {
          setState(() {
            _hint = "";
            _questionNumber = _questionNumber + 1;
            ekraniCevapla();
            _cevapTextFieldController.text = "";
            _geriSayilcakSure2 = 2500;
            _cevapFieldVisible = false;
            _puan = _puan -
                (widget.wordsForPlay[_questionNumber]["_answer"]
                        .toString()
                        .length *
                    5);
          });
          _timer2.cancel();
          geriSayacBasla();
        } else {
          setState(() {
            _geriSayilcakSure2--;
          });
        }
      },
    );
  }

  void geriSayacBasla() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_geriSayilcakSure == 0) {
          setState(() {
            timer.cancel();
            _gameEnd = true;
            _hint = "";

            CloudDB().updateScoreTable(widget.seasonNumber, widget.uid,
                widget.userName, widget.point + _puan);
          });
        } else {
          setState(() {
            _geriSayilcakSure--;
          });
        }
      },
    );
  }

  void cevabiBuldum() {
    _timer.cancel();
    setState(() {
      _cevapFieldVisible = true;
    });
    geriSayacCevapSuresiBasla();
  }

  cevapKontrolFunction() {
    if (_cevapTextFieldController.text.toLowerCase() ==
        widget.wordsForPlay[_questionNumber]["_answer"]
            .toString()
            .toLowerCase()) {
      print("Doğru cevap");

      //Soru değişim
      if (_questionNumber + 1 < widget.wordsForPlay.length) {
        setState(() {
          _puan = _puan +
              ((widget.wordsForPlay[_questionNumber]["_answer"]
                          .toString()
                          .length -
                      _hint.length) *
                  10);
          _cevapFieldVisible = false;
          _hint = "";
          _questionNumber = _questionNumber + 1;
          ekraniCevapla();

          _cevapTextFieldController.text = "";
          _geriSayilcakSure2 = 2500;
        });
        _timer2.cancel();
        geriSayacBasla();
      } else {
        print("Tüm sorular bitti tebrikler Puanınız... $_puan ");
        setState(() {
          _gameEnd = true;
          _puan = _puan + int.parse(_timer.toString());
          _hint = "";
        });
        CloudDB().updateScoreTable(widget.seasonNumber, widget.uid,
            widget.userName, widget.point + _puan);
      }
    } else {
      print("Cevap yanlış");
    }
  }

  harfAl() {
    if (_hint.length <
        widget.wordsForPlay[_questionNumber]["_answer"].toString().length) {
      setState(() {
        // print(object)
        _hint = widget.wordsForPlay[_questionNumber]["_answer"]
            .toString()
            .substring(0, _hint.toString().length + 1);
      });
    }
  }

  @override
  void initState() {
    geriSayacBasla();
    ekraniCevapla();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              child: !_gameEnd
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          child: Text("Toplam Puan: " + _puan.toString(),
                              style: TextStyle(
                                color: Color.fromARGB(255, 49, 49, 196),
                                fontSize: 35,
                                fontFamily: 'Times New Roman',
                                // fontWeight: FontWeight.bold
                              )),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Container(
                          child: Text(
                              "Bu sorunun puanı: " +
                                  ((widget.wordsForPlay[_questionNumber]
                                                      ["_answer"]
                                                  .toString()
                                                  .length -
                                              _hint.length) *
                                          10)
                                      .toString(),
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 25,
                                fontFamily: 'Times New Roman',
                                // fontWeight: FontWeight.bold
                              )),
                        ),
                        Visibility(
                          visible: _cevapFieldVisible,
                          child: Center(
                            child: Container(
                              child: Text(_geriSayilcakSure2.toString(),
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 25,
                                    fontFamily: 'Times New Roman',
                                    // fontWeight: FontWeight.bold
                                  )),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            child: Text(_geriSayilcakSure.toString()),
                          ),
                        ),
                        AnimatedContainer(
                          padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                          duration: Duration(milliseconds: 500),
                          child: Text(
                            widget.wordsForPlay[_questionNumber]["_question"]
                                .toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Text(_hint),
                        Visibility(
                          visible: _cevapFieldVisible,
                          child: TextField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(widget
                                  .wordsForPlay[_questionNumber]["_answer"]
                                  .length),
                            ],
                            autofocus: true,
                            onChanged: (value2) {
                              // print(_cevapTextFieldController.text);
                            },
                            controller: _cevapTextFieldController,
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
                              hintText: "Answer",
                              hintStyle: TextStyle(
                                  color: Color.fromARGB(75, 21, 9, 35)),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _cevapFieldVisible,
                          child: RawMaterialButton(
                              fillColor: Color.fromARGB(255, 45, 179, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0))),
                              splashColor: Color(0xff77A830),
                              textStyle: TextStyle(color: Colors.white),
                              child: Text("TAMAM",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 18, 9, 9),
                                    fontSize: 15,
                                    fontFamily: 'Times New Roman',
                                    // fontWeight: FontWeight.bold
                                  )),
                              onPressed: () async {
                                cevapKontrolFunction();
                              }),
                        ),
                        Visibility(
                          visible: !_cevapFieldVisible,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RawMaterialButton(
                                  fillColor: Color.fromARGB(255, 33, 39, 120),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15.0))),
                                  splashColor: Color(0xff77A830),
                                  textStyle: TextStyle(color: Colors.white),
                                  child: Text("Harf alayım..",
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 15,
                                        fontFamily: 'Times New Roman',
                                        // fontWeight: FontWeight.bold
                                      )),
                                  onPressed: () async {
                                    harfAl();
                                  }),
                              RawMaterialButton(
                                  fillColor: Color.fromARGB(255, 33, 39, 120),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15.0))),
                                  splashColor: Color(0xff77A830),
                                  textStyle: TextStyle(color: Colors.white),
                                  child: Text("Cevabımı buldum..",
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 15,
                                        fontFamily: 'Times New Roman',
                                        // fontWeight: FontWeight.bold
                                      )),
                                  onPressed: () async {
                                    cevabiBuldum();
                                  }),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Center(child: Text(" Oyun tamamlandı... Puan: $_puan"))),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.wordsForPlay[_questionNumber]["_answer"]
                                .toString()
                                .length ==
                            0
                        ? [
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                      // border:
                                      //     Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  width: 35,
                                  height: 40,
                                  child: Center(
                                      child: Text(
                                    "",
                                    style: TextStyle(
                                      // backgroundColor:
                                      //     Colors
                                      //         .white,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ))),
                            )
                          ]
                        : _ekrandakiCevap
                            .map((word) => Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          // border:
                                          //     Border.all(color: Colors.black),
                                          color: Color(0xff240046),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      width: 35,
                                      height: 40,
                                      child: Center(
                                          child: Text(
                                        "",
                                        style: TextStyle(
                                          // backgroundColor:
                                          //     Colors
                                          //         .white,
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ))),
                                ))
                            .toList()),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _alphabet0
                        .map((word) => Padding(
                              padding: const EdgeInsets.fromLTRB(4, 5, 4, 5),
                              child: InkWell(
                                onTap: (() async {}),
                                child: Container(
                                    decoration: BoxDecoration(
                                        // border:
                                        //     Border.all(color: Colors.black),
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    width:
                                        MediaQuery.of(context).size.width / 13,
                                    height: 40,
                                    child: Center(child: Text(word))),
                              ),
                            ))
                        .toList()),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _alphabet1
                        .map((word) => Padding(
                              padding: const EdgeInsets.fromLTRB(4, 5, 4, 5),
                              child: InkWell(
                                onTap: (() async {}),
                                child: Container(
                                    decoration: BoxDecoration(
                                        // border:
                                        //     Border.all(color: Colors.black),
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    width:
                                        MediaQuery.of(context).size.width / 13,
                                    height: 40,
                                    child: Center(child: Text(word))),
                              ),
                            ))
                        .toList()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _alphabet2
                            .map((word) => Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(4, 5, 4, 5),
                                  child: InkWell(
                                    onTap: (() async {}),
                                    child: Container(
                                        decoration: BoxDecoration(
                                            // border:
                                            //     Border.all(color: Colors.black),
                                            color: Colors.amber,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                13,
                                        height: 40,
                                        child: Center(child: Text(word))),
                                  ),
                                ))
                            .toList()),
                  ],
                ),
              ],
            ),
          ),
          RawMaterialButton(
              fillColor: Color.fromARGB(255, 33, 39, 120),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              splashColor: Color(0xff77A830),
              textStyle: TextStyle(color: Colors.white),
              child: Text("Çıkış",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 15,
                    fontFamily: 'Times New Roman',
                    // fontWeight: FontWeight.bold
                  )),
              onPressed: () async {
                print(_ekrandakiCevap);

                // Navigator.pushAndRemoveUntil(
                //     context,
                //     MaterialPageRoute(
                //         builder: (BuildContext context) => HomePage(
                //               userID: widget.uid,
                //             )),
                //     (Route<dynamic> route) => false);

                // Navigator.pop(context);
                // (Route<dynamic> route) => false);
              }),
        ],
      )),
    );
  }
}
