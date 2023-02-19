import 'package:cloud_firestore/cloud_firestore.dart';

class CloudDB {
  getDataFromFireStore() async {
    var _finalData;
    var data = await FirebaseFirestore.instance
        .collection("Configs")
        .doc("ConfigTest")
        .get()
        .then((gelenVeri) {
      _finalData = gelenVeri.data();
      print(_finalData);
    });

    // print(_allResults);
    return _finalData;
  }
}
