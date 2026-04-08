import 'package:flutter/material.dart';
import 'dart:async';

class TimerProvider extends ChangeNotifier {
  int _secondiIniziali = 0;
  int _secondiRimanenti = 0;
  Timer? _timer;
  bool _inEsecuzione = false;
  bool _mostraDialogo = false; // Flag per sapere se mostrare il pop-up

  // Getter per leggere i dati dalla pagina
  int get secondiRimanenti => _secondiRimanenti;
  bool get inEsecuzione => _inEsecuzione;
  bool get mostraDialogo => _mostraDialogo;

  String get testoTempo {
    int minuti = _secondiRimanenti ~/ 60;
    int secondi = _secondiRimanenti % 60;
    return '${minuti.toString().padLeft(2, '0')}:${secondi.toString().padLeft(2, '0')}';
  }

  void impostaDurata(int secondi) {
    fermaTimer();
    _secondiIniziali = secondi;
    _secondiRimanenti = secondi;
    _mostraDialogo = false;
    notifyListeners();
  }

  void avviaTimer() {
    if (_inEsecuzione) return;
    _inEsecuzione = true;
    _mostraDialogo = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondiRimanenti > 0) {
        _secondiRimanenti--;
        notifyListeners();
      } else {
        fermaTimer();
        _mostraDialogo = true; // Attiviamo l'avviso
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void fermaTimer() {
    _timer?.cancel();
    _inEsecuzione = false;
    notifyListeners();
  }

  void resettaTimer() {
    fermaTimer();
    _secondiRimanenti = _secondiIniziali;
    _mostraDialogo = false;
    notifyListeners();
  }

  // Chiamato dalla pagina dopo aver mostrato il pop-up per "resettare" l'avviso
  void avvisoVisualizzato() {
    _mostraDialogo = false;
  }
}
