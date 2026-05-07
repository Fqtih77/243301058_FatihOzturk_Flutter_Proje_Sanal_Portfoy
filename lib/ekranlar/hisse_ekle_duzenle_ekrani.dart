import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modeller/hisse_modeli.dart';
import '../saglayicilar/saglayicilar.dart';

class HisseEkleDuzenleEkrani extends ConsumerStatefulWidget {
  final HisseModeli? mevcutHisse;
  const HisseEkleDuzenleEkrani({super.key, this.mevcutHisse});

  @override
  ConsumerState<HisseEkleDuzenleEkrani> createState() => _HisseEkleDuzenleEkraniState();
}

class _HisseEkleDuzenleEkraniState extends ConsumerState<HisseEkleDuzenleEkrani> {
  final _formAnahtar = GlobalKey<FormState>();
  late final TextEditingController _sembolKontrolcu;
  late final TextEditingController _sirketAdiKontrolcu;
  late final TextEditingController _adetKontrolcu;
  late final TextEditingController _alisKontrolcu;
  late final TextEditingController _guncelKontrolcu;
  late DateTime _secilenTarih;
  bool _yukleniyor = false;

  bool get _duzenlemeModunda => widget.mevcutHisse != null;

  @override
  void initState() {
    super.initState();
    final h = widget.mevcutHisse;
    _secilenTarih = h?.alisTarihi ?? DateTime.now();
    _sembolKontrolcu = TextEditingController(text: h?.sembol ?? '');
    _sirketAdiKontrolcu = TextEditingController(text: h?.sirketAdi ?? '');
    _adetKontrolcu = TextEditingController(text: h != null ? h.adet.toString() : '');
    _alisKontrolcu = TextEditingController(text: h != null ? h.alisFiyati.toString() : '');
    _guncelKontrolcu = TextEditingController(text: h != null ? h.guncelFiyat.toString() : '');
    _adetKontrolcu.addListener(() => setState(() {}));
    _alisKontrolcu.addListener(() => setState(() {}));
    _guncelKontrolcu.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _sembolKontrolcu.dispose();
    _sirketAdiKontrolcu.dispose();
    _adetKontrolcu.dispose();
    _alisKontrolcu.dispose();
    _guncelKontrolcu.dispose();
    super.dispose();
  }

  Future<void> _tarihSec() async {
    final secilen = await showDatePicker(
      context: context, initialDate: _secilenTarih, firstDate: DateTime(2000), lastDate: DateTime.now());
    if (secilen != null) setState(() => _secilenTarih = secilen);
  }

  Future<void> _kaydet() async {
    if (!_formAnahtar.currentState!.validate()) return;
    setState(() => _yukleniyor = true);
    final servis = ref.read(firestoreServisSaglayici);
    final yeniHisse = HisseModeli(
      id: widget.mevcutHisse?.id ?? '',
      sembol: _sembolKontrolcu.text.trim().toUpperCase(),
      sirketAdi: _sirketAdiKontrolcu.text.trim(),
      adet: double.parse(_adetKontrolcu.text.replaceAll(',', '.')),
      alisFiyati: double.parse(_alisKontrolcu.text.replaceAll(',', '.')),
      guncelFiyat: double.parse(_guncelKontrolcu.text.replaceAll(',', '.')),
      alisTarihi: _secilenTarih,
    );
    try {
      if (_duzenlemeModunda) {
        await servis.hisseDuzenle(yeniHisse);
      } else {
        await servis.hisseEkle(yeniHisse);
      }
      if (mounted) { Navigator.pop(context); }
    } catch (e) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'))); }
    } finally {
      if (mounted) { setState(() => _yukleniyor = false); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tarihMetin = '${_secilenTarih.day.toString().padLeft(2, '0')}.${_secilenTarih.month.toString().padLeft(2, '0')}.${_secilenTarih.year}';

    final adet = double.tryParse(_adetKontrolcu.text.replaceAll(',', '.')) ?? 0;
    final alis = double.tryParse(_alisKontrolcu.text.replaceAll(',', '.')) ?? 0;
    final guncel = double.tryParse(_guncelKontrolcu.text.replaceAll(',', '.')) ?? 0;
    final maliyet = adet * alis;
    final deger = adet * guncel;
    final karZarar = deger - maliyet;
    final yuzde = maliyet > 0 ? (karZarar / maliyet) * 100 : 0.0;
    final hesaplamaGoster = adet > 0 && alis > 0 && guncel > 0;

    return Scaffold(
      appBar: AppBar(title: Text(_duzenlemeModunda ? 'Hisse Düzenle' : 'Hisse Ekle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          if (hesaplamaGoster) ...[
            Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF3949AB), Color(0xFF1A237E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Anlık Hesaplama', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _HesapKutu(baslik: 'Maliyet', deger: '₺${maliyet.toStringAsFixed(2)}')),
                  const SizedBox(width: 8),
                  Expanded(child: _HesapKutu(baslik: 'Değer', deger: '₺${deger.toStringAsFixed(2)}')),
                  const SizedBox(width: 8),
                  Expanded(child: _HesapKutu(
                    baslik: 'Kar/Zarar',
                    deger: '${karZarar >= 0 ? '+' : ''}₺${karZarar.toStringAsFixed(2)}',
                    renk: karZarar >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
                  )),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(karZarar >= 0 ? Icons.trending_up : Icons.trending_down,
                      color: karZarar >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFEF5350), size: 16),
                  const SizedBox(width: 6),
                  Text('${yuzde >= 0 ? '+' : ''}${yuzde.toStringAsFixed(2)}% getiri',
                      style: TextStyle(color: karZarar >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFEF5350), fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              ]),
            ),
            const SizedBox(height: 16),
          ],
          Form(key: _formAnahtar, child: Column(children: [
            TextFormField(
              controller: _sembolKontrolcu, textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Sembol (örn: THYAO)', prefixIcon: Icon(Icons.tag)),
              validator: (v) => v == null || v.isEmpty ? 'Sembol giriniz' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _sirketAdiKontrolcu,
              decoration: const InputDecoration(labelText: 'Şirket Adı', prefixIcon: Icon(Icons.business_outlined)),
              validator: (v) => v == null || v.isEmpty ? 'Şirket adı giriniz' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _adetKontrolcu, keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Adet', prefixIcon: Icon(Icons.numbers)),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Adet giriniz';
                if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Geçerli sayı giriniz';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _alisKontrolcu, keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Alış Fiyatı (₺)', prefixIcon: Icon(Icons.price_change_outlined)),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Alış fiyatı giriniz';
                if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Geçerli fiyat giriniz';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _guncelKontrolcu, keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Güncel Fiyat (₺)', prefixIcon: Icon(Icons.update)),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Güncel fiyat giriniz';
                if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Geçerli fiyat giriniz';
                return null;
              },
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _tarihSec, borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Alış Tarihi', prefixIcon: Icon(Icons.calendar_today_outlined), suffixIcon: Icon(Icons.arrow_drop_down)),
                child: Text(tarihMetin),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: _yukleniyor ? null : _kaydet,
              child: _yukleniyor
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_duzenlemeModunda ? 'Güncelle' : 'Ekle'),
            )),
          ])),
        ]),
      ),
    );
  }
}

class _HesapKutu extends StatelessWidget {
  final String baslik;
  final String deger;
  final Color? renk;
  const _HesapKutu({required this.baslik, required this.deger, this.renk});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(baslik, style: const TextStyle(color: Colors.white60, fontSize: 10)),
    const SizedBox(height: 2),
    Text(deger, style: TextStyle(color: renk ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
  ]);
}
