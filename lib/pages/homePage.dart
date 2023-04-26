import 'dart:collection';
import 'dart:math';
import 'dart:ui';
import 'package:timezone/timezone.dart' as tz;
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
import 'package:wordopol/services/langeuages.dart';
import 'package:wordopol/services/notificationService.dart';
import 'package:collection/collection.dart';
import 'package:wordopol/services/speechService.dart';

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
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  final Color _yaziTipiRengi = Color(0xffE4EBDE);
  final Color _backgroudRengi = Color.fromRGBO(21, 9, 35, 1);
  var _userInfo;
  var _scoreTable;
  var _scoreTable2;
  var _configData;
  AuthService _authService = AuthService();
  bool _userDataLoadScreen = true;
  var _languageSelectedBefore;
  var _wordPool;
  var _wordPoolData;
  Map _winners = {};
  var _languageFull = "English";
  int _todayNumber = 100;
  List _todayGames = [
    TimeOfDay(hour: 08, minute: 30),
    TimeOfDay(hour: 12, minute: 30),
    TimeOfDay(hour: 20, minute: 30)
  ];

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

  LanguageService _languageService = LanguageService();
  String _lanWelcome = "";
  String _lanLeaderboard = "";
  String _lanSignOut = "";
  String _lanGame = "";
  String _lanLastChamp = "";
  languageService(String _lan) {
    // _lanWelcome = _languageService.homePageWelcomeLangueages(_lan);
    // _lanLeaderboard = _languageService.homePageLeaderboardLangueages(_lan);

    // _lanSignOut = _languageService.homePageSignOutLangueages(_lan);
    List _allLangueages = _languageService.homePageLanguages(_lan);
    _lanWelcome = _allLangueages[0];
    _lanLeaderboard = _allLangueages[1];
    _lanSignOut = _allLangueages[2];
    _lanGame = _allLangueages[3];
    _lanLastChamp = _allLangueages[4];
  }

  notificationCheck() {
    if (!DeepCollectionEquality().equals(_winners, _configData['winners'])) {
      var _key = "";
      for (_key in _configData['winners'].keys) {
        print(_key);
      }
      var _lastChamp = _configData['winners'][_key];
      print("Aa $_lastChamp");

      notificationsServices.sendNotifications(
          "Wordopol🎯", "$_lanLastChamp $_lastChamp 😎🏆");
      box.put("winners", _configData['winners']);
    }

    print(_configData['winners']);
  }

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

  testFunctionDeleteLater() {}

  groupOfWords() {
    _todayNumber = dayOfToday();

    var map = _wordPoolData[_currentLanguage];
    List _4lerMap = [];
    List _5lerMap = [];
    List _6larMap = [];
    List _7lerMap = [];
    List _8lerMap = [];

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
      } else if (v['_letterNumber'] == "7") {
        _7lerMap.add(map[k]);
      } else if (v['_letterNumber'] == "8") {
        _8lerMap.add(map[k]);
      }
    });

    // print("_todayNumber $_todayNumber");
    // print("_4lerMap.length " + _4lerMap.length.toString());

    _wordsForPlay1
        .add(_4lerMap[((_todayNumber % 738615) * 12) % _4lerMap.length]);
    _wordsForPlay1
        .add(_4lerMap[((_todayNumber % 738615) * 12) + 1 % _4lerMap.length]);
    _wordsForPlay1
        .add(_5lerMap[((_todayNumber % 738615) * 12) % _5lerMap.length]);
    _wordsForPlay1
        .add(_5lerMap[((_todayNumber % 738615) * 12) + 1 % _5lerMap.length]);
    _wordsForPlay1
        .add(_6larMap[((_todayNumber % 738615) * 12) % _6larMap.length]);
    _wordsForPlay1
        .add(_6larMap[((_todayNumber % 738615) * 12) + 1 % _6larMap.length]);
    _wordsForPlay1
        .add(_7lerMap[((_todayNumber % 738615) * 12) % _7lerMap.length]);
    _wordsForPlay1
        .add(_7lerMap[((_todayNumber % 738615) * 12) + 1 % _7lerMap.length]);
    _wordsForPlay1
        .add(_8lerMap[((_todayNumber % 738615) * 12) % _8lerMap.length]);
    _wordsForPlay1
        .add(_8lerMap[((_todayNumber % 738615) * 12) + 1 % _8lerMap.length]);

    _wordsForPlay2
        .add(_4lerMap[((_todayNumber % 738615) * 12) + 2 % _4lerMap.length]);
    _wordsForPlay2
        .add(_4lerMap[((_todayNumber % 738615) * 12) + 3 % _4lerMap.length]);
    _wordsForPlay2
        .add(_5lerMap[((_todayNumber % 738615) * 12) + 2 % _5lerMap.length]);
    _wordsForPlay2
        .add(_5lerMap[((_todayNumber % 738615) * 12) + 3 % _5lerMap.length]);
    _wordsForPlay2
        .add(_6larMap[((_todayNumber % 738615) * 12) + 2 % _6larMap.length]);
    _wordsForPlay2
        .add(_6larMap[((_todayNumber % 738615) * 12) + 3 % _6larMap.length]);
    _wordsForPlay2
        .add(_7lerMap[((_todayNumber % 738615) * 12) + 2 % _7lerMap.length]);
    _wordsForPlay2
        .add(_7lerMap[((_todayNumber % 738615) * 12) + 3 % _7lerMap.length]);
    _wordsForPlay2
        .add(_8lerMap[((_todayNumber % 738615) * 12) + 2 % _8lerMap.length]);
    _wordsForPlay2
        .add(_8lerMap[((_todayNumber % 738615) * 12) + 3 % _8lerMap.length]);

    _wordsForPlay3
        .add(_4lerMap[((_todayNumber % 738615) * 12) + 4 % _4lerMap.length]);
    _wordsForPlay3
        .add(_4lerMap[((_todayNumber % 738615) * 12) + 5 % _4lerMap.length]);
    _wordsForPlay3
        .add(_5lerMap[((_todayNumber % 738615) * 12) + 4 % _5lerMap.length]);
    _wordsForPlay3
        .add(_5lerMap[((_todayNumber % 738615) * 12) + 5 % _5lerMap.length]);
    _wordsForPlay3
        .add(_6larMap[((_todayNumber % 738615) * 12) + 4 % _6larMap.length]);
    _wordsForPlay3
        .add(_6larMap[((_todayNumber % 738615) * 12) + 5 % _6larMap.length]);
    _wordsForPlay3
        .add(_7lerMap[((_todayNumber % 738615) * 12) + 4 % _7lerMap.length]);
    _wordsForPlay3
        .add(_7lerMap[((_todayNumber % 738615) * 12) + 5 % _7lerMap.length]);
    _wordsForPlay3
        .add(_8lerMap[((_todayNumber % 738615) * 12) + 4 % _8lerMap.length]);
    _wordsForPlay3
        .add(_8lerMap[((_todayNumber % 738615) * 12) + 5 % _8lerMap.length]);

    _wordsForPlay4
        .add(_4lerMap[((_todayNumber % 738615) * 12) + 6 % _4lerMap.length]);
    _wordsForPlay4
        .add(_4lerMap[((_todayNumber % 738615) * 12) + 7 % _4lerMap.length]);
    _wordsForPlay4
        .add(_5lerMap[((_todayNumber % 738615) * 12) + 6 % _5lerMap.length]);
    _wordsForPlay4
        .add(_5lerMap[((_todayNumber % 738615) * 12) + 7 % _5lerMap.length]);
    _wordsForPlay4
        .add(_6larMap[((_todayNumber % 738615) * 12) + 6 % _6larMap.length]);
    _wordsForPlay4
        .add(_6larMap[((_todayNumber % 738615) * 12) + 7 % _6larMap.length]);
    _wordsForPlay4
        .add(_7lerMap[((_todayNumber % 738615) * 12) + 6 % _7lerMap.length]);
    _wordsForPlay4
        .add(_7lerMap[((_todayNumber % 738615) * 12) + 7 % _7lerMap.length]);
    _wordsForPlay4
        .add(_8lerMap[((_todayNumber % 738615) * 12) + 6 % _8lerMap.length]);
    _wordsForPlay4
        .add(_8lerMap[((_todayNumber % 738615) * 12) + 7 % _8lerMap.length]);

    _wordsForPlay5
        .add(_4lerMap[((_todayNumber % 738615) * 12) + 8 % _4lerMap.length]);
    _wordsForPlay5
        .add(_4lerMap[((_todayNumber % 738615) * 12) + 9 % _4lerMap.length]);
    _wordsForPlay5
        .add(_5lerMap[((_todayNumber % 738615) * 12) + 8 % _5lerMap.length]);
    _wordsForPlay5
        .add(_5lerMap[((_todayNumber % 738615) * 12) + 9 % _5lerMap.length]);
    _wordsForPlay5
        .add(_6larMap[((_todayNumber % 738615) * 12) + 8 % _6larMap.length]);
    _wordsForPlay5
        .add(_6larMap[((_todayNumber % 738615) * 12) + 9 % _6larMap.length]);
    _wordsForPlay5
        .add(_7lerMap[((_todayNumber % 738615) * 12) + 8 % _7lerMap.length]);
    _wordsForPlay5
        .add(_7lerMap[((_todayNumber % 738615) * 12) + 9 % _7lerMap.length]);
    _wordsForPlay5
        .add(_8lerMap[((_todayNumber % 738615) * 12) + 8 % _8lerMap.length]);
    _wordsForPlay5
        .add(_8lerMap[((_todayNumber % 738615) * 12) + 9 % _8lerMap.length]);

    _wordsForPlay6
        .add(_4lerMap[((_todayNumber % 738615) * 12) + 10 % _4lerMap.length]);
    _wordsForPlay6
        .add(_4lerMap[((_todayNumber % 738615) * 12) + 11 % _4lerMap.length]);
    _wordsForPlay6
        .add(_5lerMap[((_todayNumber % 738615) * 12) + 10 % _5lerMap.length]);
    _wordsForPlay6
        .add(_5lerMap[((_todayNumber % 738615) * 12) + 11 % _5lerMap.length]);
    _wordsForPlay6
        .add(_6larMap[((_todayNumber % 738615) * 12) + 10 % _6larMap.length]);
    _wordsForPlay6
        .add(_6larMap[((_todayNumber % 738615) * 12) + 11 % _6larMap.length]);
    _wordsForPlay6
        .add(_7lerMap[((_todayNumber % 738615) * 12) + 10 % _7lerMap.length]);
    _wordsForPlay6
        .add(_7lerMap[((_todayNumber % 738615) * 12) + 11 % _7lerMap.length]);
    _wordsForPlay6
        .add(_8lerMap[((_todayNumber % 738615) * 12) + 10 % _8lerMap.length]);
    _wordsForPlay6
        .add(_8lerMap[((_todayNumber % 738615) * 12) + 11 % _8lerMap.length]);

    // _wordsForPlay1.add(_4lerMap[_todayNumber % _4lerMap.length]);
    // _wordsForPlay1.add(_5lerMap[_todayNumber % _5lerMap.length]);
    // _wordsForPlay1.add(_6larMap[_todayNumber % _6larMap.length]);
    // _wordsForPlay1.add(_7lerMap[_todayNumber % _7lerMap.length]);
    // _wordsForPlay1.add(_8lerMap[_todayNumber % _8lerMap.length]);

    // _wordsForPlay2.add(_4lerMap[(_todayNumber + (47)) % _4lerMap.length]);
    // _wordsForPlay2.add(_5lerMap[(_todayNumber + (47)) % _5lerMap.length]);
    // _wordsForPlay2.add(_6larMap[(_todayNumber + (47)) % _6larMap.length]);
    // _wordsForPlay2.add(_7lerMap[(_todayNumber + (47)) % _7lerMap.length]);
    // _wordsForPlay2.add(_8lerMap[(_todayNumber + (47)) % _8lerMap.length]);

    // _wordsForPlay3.add(_4lerMap[(_todayNumber + (67)) % _4lerMap.length]);
    // _wordsForPlay3.add(_5lerMap[(_todayNumber + (67)) % _5lerMap.length]);
    // _wordsForPlay3.add(_6larMap[(_todayNumber + (67)) % _6larMap.length]);
    // _wordsForPlay3.add(_7lerMap[(_todayNumber + (67)) % _7lerMap.length]);
    // _wordsForPlay3.add(_8lerMap[(_todayNumber + (67)) % _8lerMap.length]);

    // _wordsForPlay4.add(_4lerMap[(_todayNumber + (97)) % _4lerMap.length]);
    // _wordsForPlay4.add(_5lerMap[(_todayNumber + (97)) % _5lerMap.length]);
    // _wordsForPlay4.add(_6larMap[(_todayNumber + (97)) % _6larMap.length]);
    // _wordsForPlay4.add(_7lerMap[(_todayNumber + (97)) % _7lerMap.length]);
    // _wordsForPlay4.add(_8lerMap[(_todayNumber + (97)) % _8lerMap.length]);

    // _wordsForPlay5.add(_4lerMap[(_todayNumber + (137)) % _4lerMap.length]);
    // _wordsForPlay5.add(_5lerMap[(_todayNumber + (137)) % _5lerMap.length]);
    // _wordsForPlay5.add(_6larMap[(_todayNumber + (137)) % _6larMap.length]);
    // _wordsForPlay5.add(_7lerMap[(_todayNumber + (137)) % _7lerMap.length]);
    // _wordsForPlay5.add(_8lerMap[(_todayNumber + (137)) % _8lerMap.length]);

    // _wordsForPlay6.add(_4lerMap[(_todayNumber + (167)) % _4lerMap.length]);
    // _wordsForPlay6.add(_5lerMap[(_todayNumber + (167)) % _5lerMap.length]);
    // _wordsForPlay6.add(_6larMap[(_todayNumber + (167)) % _6larMap.length]);
    // _wordsForPlay6.add(_7lerMap[(_todayNumber + (167)) % _7lerMap.length]);
    // _wordsForPlay6.add(_8lerMap[(_todayNumber + (167)) % _8lerMap.length]);
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
    languageService(_currentLanguage);
  }

  scoreTableGetFunction() async {
    _scoreTable =
        await CloudDB().getScoreTable(_configData['ScoreTableSeason']);

    _scoreTable2 = await SplayTreeMap.from(_scoreTable,
        (key1, key2) => _scoreTable[key2].compareTo(_scoreTable[key1]));
  }

  wordDBSyncFunction() async {
    _userInfo = await CloudDB().getUserInfo(widget.userID);
    _configData = await CloudDB().getConfigDatas();
    scoreTableGetFunction();

    // print("KKKKKKKKK");
    // print(_configData);

    var _DBId = box.get("DBId") ?? 0;
    _currentLanguage = box.get("languageSelectedBefore") ?? "en";
    _winners = box.get("winners") ?? {"1": "Elo"};
    Future.delayed(const Duration(milliseconds: 1000), () {
      notificationCheck();
    });

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
  void listenToNotification() =>
      notificationsServices.onNotificationClick.stream
          .listen(onNotificationListener);

  void onNotificationListener(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      //print('payload $payload');

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CheckAuth()));
    }
  }

  notificaitonMap() {
    notificationsServices.stopNotifications();
    int _notificaitonID = 0;
    if (DateTime.now()
        .difference(DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 20, 30))
        .isNegative) {
      if (_completedGames[_todayNumber] != null) {
        if (_completedGames[_todayNumber].keys.length < 3) {
          DateTime _dt = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            20,
            30,
            DateTime.now().add(Duration(seconds: 10)).second,
          );
          // print(_dt);
          var tzdatetime = tz.TZDateTime.from(_dt, tz.local);
          notificationsServices.sendScheduledNotifications2(
              _notificaitonID,
              "Wordopol🎯",
              "Bugünkü kelimelerini tamamlayıp sıralamada yükselmek ister misin?",
              // _startTime.hour.toString() +
              //     ":0" +
              //     _startTime.minute.toString(),
              tzdatetime);
          _notificaitonID++;
          // print("Bugüne bildirim göndericem3");
        }
      }
    }

    for (var i = 1; i < 10; i++) {
      DateTime _dt = DateTime.now().add(Duration(days: i));

      var timeNew = new DateTime(_dt.year, _dt.month, _dt.day, 20, 00,
          _dt.second, _dt.millisecond, _dt.microsecond);
      // print(timeNew);
      var tzdatetime = tz.TZDateTime.from(timeNew, tz.local);

      notificationsServices.sendScheduledNotifications2(
          _notificaitonID,
          "Wordopol🎯",
          "Bugünkü kelimelerini tamamlayıp sıralamada yükselmek ister misin?",
          // _startTime.hour.toString() +
          //     ":0" +
          //     _startTime.minute.toString(),
          tzdatetime);
      _notificaitonID++;
    }

    ////ABC
  }

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
    Future.delayed(const Duration(milliseconds: 2500), () {
      notificaitonMap();
    });
    notificationsServices.initialiseNotifications();
    // groupOfWords();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          key: _scaffoldState,
          drawer: Drawer(
              backgroundColor: _yaziTipiRengi,
              child: Container(
                child: Column(
                  children: [
                    UserAccountsDrawerHeader(
                      accountName: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("_todayText",
                              style: GoogleFonts.publicSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: _backgroudRengi)),
                          Column(
                            children: [
                              Text("asd",
                                  style: TextStyle(
                                    color: _backgroudRengi,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    // fontFamily: 'Times New Roman'
                                  )),
                            ],
                          ),
                        ],
                      ),
                      currentAccountPicture: GestureDetector(
                          onTap: () {
                            // uploadImage();
                            // //profil fotosunun yenileneceği alan burası
                          },
                          child: Stack(
                            children: [
                              // CircleAvatar(
                              //   backgroundColor: Colors.transparent,
                              //   backgroundImage: _photo,
                              //   // child: ClipOval(
                              //   //   child: _photo,
                              //   // )
                              // ),
                              // Center(child: Icon(Icons.add_a_photo_rounded))
                            ],
                          )),
                      decoration: BoxDecoration(
                        color: _backgroudRengi,
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage("assets/images/kapak.jpg")),
                      ),
                      accountEmail: null,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Visibility(
                                visible: true,
                                child: ListTile(
                                  leading: Icon(Icons.analytics),
                                  title: InkWell(
                                    onTap: () async {},
                                    child: Container(
                                      child: Text("Analytics",
                                          style: GoogleFonts.publicSans(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                              color: _backgroudRengi)),
                                    ),
                                  ),
                                ),
                              ),

                              Visibility(
                                visible: true,
                                child: ListTile(
                                  leading: Icon(Icons.voicemail),
                                  title: InkWell(
                                    onTap: () async {},
                                    child: Container(
                                      child: Text("Audio Test",
                                          style: GoogleFonts.publicSans(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                              color: _backgroudRengi)),
                                    ),
                                  ),
                                ),
                              ),

                              _userInfo != null
                                  ? _userInfo['userName'] == "Guest"
                                      ? ListTile(
                                          leading: Icon(Icons.person),
                                          title: InkWell(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {},
                                            child: Container(
                                              child: Text("_signIn",
                                                  style: GoogleFonts.publicSans(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 18,
                                                      color: _backgroudRengi)),
                                            ),
                                          ),
                                        )
                                      : ListTile(
                                          leading: CircleAvatar(
                                              backgroundColor:
                                                  Colors.black.withOpacity(0),
                                              backgroundImage: NetworkImage(
                                                  _userInfo['photoUrl'])),
                                          title: InkWell(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {},
                                            child: Container(
                                              child: Text(_userInfo['userName'],
                                                  style: GoogleFonts.publicSans(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 18,
                                                      color: _backgroudRengi)),
                                            ),
                                          ),
                                        )
                                  : SizedBox(),

                              // ListTile(
                              //   leading:
                              //       Icon(Icons.notification_important_rounded),
                              //   title: InkWell(
                              //     splashColor: Colors.transparent,
                              //     highlightColor: Colors.transparent,
                              //     onTap: () async {
                              //       //print(DateFormat('dd/MM/yyyy - HH:mm:ss')
                              //           .format(DateTime.now())
                              //           .toString());

                              //       // //print(_configsInfo.docs[_configsInfoInteger]
                              //       //     ['Social']);
                              //       // // //print(_todayText);
                              //       // // notificationsServices
                              //       // //     .specificTimeNotification(
                              //       // //         "KiWi🥝", "Yoga zamanı 💁", 0, 5);

                              //       // //////////BURASI ÖNEMLİ////////////
                              //       // notificationsServices.sendNotifications(
                              //       //     "KiWi🥝", "Yoga zamanı 💁");

                              //       // notificationsServices
                              //       //     .sendPayloadNotifications(
                              //       //         0,
                              //       //         "KiWi🥝",
                              //       //         "Premium ol 💁",
                              //       //         "payload navigationnnnn");
                              //       // DateTime dt = DateTime.now().add(Duration(
                              //       //     seconds:
                              //       //         5)); //Or whatever DateTime you want
                              //       // var tzdatetime = tz.TZDateTime.from(dt,
                              //       //     tz.local); //could be var instead of final
                              //       // // notificationsServices
                              //       // //     .sendScheduledNotifications2(
                              //       // //         0, "Swim", "20:05", tzdatetime);
                              //       // notificationsServices.stopNotifications();

                              //       //////////BURASI ÖNEMLİ////////////
                              //     },
                              //     child: Container(
                              //       child: Text("Notifications Test",
                              //           style: GoogleFonts.publicSans(
                              //               fontWeight: FontWeight.w600,
                              //               fontSize: 18,
                              //               color: _backgroudRengi)),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Version: ",
                                        style: GoogleFonts.publicSans(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: _backgroudRengi)),
                                    Text(
                                        _userInfo != null
                                            ? _userInfo['id']
                                            : "",
                                        style: GoogleFonts.publicSans(
                                            fontWeight: FontWeight.w200,
                                            fontSize: 8,
                                            color: _backgroudRengi))
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 0, 0, 20.0),
                                child: Column(
                                  children: [
                                    _userInfo != null
                                        ? _userInfo['userName'] == "Guest"
                                            ? SizedBox()
                                            : ListTile(
                                                leading: Icon(Icons.delete),
                                                title: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {},
                                                  child: Container(
                                                    child: Text(
                                                        "_deleteAccount",
                                                        style: GoogleFonts
                                                            .publicSans(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 18,
                                                                color:
                                                                    _backgroudRengi)),
                                                  ),
                                                ),
                                              )
                                        : SizedBox(),
                                    ListTile(
                                      leading: Icon(Icons.exit_to_app),
                                      title: InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          var a = await _authService
                                              .signOutAndDeleteUser(
                                                  widget.userID,
                                                  "Anonym",
                                                  _userInfo['userName'],
                                                  _configData[
                                                      'ScoreTableSeason']);
                                          box.put("DBId", 0);
                                          box.put("WordPool", {});
                                          box.put("CompletedGames", {});
                                          box.put("winners", {});
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          CheckAuth()),
                                              (Route<dynamic> route) => false);
                                        },
                                        child: Container(
                                          child: Text("Çıkış",
                                              style: GoogleFonts.publicSans(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18,
                                                  color: _backgroudRengi)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          body: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 70,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                      child: Text(
                        "WORDOPOL",
                        style: TextStyle(shadows: <Shadow>[
                          // Shadow(
                          //   offset: Offset(5.0, 2),
                          //   blurRadius: 3.0,
                          //   color: Color.fromARGB(255, 0, 0, 0),
                          // ),
                          Shadow(
                            offset: Offset(3.0, 3.0),
                            blurRadius: 8.0,
                            color: Color.fromARGB(255, 48, 57, 107),
                          ),
                        ], fontWeight: FontWeight.w800, fontSize: 40),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      // height: MediaQuery.of(context).size.height / 2 - 30 -200,
                      child: Column(
                        children: [
                          Text(
                            _lanLeaderboard,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () => scoreTableGetFunction(),
                              child: ListView.builder(
                                itemCount: _scoreTable2 != null
                                    ? _scoreTable2.keys.toList().length
                                    : 0,
                                itemBuilder: (context, index) {
                                  final username = _scoreTable2.keys
                                      .toList()[index]
                                      .toString()
                                      .split('%')[1];
                                  final score =
                                      _scoreTable2.values.toList()[index];
                                  return ListTile(
                                    leading: Text(
                                      "${index + 1}.",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    title: Text(username),
                                    trailing: Text(score.toString()),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      // height: MediaQuery.of(context).size.height / 2 + 30,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _todayGames.length,
                          itemBuilder: (context, index2) {
                            // print(_kaydirmaNoktalari);
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              child: Container(
                                height: (((MediaQuery.of(context).size.height-70)/8*5)-60)/3,
                                width: MediaQuery.of(context).size.width / 3,
                                child: RawMaterialButton(
                                    // fillColor: _yaziTipiRengi,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: (_completedGames[
                                                        _todayNumber] !=
                                                    null
                                                ? (_completedGames[_todayNumber]
                                                            [index2 + 1] ==
                                                        true
                                                    ? Color(0xff77A830)
                                                    : Color.fromARGB(
                                                        255, 168, 76, 48))
                                                : Color.fromARGB(
                                                    255, 168, 76, 48))),
                  
                                        //eski sistemin kodu
                                        //  TimeOfDay.now().hour >
                                        //         _todayGames[index2].hour
                                        //     ? Color(0xff77A830)
                                        //     : TimeOfDay.now().hour ==
                                        //             _todayGames[index2].hour
                                        //         ? TimeOfDay.now().minute >=
                                        //                 _todayGames[index2]
                                        //                     .minute
                                        //             ? Color(0xff77A830)
                                        //             : Color.fromARGB(
                                        //                 255, 168, 76, 48)
                                        //         : Color.fromARGB(
                                        //             255, 168, 76, 48)),
                                        //eski sistemin kodu
                  
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
                                          Text(
                                              _lanGame +
                                                  " " +
                                                  (index2 + 1).toString(),
                                              style: GoogleFonts.publicSans(
                                                  // fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: Colors.black)),
                                          Row(
                                            children: [
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () {},
                                                child: Icon(
                                                  (_completedGames[
                                                              _todayNumber] !=
                                                          null
                                                      ? (_completedGames[
                                                                      _todayNumber]
                                                                  [index2 + 1] ==
                                                              true
                                                          ? Icons.check
                                                          : Icons.pending)
                                                      : Icons.pending),
                  
                                                  //eski sistemin kodu
                                                  // Icon(
                                                  //   TimeOfDay.now().hour >
                                                  //           _todayGames[index2].hour
                                                  //       ? (_completedGames[
                                                  //                   _todayNumber] !=
                                                  //               null
                                                  //           ? (_completedGames[_todayNumber]
                                                  //                       [
                                                  //                       index2 + 1] ==
                                                  //                   true
                                                  //               ? Icons.check
                                                  //               : Icons.pending)
                                                  //           : Icons.pending)
                                                  //       : TimeOfDay.now().hour ==
                                                  //               _todayGames[index2]
                                                  //                   .hour
                                                  //           ? TimeOfDay.now().minute >=
                                                  //                   _todayGames[index2]
                                                  //                       .minute
                                                  //               ? (_completedGames[
                                                  //                           _todayNumber] !=
                                                  //                       null
                                                  //                   ? (_completedGames[_todayNumber]
                                                  //                               [index2 + 1] ==
                                                  //                           true
                                                  //                       ? Icons.check
                                                  //                       : Icons.pending)
                                                  //                   : Icons.pending)
                                                  //               : Icons.lock
                                                  //           : Icons.lock,
                                                  //eski sistemin kodu
                                                  size: 25,
                                                  color: (_completedGames[
                                                              _todayNumber] !=
                                                          null
                                                      ? (_completedGames[
                                                                      _todayNumber]
                                                                  [index2 + 1] ==
                                                              true
                                                          ? Color(0xff77A830)
                                                          : Color.fromARGB(
                                                              255, 168, 76, 48))
                                                      : Color.fromARGB(
                                                          255, 168, 76, 48)),
                  
                                                  //eski sistemin renk düzeni
                                                  // TimeOfDay.now().hour >
                                                  //         _todayGames[index2].hour
                                                  //     ? Color(0xff77A830)
                                                  //     : TimeOfDay.now().hour ==
                                                  //             _todayGames[index2]
                                                  //                 .hour
                                                  //         ? TimeOfDay.now()
                                                  //                     .minute >=
                                                  //                 _todayGames[
                                                  //                         index2]
                                                  //                     .minute
                                                  //             ? Color(0xff77A830)
                                                  //             : Color.fromARGB(
                                                  //                 255, 168, 76, 48)
                                                  //         : Color.fromARGB(
                                                  //             255, 168, 76, 48),
                                                  //eski sistemin renk düzeni
                                                ),
                                              ),
                  
                                              //eski sistemin kodu
                                              // InkWell(
                                              //   splashColor: Colors.transparent,
                                              //   highlightColor: Colors.transparent,
                                              //   onTap: () async {},
                                              //   child: Text(
                                              //       _todayGames[index2]
                                              //           .format(context),
                                              //       style: GoogleFonts.publicSans(
                                              //           // fontWeight: FontWeight.bold,
                                              //           fontSize: 25,
                                              //           color: Colors.black)),
                                              // ),
                                              //eski sistemin kodu
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
                  
                                      if (
                                          // _check == "vakitGeldi"
                                          _check == _check) {
                                        if (_completedGames[_todayNumber] ==
                                            null) {
                                          _completedGames[_todayNumber] = {};
                                        }
                                        _completedGames[_todayNumber]
                                            [index2 + 1] = true;
                                        box.put(
                                            "CompletedGames", _completedGames);
                                        if (index2 == 0) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
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
                                                        language:
                                                            _currentLanguage,
                                                      )));
                                        } else if (index2 == 1) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
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
                                                        language:
                                                            _currentLanguage,
                                                      )));
                                        } else if (index2 == 2) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
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
                                                        language:
                                                            _currentLanguage,
                                                      )));
                                        }
                                      } else if (_check == "oyunTamamlandi") {
                                        ScaffoldMessenger.of(context)
                                            .hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            duration:
                                                Duration(milliseconds: 2000),
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
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            duration:
                                                Duration(milliseconds: 2000),
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
                              ),
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
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(35.0))),
                  child: ClipOval(
                    child: Ink.image(
                      height: 40,
                      width: 40,
                      image: AssetImage("assets/images/wordopolLogo.png"),
                      fit: BoxFit.cover,
                      child: InkWell(
                        onTap: () {
                          _scaffoldState.currentState!.openDrawer();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
