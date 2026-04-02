// lib/providers/recupero_provider.dart

import 'package:flutter/material.dart';

// 1. Il modello dati
class StatoMuscolo {
  final String nome;
  double livelloRecupero; // Da 0.0 (distrutto) a 1.0 (fresco)

  StatoMuscolo({required this.nome, required this.livelloRecupero});

  Color get coloreStato {
    if (livelloRecupero <= 0.3) return Colors.redAccent;
    if (livelloRecupero <= 0.7) return Colors.orangeAccent;
    return Colors.green;
  }

  String get testoStato {
    if (livelloRecupero <= 0.3) return "Affaticato";
    if (livelloRecupero <= 0.7) return "In Recupero";
    return "Pronto";
  }
}

// 2. Il Provider (Il "cervello" centrale)
class RecuperoProvider extends ChangeNotifier {
  // Lista iniziale dei muscoli
  final List<StatoMuscolo> _muscoli = [
    StatoMuscolo(nome: 'Pettorali', livelloRecupero: 1.0),
    StatoMuscolo(nome: 'Dorsali', livelloRecupero: 1.0),
    StatoMuscolo(nome: 'Quadricipiti', livelloRecupero: 1.0),
    StatoMuscolo(nome: 'Femorali', livelloRecupero: 1.0),
    StatoMuscolo(nome: 'Spalle', livelloRecupero: 1.0),
    StatoMuscolo(nome: 'Bicipiti', livelloRecupero: 1.0),
    StatoMuscolo(nome: 'Tricipiti', livelloRecupero: 1.0),
    StatoMuscolo(nome: 'Addominali', livelloRecupero: 1.0),
  ];

  // Getter per leggere la lista dall'esterno
  List<StatoMuscolo> get muscoli => _muscoli;

  // 3. Metodo per simulare la fine di un allenamento
  void allenaMuscoli(List<String> nomiMuscoliAllenati) {
    for (var muscolo in _muscoli) {
      if (nomiMuscoliAllenati.contains(muscolo.nome)) {
        // Abbassiamo il recupero a 0.0 (appena allenato, affaticato)
        muscolo.livelloRecupero = 0.0;
      }
    }
    // IMPORTANTE: Avvisa tutte le schermate in ascolto che i dati sono cambiati!
    notifyListeners();
  }

  // Metodo opzionale: Simula il passare del tempo (es. +0.3 di recupero al giorno)
  void avanzaGiorno() {
    for (var muscolo in _muscoli) {
      if (muscolo.livelloRecupero < 1.0) {
        muscolo.livelloRecupero += 0.3;
        if (muscolo.livelloRecupero > 1.0) muscolo.livelloRecupero = 1.0;
      }
    }
    notifyListeners();
  }
}
