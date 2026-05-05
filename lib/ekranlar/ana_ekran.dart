import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_ekrani.dart';
import 'portfoy_ekrani.dart';
import 'profil_ekrani.dart';

class AnaEkran extends ConsumerStatefulWidget {
  const AnaEkran({super.key});

  @override
  ConsumerState<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends ConsumerState<AnaEkran> {
  int _secilenIndeks = 0;

  void _tabDegistir(int indeks) => setState(() => _secilenIndeks = indeks);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _secilenIndeks,
        children: [
          DashboardEkrani(onTabDegistir: _tabDegistir),
          const PortfoyEkrani(),
          const ProfilEkrani(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _secilenIndeks,
        onDestinationSelected: _tabDegistir,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Portföy',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
