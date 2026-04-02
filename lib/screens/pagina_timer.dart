import 'package:flutter/material.dart';
import 'dart:async';

class PaginaTimer extends StatefulWidget {
  const PaginaTimer({super.key});

  @override
  State<PaginaTimer> createState() => _PaginaTimerState();
}

class _PaginaTimerState extends State<PaginaTimer> {
  // Tempo di base: 90 secondi (1 minuto e mezzo)
  int _secondiIniziali = 00;
  int _secondiRimanenti = 00;

  Timer? _timer; // Il nostro "motore" che conta i secondi
  bool _inEsecuzione = false; // Ci dice se il timer sta andando o è in pausa

  // Funzione per formattare i secondi in formato "Minuti:Secondi"
  String get _testoTempo {
    int minuti = _secondiRimanenti ~/ 60;
    int secondi = _secondiRimanenti % 60;
    return '${minuti.toString().padLeft(2, '0')}:${secondi.toString().padLeft(2, '0')}';
  }

  // --- NUOVA FUNZIONE: L'avviso a comparsa (Pop-up) ---
  void _mostraAvvisoFineRecupero() {
    showDialog(
      context: context,
      // Impedisce di chiudere l'avviso toccando fuori dalla finestra
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⏰ Tempo scaduto!'),
          content: const Text('È ora di tornare a spingere! 💪'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Chiude la finestrella di avviso
                _resettaTimer(); // Riporta l'orologio al tempo iniziale
              },
              child: const Text('OK, ANDIAMO!', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  // Funzione per far partire il timer
  void _avviaTimer() {
    if (_inEsecuzione) return; // Se sta già andando, non facciamo nulla

    setState(() {
      _inEsecuzione = true;
    });

    // Crea un timer che scatta ogni 1 secondo
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondiRimanenti > 0) {
          _secondiRimanenti--; // Togli un secondo
        } else {
          _fermaTimer(); // Il tempo è scaduto, spegni il motore!
          _mostraAvvisoFineRecupero(); // <-- CHIAMIAMO IL NOSTRO AVVISO QUI
        }
      });
    });
  }

  // Funzione per mettere in pausa
  void _fermaTimer() {
    _timer?.cancel(); // Spegne il motore del timer
    setState(() {
      _inEsecuzione = false;
    });
  }

  // Funzione per azzerare tutto e ricominciare
  void _resettaTimer() {
    _fermaTimer();
    setState(() {
      _secondiRimanenti = _secondiIniziali;
    });
  }

  // Funzione per cambiare la durata del recupero dai pulsanti rapidi
  void _impostaDurata(int secondi) {
    _fermaTimer();
    setState(() {
      _secondiIniziali = secondi;
      _secondiRimanenti = secondi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Recupero',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Pulsanti rapidi per scegliere il tempo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _impostaDurata(60),
                child: const Text('1 min'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _impostaDurata(90),
                child: const Text('1.5 min'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _impostaDurata(120),
                child: const Text('2 min'),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // L'orologio grande al centro
          Text(
            _testoTempo,
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),

          const SizedBox(height: 40),

          // Pulsanti Start/Pausa e Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tasto Start/Pausa
              FloatingActionButton.large(
                onPressed: _inEsecuzione ? _fermaTimer : _avviaTimer,
                backgroundColor: _inEsecuzione ? Colors.orange : Colors.green,
                child: Icon(
                  _inEsecuzione ? Icons.pause : Icons.play_arrow,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 30),
              // Tasto Reset
              FloatingActionButton(
                onPressed: _resettaTimer,
                backgroundColor: Colors.red,
                child: const Icon(Icons.stop, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
