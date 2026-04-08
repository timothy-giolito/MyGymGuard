import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';

class PaginaTimer extends StatelessWidget {
  const PaginaTimer({super.key});

  // Funzione per il pop-up (rimane nella pagina perché serve il context)
  void _mostraAvvisoFineRecupero(BuildContext context, TimerProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⏰ Tempo scaduto!'),
          content: const Text('È ora di tornare a spingere! 💪'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                provider.resettaTimer();
              },
              child: const Text('OK, ANDIAMO!', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  String _formattaTestoPulsante(int sec) {
    if (sec < 60) return '$sec sec';
    double min = sec / 60;
    return min == min.toInt() ? '${min.toInt()} min' : '$min min';
  }

  @override
  Widget build(BuildContext context) {
    // Ascoltiamo il provider
    final timerProvider = context.watch<TimerProvider>();

    // Controlliamo se il timer è finito mentre eravamo in un'altra pagina
    if (timerProvider.mostraDialogo) {
      // Usiamo addPostFrameCallback per mostrare il dialogo dopo che la pagina è stata costruita
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (timerProvider.mostraDialogo) {
          _mostraAvvisoFineRecupero(context, timerProvider);
          timerProvider.avvisoVisualizzato();
        }
      });
    }

    final List<int> duratePreimpostate = [30, 60, 90, 120, 180, 240, 300];

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Scegli durata recupero:',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: duratePreimpostate.map((secondi) {
                  return ElevatedButton(
                    onPressed: () => timerProvider.impostaDurata(secondi),
                    child: Text(_formattaTestoPulsante(secondi)),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              timerProvider.testoTempo,
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.large(
                  onPressed: timerProvider.inEsecuzione
                      ? timerProvider.fermaTimer
                      : timerProvider.avviaTimer,
                  backgroundColor: timerProvider.inEsecuzione
                      ? Colors.orange
                      : Colors.green,
                  child: Icon(
                    timerProvider.inEsecuzione ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 30),
                FloatingActionButton(
                  onPressed: timerProvider.resettaTimer,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.stop, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
