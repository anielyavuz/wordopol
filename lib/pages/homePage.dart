import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:wordopol/pages/checkAuth.dart';
import 'package:wordopol/pages/playPage.dart';
import 'package:wordopol/services/authFunctions.dart';
import 'package:wordopol/services/firebaseFunctions.dart';

class HomePage extends StatefulWidget {
  final String userID;

  //Note: statefull'a parametre göndermek için gerekli
  const HomePage({Key? key, required this.userID}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box box;

  var _userInfo;
  var _configData;
  AuthService _authService = AuthService();
  bool _userDataLoadScreen = true;
  var _wordPool;
  var _wordPoolData;

  var _languageFull = "English";

  String _currentLanguage = "en";
  List _wordsForPlay = [];

  Map _languageDropdown = {
    'Türkçe': 'tr',
    'Español': 'es',
    'Deutsch': 'de',
    'Français': 'fr',
    'English': 'en'
  };

  wordPickForPlay() {
    _wordsForPlay = [];
    setState(() {
      _wordsForPlay.add(_wordPoolData[_currentLanguage]['0']);
    });
  }

  languageSelect()
  //telefonun native dili eğer desteklenen dillerdense dropdown'da o gelir

  {
    if (_configData['supportedLanguages'] != null) {
      setState(() {
        _languageDropdown = _configData['supportedLanguages'];
      });
    }

    if (_configData['supportedLanguages']
        .keys
        .contains(Localizations.localeOf(context).languageCode.toString())) {
      print("yes");
      setState(() {
        _currentLanguage =
            Localizations.localeOf(context).languageCode.toString();
      });
    }

    setState(() {
      if (_currentLanguage == "tr") {
        _languageFull = "Türkçe";
      } else if (_currentLanguage == "en") {
        _languageFull = "English";
      } else if (_currentLanguage == "de") {
        _languageFull = "Deutsch";
      } else if (_currentLanguage == "fr") {
        _languageFull = "Français";
      } else if (_currentLanguage == "es") {
        _languageFull = "Español";
      } else {
        _languageFull = "Engilish";
      }
    });
    print(_currentLanguage);

    print((_languageFull));
  }

  wordDBSyncFunction() async {
    _userInfo = await CloudDB().getUserInfo(widget.userID);
    _configData = await CloudDB().getConfigDatas();

    var _DBId = box.get("DBId") ?? 0;
    // var _configData = await CloudDB().getConfigDatas();

    // await CloudDB().firestoreFileReach(_configData['DBId']);

    if (_configData['DBId'] != _DBId) {
      print(
          "Clouddaki son kelimeler bu cihazda yüklü değil. Güncelleme yapılıyor...");

      _wordPool = await CloudDB().firestoreFileReach(_configData['DBId']);

      box.put("DBId", _configData['DBId']);
      box.put("WordPool", _wordPool);
      setState(() {
        _userDataLoadScreen = false;
      });
    } else {
      print("Dbler güncel");
    }
    setState(() {
      _userDataLoadScreen = false;
    });
    _DBId = box.get("DBId") ?? 0;
    _wordPoolData = box.get("WordPool") ?? {};

    print(_DBId);
  }

  // getCloudData() async {
  //   _userInfo = await CloudDB().getUserInfo(widget.userID);
  //   _configData = await CloudDB().getConfigDatas();
  //   setState(() {
  //     _userDataLoadScreen = false;
  //   });
  // }

  @override
  void initState() {
    box = Hive.box("wordopolHive");
    wordDBSyncFunction();
    //LOGOYU BELLİ SURE GOSTEREN KOD BURASIYDI YORUMA ALINDI
    Future.delayed(const Duration(milliseconds: 1000), () {
// Here you can write your code
      languageSelect();
    });
    // rootControl();
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
                    child: Center(
                        child: Text("Welcome"

                            // _wordPoolData[_currentLanguage].toString()

                            ))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                  child: DropdownButton<String>(
                      dropdownColor: Color(0xff010114).withOpacity(1),
                      value: _languageFull,
                      items:
                          _languageDropdown.keys.toList().map((dynamic value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 137, 111, 111),
                                  fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _languageFull = value!;
                        });

                        if (_configData['supportedLanguages'] != null) {
                          setState(() {
                            _currentLanguage = _configData['supportedLanguages']
                                [_languageFull];
                          });
                        }

                        // if (_languageFull == "Español") {
                        //   setState(() {
                        //     _currentLanguage = "es";
                        //   });
                        // } else if (value == "Deutsch") {
                        //   setState(() {
                        //     _currentLanguage = "de";
                        //   });
                        // } else if (value == "Français") {
                        //   setState(() {
                        //     _currentLanguage = "fr";
                        //   });
                        // } else if (value == "English") {
                        //   setState(() {
                        //     _currentLanguage = "en";
                        //   });
                        // } else {
                        //   setState(() {
                        //     _currentLanguage = "tr";
                        //   });
                        // }

                        print(_currentLanguage);
                      }),
                ),
                RawMaterialButton(
                    fillColor: Color.fromARGB(255, 33, 39, 120),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0))),
                    splashColor: Color(0xff77A830),
                    textStyle: TextStyle(color: Colors.white),
                    child: Text("Play",
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 15,
                          fontFamily: 'Times New Roman',
                          // fontWeight: FontWeight.bold
                        )),
                    onPressed: () async {
                      await wordPickForPlay();
                      print(_wordsForPlay);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => PlayPage(
                                    wordsForPlay: _wordsForPlay,
                                  )));
                    }),
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
                          widget.userID, "Anonym");
                      box.put("DBId", 0);
                      box.put("WordPool", {});

                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => CheckAuth()),
                          (Route<dynamic> route) => false);
                    }),
              ],
            ),
            Visibility(
              visible: _userDataLoadScreen,
              child: Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                    child: Container(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Center(
                    child: Container(
                      child: Lottie.asset(
                          // "https://assets5.lottiefiles.com/private_files/lf30_ijwulw45.json"
                          "assets/json/loading.json"),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
