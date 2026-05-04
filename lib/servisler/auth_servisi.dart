import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'log_servisi.dart';

class AuthServisi {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _logServisi = LogServisi();

  Future<UserCredential> girisYap(String email, String sifre) async {
    final sonuc = await _auth.signInWithEmailAndPassword(
      email: email,
      password: sifre,
    );
    await _logServisi.logKaydet(sonuc.user!.uid, 'Giriş yapıldı');
    return sonuc;
  }

  Future<UserCredential> kayitOl(
      String email, String sifre, String ad) async {
    final sonuc = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: sifre,
    );
    await _db.collection('kullanicilar').doc(sonuc.user!.uid).set({
      'email': email,
      'ad': ad,
      'rol': 'user',
    });
    await _logServisi.logKaydet(sonuc.user!.uid, 'Hesap oluşturuldu');
    return sonuc;
  }

  Future<void> cikisYap() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) await _logServisi.logKaydet(uid, 'Çıkış yapıldı');
    await _auth.signOut();
  }
}
