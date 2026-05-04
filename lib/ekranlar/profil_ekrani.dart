import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../saglayicilar/saglayicilar.dart';

class ProfilEkrani extends ConsumerWidget {
  const ProfilEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kullanici = ref.watch(kullaniciProfilSaglayici);
    final portfoy = ref.watch(portfoySaglayici);

    return Scaffold(
      appBar: AppBar(title: const Text('Profilim')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            kullanici.when(
              data: (k) => k != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          k.ad,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(k.email,
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(k.rol == 'admin' ? 'Admin' : 'Kullanıcı'),
                        ),
                      ],
                    )
                  : const SizedBox(),
              loading: () => const CircularProgressIndicator(),
              error: (_, _) => const SizedBox(),
            ),
            const Divider(height: 32),
            const Text(
              'Portföy Özeti',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            portfoy.when(
              data: (hisseler) {
                final toplamMaliyet =
                    hisseler.fold(0.0, (t, h) => t + h.toplamMaliyet);
                final toplamDeger =
                    hisseler.fold(0.0, (t, h) => t + h.toplamDeger);
                final toplamKarZarar = toplamDeger - toplamMaliyet;

                return Column(
                  children: [
                    _OzetSatiri('Toplam Hisse Sayısı', '${hisseler.length}'),
                    _OzetSatiri(
                        'Toplam Maliyet',
                        '₺${toplamMaliyet.toStringAsFixed(2)}'),
                    _OzetSatiri(
                        'Toplam Değer',
                        '₺${toplamDeger.toStringAsFixed(2)}'),
                    _OzetSatiriRenkli(
                      'Toplam Kar / Zarar',
                      '${toplamKarZarar >= 0 ? '+' : ''}₺${toplamKarZarar.toStringAsFixed(2)}',
                      toplamKarZarar >= 0 ? Colors.green : Colors.red,
                    ),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, _) => const SizedBox(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await ref.read(authServisSaglayici).cikisYap();
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Çıkış Yap'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OzetSatiri extends StatelessWidget {
  final String baslik;
  final String deger;

  const _OzetSatiri(this.baslik, this.deger);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(color: Colors.grey)),
          Text(deger),
        ],
      ),
    );
  }
}

class _OzetSatiriRenkli extends StatelessWidget {
  final String baslik;
  final String deger;
  final Color renk;

  const _OzetSatiriRenkli(this.baslik, this.deger, this.renk);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(color: Colors.grey)),
          Text(deger,
              style:
                  TextStyle(color: renk, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
