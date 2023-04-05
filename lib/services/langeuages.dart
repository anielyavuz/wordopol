class LanguageService {
  homePageLanguages(String _lan) {
    List _result = [];
    String _welcome = "Welcome";
    String _leaderboard = "Leaderboard";
    String _signout = "Sign Out";
    String _game = "Game";
    if (_lan == "en") {
    } else if (_lan == "tr") {
      _welcome = "Hoşgeldiniz";
      _leaderboard = "Skor Tablosu";
      _signout = "Çıkış";
      _game = "Oyun";
    }

    _result.insert(0, _welcome);
    _result.insert(1, _leaderboard);
    _result.insert(2, _signout);
    _result.insert(3, _game);
    return _result;
  }

  welcomePageLanguages(String _lan) {
    List _result = [];
    String _welcome = "Welcome";
    String _username = "Username";
    String _next = "Next";

    if (_lan == "en") {
    } else if (_lan == "tr") {
      _welcome = "Hoşgeldiniz";
      _username = "Kullanıcı Adınız";
      _next = "Devam";
    }

    _result.insert(0, _welcome);
    _result.insert(1, _username);
    _result.insert(2, _next);

    return _result;
  }
}
