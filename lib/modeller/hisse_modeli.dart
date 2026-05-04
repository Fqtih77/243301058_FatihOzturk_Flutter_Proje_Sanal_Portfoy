import 'package:cloud_firestore/cloud_firestore.dart';

class HisseModeli {
  final String id;
  final String sembol;
  final String sirketAdi;
  final double adet;
  final double alisFiyati;
  final double guncelFiyat;
  final DateTime alisTarihi;

  HisseModeli({
    required this.id,
    required this.sembol,
    required this.sirketAdi,
    required this.adet,
    required this.alisFiyati,
    required this.guncelFiyat,
    required this.alisTarihi,
  });

  double get toplamMaliyet => adet * alisFiyati;
  double get toplamDeger => adet * guncelFiyat;
  double get karZarar => toplamDeger - toplamMaliyet;
  double get karZararYuzdesi =>
      toplamMaliyet == 0 ? 0 : (karZarar / toplamMaliyet) * 100;

  factory HisseModeli.fromMap(Map<String, dynamic> map, String id) {
    return HisseModeli(
      id: id,
      sembol: map['sembol'] ?? '',
      sirketAdi: map['sirketAdi'] ?? '',
      adet: (map['adet'] ?? 0).toDouble(),
      alisFiyati: (map['alisFiyati'] ?? 0).toDouble(),
      guncelFiyat: (map['guncelFiyat'] ?? 0).toDouble(),
      alisTarihi: map['alisTarihi'] != null
          ? (map['alisTarihi'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'sembol': sembol,
        'sirketAdi': sirketAdi,
        'adet': adet,
        'alisFiyati': alisFiyati,
        'guncelFiyat': guncelFiyat,
        'alisTarihi': Timestamp.fromDate(alisTarihi),
      };
}
