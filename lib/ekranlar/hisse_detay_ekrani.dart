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
    final kar = hisse.karZarar >= 0;
    final karRenk = kar ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final karArkaRenk = kar
        ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
        : const Color(0xFFEF5350).withValues(alpha: 0.1);

    return Scaffold(
      appBar: AppBar(
        title: Text(hisse.sembol),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HisseEkleDuzenleEkrani(mevcutHisse: hisse),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _silmeOnayi(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3949AB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      hisse.sembol.length > 4
                          ? hisse.sembol.substring(0, 4)
                          : hisse.sembol,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3949AB),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hisse.sirketAdi,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      hisse.sembol,
                      style: const TextStyle(
                          color: Color(0xFF6B7280), fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: karArkaRenk,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: karRenk.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        kar ? Icons.trending_up : Icons.trending_down,
                        color: karRenk,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${kar ? '+' : ''}₺${hisse.karZarar.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: karRenk,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${kar ? '+' : ''}${hisse.karZararYuzdesi.toStringAsFixed(2)}% getiri',
                    style: TextStyle(color: karRenk, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _BilgiSatiri(
                        Icons.numbers, 'Adet', '${hisse.adet}'),
                    _BilgiSatiri(Icons.price_change_outlined, 'Alış Fiyatı',
                        '₺${hisse.alisFiyati.toStringAsFixed(2)}'),
                    _BilgiSatiri(Icons.update, 'Güncel Fiyat',
                        '₺${hisse.guncelFiyat.toStringAsFixed(2)}'),
                    _BilgiSatiri(
                      Icons.calendar_today_outlined,
                      'Alış Tarihi',
                      '${hisse.alisTarihi.day.toString().padLeft(2, '0')}'
                          '.${hisse.alisTarihi.month.toString().padLeft(2, '0')}'
                          '.${hisse.alisTarihi.year}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _BilgiSatiri(Icons.account_balance_wallet_outlined,
                        'Toplam Maliyet',
                        '₺${hisse.toplamMaliyet.toStringAsFixed(2)}'),
                    _BilgiSatiri(Icons.savings_outlined, 'Toplam Değer',
                        '₺${hisse.toplamDeger.toStringAsFixed(2)}'),
                  ],
                ),
              ),
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
        content: Text(
            '${hisse.sembol} hissesini portföyden silmek istiyor musunuz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sil',
                  style: TextStyle(color: Color(0xFFC62828)))),
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
  final IconData ikon;
  final String baslik;
  final String deger;

  const _BilgiSatiri(this.ikon, this.baslik, this.deger);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(ikon, size: 18, color: const Color(0xFF6B7280)),
          const SizedBox(width: 10),
          Text(baslik,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          const Spacer(),
          Text(deger,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}
