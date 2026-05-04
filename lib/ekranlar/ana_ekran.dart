import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../saglayicilar/saglayicilar.dart';
import '../modeller/hisse_modeli.dart';
import 'hisse_detay_ekrani.dart';
import 'hisse_ekle_duzenle_ekrani.dart';
import 'profil_ekrani.dart';
import 'admin_ekrani.dart';

class AnaEkran extends ConsumerWidget {
  const AnaEkran({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfoy = ref.watch(portfoySaglayici);
    final kullanici = ref.watch(kullaniciProfilSaglayici);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portföyüm'),
        actions: [
          kullanici.when(
            data: (k) => k?.rol == 'admin'
                ? IconButton(
                    icon: const Icon(Icons.admin_panel_settings),
                    tooltip: 'Admin Paneli',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminEkrani()),
                    ),
                  )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, _) => const SizedBox(),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profil',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilEkrani()),
            ),
          ),
        ],
      ),
      body: portfoy.when(
        data: (hisseler) {
          if (hisseler.isEmpty) {
            return const Center(
              child: Text(
                'Portföyünüz boş.\n+ butonuna basarak hisse ekleyin.',
                textAlign: TextAlign.center,
              ),
            );
          }

          final toplamDeger =
              hisseler.fold(0.0, (t, h) => t + h.toplamDeger);
          final toplamKarZarar =
              hisseler.fold(0.0, (t, h) => t + h.karZarar);

          return Column(
            children: [
              _OzetKart(
                toplamDeger: toplamDeger,
                toplamKarZarar: toplamKarZarar,
                hisseSayisi: hisseler.length,
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: hisseler.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return _HisseSatiri(hisse: hisseler[index]);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
      floatingActionButton: FloatingActionButton(
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

class _OzetKart extends StatelessWidget {
  final double toplamDeger;
  final double toplamKarZarar;
  final int hisseSayisi;

  const _OzetKart({
    required this.toplamDeger,
    required this.toplamKarZarar,
    required this.hisseSayisi,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _OzetSutun(
              baslik: 'Toplam Değer',
              deger: '₺${toplamDeger.toStringAsFixed(2)}',
            ),
            _OzetSutun(
              baslik: 'Kar / Zarar',
              deger:
                  '${toplamKarZarar >= 0 ? '+' : ''}₺${toplamKarZarar.toStringAsFixed(2)}',
              renk: toplamKarZarar >= 0 ? Colors.green : Colors.red,
            ),
            _OzetSutun(
              baslik: 'Hisse Sayısı',
              deger: '$hisseSayisi',
            ),
          ],
        ),
      ),
    );
  }
}

class _OzetSutun extends StatelessWidget {
  final String baslik;
  final String deger;
  final Color? renk;

  const _OzetSutun({required this.baslik, required this.deger, this.renk});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(baslik,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          deger,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: renk,
          ),
        ),
      ],
    );
  }
}

class _HisseSatiri extends StatelessWidget {
  final HisseModeli hisse;

  const _HisseSatiri({required this.hisse});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        hisse.sembol,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(hisse.sirketAdi,
          style: const TextStyle(fontSize: 12)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('₺${hisse.toplamDeger.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            '${hisse.karZararYuzdesi >= 0 ? '+' : ''}${hisse.karZararYuzdesi.toStringAsFixed(2)}%',
            style: TextStyle(
              fontSize: 12,
              color: hisse.karZararYuzdesi >= 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => HisseDetayEkrani(hisse: hisse)),
      ),
    );
  }
}
