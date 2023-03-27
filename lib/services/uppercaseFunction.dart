class Uppercase {
  upperCaseFunction(String word) {
    Map _alfabe = {
      "a": "A",
      "b": "B",
      "c": "C",
      "ç": "Ç",
      "d": "D",
      "e": "E",
      "f": "F",
      "g": "G",
      "ğ": "Ğ",
      "h": "H",
      "ı": "I",
      "i": "İ",
      "j": "J",
      "k": "K",
      "l": "L",
      "m": "M",
      "n": "N",
      "o": "O",
      "ö": "Ö",
      "p": "P",
      "r": "R",
      "s": "S",
      "ş": "Ş",
      "t": "T",
      "u": "U",
      "ü": "Ü",
      "v": "V",
      "y": "Y",
      "z": "Z"
    };

    String _buyukHarfKelime = "";
    List _kelimeList = word.split("");

    for (var _harf in _kelimeList) {
      if (_alfabe.containsKey(_harf)) {
        _buyukHarfKelime += _alfabe[_harf];
      } else {
        _buyukHarfKelime += _harf;
      }
    }
    return _buyukHarfKelime;
  }
}
