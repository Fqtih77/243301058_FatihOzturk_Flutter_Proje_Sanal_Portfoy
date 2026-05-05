import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../saglayicilar/saglayicilar.dart';
import 'admin_ekrani.dart';

class ProfilEkrani extends ConsumerWidget {
  const ProfilEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kullanici = ref.watch(kullaniciProfilSaglayici);
    final portfoy = ref.watch(portfoySaglayici);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            kullanici.when(
              data: (k) {
                if (k == null) return const SizedBox();
                final basTurlari = k.ad.trim().isNotEmpty
                    ? k.ad.trim().split(' ').map((w) => w[0]).take(2).join()
                    : '?';
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF3949AB),
                      child: Text(
                        basTurlari.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(k.ad,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(k.email,
                        style: const TextStyle(
                            color: Color(0xFF6B7280), fontSize: 13)),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(
                        k.rol == 'admin' ? 'Admin' : 'Kullanıcı',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    if (k.rol == 'admin') ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.admin_panel_settings),
                          label: const Text('Admin Paneli'),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AdminEkrani()),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, _) => const SizedBox(),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Portföy Özeti',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    portfoy.when(
                      data: (hisseler) {
                        final toplamMaliyet = hisseler.fold(
                            0.0, (t, h) => t + h.toplamMaliyet);
                        final toplamDeger = hisseler.fold(
                            0.0, (t, h) => t + h.toplamDeger);
                        final karZarar = toplamDeger - toplamMaliyet;
                        final kar = karZarar >= 0;

                        return Column(
                          children: [
                            _OzetSatiri(
                                Icons.inventory_2_outlined,
                                'Hisse Sayısı',
                                '${hisseler.length}',
                                null),
                            _OzetSatiri(
                                Icons.account_balance_wallet_outlined,
                                'Toplam Maliyet',
                                '₺${toplamMaliyet.toStringAsFixed(2)}',
                                null),
                            _OzetSatiri(
                                Icons.savings_outlined,
                                'Toplam Değer',
                                '₺${toplamDeger.toStringAsFixed(2)}',
                                null),
                            _OzetSatiri(
                              kar
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              'Kar / Zarar',
                              '${kar ? '+' : ''}₺${karZarar.toStringAsFixed(2)}',
                              kar
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFC62828),
                            ),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, _) => const SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Color(0xFFC62828)),
                label: const Text('Çıkış Yap',
                    style: TextStyle(color: Color(0xFFC62828))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFC62828)),
                ),
                onPressed: () =>
                    ref.read(authServisSaglayici).cikisYap(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OzetSatiri extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String deger;
  final Color? renk;

  const _OzetSatiri(this.ikon, this.baslik, this.deger, this.renk);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(ikon, size: 18, color: renk ?? const Color(0xFF6B7280)),
          const SizedBox(width: 10),
          Text(baslik,
              style: const TextStyle(
                  color: Color(0xFF6B7280), fontSize: 14)),
          const Spacer(),
          Text(deger,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: renk ?? const Color(0xFF1C1C1E))),
        ],
      ),
    );
  }
}
