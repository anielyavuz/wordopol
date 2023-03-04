import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:wordopol/pages/checkAuth.dart';
import 'package:wordopol/pages/playPage.dart';
import 'package:wordopol/services/authFunctions.dart';
import 'package:wordopol/services/firebaseFunctions.dart';
import 'package:wordopol/services/notificationService.dart';

class HomePage extends StatefulWidget {
  final String userID;

  //Note: statefull'a parametre göndermek için gerekli
  const HomePage({Key? key, required this.userID}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box box;
  NotificationsServices notificationsServices = NotificationsServices();

  var _userInfo;
  var _scoreTable;
  var _configData;
  AuthService _authService = AuthService();
  bool _userDataLoadScreen = true;
  var _languageSelectedBefore;
  var _wordPool;
  var _wordPoolData;

  var _languageFull = "English";
  int _todayNumber = 100;
  List _todayGames = [
    TimeOfDay(hour: 0, minute: 05),
    TimeOfDay(hour: 12, minute: 30),
    TimeOfDay(hour: 23, minute: 50)
  ];
  final Color _yaziTipiRengi = Color(0xffE4EBDE);
  String _currentLanguage = "en";
  List _wordsForPlay1 = [];
  List _wordsForPlay2 = [];
  List _wordsForPlay3 = [];
  List _wordsForPlay4 = [];
  List _wordsForPlay5 = [];
  List _wordsForPlay6 = [];
  List _todayQuestions = [];
  Map _languageDropdown = {
    'Türkçe': 'tr',
    'Español': 'es',
    'Deutsch': 'de',
    'Français': 'fr',
    'English': 'en'
  };
  Map _completedGames = {};
  bool _Game1Completed = false;
  bool _Game2Completed = false;
  bool _Game3Completed = false;
  bool _Game4Completed = false;
  bool _Game5Completed = false;
  bool _Game6Completed = false;

  completedGames() {
    // print("Completed Games:  $_completedGames");
    if (_completedGames[_todayNumber] != null) {
      if (_completedGames[_todayNumber][1] != null) {
        setState(() {
          _Game1Completed = _completedGames[_todayNumber][1];
        });
      }
      if (_completedGames[_todayNumber][2] != null) {
        setState(() {
          _Game2Completed = _completedGames[_todayNumber][2];
        });
      }
      if (_completedGames[_todayNumber][3] != null) {
        setState(() {
          _Game3Completed = _completedGames[_todayNumber][3];
        });
      }
      // if (_completedGames[_todayNumber][4] != null) {
      //   setState(() {
      //     _Game4Completed = _completedGames[_todayNumber][4];
      //   });
      // }
      // if (_completedGames[_todayNumber][5] != null) {
      //   setState(() {
      //     _Game5Completed = _completedGames[_todayNumber][5];
      //   });
      // }
      // if (_completedGames[_todayNumber][6] != null) {
      //   setState(() {
      //     _Game6Completed = _completedGames[_todayNumber][6];
      //   });
      // }
    }
  }

  dayOfToday() {
    var now = DateTime.now();
    var dayOfYear = now.difference(DateTime(1, 1, 1)).inDays + 1;
    // print("Bugün yılın $dayOfYear. günüdür.");
    return dayOfYear;
  }

  groupOfWords() {
    _todayNumber = dayOfToday();

    var map = _wordPoolData[_currentLanguage];
    List _4lerMap = [];
    List _5lerMap = [];
    List _6larMap = [];

    // Random rnd4ler;
    // int min = 0;
    // int max = _4lerMap.length;
    // rnd4ler = new Random();
    // var r = min + rnd4ler.nextInt(max - min);
    // print("$r is in the range of $min and $max");

    map.forEach((k, v) {
      if (v['_letterNumber'] == "4") {
        _4lerMap.add(map[k]);
      } else if (v['_letterNumber'] == "5") {
        _5lerMap.add(map[k]);
      } else if (v['_letterNumber'] == "6") {
        _6larMap.add(map[k]);
      }
    });
    _wordsForPlay1.add(_4lerMap[_todayNumber % _4lerMap.length]);
    _wordsForPlay1.add(_5lerMap[_todayNumber % _5lerMap.length]);
    _wordsForPlay1.add(_6larMap[_todayNumber % _6larMap.length]);

    _wordsForPlay2.add(_4lerMap[(_todayNumber + (47)) % _4lerMap.length]);
    _wordsForPlay2.add(_5lerMap[(_todayNumber + (47)) % _5lerMap.length]);
    _wordsForPlay2.add(_6larMap[(_todayNumber + (47)) % _6larMap.length]);

    _wordsForPlay3.add(_4lerMap[(_todayNumber + (67)) % _4lerMap.length]);
    _wordsForPlay3.add(_5lerMap[(_todayNumber + (67)) % _5lerMap.length]);
    _wordsForPlay3.add(_6larMap[(_todayNumber + (67)) % _6larMap.length]);

    _wordsForPlay4.add(_4lerMap[(_todayNumber + (97)) % _4lerMap.length]);
    _wordsForPlay4.add(_5lerMap[(_todayNumber + (97)) % _5lerMap.length]);
    _wordsForPlay4.add(_6larMap[(_todayNumber + (97)) % _6larMap.length]);

    _wordsForPlay5.add(_4lerMap[(_todayNumber + (137)) % _4lerMap.length]);
    _wordsForPlay5.add(_5lerMap[(_todayNumber + (137)) % _5lerMap.length]);
    _wordsForPlay5.add(_6larMap[(_todayNumber + (137)) % _6larMap.length]);

    _wordsForPlay6.add(_4lerMap[(_todayNumber + (167)) % _4lerMap.length]);
    _wordsForPlay6.add(_5lerMap[(_todayNumber + (167)) % _5lerMap.length]);
    _wordsForPlay6.add(_6larMap[(_todayNumber + (167)) % _6larMap.length]);
  }

  languageSelect()
  //telefonun native dili eğer desteklenen dillerdense dropdown'da o gelir

  {
    if (_configData != null) {
      if (_configData['supportedLanguages'] != null) {
        setState(() {
          _languageDropdown = _configData['supportedLanguages'];
        });
      }
    }

    // if (_configData['supportedLanguages']
    //     .values
    //     .contains(Localizations.localeOf(context).languageCode.toString())) {
    //   print("yes");
    //   setState(() {
    //     _currentLanguage =
    //         Localizations.localeOf(context).languageCode.toString();
    //   });
    // }

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
    // print(_currentLanguage);

    // print((_languageFull));
  }

  wordDBSyncFunction() async {
    _userInfo = await CloudDB().getUserInfo(widget.userID);
    _configData = await CloudDB().getConfigDatas();
    _scoreTable =
        await CloudDB().getScoreTable(_configData['ScoreTableSeason']);
    // print("KKKKKKKKK");
    // print(_configData);

    var _DBId = box.get("DBId") ?? 0;
    _currentLanguage = box.get("languageSelectedBefore") ?? "en";
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
    _completedGames = box.get("CompletedGames") ??
        {
          1: {1: false}
        };
    completedGames(); //tamamlanan günlerin atamaları ilgili değişkenler için yapılır.
    print(_DBId);
    groupOfWords();
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
    listenToNotification(); //payload için
    notificationsServices.initialiseNotifications();
    // groupOfWords();
  }

  void listenToNotification() =>
      notificationsServices.onNotificationClick.stream
          .listen(onNotificationListener);

  void onNotificationListener(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      //print('payload $payload');

      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => BePremiumUser()));
    }
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
                Expanded(
                  child: Container(
                      child: Center(
                          child: Text("Welcome"

                              // _wordPoolData[_currentLanguage].toString()

                              ))),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: DropdownButton<String>(
                        dropdownColor: Color(0xff010114).withOpacity(1),
                        value: _languageFull,
                        items: _languageDropdown.keys
                            .toList()
                            .map((dynamic value) {
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
                              _currentLanguage =
                                  _configData['supportedLanguages']
                                      [_languageFull];
                              box.put(
                                  "languageSelectedBefore", _currentLanguage);
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
                ),
                // RawMaterialButton(
                //     fillColor: Color.fromARGB(255, 33, 39, 120),
                //     shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.all(Radius.circular(15.0))),
                //     splashColor: Color(0xff77A830),
                //     textStyle: TextStyle(color: Colors.white),
                //     child: Text("Play",
                //         style: TextStyle(
                //           color: Colors.amber,
                //           fontSize: 15,
                //           fontFamily: 'Times New Roman',
                //           // fontWeight: FontWeight.bold
                //         )),
                //     onPressed: () async {
                //       await wordPickForPlay();
                //       print(_wordsForPlay);
                //       Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (BuildContext context) => PlayPage(
                //                     wordsForPlay: _wordsForPlay,
                //                     userName: _userInfo['userName'],
                //                     uid: _userInfo['id'],
                //                     point: _scoreTable[_userInfo['id'] +
                //                         "%" +
                //                         _userInfo['userName']],
                //                     seasonNumber:
                //                         _configData['ScoreTableSeason'],
                //                   )));
                //     }),

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
                      box.put("CompletedGames", {});

                      // var a = await _authService.signOutAndDeleteUser(
                      //     widget.userID,
                      //     "Anonym",
                      //     _userInfo['userName'],
                      //     _configData['ScoreTableSeason']);
                      // box.put("DBId", 0);
                      // box.put("WordPool", {});

                      // Navigator.pushAndRemoveUntil(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (BuildContext context) => CheckAuth()),
                      //     (Route<dynamic> route) => false);
                    }),
                Expanded(
                  child: Container(
                    // width:
                    //     MediaQuery.of(context).size.width *
                    //         3 /
                    //         5,
                    height: 200,
                    // width: 50,

                    child: ListView.builder(
                        itemCount: _todayGames.length,
                        itemBuilder: (context, index2) {
                          // print(_kaydirmaNoktalari);
                          return Container(
                            width: MediaQuery.of(context).size.width / 3,
                            child: RawMaterialButton(
                                // fillColor: _yaziTipiRengi,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: TimeOfDay.now().hour >
                                                _todayGames[index2].hour
                                            ? Color(0xff77A830)
                                            : TimeOfDay.now().hour ==
                                                    _todayGames[index2].hour
                                                ? TimeOfDay.now().minute >=
                                                        _todayGames[index2]
                                                            .minute
                                                    ? Color(0xff77A830)
                                                    : Color.fromARGB(
                                                        255, 168, 76, 48)
                                                : Color.fromARGB(
                                                    255, 168, 76, 48)),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(15.0))),
                                // splashColor: Colors.green,
                                textStyle: TextStyle(color: Colors.black),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Oyun " + (index2 + 1).toString(),
                                          style: GoogleFonts.publicSans(
                                              // fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black)),
                                      Row(
                                        children: [
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () {},
                                            child: Icon(
                                              TimeOfDay.now().hour >
                                                      _todayGames[index2].hour
                                                  ? (_completedGames[
                                                              _todayNumber] !=
                                                          null
                                                      ? (_completedGames[_todayNumber]
                                                                  [
                                                                  index2 + 1] ==
                                                              true
                                                          ? Icons.check
                                                          : Icons.pending)
                                                      : Icons.pending)
                                                  : TimeOfDay.now().hour ==
                                                          _todayGames[index2]
                                                              .hour
                                                      ? TimeOfDay.now().minute >=
                                                              _todayGames[index2]
                                                                  .minute
                                                          ? (_completedGames[
                                                                      _todayNumber] !=
                                                                  null
                                                              ? (_completedGames[_todayNumber]
                                                                          [index2 + 1] ==
                                                                      true
                                                                  ? Icons.check
                                                                  : Icons.pending)
                                                              : Icons.pending)
                                                          : Icons.lock
                                                      : Icons.lock,
                                              size: 25,
                                              color: TimeOfDay.now().hour >
                                                      _todayGames[index2].hour
                                                  ? Color(0xff77A830)
                                                  : TimeOfDay.now().hour ==
                                                          _todayGames[index2]
                                                              .hour
                                                      ? TimeOfDay.now()
                                                                  .minute >=
                                                              _todayGames[
                                                                      index2]
                                                                  .minute
                                                          ? Color(0xff77A830)
                                                          : Color.fromARGB(
                                                              255, 168, 76, 48)
                                                      : Color.fromARGB(
                                                          255, 168, 76, 48),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Visibility(
                                            visible: TimeOfDay.now().hour >
                                                    _todayGames[index2].hour
                                                ? false
                                                : TimeOfDay.now().hour ==
                                                        _todayGames[index2].hour
                                                    ? TimeOfDay.now().minute >=
                                                            _todayGames[index2]
                                                                .minute
                                                        ? false
                                                        : true
                                                    : true,
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () {},
                                              child: Icon(
                                                Icons.notifications_active,
                                                size: 25,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {},
                                            child: Text(
                                                _todayGames[index2]
                                                    .format(context),
                                                style: GoogleFonts.publicSans(
                                                    // fontWeight: FontWeight.bold,
                                                    fontSize: 25,
                                                    color: Colors.black)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                onPressed: () {
                                  String _check = "vakitGeldi";

                                  if (TimeOfDay.now().hour >
                                      _todayGames[index2].hour) {
                                    _check = "vakitGeldi";
                                  } else {
                                    if (TimeOfDay.now().hour ==
                                        _todayGames[index2].hour) {
                                      if (TimeOfDay.now().minute >=
                                          _todayGames[index2].minute) {
                                        _check = "vakitGeldi";
                                      } else {
                                        _check = "vakitGelmedi";
                                      }
                                    } else {
                                      _check = "vakitGelmedi";
                                    }
                                  }

                                  if (_completedGames[_todayNumber] != null) {
                                    if (_completedGames[_todayNumber]
                                            [index2 + 1] ==
                                        true) {
                                      _check = "oyunTamamlandi";
                                    }
                                  }

                                  if (_check == "vakitGeldi") {
                                    if (_completedGames[_todayNumber] == null) {
                                      _completedGames[_todayNumber] = {};
                                    }
                                    _completedGames[_todayNumber][index2 + 1] =
                                        true;
                                    box.put("CompletedGames", _completedGames);
                                    if (index2 == 0) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  PlayPage(
                                                    wordsForPlay:
                                                        _wordsForPlay1,
                                                    userName:
                                                        _userInfo['userName'],
                                                    uid: _userInfo['id'],
                                                    point: _scoreTable[
                                                        _userInfo['id'] +
                                                            "%" +
                                                            _userInfo[
                                                                'userName']],
                                                    seasonNumber: _configData[
                                                        'ScoreTableSeason'],
                                                  )));
                                    } else if (index2 == 1) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  PlayPage(
                                                    wordsForPlay:
                                                        _wordsForPlay2,
                                                    userName:
                                                        _userInfo['userName'],
                                                    uid: _userInfo['id'],
                                                    point: _scoreTable[
                                                        _userInfo['id'] +
                                                            "%" +
                                                            _userInfo[
                                                                'userName']],
                                                    seasonNumber: _configData[
                                                        'ScoreTableSeason'],
                                                  )));
                                    } else if (index2 == 2) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  PlayPage(
                                                    wordsForPlay:
                                                        _wordsForPlay3,
                                                    userName:
                                                        _userInfo['userName'],
                                                    uid: _userInfo['id'],
                                                    point: _scoreTable[
                                                        _userInfo['id'] +
                                                            "%" +
                                                            _userInfo[
                                                                'userName']],
                                                    seasonNumber: _configData[
                                                        'ScoreTableSeason'],
                                                  )));
                                    }
                                  } else if (_check == "oyunTamamlandi") {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: Duration(milliseconds: 2000),
                                        content: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text("Bu oyunu oynadınız..."),
                                          ],
                                        ),
                                        // action: SnackBarAction(
                                        //   label: "Be a Premium User",
                                        //   onPressed: () {
                                        //     Navigator.push(
                                        //         context,
                                        //         MaterialPageRoute(
                                        //             builder: (context) =>
                                        //                 BePremiumUser()));
                                        //   },
                                        // )
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: Duration(milliseconds: 2000),
                                        content: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                                "Bu oyun için zaman henüz gelmedi"),
                                          ],
                                        ),
                                        // action: SnackBarAction(
                                        //   label: "Be a Premium User",
                                        //   onPressed: () {
                                        //     Navigator.push(
                                        //         context,
                                        //         MaterialPageRoute(
                                        //             builder: (context) =>
                                        //                 BePremiumUser()));
                                        //   },
                                        // )
                                      ),
                                    );
                                  }
                                }),
                          );
                        }),
                  ),
                ),
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
