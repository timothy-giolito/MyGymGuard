import 'package:flutter/material.dart';
import 'pagina_abbonamento.dart';
import 'pagina_timer.dart';
import 'pagina_schede.dart';
import 'pagina_dashboard.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Questa variabile tiene traccia di quale pagina stiamo guardando (0, 1 o 2)
  int _indiceAttuale = 0;

  // Questa è una lista delle nostre 3 pagine
  final List<Widget> _pagine = [
    const PaginaAbbonamento(),
    const PaginaTimer(),
    const PaginaSchede(),
    const PaginaDashboard(),
  ];

  // Funzione che cambia la pagina quando tocchi un'icona
  void _cambiaPagina(int index) {
    setState(() {
      _indiceAttuale = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gym Guard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // Mostriamo la pagina corrispondente all'indice attuale
      body: _pagine[_indiceAttuale],

      // La barra di navigazione in basso
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAttuale,
        onTap: _cambiaPagina, // Chiama la funzione quando tocchi un'icona
        type: BottomNavigationBarType.fixed, // Per mostrare tutte le icone
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Abbonamento',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Schede'),
          BottomNavigationBarItem(
            icon: Icon(Icons.accessibility_new),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }
}
