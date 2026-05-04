import 'package:cloud_firestore/cloud_firestore.dart';

class LogServisi {
  final _db = FirebaseFirestore.instance;

  Future<void> logKaydet(String kullaniciId, String islem) async {
    await _db.collection('logs').add({
      'kullaniciId': kullaniciId,
      'islem': islem,
      'tarih': FieldValue.serverTimestamp(),
    });
  }
}
