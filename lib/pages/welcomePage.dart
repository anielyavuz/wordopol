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
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: DropdownButton<String>(
                  dropdownColor: Color(0xff010114).withOpacity(1),
                  value: _languageFull,
                  items: _languageDropdown.keys.toList().map((dynamic value) {
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
                            _configData['supportedLanguages'][_languageFull];
                        box.put("languageSelectedBefore", _currentLanguage);
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
            Visibility(
              visible: _textFieldValue.toString().length > 0,
              child: RawMaterialButton(
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
            ),
          ],
        )),
      )),
    );
  }
}
