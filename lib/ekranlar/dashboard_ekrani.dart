import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../saglayicilar/saglayicilar.dart';
import '../modeller/hisse_modeli.dart';
import 'hisse_ekle_duzenle_ekrani.dart';
import 'hisse_detay_ekrani.dart';

const _grafikRenkleri = [
  Color(0xFF3949AB),
  Color(0xFF00897B),
  Color(0xFFE53935),
  Color(0xFFFB8C00),
  Color(0xFF8E24AA),
  Color(0xFF43A047),
  Color(0xFF1E88E5),
  Color(0xFFD81B60),
];

class DashboardEkrani extends ConsumerWidget {
  final void Function(int) onTabDegistir;
  const DashboardEkrani({super.key, required this.onTabDegistir});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kullanici = ref.watch(kullaniciProfilSaglayici);
    final portfoy = ref.watch(portfoySaglayici);
    final loglar = ref.watch(loglarSaglayici);

    return Scaffold(
      appBar: AppBar(
        title: kullanici.when(
          data: (k) => Text('Merhaba, ${k?.ad.split(' ').first ?? 'Yatırımcı'}'),
          loading: () => const Text('Ana Sayfa'),
          error: (_, _) => const Text('Ana Sayfa'),
        ),
        actions: [
          kullanici.when(
            data: (k) => k?.rol == 'admin'
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: const Text('Admin', style: TextStyle(fontSize: 11, color: Colors.white)),
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      padding: EdgeInsets.zero,
                    ),
                  )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, _) => const SizedBox(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(portfoySaglayici),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              portfoy.when(
                data: (h) => _PortfoyKart(hisseler: h),
                loading: () => _YuklenenKart(),
                error: (_, _) => const SizedBox(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _HizliIslem(ikon: Icons.add_circle_outline, baslik: 'Hisse Ekle',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HisseEkleDuzenleEkrani())))),
                  const SizedBox(width: 12),
                  Expanded(child: _HizliIslem(ikon: Icons.bar_chart, baslik: 'Portföyüm', onTap: () => onTabDegistir(1))),
                ],
              ),
              const SizedBox(height: 16),
              portfoy.when(
                data: (hisseler) {
                  if (hisseler.length < 2) return const SizedBox();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Portföy Dağılımı', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E))),
                      const SizedBox(height: 8),
                      _DagilimGrafigi(hisseler: hisseler),
                      const SizedBox(height: 16),
                    ],
                  );
                },
                loading: () => const SizedBox(),
                error: (_, _) => const SizedBox(),
              ),
              portfoy.when(
                data: (hisseler) {
                  if (hisseler.length < 2) return const SizedBox();
                  final sirali = [...hisseler]..sort((a, b) => b.karZararYuzdesi.compareTo(a.karZararYuzdesi));
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Performans', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E))),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: _PerformansKart(baslik: 'En İyi', hisse: sirali.first, renk: const Color(0xFF2E7D32), ikon: Icons.trending_up)),
                        const SizedBox(width: 12),
                        Expanded(child: _PerformansKart(baslik: 'En Kötü', hisse: sirali.last, renk: const Color(0xFFC62828), ikon: Icons.trending_down)),
                      ]),
                      const SizedBox(height: 16),
                    ],
                  );
                },
                loading: () => const SizedBox(),
                error: (_, _) => const SizedBox(),
              ),
              portfoy.when(
                data: (hisseler) {
                  if (hisseler.isEmpty) return const SizedBox();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Son Hisselerim', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E))),
                          TextButton(onPressed: () => onTabDegistir(1), child: const Text('Tümü')),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Card(
                        child: Column(
                          children: List.generate(hisseler.length > 3 ? 3 : hisseler.length, (i) => Column(children: [
                            _MiniHisseSatiri(hisse: hisseler[i], onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => HisseDetayEkrani(hisse: hisseler[i])))),
                            if (i < (hisseler.length > 3 ? 2 : hisseler.length - 1)) const Divider(height: 1, indent: 60),
                          ])),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
                loading: () => const SizedBox(),
                error: (_, _) => const SizedBox(),
              ),
              const Text('Son Hareketler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E))),
              const SizedBox(height: 8),
              loglar.when(
                data: (liste) => _SonHareketler(liste: liste),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DagilimGrafigi extends StatelessWidget {
  final List<HisseModeli> hisseler;
  const _DagilimGrafigi({required this.hisseler});

  @override
  Widget build(BuildContext context) {
    final toplam = hisseler.fold(0.0, (t, h) => t + h.toplamDeger);
    final sections = hisseler.asMap().entries.map((e) {
      final renk = _grafikRenkleri[e.key % _grafikRenkleri.length];
      final yuzde = e.value.toplamDeger / toplam * 100;
      return PieChartSectionData(
        value: e.value.toplamDeger,
        title: yuzde > 8 ? '%${yuzde.toStringAsFixed(0)}' : '',
        color: renk,
        radius: 65,
        titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 44, sectionsSpace: 3)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: hisseler.asMap().entries.map((e) {
                final renk = _grafikRenkleri[e.key % _grafikRenkleri.length];
                final yuzde = e.value.toplamDeger / toplam * 100;
                return Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: renk, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text('${e.value.sembol} %${yuzde.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12)),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfoyKart extends StatelessWidget {
  final List<HisseModeli> hisseler;
  const _PortfoyKart({required this.hisseler});

  @override
  Widget build(BuildContext context) {
    if (hisseler.isEmpty) {
      return Container(
        width: double.infinity, padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF3949AB), Color(0xFF1A237E)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Toplam Portföy Değeri', style: TextStyle(color: Colors.white70, fontSize: 13)),
          SizedBox(height: 6),
          Text('₺0.00', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Portföy sekmesinden hisse ekleyebilirsiniz.', style: TextStyle(color: Colors.white60, fontSize: 12)),
        ]),
      );
    }
    final toplamDeger = hisseler.fold(0.0, (t, h) => t + h.toplamDeger);
    final toplamKar = hisseler.fold(0.0, (t, h) => t + h.karZarar);
    final toplamMaliyet = hisseler.fold(0.0, (t, h) => t + h.toplamMaliyet);
    final yuzde = toplamMaliyet > 0 ? (toplamKar / toplamMaliyet) * 100 : 0.0;
    final kar = toplamKar >= 0;
    final karRenk = kar ? const Color(0xFF4CAF50) : const Color(0xFFEF5350);

    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF3949AB), Color(0xFF1A237E)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Toplam Portföy Değeri', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        Text('₺${toplamDeger.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Maliyet: ₺${toplamMaliyet.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 14),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: karRenk.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Icon(kar ? Icons.trending_up : Icons.trending_down, color: karRenk, size: 16),
              const SizedBox(width: 6),
              Text('${kar ? '+' : ''}₺${toplamKar.toStringAsFixed(2)}', style: TextStyle(color: karRenk, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 4),
              Text('(${kar ? '+' : ''}${yuzde.toStringAsFixed(2)}%)', style: TextStyle(color: karRenk.withValues(alpha: 0.8), fontSize: 12)),
            ]),
          ),
          const Spacer(),
          Text('${hisseler.length} hisse', style: const TextStyle(color: Colors.white60, fontSize: 13)),
        ]),
      ]),
    );
  }
}

class _YuklenenKart extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, height: 150,
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF3949AB), Color(0xFF1A237E)]), borderRadius: BorderRadius.circular(16)),
    child: const Center(child: CircularProgressIndicator(color: Colors.white)),
  );
}

class _HizliIslem extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final VoidCallback onTap;
  const _HizliIslem({required this.ikon, required this.baslik, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(12),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Column(children: [
        Icon(ikon, color: const Color(0xFF3949AB), size: 28),
        const SizedBox(height: 6),
        Text(baslik, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
      ])),
    ),
  );
}

class _PerformansKart extends StatelessWidget {
  final String baslik;
  final HisseModeli hisse;
  final Color renk;
  final IconData ikon;
  const _PerformansKart({required this.baslik, required this.hisse, required this.renk, required this.ikon});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(ikon, size: 14, color: renk),
        const SizedBox(width: 4),
        Text(baslik, style: TextStyle(color: renk, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 8),
      Text(hisse.sembol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 2),
      Text(hisse.sirketAdi, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)), overflow: TextOverflow.ellipsis),
      const SizedBox(height: 6),
      Text('${hisse.karZararYuzdesi >= 0 ? '+' : ''}${hisse.karZararYuzdesi.toStringAsFixed(2)}%',
          style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontSize: 14)),
      Text('${hisse.karZarar >= 0 ? '+' : ''}₺${hisse.karZarar.toStringAsFixed(2)}',
          style: TextStyle(color: renk.withValues(alpha: 0.8), fontSize: 12)),
    ])),
  );
}

class _MiniHisseSatiri extends StatelessWidget {
  final HisseModeli hisse;
  final VoidCallback onTap;
  const _MiniHisseSatiri({required this.hisse, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final kar = hisse.karZararYuzdesi >= 0;
    return ListTile(
      dense: true, onTap: onTap,
      leading: Container(width: 36, height: 36,
        decoration: BoxDecoration(color: const Color(0xFF3949AB).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Center(child: Text(hisse.sembol.length > 3 ? hisse.sembol.substring(0, 3) : hisse.sembol,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3949AB), fontSize: 10)))),
      title: Text(hisse.sembol, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text(hisse.sirketAdi, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('₺${hisse.toplamDeger.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        Text('${kar ? '+' : ''}${hisse.karZararYuzdesi.toStringAsFixed(2)}%',
            style: TextStyle(fontSize: 11, color: kar ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),
      ]),
    );
  }
}

class _SonHareketler extends StatelessWidget {
  final List<Map<String, dynamic>> liste;
  const _SonHareketler({required this.liste});

  IconData _ikon(String islem) {
    if (islem.contains('Giriş')) return Icons.login;
    if (islem.contains('eklendi') || islem.contains('Hesap')) return Icons.add_circle_outline;
    if (islem.contains('düzenlendi') || islem.contains('güncellendi')) return Icons.edit_outlined;
    if (islem.contains('silindi')) return Icons.delete_outline;
    if (islem.contains('Çıkış')) return Icons.logout;
    return Icons.receipt_outlined;
  }

  @override
  Widget build(BuildContext context) {
    if (liste.isEmpty) {
      return Card(child: Padding(padding: const EdgeInsets.all(20),
          child: Center(child: Text('Henüz hareket yok', style: TextStyle(color: Colors.grey.shade500)))));
    }
    final son3 = liste.take(3).toList();
    return Card(child: Column(children: List.generate(son3.length, (i) {
      final log = son3[i];
      final tarih = log['tarih'] as Timestamp?;
      final tarihStr = tarih != null
          ? '${tarih.toDate().hour.toString().padLeft(2, '0')}:${tarih.toDate().minute.toString().padLeft(2, '0')} · ${tarih.toDate().day.toString().padLeft(2, '0')}.${tarih.toDate().month.toString().padLeft(2, '0')}'
          : '-';
      final islem = log['islem'] as String? ?? '-';
      return Column(children: [
        ListTile(
          dense: true,
          leading: Container(width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFF3949AB).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(_ikon(islem), size: 18, color: const Color(0xFF3949AB))),
          title: Text(islem, style: const TextStyle(fontSize: 13)),
          trailing: Text(tarihStr, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
        ),
        if (i < son3.length - 1) const Divider(height: 1, indent: 60),
      ]);
    })));
  }
}
