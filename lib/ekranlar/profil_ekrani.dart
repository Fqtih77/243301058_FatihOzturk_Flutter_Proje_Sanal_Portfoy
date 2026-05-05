import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../saglayicilar/saglayicilar.dart';
import '../modeller/hisse_modeli.dart';
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
                final basTurler = k.ad.trim().isNotEmpty
                    ? k.ad
                        .trim()
                        .split(' ')
                        .map((w) => w[0])
                        .take(2)
                        .join()
                        .toUpperCase()
                    : '?';
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: const Color(0xFF3949AB),
                          child: Text(
                            basTurler,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(k.ad,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(k.email,
                            style: const TextStyle(
                                color: Color(0xFF6B7280), fontSize: 13)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: k.rol == 'admin'
                                ? const Color(0xFF3949AB)
                                    .withValues(alpha: 0.12)
                                : const Color(0xFF6B7280)
                                    .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                k.rol == 'admin'
                                    ? Icons.admin_panel_settings
                                    : Icons.person,
                                size: 14,
                                color: k.rol == 'admin'
                                    ? const Color(0xFF3949AB)
                                    : const Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                k.rol == 'admin' ? 'Admin' : 'Kullanıcı',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: k.rol == 'admin'
                                      ? const Color(0xFF3949AB)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, _) => const SizedBox(),
            ),
            const SizedBox(height: 12),
            portfoy.when(
              data: (hisseler) {
                final toplamMaliyet =
                    hisseler.fold(0.0, (t, h) => t + h.toplamMaliyet);
                final toplamDeger =
                    hisseler.fold(0.0, (t, h) => t + h.toplamDeger);
                final karZarar = toplamDeger - toplamMaliyet;
                final kar = karZarar >= 0;

                HisseModeli? enIyi;
                if (hisseler.isNotEmpty) {
                  enIyi = hisseler.reduce((a, b) =>
                      a.karZararYuzdesi > b.karZararYuzdesi ? a : b);
                }

                return Column(
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.2,
                      children: [
                        _IstatistikKutu(
                          ikon: Icons.inventory_2_outlined,
                          baslik: 'Hisse Sayısı',
                          deger: '${hisseler.length}',
                          renk: const Color(0xFF3949AB),
                        ),
                        _IstatistikKutu(
                          ikon: Icons.savings_outlined,
                          baslik: 'Toplam Değer',
                          deger: '₺${toplamDeger.toStringAsFixed(0)}',
                          renk: const Color(0xFF3949AB),
                        ),
                        _IstatistikKutu(
                          ikon: kar
                              ? Icons.trending_up
                              : Icons.trending_down,
                          baslik: 'Kar / Zarar',
                          deger:
                              '${kar ? '+' : ''}₺${karZarar.toStringAsFixed(0)}',
                          renk: kar
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828),
                        ),
                        _IstatistikKutu(
                          ikon: Icons.star_outline,
                          baslik: 'En İyi Hisse',
                          deger: enIyi != null
                              ? '${enIyi.sembol} ${enIyi.karZararYuzdesi >= 0 ? '+' : ''}${enIyi.karZararYuzdesi.toStringAsFixed(1)}%'
                              : '-',
                          renk: const Color(0xFF2E7D32),
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
                            const Text('Portföy Detayı',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            _DetaySatir('Toplam Maliyet',
                                '₺${toplamMaliyet.toStringAsFixed(2)}', null),
                            const Divider(height: 16),
                            _DetaySatir('Toplam Değer',
                                '₺${toplamDeger.toStringAsFixed(2)}', null),
                            const Divider(height: 16),
                            _DetaySatir(
                              'Net Getiri',
                              '${kar ? '+' : ''}₺${karZarar.toStringAsFixed(2)}',
                              kar
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFC62828),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, _) => const SizedBox(),
            ),
            const SizedBox(height: 12),
            kullanici.when(
              data: (k) => k?.rol == 'admin'
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.admin_panel_settings,
                              color: Color(0xFF3949AB)),
                          label: const Text('Admin Paneli',
                              style:
                                  TextStyle(color: Color(0xFF3949AB))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFF3949AB)),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AdminEkrani()),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
              loading: () => const SizedBox(),
              error: (_, _) => const SizedBox(),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout,
                    color: Color(0xFFC62828)),
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

class _IstatistikKutu extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String deger;
  final Color renk;

  const _IstatistikKutu({
    required this.ikon,
    required this.baslik,
    required this.deger,
    required this.renk,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: renk.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(ikon, size: 18, color: renk),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(baslik,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF6B7280))),
                  const SizedBox(height: 2),
                  Text(deger,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: renk),
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

class _DetaySatir extends StatelessWidget {
  final String baslik;
  final String deger;
  final Color? renk;

  const _DetaySatir(this.baslik, this.deger, this.renk);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(baslik,
            style: const TextStyle(
                color: Color(0xFF6B7280), fontSize: 14)),
        Text(deger,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: renk ?? const Color(0xFF1C1C1E))),
      ],
    );
  }
}
