import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modeller/hisse_modeli.dart';
import '../modeller/kullanici_modeli.dart';
import '../servisler/auth_servisi.dart';
import '../servisler/firestore_servisi.dart';

final authServisSaglayici = Provider<AuthServisi>((ref) => AuthServisi());

final firestoreServisSaglayici =
    Provider<FirestoreServisi>((ref) => FirestoreServisi());

final authDurumSaglayici = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final kullaniciProfilSaglayici = FutureProvider<KullaniciModeli?>((ref) async {
  final authDurum = ref.watch(authDurumSaglayici);
  final kullanici = authDurum.asData?.value;
  if (kullanici == null) return null;

  final servis = ref.read(firestoreServisSaglayici);
  final veri = await servis.kullaniciBilgisiGetir(kullanici.uid);
  if (veri == null) return null;
  return KullaniciModeli.fromMap(veri, kullanici.uid);
});

final portfoySaglayici = StreamProvider<List<HisseModeli>>((ref) {
  final authDurum = ref.watch(authDurumSaglayici);
  final kullanici = authDurum.asData?.value;
  if (kullanici == null) return Stream.value([]);

  final servis = ref.read(firestoreServisSaglayici);
  return servis.hisseleriDinle();
});

final loglarSaglayici =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final servis = ref.read(firestoreServisSaglayici);
  return servis.loglariDinle();
});
