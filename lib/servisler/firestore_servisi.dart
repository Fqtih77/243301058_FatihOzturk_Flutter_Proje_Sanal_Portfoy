import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modeller/hisse_modeli.dart';
import 'log_servisi.dart';

class FirestoreServisi {
  final _db = FirebaseFirestore.instance;
  final _logServisi = LogServisi();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _hisseler =>
      _db.collection('portfoy').doc(_uid).collection('hisseler');

  Stream<List<HisseModeli>> hisseleriDinle() {
    return _hisseler.snapshots().map(
          (snap) => snap.docs
              .map((doc) => HisseModeli.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> hisseEkle(HisseModeli hisse) async {
    await _hisseler.add(hisse.toMap());
    await _logServisi.logKaydet(_uid!, 'Hisse eklendi: ${hisse.sembol}');
  }

  Future<void> hisseDuzenle(HisseModeli hisse) async {
    await _hisseler.doc(hisse.id).update(hisse.toMap());
    await _logServisi.logKaydet(_uid!, 'Hisse düzenlendi: ${hisse.sembol}');
  }

  Future<void> hisseSil(HisseModeli hisse) async {
    await _hisseler.doc(hisse.id).delete();
    await _logServisi.logKaydet(_uid!, 'Hisse silindi: ${hisse.sembol}');
  }

  Stream<List<Map<String, dynamic>>> loglariDinle() {
    return _db
        .collection('logs')
        .orderBy('tarih', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  Future<Map<String, dynamic>?> kullaniciBilgisiGetir(String uid) async {
    final doc = await _db.collection('kullanicilar').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }
}
