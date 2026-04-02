// lib/screens/pagina_heatmap.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Importa il provider
import '../providers/recupero_provider.dart';

class PaginaHeatmap extends StatelessWidget {
  const PaginaHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ci mettiamo in "ascolto" del provider
    // context.watch farà ricostruire questa pagina ogni volta che chiami notifyListeners() nel provider
    final recuperoData = context.watch<RecuperoProvider>();
    final muscoli = recuperoData.muscoli;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Stato di Recupero Muscolare",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Controlla quali muscoli sono pronti per essere allenati oggi.",
            ),
            const SizedBox(height: 20),

            // Griglia visiva
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                itemCount: muscoli.length,
                itemBuilder: (context, index) {
                  final muscolo = muscoli[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: muscolo.coloreStato.withOpacity(0.2),
                      border: Border.all(color: muscolo.coloreStato, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            muscolo.nome,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: muscolo.coloreStato,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                muscolo.testoStato,
                                style: TextStyle(
                                  color: muscolo.coloreStato,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 2. Bottoni per simulare le azioni
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.fitness_center),
                  label: const Text("Allena Petto e Tricipiti"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // context.read serve per ESEGUIRE un'azione senza ascoltare (ideale per i bottoni)
                    context.read<RecuperoProvider>().allenaMuscoli([
                      'Pettorali',
                      'Tricipiti',
                    ]);
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.bedtime),
                  label: const Text("+1 Giorno"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    context.read<RecuperoProvider>().avanzaGiorno();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
