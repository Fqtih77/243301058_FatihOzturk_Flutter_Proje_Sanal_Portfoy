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
      appBar: AppBar(title: const Text('Admin Paneli — Loglar')),
      body: loglar.when(
        data: (liste) {
          if (liste.isEmpty) {
            return const Center(child: Text('Henüz log kaydı yok.'));
          }
          return ListView.separated(
            itemCount: liste.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final log = liste[index];
              final tarih = log['tarih'] as Timestamp?;
              final tarihStr = tarih != null
                  ? '${tarih.toDate().day.toString().padLeft(2, '0')}'
                      '.${tarih.toDate().month.toString().padLeft(2, '0')}'
                      '.${tarih.toDate().year} '
                      '${tarih.toDate().hour.toString().padLeft(2, '0')}'
                      ':${tarih.toDate().minute.toString().padLeft(2, '0')}'
                  : '-';
              return ListTile(
                title: Text(log['islem'] ?? '-'),
                subtitle: Text(
                  'Kullanıcı: ${log['kullaniciId'] ?? '-'}',
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: Text(
                  tarihStr,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
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
}
