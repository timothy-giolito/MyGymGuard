import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recupero_provider.dart';

class PaginaDashboard extends StatelessWidget {
  const PaginaDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Ci mettiamo in ascolto del provider per aggiornare le barre in tempo reale
    final recuperoProvider = context.watch<RecuperoProvider>();
    final muscoli = recuperoProvider.muscoli;

    return Column(
      children: [
        // Intestazione con riassunto rapido
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.blue.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bolt, color: Colors.orange),
              const SizedBox(width: 10),
              Text(
                "${muscoli.where((m) => m.livelloRecupero > 0.7).length} muscoli su ${muscoli.length} pronti",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Lista a scorrimento dei muscoli
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: muscoli.length,
            itemBuilder: (context, index) {
              final muscolo = muscoli[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            muscolo.nome,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            muscolo.testoStato,
                            style: TextStyle(
                              color: muscolo.coloreStato,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // La barra di progresso orizzontale
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: muscolo.livelloRecupero,
                          minHeight: 10,
                          backgroundColor: Colors.grey[200],
                          // Il colore cambia dinamicamente in base al recupero (verde, arancione o rosso)
                          valueColor: AlwaysStoppedAnimation<Color>(
                            muscolo.coloreStato,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
