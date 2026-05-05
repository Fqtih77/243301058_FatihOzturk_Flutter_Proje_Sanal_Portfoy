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
    final karArkaPlan = kar
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3949AB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          hisse.sembol.length > 4
                              ? hisse.sembol.substring(0, 4)
                              : hisse.sembol,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3949AB),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hisse.sirketAdi,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3949AB)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  hisse.sembol,
                                  style: const TextStyle(
                                    color: Color(0xFF3949AB),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'BIST',
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: karArkaPlan,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: karRenk.withValues(alpha: 0.25)),
              ),
              child: Column(
                children: [
                  Icon(
                    kar ? Icons.trending_up : Icons.trending_down,
                    color: karRenk,
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${kar ? '+' : ''}₺${hisse.karZarar.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: karRenk,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${kar ? '+' : ''}${hisse.karZararYuzdesi.toStringAsFixed(2)}% getiri',
                    style: TextStyle(color: karRenk, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.0,
              children: [
                _StatKutu(
                  ikon: Icons.numbers,
                  baslik: 'Adet',
                  deger: '${hisse.adet}',
                ),
                _StatKutu(
                  ikon: Icons.price_change_outlined,
                  baslik: 'Alış Fiyatı',
                  deger: '₺${hisse.alisFiyati.toStringAsFixed(2)}',
                ),
                _StatKutu(
                  ikon: Icons.update,
                  baslik: 'Güncel Fiyat',
                  deger: '₺${hisse.guncelFiyat.toStringAsFixed(2)}',
                ),
                _StatKutu(
                  ikon: Icons.calendar_today_outlined,
                  baslik: 'Alış Tarihi',
                  deger:
                      '${hisse.alisTarihi.day.toString().padLeft(2, '0')}.${hisse.alisTarihi.month.toString().padLeft(2, '0')}.${hisse.alisTarihi.year}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yatırım Özeti',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _OzetSatir(
                      'Toplam Maliyet',
                      '₺${hisse.toplamMaliyet.toStringAsFixed(2)}',
                      null,
                    ),
                    const Divider(height: 20),
                    _OzetSatir(
                      'Toplam Değer',
                      '₺${hisse.toplamDeger.toStringAsFixed(2)}',
                      null,
                    ),
                    const Divider(height: 20),
                    _OzetSatir(
                      'Net Kar / Zarar',
                      '${kar ? '+' : ''}₺${hisse.karZarar.toStringAsFixed(2)}',
                      karRenk,
                    ),
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

class _StatKutu extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String deger;

  const _StatKutu(
      {required this.ikon, required this.baslik, required this.deger});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(ikon, size: 20, color: const Color(0xFF3949AB)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(baslik,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6B7280))),
                  const SizedBox(height: 2),
                  Text(deger,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OzetSatir extends StatelessWidget {
  final String baslik;
  final String deger;
  final Color? renk;

  const _OzetSatir(this.baslik, this.deger, this.renk);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(baslik,
            style:
                const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
        Text(deger,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: renk ?? const Color(0xFF1C1C1E))),
      ],
    );
  }
}
