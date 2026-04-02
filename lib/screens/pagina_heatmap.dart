import 'package:flutter/material.dart';

// 1. Definiamo il modello dati per lo stato del muscolo
class StatoMuscolo {
  final String nome;
  double livelloRecupero; // Da 0.0 (distrutto) a 1.0 (completamente fresco)

  StatoMuscolo({required this.nome, required this.livelloRecupero});

  // Logica per assegnare il colore in base al recupero
  Color get coloreStato {
    if (livelloRecupero <= 0.3) return Colors.redAccent; // Affaticato
    if (livelloRecupero <= 0.7) return Colors.orangeAccent; // In recupero
    return Colors.green; // Fresco
  }

  // Etichetta testuale
  String get testoStato {
    if (livelloRecupero <= 0.3) return "Affaticato";
    if (livelloRecupero <= 0.7) return "In Recupero";
    return "Pronto";
  }
}

class PaginaHeatmap extends StatefulWidget {
  const PaginaHeatmap({super.key});

  @override
  State<PaginaHeatmap> createState() => _PaginaHeatmapState();
}

class _PaginaHeatmapState extends State<PaginaHeatmap> {
  // 2. Creiamo una lista fittizia di muscoli per testare la UI
  // In futuro, questi dati verranno aggiornati quando salvi un allenamento
  final List<StatoMuscolo> _muscoli = [
    StatoMuscolo(
      nome: 'Pettorali',
      livelloRecupero: 0.2,
    ), // Allenati di recente
    StatoMuscolo(nome: 'Dorsali', livelloRecupero: 0.8),
    StatoMuscolo(nome: 'Quadricipiti', livelloRecupero: 0.5),
    StatoMuscolo(nome: 'Femorali', livelloRecupero: 0.9),
    StatoMuscolo(nome: 'Spalle', livelloRecupero: 1.0), // Freschissime
    StatoMuscolo(nome: 'Bicipiti', livelloRecupero: 0.3),
    StatoMuscolo(nome: 'Tricipiti', livelloRecupero: 0.2),
    StatoMuscolo(nome: 'Addominali', livelloRecupero: 0.6),
  ];

  @override
  Widget build(BuildContext context) {
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

            // 3. Griglia visiva (la nostra Heatmap logica)
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 colonne
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5, // Proporzione larghezza/altezza
                ),
                itemCount: _muscoli.length,
                itemBuilder: (context, index) {
                  final muscolo = _muscoli[index];
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
          ],
        ),
      ),
    );
  }
}
