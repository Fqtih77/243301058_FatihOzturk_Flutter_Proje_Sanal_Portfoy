import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../saglayicilar/saglayicilar.dart';

class KayitEkrani extends ConsumerStatefulWidget {
  const KayitEkrani({super.key});

  @override
  ConsumerState<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends ConsumerState<KayitEkrani> {
  final _formAnahtar = GlobalKey<FormState>();
  final _adKontrolcu = TextEditingController();
  final _emailKontrolcu = TextEditingController();
  final _sifreKontrolcu = TextEditingController();
  bool _yukleniyor = false;

  @override
  void dispose() {
    _adKontrolcu.dispose();
    _emailKontrolcu.dispose();
    _sifreKontrolcu.dispose();
    super.dispose();
  }

  Future<void> _kayitOl() async {
    if (!_formAnahtar.currentState!.validate()) return;
    setState(() => _yukleniyor = true);
    try {
      await ref.read(authServisSaglayici).kayitOl(
            _emailKontrolcu.text.trim(),
            _sifreKontrolcu.text,
            _adKontrolcu.text.trim(),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt başarısız: ${_hataMesaji(e.toString())}')),
        );
      }
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  String _hataMesaji(String hata) {
    if (hata.contains('email-already-in-use')) return 'Bu e-posta zaten kayıtlı';
    if (hata.contains('weak-password')) return 'Şifre çok zayıf';
    if (hata.contains('invalid-email')) return 'Geçersiz e-posta';
    return 'Bir hata oluştu';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formAnahtar,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              TextFormField(
                controller: _adKontrolcu,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ad giriniz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailKontrolcu,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'E-posta giriniz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sifreKontrolcu,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Şifre',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.length < 6 ? 'En az 6 karakter giriniz' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _yukleniyor ? null : _kayitOl,
                  child: _yukleniyor
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Kayıt Ol'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
