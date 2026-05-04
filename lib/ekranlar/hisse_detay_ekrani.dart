import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modeller/hisse_modeli.dart';
import '../saglayicilar/saglayicilar.dart';
import 'hisse_ekle_duzenle_ekrani.dart';

class HisseDetayEkrani extends ConsumerWidget {
  final HisseModeli hisse;

  const HisseDetayEkrani({super.key, required this.hisse});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hisse.sembol),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    HisseEkleDuzenleEkrani(mevcutHisse: hisse),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _silmeOnayi(context, ref),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hisse.sirketAdi,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(hisse.sembol,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const Divider(height: 32),
            _BilgiSatiri('Adet', '${hisse.adet}'),
            _BilgiSatiri(
                'Alış Fiyatı', '₺${hisse.alisFiyati.toStringAsFixed(2)}'),
            _BilgiSatiri(
                'Güncel Fiyat', '₺${hisse.guncelFiyat.toStringAsFixed(2)}'),
            const Divider(height: 24),
            _BilgiSatiri(
                'Toplam Maliyet', '₺${hisse.toplamMaliyet.toStringAsFixed(2)}'),
            _BilgiSatiri(
                'Toplam Değer', '₺${hisse.toplamDeger.toStringAsFixed(2)}'),
            _BilgiSatiriRenkli(
              'Kar / Zarar',
              '${hisse.karZarar >= 0 ? '+' : ''}₺${hisse.karZarar.toStringAsFixed(2)}  '
                  '(${hisse.karZararYuzdesi >= 0 ? '+' : ''}${hisse.karZararYuzdesi.toStringAsFixed(2)}%)',
              hisse.karZarar >= 0 ? Colors.green : Colors.red,
            ),
            const Divider(height: 24),
            _BilgiSatiri(
              'Alış Tarihi',
              '${hisse.alisTarihi.day.toString().padLeft(2, '0')}'
                  '.${hisse.alisTarihi.month.toString().padLeft(2, '0')}'
                  '.${hisse.alisTarihi.year}',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _silmeOnayi(BuildContext context, WidgetRef ref) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hisseyi Sil'),
        content: Text('${hisse.sembol} hissesini portföyden silmek istiyor musunuz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sil', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (onay == true && context.mounted) {
      await ref.read(firestoreServisSaglayici).hisseSil(hisse);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _BilgiSatiri extends StatelessWidget {
  final String baslik;
  final String deger;

  const _BilgiSatiri(this.baslik, this.deger);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(color: Colors.grey)),
          Text(deger, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _BilgiSatiriRenkli extends StatelessWidget {
  final String baslik;
  final String deger;
  final Color renk;

  const _BilgiSatiriRenkli(this.baslik, this.deger, this.renk);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(color: Colors.grey)),
          Text(deger,
              style: TextStyle(fontWeight: FontWeight.bold, color: renk)),
        ],
      ),
    );
  }
}
