import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../saglayicilar/saglayicilar.dart';

class AdminEkrani extends ConsumerWidget {
  const AdminEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loglar = ref.watch(loglarSaglayici);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Paneli'),
        actions: [
          loglar.when(
            data: (liste) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${liste.length} kayıt',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            loading: () => const SizedBox(),
            error: (_, _) => const SizedBox(),
          ),
        ],
      ),
      body: loglar.when(
        data: (liste) {
          if (liste.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Henüz log kaydı yok',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C1C1E))),
                  const SizedBox(height: 6),
                  const Text('İşlem yapıldıkça burada görünecek',
                      style: TextStyle(color: Color(0xFF6B7280))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: liste.length,
            itemBuilder: (context, i) {
              final log = liste[i];
              final islem = log['islem'] as String? ?? '-';
              final tarih = log['tarih'] as Timestamp?;

              final tarihStr = tarih != null
                  ? '${tarih.toDate().day.toString().padLeft(2, '0')}.${tarih.toDate().month.toString().padLeft(2, '0')}.${tarih.toDate().year}  ${tarih.toDate().hour.toString().padLeft(2, '0')}:${tarih.toDate().minute.toString().padLeft(2, '0')}'
                  : '-';

              final tip = _logTipiAl(islem);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: tip.renk.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(tip.ikon, size: 20, color: tip.renk),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: tip.renk.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tip.etiket,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: tip.renk,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              islem,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tarihStr,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (hata, _) => Center(child: Text('Hata: $hata')),
      ),
    );
  }

  _LogTipi _logTipiAl(String islem) {
    if (islem.contains('Giriş yapıldı')) {
      return _LogTipi(
          Icons.login, 'Giriş', const Color(0xFF1565C0));
    }
    if (islem.contains('Çıkış yapıldı')) {
      return _LogTipi(
          Icons.logout, 'Çıkış', const Color(0xFF6B7280));
    }
    if (islem.contains('Hesap oluşturuldu')) {
      return _LogTipi(
          Icons.person_add_outlined, 'Kayıt', const Color(0xFF6A1B9A));
    }
    if (islem.contains('eklendi')) {
      return _LogTipi(
          Icons.add_circle_outline, 'Ekleme', const Color(0xFF2E7D32));
    }
    if (islem.contains('güncellendi') || islem.contains('düzenlendi')) {
      return _LogTipi(
          Icons.edit_outlined, 'Güncelleme', const Color(0xFFE65100));
    }
    if (islem.contains('silindi')) {
      return _LogTipi(
          Icons.delete_outline, 'Silme', const Color(0xFFC62828));
    }
    return _LogTipi(
        Icons.receipt_outlined, 'İşlem', const Color(0xFF6B7280));
  }
}

class _LogTipi {
  final IconData ikon;
  final String etiket;
  final Color renk;

  const _LogTipi(this.ikon, this.etiket, this.renk);
}
