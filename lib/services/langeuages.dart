class LanguageService {
  homePageLanguages(String _lan) {
    List _result = [];
    String _welcome = "Welcome";
    String _leaderboard = "Leaderboard";
    String _signout = "Sign Out & Delete My Account";
    String _game = "Game";
    String _lanLastChamp = "Last Champion";
    if (_lan == "en") {
    } else if (_lan == "tr") {
      _welcome = "Hoşgeldiniz";
      _leaderboard = "Skor Tablosu";
      _signout = "Çık ve Hesabımı Sil";
      _game = "Oyun";
      _lanLastChamp = "Son Şampiyon";
    }

    _result.insert(0, _welcome);
    _result.insert(1, _leaderboard);
    _result.insert(2, _signout);
    _result.insert(3, _game);
    _result.insert(4, _lanLastChamp);
    return _result;
  }

  welcomePageLanguages(String _lan) {
    List _result = [];
    String _welcome = "Welcome";
    String _username = "Username";
    String _next = "Let's Start";

    if (_lan == "en") {
    } else if (_lan == "tr") {
      _welcome = "Hoşgeldiniz";
      _username = "Kullanıcı Adınız";
      _next = "Başlayalım";
    }

    _result.insert(0, _welcome);
    _result.insert(1, _username);
    _result.insert(2, _next);

    return _result;
  }

  playPageLanguages(String _lan) {
    List _result = [];
    String _lanTotalPoint = "Total Point";
    String _lanQuestionPoint = "Question Point";
    String _lanTakeLetter = "Take Letter";

    String _lanFoundAnswer = "I found answer!";
    String _lanOkay = "Okay";
    String _lanSignOut = "Quit";

    if (_lan == "en") {
    } else if (_lan == "tr") {
      _lanTotalPoint = "Toplam Puan";
      _lanQuestionPoint = "Bu sorunun puanı";
      _lanTakeLetter = "Harf Al";

      _lanFoundAnswer = "Cevabı buldum";
      _lanOkay = "Tamam";
      _lanSignOut = "Çıkış";
    }

    _result.insert(0, _lanTotalPoint);
    _result.insert(1, _lanQuestionPoint);
    _result.insert(2, _lanTakeLetter);
    _result.insert(3, _lanFoundAnswer);
    _result.insert(4, _lanOkay);
    _result.insert(5, _lanSignOut);

    return _result;
  }
}
