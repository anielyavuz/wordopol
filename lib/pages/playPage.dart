import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:wordopol/pages/homePage.dart';
import 'package:wordopol/services/firebaseFunctions.dart';
import 'package:wordopol/services/uppercaseFunction.dart';

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

class _PlayPageState extends State<PlayPage> with TickerProviderStateMixin {
  String _lonieURL = "";
  List _alphabet0 = [
    "Q",
    "W",
    "E",
    "R",
    "T",
    "Y",
    "U",
    "I",
    "O",
    "P",
  ];
  List _alphabet1 = [
    "A",
    "S",
    "D",
    "F",
    "G",
    "H",
    "J",
    "K",
    "L",
  ];
  List _alphabet2 = ["Z", "X", "C", "V", "B", "N", "M"];
  List _alphabet3 = ["Ğ", "Ü", "Ş", "İ", "Ö", "Ç"];
  List _alinanHarfler = [];
  List _ekrandakiCevap = [];
  List _cevabiYazilanIndexler = [];
  int _puan = 0;
  int _questionNumber = 0; //hangi soruda olunduğu
  bool _gameEnd = false;
  String _hint = "";
  bool _ekrandakiCevapVisibility = true;

  TextEditingController _cevapTextFieldController = TextEditingController();
  late AnimationController _checkController;

  late Timer _timer;
  int _geriSayilcakSure = 600;

  late Timer _timer2;
  int _geriSayilcakSure2 = 30;
  bool _cevapFieldVisible = false;

  /// LOCAL DB Çalışmaları
  animationCall(String input) {
    if (input == "Check") {
      setState(() {
        _lonieURL = "assets/json/check.json";
      });
      _checkController.forward();
      Future.delayed(const Duration(milliseconds: 1200), () {
        _checkController.reset();
        setState(() {
          _lonieURL = "";
        });
      });
    } else if (input == "Wrong") {
      setState(() {
        _lonieURL = "assets/json/wrong.json";
      });
      _checkController.forward();
      Future.delayed(const Duration(milliseconds: 1200), () {
        _checkController.reset();
        setState(() {
          _lonieURL = "";
        });
      });
    }
  }

  ekrandakiCevapla() {
    _ekrandakiCevap = [];
    for (var item in widget.wordsForPlay[_questionNumber]["_answer"]
        .toString()
        .split("")) {
      _ekrandakiCevap.add(" ");
      // print("AAAAAAAA");
    }
  }

  void geriSayacCevapSuresiBasla() {
    const oneSec = const Duration(seconds: 1);
    _timer2 = new Timer.periodic(
      oneSec,
      (Timer timer2) {
        if (_geriSayilcakSure2 == 0) {
          if (_questionNumber + 1 < widget.wordsForPlay.length) {
            setState(() {
              _hint = "";
              _cevabiYazilanIndexler = [];
              _alinanHarfler = [];
              _questionNumber = _questionNumber + 1;
              ekrandakiCevapla();
              _cevapTextFieldController.text = "";
              _geriSayilcakSure2 = 30;
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
            print("Tüm sorular bitti tebrikler Puanınız... $_puan ");
            _timer2.cancel();
            setState(() {
              _cevapFieldVisible = false;
              _ekrandakiCevapVisibility = false;
              _gameEnd = true;
              // _puan = _puan + int.parse(_timer.toString());
              _hint = "";
              _cevabiYazilanIndexler = [];
              _alinanHarfler = [];
            });
            CloudDB().updateScoreTable(widget.seasonNumber, widget.uid,
                widget.userName, widget.point + _puan);
          }
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
          print(_questionNumber);
          if (_questionNumber + 1 < widget.wordsForPlay.length) {
            setState(() {
              timer.cancel();
              _gameEnd = true;
              _hint = "";
              _cevabiYazilanIndexler = [];
              _alinanHarfler = [];

              CloudDB().updateScoreTable(widget.seasonNumber, widget.uid,
                  widget.userName, widget.point + _puan);
            });
          } else {
            print("Tüm sorular bitti tebrikler Puanınız... $_puan ");
            timer.cancel();
            setState(() {
              _cevapFieldVisible = false;
              _ekrandakiCevapVisibility = false;
              _gameEnd = true;
              // _puan = _puan + int.parse(_timer.toString());
              _hint = "";
              _cevabiYazilanIndexler = [];
              _alinanHarfler = [];
            });
            CloudDB().updateScoreTable(widget.seasonNumber, widget.uid,
                widget.userName, widget.point + _puan);
          }
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

  sonBasilaniSil() {
    if (_cevabiYazilanIndexler.length > 0) {
      int _silinecekIndex = _cevabiYazilanIndexler.last;
      print(_silinecekIndex);

      setState(() {
        _ekrandakiCevap[_silinecekIndex] = " ";
        _cevabiYazilanIndexler.removeLast();
      });
    }
  }

  cevabiYaz(String word) {
    int _index = 0;
    for (var item in _ekrandakiCevap) {
      if (item == " ") {
        setState(() {
          _ekrandakiCevap[_index] = word;
          _cevabiYazilanIndexler.add(_index);
        });
        break;
      }
      _index++;
    }
  }

  cevapKontrolFunction(bool _timer2On) async {
    List _tempEkrandakiler = [];
    for (var item in _ekrandakiCevap) {
      if (item != " ") {
        _tempEkrandakiler.add(item);
      }
    }
    if (_tempEkrandakiler.length ==
        widget.wordsForPlay[_questionNumber]["_answer"].split("").length) {
      String _ekrandakiCevapString = "";
      for (var item in _ekrandakiCevap) {
        _ekrandakiCevapString += item;
      }

      if (Uppercase().upperCaseFunction(_ekrandakiCevapString) ==
          Uppercase().upperCaseFunction(
              widget.wordsForPlay[_questionNumber]["_answer"])) {
        print("Doğru cevap");

        animationCall("Check");
        await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
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
            _cevabiYazilanIndexler = [];
            _alinanHarfler = [];
            _questionNumber = _questionNumber + 1;
            ekrandakiCevapla();

            _cevapTextFieldController.text = "";
            _geriSayilcakSure2 = 30;
          });
          if (_timer2On) {
            _timer2.cancel();
          }

          geriSayacBasla();
        } else {
          print("Tüm sorular bitti tebrikler Puanınız... $_puan ");
          if (_timer2On) {
            _timer2.cancel();
          }
          setState(() {
            _cevapFieldVisible = false;
            _ekrandakiCevapVisibility = false;
            _gameEnd = true;
            // _puan = _puan + int.parse(_timer.toString());
            _hint = "";
            _cevabiYazilanIndexler = [];
            _alinanHarfler = [];
          });
          CloudDB().updateScoreTable(widget.seasonNumber, widget.uid,
              widget.userName, widget.point + _puan);
        }
      } else {
        animationCall("Wrong");
        print("Cevap yanlış");
        print(Uppercase().upperCaseFunction(_ekrandakiCevapString));
        print(widget.wordsForPlay[_questionNumber]["_answer"]);
        print(Uppercase().upperCaseFunction(
            widget.wordsForPlay[_questionNumber]["_answer"]));
        // print(_cevapTextFieldController.text.toUpperCase());
        // print(widget.wordsForPlay[_questionNumber]["_answer"]
        //     .toString()
        //     .toUpperCase());
      }
    } else {
      print("Cevap için yazılan karakter sayısı az...");
    }
  }

  harfAl() {
    List _tempListe =
        widget.wordsForPlay[_questionNumber]["_answer"].toString().split('');

    if (_hint.length < _tempListe.length - 1) {
      Random rnd;
      int min = 0;
      int max = _tempListe.length;

      int _tempResult = 0;
      for (var i = 0; i < 100; i++) {
        rnd = new Random();
        _tempResult = min + rnd.nextInt(max - min);
        print(_tempResult);
        if (!_alinanHarfler.contains(_tempResult)) {
          setState(() {
            _alinanHarfler.add(_tempResult);
          });
          break;
        }
      }

      setState(() {
        _ekrandakiCevap[_tempResult] =
            Uppercase().upperCaseFunction(_tempListe[_tempResult].toString());
      });
      print(_ekrandakiCevap);

      if (_hint.length <
          widget.wordsForPlay[_questionNumber]["_answer"].toString().length) {
        setState(() {
          // print(object)
          _hint = widget.wordsForPlay[_questionNumber]["_answer"]
              .toString()
              .substring(0, _hint.toString().length + 1);
        });
      }
    } else if (_hint.length == _tempListe.length - 1) {
      Random rnd;
      int min = 0;
      int max = _tempListe.length;

      int _tempResult = 0;
      for (var i = 0; i < 100; i++) {
        rnd = new Random();
        _tempResult = min + rnd.nextInt(max - min);
        print(_tempResult);
        if (!_alinanHarfler.contains(_tempResult)) {
          setState(() {
            _alinanHarfler.add(_tempResult);
          });
          break;
        }
      }

      setState(() {
        _ekrandakiCevap[_tempResult] =
            Uppercase().upperCaseFunction(_tempListe[_tempResult].toString());
      });
      print(_ekrandakiCevap);

      if (_hint.length <
          widget.wordsForPlay[_questionNumber]["_answer"].toString().length) {
        setState(() {
          // print(object)
          _hint = widget.wordsForPlay[_questionNumber]["_answer"]
              .toString()
              .substring(0, _hint.toString().length + 1);
        });
      }
      cevapKontrolFunction(false);
    }
  }

  @override
  void initState() {
    geriSayacBasla();
    ekrandakiCevapla();
    _checkController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    _timer.cancel();
    _timer2.cancel();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: Stack(
        children: [
          Column(
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
                                widget.wordsForPlay[_questionNumber]
                                        ["_question"]
                                    .toString(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // Visibility(
                            //   visible: _cevapFieldVisible,
                            //   child: TextField(
                            //     inputFormatters: [
                            //       LengthLimitingTextInputFormatter(widget
                            //           .wordsForPlay[_questionNumber]["_answer"]
                            //           .length),
                            //     ],
                            //     autofocus: true,
                            //     onChanged: (value2) {
                            //       // print(_cevapTextFieldController.text);
                            //     },
                            //     controller: _cevapTextFieldController,
                            //     decoration: InputDecoration(
                            //       contentPadding: EdgeInsets.all(10),
                            //       isCollapsed: true,
                            //       filled: true,
                            //       fillColor: Color.fromARGB(255, 216, 255, 161),
                            //       enabledBorder: OutlineInputBorder(
                            //         borderRadius: BorderRadius.circular(30),
                            //         borderSide: BorderSide(
                            //           color: Colors.green,
                            //           width: 1.0,
                            //         ),
                            //       ),
                            //       focusedBorder: OutlineInputBorder(
                            //         borderRadius: BorderRadius.circular(30),
                            //         borderSide: BorderSide(
                            //           color: Colors.purple,
                            //           width: 2.0,
                            //         ),
                            //       ),
                            //       hintText: "Answer",
                            //       hintStyle: TextStyle(
                            //           color: Color.fromARGB(75, 21, 9, 35)),
                            //     ),
                            //   ),
                            // ),

                            Visibility(
                              visible: _cevapFieldVisible,
                              child: RawMaterialButton(
                                  fillColor: Color.fromARGB(255, 45, 179, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15.0))),
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
                                    cevapKontrolFunction(true);
                                  }),
                            ),
                            Visibility(
                              visible: !_cevapFieldVisible,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  RawMaterialButton(
                                      fillColor:
                                          Color.fromARGB(255, 33, 39, 120),
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
                                      fillColor:
                                          Color.fromARGB(255, 33, 39, 120),
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
                      : Center(
                          child: Text(" Oyun tamamlandı... Puan: $_puan"))),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                child: Column(
                  children: [
                    Visibility(
                      visible: _ekrandakiCevapVisibility ? true : false,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _ekrandakiCevap
                              .map((word) => Padding(
                                    padding: EdgeInsets.all(
                                        (MediaQuery.of(context).size.width -
                                                (35 * 8)) /
                                            16),
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
                                          word,
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
                    ),
                    Visibility(
                      visible: _cevapFieldVisible ? true : false,
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _alphabet0
                                  .map((word) => Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            4, 5, 4, 5),
                                        child: InkWell(
                                          onTap: _cevapFieldVisible
                                              ? (() async {
                                                  cevabiYaz(word);
                                                })
                                              : null,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  // border:
                                                  //     Border.all(color: Colors.black),
                                                  color: _cevapFieldVisible
                                                      ? Colors.amber
                                                      : Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10))),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  13,
                                              height: 40,
                                              child: Center(child: Text(word))),
                                        ),
                                      ))
                                  .toList()),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _alphabet1
                                  .map((word) => Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            4, 5, 4, 5),
                                        child: InkWell(
                                          onTap: _cevapFieldVisible
                                              ? (() async {
                                                  cevabiYaz(word);
                                                })
                                              : null,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  // border:
                                                  //     Border.all(color: Colors.black),
                                                  color: _cevapFieldVisible
                                                      ? Colors.amber
                                                      : Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10))),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  13,
                                              height: 40,
                                              child: Center(child: Text(word))),
                                        ),
                                      ))
                                  .toList()),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(4, 5, 4, 5),
                                child: InkWell(
                                  onTap: (() async {
                                    // print(word);
                                  }),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          // border:
                                          //     Border.all(color: Colors.black),
                                          color: _cevapFieldVisible
                                              ? Colors.amber
                                              : Colors.grey,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      width: MediaQuery.of(context).size.width /
                                          13,
                                      height: 40,
                                      child: Center(child: Text("🔔"))),
                                ),
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _alphabet2
                                      .map((word) => Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                4, 5, 4, 5),
                                            child: InkWell(
                                              onTap: _cevapFieldVisible
                                                  ? (() async {
                                                      // print(word);
                                                      cevabiYaz(word);
                                                    })
                                                  : null,
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      // border:
                                                      //     Border.all(color: Colors.black),
                                                      color: _cevapFieldVisible
                                                          ? Colors.amber
                                                          : Colors.grey,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10))),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      13,
                                                  height: 40,
                                                  child: Center(
                                                      child: Text(word))),
                                            ),
                                          ))
                                      .toList()),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(4, 5, 4, 5),
                                child: InkWell(
                                  onTap: (() async {
                                    sonBasilaniSil();
                                    // print(word);
                                  }),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          // border:
                                          //     Border.all(color: Colors.black),
                                          color: _cevapFieldVisible
                                              ? Colors.amber
                                              : Colors.grey,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      width: MediaQuery.of(context).size.width /
                                          13,
                                      height: 40,
                                      child: Center(child: Text("⌫"))),
                                ),
                              )
                            ],
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _alphabet3
                                  .map((word) => Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            4, 5, 4, 5),
                                        child: InkWell(
                                          onTap: _cevapFieldVisible
                                              ? (() async {
                                                  cevabiYaz(word);
                                                })
                                              : null,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  // border:
                                                  //     Border.all(color: Colors.black),
                                                  color: _cevapFieldVisible
                                                      ? Colors.amber
                                                      : Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10))),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  13,
                                              height: 40,
                                              child: Center(child: Text(word))),
                                        ),
                                      ))
                                  .toList()),
                        ],
                      ),
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
                    // print(_ekrandakiCevap);

                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => HomePage(
                                  userID: widget.uid,
                                )),
                        (Route<dynamic> route) => false);

                    // Navigator.pop(context);
                    // (Route<dynamic> route) => false);
                  }),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height - 340 + 80,
            right: MediaQuery.of(context).size.width / 2 - 125,
            child: Container(
              //  BoxDecoration(
              //   border: Border.all(color: Colors.black),
              //   color: Color(0xff70e000),
              //   borderRadius:
              //       BorderRadius.all(Radius.circular(50 / 2)),
              // )

              width: 250,
              height: 250,
              child: _lonieURL == ""
                  ? SizedBox()
                  : Lottie.asset(_lonieURL, controller: _checkController),
            ),
          ),
        ],
      )),
    );
  }
}
