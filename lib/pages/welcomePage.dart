import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:wordopol/pages/checkAuth.dart';
import 'package:wordopol/services/authFunctions.dart';
import 'package:wordopol/services/firebaseFunctions.dart';
import 'package:wordopol/services/langeuages.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late Box box;
  TextEditingController _turkceTextFieldController = TextEditingController();
  AuthService _authService = AuthService();
  var _languageFull = "English";
  Map _languageDropdown = {
    'Türkçe': 'tr',
    'Español': 'es',
    'Deutsch': 'de',
    'Français': 'fr',
    'English': 'en'
  };
  String _currentLanguage = "en";
  var _configData;
  var _textFieldValue = "";
  LanguageService _languageService = LanguageService();
  String _lanWelcome = "";
  String _lanUsername = "";
  String _lanNext = "";

  languageService(String _lan) {
    // _lanWelcome = _languageService.homePageWelcomeLangueages(_lan);
    // _lanLeaderboard = _languageService.homePageLeaderboardLangueages(_lan);

    // _lanSignOut = _languageService.homePageSignOutLangueages(_lan);
    List _allLangueages = _languageService.welcomePageLanguages(_lan);
    _lanWelcome = _allLangueages[0];
    _lanUsername = _allLangueages[1];
    _lanNext = _allLangueages[2];
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
    print(_currentLanguage);

    print((_languageFull));
    languageService(_currentLanguage);
  }

  startFunctions() async {
    _configData = await CloudDB().getConfigDatas();

    _currentLanguage = box.get("languageSelectedBefore") ?? "en";

    Future.delayed(const Duration(milliseconds: 1000), () {
// Here you can write your code
      languageSelect();
    });
  }

  @override
  void initState() {
    box = Hive.box("wordopolHive");
    startFunctions();
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
          resizeToAvoidBottomInset: false,
          body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Color.fromARGB(255, 255, 80, 80),
              Color.fromARGB(255, 219, 243, 243),
              Color.fromARGB(255, 255, 80, 80),
            ])),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 5 / 7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
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
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                            child: TextField(
                              style: TextStyle(
                                  color: Color.fromARGB(255, 244, 246, 248)),
                              onSubmitted: (value) async {
                                print(_textFieldValue.toString().length);
                                if (_textFieldValue.toString().length == 0) {
                                } else {
                                  var a = await _authService.anonymSignIn(
                                      _turkceTextFieldController.text);
                                }
                              },
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(40),
                                FilteringTextInputFormatter.deny("%"),
                              ],
                              autofocus: true,
                              onChanged: (value2) {
                                setState(() {
                                  _textFieldValue = value2;
                                });
                              },
                              controller: _turkceTextFieldController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10),
                                isCollapsed: true,
                                filled: true,
                                fillColor: Color.fromARGB(219, 19, 21, 52),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 0, 5, 64),
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 200, 202, 204),
                                    width: 2.0,
                                  ),
                                ),
                                hintText: _lanUsername,
                                hintStyle: TextStyle(
                                    color: Color.fromARGB(195, 219, 230, 229)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                  buttonDecoration: BoxDecoration(
                                      // color: Color.fromARGB(255, 112, 112, 112),
                                      ),
                                  dropdownDecoration: BoxDecoration(
                                    color: Color.fromARGB(195, 219, 230, 229),
                                  ),
                                  offset: const Offset(-15.5, 0),
                                  alignment: AlignmentDirectional.center,
                                  dropdownWidth: 105,
                                  // borderRadius: BorderRadius.circular(10),
                                  // dropdownColor: Color(0xff010114).withOpacity(1),
                                  value: _languageFull,
                                  items: _languageDropdown.keys
                                      .toList()
                                      .map((dynamic value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Center(
                                        child: new Text(value,
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    219, 19, 21, 52),
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _languageFull = value!;
                                    });

                                    if (_configData['supportedLanguages'] !=
                                        null) {
                                      setState(() {
                                        _currentLanguage =
                                            _configData['supportedLanguages']
                                                [_languageFull];
                                        box.put("languageSelectedBefore",
                                            _currentLanguage);
                                      });
                                    }
                                    languageService(_currentLanguage);
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
                        ],
                      ),
                      RawMaterialButton(
                          constraints: BoxConstraints(
                            minHeight: 80,
                            minWidth: 150,
                          ),
                          fillColor: _textFieldValue.toString().length == 0
                              ? Color.fromARGB(255, 74, 74, 79).withOpacity(0.3)
                              : Color.fromARGB(219, 19, 21, 52),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0))),
                          // splashColor: Color.fromARGB(255, 255, 80, 80),
                          splashColor: Colors.transparent,
                          // highlightColor: Colors.transparent,
                          textStyle: TextStyle(color: Colors.white),
                          child: Text(_lanNext,
                              style: TextStyle(
                                color: _textFieldValue.toString().length == 0
                                    ? Color.fromARGB(255, 255, 255, 255)
                                    : Color.fromARGB(255, 255, 80, 80),
                                fontSize: 25,
                                fontFamily: 'Times New Roman',
                                // fontWeight: FontWeight.bold
                              )),
                          onPressed: _textFieldValue.toString().length == 0
                              ? null
                              : () async {
                                  var a = await _authService.anonymSignIn(
                                      _turkceTextFieldController.text);
                                }),
                    ],
                  ),
                ),
                Container(
                  // padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                  // child: Center(
                  //   child: Text(
                  //     _lanWelcome,
                  //     style:
                  //         TextStyle(shadows: <Shadow>[
                  //           // Shadow(
                  //           //   offset: Offset(5.0, 2),
                  //           //   blurRadius: 3.0,
                  //           //   color: Color.fromARGB(255, 0, 0, 0),
                  //           // ),
                  //           Shadow(
                  //             offset: Offset(3.0, 3.0),
                  //             blurRadius: 8.0,
                  //             color: Color.fromARGB(255, 48, 57, 107),
                  //           ),
                  //         ],fontWeight: FontWeight.w800, fontSize: 40),
                  //   ),
                  // ),
                  height: MediaQuery.of(context).size.height * 2 / 7,
                )
              ],
            ),
          )),
    );
  }
}
