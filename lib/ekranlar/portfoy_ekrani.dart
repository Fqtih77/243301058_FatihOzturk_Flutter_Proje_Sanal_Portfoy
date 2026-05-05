import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../saglayicilar/saglayicilar.dart';
import '../modeller/hisse_modeli.dart';
import 'hisse_detay_ekrani.dart';
import 'hisse_ekle_duzenle_ekrani.dart';

enum _Siralama { deger, kar, ad }

class PortfoyEkrani extends ConsumerStatefulWidget {
  const PortfoyEkrani({super.key});

  @override
  ConsumerState<PortfoyEkrani> createState() => _PortfoyEkraniState();
}

class _PortfoyEkraniState extends ConsumerState<PortfoyEkrani> {
  _Siralama _siralama = _Siralama.deger;

  List<HisseModeli> _sirala(List<HisseModeli> liste) {
    final kopi = [...liste];
    switch (_siralama) {
      case _Siralama.deger:
        kopi.sort((a, b) => b.toplamDeger.compareTo(a.toplamDeger));
      case _Siralama.kar:
        kopi.sort(
            (a, b) => b.karZararYuzdesi.compareTo(a.karZararYuzdesi));
      case _Siralama.ad:
        kopi.sort((a, b) => a.sembol.compareTo(b.sembol));
    }
    return kopi;
  }

  @override
  Widget build(BuildContext context) {
    final portfoy = ref.watch(portfoySaglayici);

    return Scaffold(
      appBar: AppBar(title: const Text('Portföy')),
      body: portfoy.when(
        data: (hisseler) {
          if (hisseler.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart,
                      size: 72, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Portföyünüz boş',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C1C1E))),
                  const SizedBox(height: 6),
                  const Text('İlk hissenizi eklemek için + butonuna basın',
                      style: TextStyle(color: Color(0xFF6B7280))),
                ],
              ),
            );
          }

          final sirali = _sirala(hisseler);
          final toplamDeger =
              hisseler.fold(0.0, (t, h) => t + h.toplamDeger);
          final toplamMaliyet =
              hisseler.fold(0.0, (t, h) => t + h.toplamMaliyet);
          final toplamKarZarar = toplamDeger - toplamMaliyet;
          final kar = toplamKarZarar >= 0;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(portfoySaglayici),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    color: const Color(0xFF3949AB),
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Toplam Değer',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            Text(
                              '₺${toplamDeger.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Kar / Zarar',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            Text(
                              '${kar ? '+' : ''}₺${toplamKarZarar.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: kar
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFEF5350),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        const Text('Sırala:',
                            style: TextStyle(
                                color: Color(0xFF6B7280), fontSize: 13)),
                        const SizedBox(width: 8),
                        _SiralamaChip(
                          baslik: 'Değer',
                          secili: _siralama == _Siralama.deger,
                          onTap: () =>
                              setState(() => _siralama = _Siralama.deger),
                        ),
                        const SizedBox(width: 6),
                        _SiralamaChip(
                          baslik: 'Kar %',
                          secili: _siralama == _Siralama.kar,
                          onTap: () =>
                              setState(() => _siralama = _Siralama.kar),
                        ),
                        const SizedBox(width: 6),
                        _SiralamaChip(
                          baslik: 'A-Z',
                          secili: _siralama == _Siralama.ad,
                          onTap: () =>
                              setState(() => _siralama = _Siralama.ad),
                        ),
                        const Spacer(),
                        Text('${hisseler.length} hisse',
                            style: const TextStyle(
                                color: Color(0xFF6B7280), fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _HisseSatiri(hisse: sirali[i]),
                      childCount: sirali.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off,
                  size: 52, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              const Text('Veriler yüklenemedi',
                  style: TextStyle(color: Color(0xFF6B7280))),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3949AB),
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const HisseEkleDuzenleEkrani()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SiralamaChip extends StatelessWidget {
  final String baslik;
  final bool secili;
  final VoidCallback onTap;

  const _SiralamaChip(
      {required this.baslik, required this.secili, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: secili
              ? const Color(0xFF3949AB)
              : const Color(0xFF3949AB).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          baslik,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: secili ? Colors.white : const Color(0xFF3949AB),
          ),
        ),
      ),
    );
  }
}

class _HisseSatiri extends StatelessWidget {
  final HisseModeli hisse;

  const _HisseSatiri({required this.hisse});

  @override
  Widget build(BuildContext context) {
    final kar = hisse.karZararYuzdesi >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => HisseDetayEkrani(hisse: hisse)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF3949AB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    hisse.sembol.length > 4
                        ? hisse.sembol.substring(0, 4)
                        : hisse.sembol,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3949AB),
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hisse.sembol,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(hisse.sirketAdi,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280))),
                    const SizedBox(height: 4),
                    Text(
                      '${hisse.adet} adet  ·  Alış: ₺${hisse.alisFiyati.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₺${hisse.toplamDeger.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kar
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.12)
                          : const Color(0xFFEF5350).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${kar ? '+' : ''}${hisse.karZararYuzdesi.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kar
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${hisse.karZarar >= 0 ? '+' : ''}₺${hisse.karZarar.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: kar
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
