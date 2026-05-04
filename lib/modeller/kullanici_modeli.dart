class KullaniciModeli {
  final String uid;
  final String email;
  final String ad;
  final String rol;

  KullaniciModeli({
    required this.uid,
    required this.email,
    required this.ad,
    required this.rol,
  });

  factory KullaniciModeli.fromMap(Map<String, dynamic> map, String uid) {
    return KullaniciModeli(
      uid: uid,
      email: map['email'] ?? '',
      ad: map['ad'] ?? '',
      rol: map['rol'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'ad': ad,
        'rol': rol,
      };
}
