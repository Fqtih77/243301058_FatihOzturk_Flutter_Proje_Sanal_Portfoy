import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'saglayicilar/saglayicilar.dart';
import 'ekranlar/giris_ekrani.dart';
import 'ekranlar/ana_ekran.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: UygulamaWidget()));
}

class UygulamaWidget extends ConsumerWidget {
  const UygulamaWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authDurum = ref.watch(authDurumSaglayici);

    return MaterialApp(
      title: 'Sanal Portföy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: authDurum.when(
        data: (kullanici) =>
            kullanici != null ? const AnaEkran() : const GirisEkrani(),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, _) => const GirisEkrani(),
      ),
    );
  }
}
