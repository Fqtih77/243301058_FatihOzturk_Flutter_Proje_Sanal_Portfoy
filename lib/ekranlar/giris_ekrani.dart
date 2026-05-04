import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../saglayicilar/saglayicilar.dart';
import 'kayit_ekrani.dart';

class GirisEkrani extends ConsumerStatefulWidget {
  const GirisEkrani({super.key});

  @override
  ConsumerState<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends ConsumerState<GirisEkrani> {
  final _formAnahtar = GlobalKey<FormState>();
  final _emailKontrolcu = TextEditingController();
  final _sifreKontrolcu = TextEditingController();
  bool _yukleniyor = false;
  bool _sifreGoster = false;

  @override
  void dispose() {
    _emailKontrolcu.dispose();
    _sifreKontrolcu.dispose();
    super.dispose();
  }

  Future<void> _girisYap() async {
    if (!_formAnahtar.currentState!.validate()) return;
    setState(() => _yukleniyor = true);
    try {
      await ref.read(authServisSaglayici).girisYap(
            _emailKontrolcu.text.trim(),
            _sifreKontrolcu.text,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Giriş başarısız: ${_hataMesaji(e.toString())}')),
        );
      }
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  String _hataMesaji(String hata) {
    if (hata.contains('user-not-found') || hata.contains('invalid-credential')) {
      return 'E-posta veya şifre hatalı';
    }
    if (hata.contains('wrong-password')) return 'Hatalı şifre';
    if (hata.contains('invalid-email')) return 'Geçersiz e-posta';
    return 'Bir hata oluştu';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3949AB), Color(0xFF1A237E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.of(context).padding.top + 48,
              24,
              40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.show_chart, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Sanal Portföy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Hesabınıza giriş yapın',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formAnahtar,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailKontrolcu,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'E-posta giriniz' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sifreKontrolcu,
                      obscureText: !_sifreGoster,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _sifreGoster ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _sifreGoster = !_sifreGoster),
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.length < 6 ? 'En az 6 karakter giriniz' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _yukleniyor ? null : _girisYap,
                        child: _yukleniyor
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Giriş Yap'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const KayitEkrani()),
                        ),
                        child: const Text('Hesabın yok mu? Kayıt ol'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
