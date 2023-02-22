import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';

class CloudDB {
  getConfigDatas() async {
    var _finalData;
    var data = await FirebaseFirestore.instance
        .collection("Configs")
        .doc("ConfigProd")
        .get()
        .then((gelenVeri) {
      _finalData = gelenVeri.data();
      // print(_finalData);
    });

    // print(_allResults);
    return _finalData;
  }

  getUserInfo(String _uid) async {
    var _finalData;
    var data = await FirebaseFirestore.instance
        .collection("Users")
        .doc(_uid)
        .get()
        .then((gelenVeri) {
      _finalData = gelenVeri.data();
      // print(_finalData);
    });

    // print(_allResults);
    return _finalData;
  }

  firestoreFileReach(int _id) async {
    final ref =
        FirebaseStorage.instance.ref().child('data' + _id.toString() + '.json');
    Uint8List? downloadedData = await ref.getData();
    var k = (utf8.decode(downloadedData!));
    return json.decode(k);
    // print(json.decode(k)['tr']['0']);
// firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
// .ref()
// .child('playground')
// .child('/put-string-example.txt');
  }
}
