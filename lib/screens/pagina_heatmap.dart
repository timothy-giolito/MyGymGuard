import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recupero_provider.dart';

// Importiamo il nuovo pacchetto!
import 'package:bodychart_heatmap/bodychart_heatmap.dart';

class PaginaHeatmap extends StatefulWidget {
  const PaginaHeatmap({super.key});

  @override
  State<PaginaHeatmap> createState() => _PaginaHeatmapState();
}

class _PaginaHeatmapState extends State<PaginaHeatmap> {
  // 1. Teniamo traccia di quali muscoli (con il nome in italiano) l'utente ha selezionato
  final List<String> _muscoliSelezionatiIT = [];

  // 2. Il nostro "Dizionario": Mappiamo i tuoi muscoli italiani ai nomi in inglese del pacchetto
  final Map<String, String> _mappaMuscoli = {
    'Pettorali': 'chest',
    'Dorsali': 'back',
    'Trapezio': 'back',
    'Quadricipiti': 'leg',
    'Adduttori': 'leg',
    'Femorali': 'leg',
    'Glutei': 'glute',
    'Polpacci': 'calf',
    'Spalle': 'shoulder',
    'Bicipiti': 'arm',
    'Tricipiti': 'arm',
    'Addominali': 'abs',
  };

  // Metodo per gestire la selezione dalla legenda
  void _toggleMuscolo(String muscoloIT) {
    setState(() {
      if (_muscoliSelezionatiIT.contains(muscoloIT)) {
        _muscoliSelezionatiIT.remove(muscoloIT);
      } else {
        _muscoliSelezionatiIT.add(muscoloIT);
      }
    });
  }

  // Salva l'allenamento usando i nomi in italiano
  void _salvaAllenamento() {
    if (_muscoliSelezionatiIT.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona almeno un muscolo dalla legenda!'),
        ),
      );
      return;
    }

    context.read<RecuperoProvider>().allenaMuscoli(_muscoliSelezionatiIT);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Allenamento registrato con successo!'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
      _muscoliSelezionatiIT.clear();
    });
  }

  // 3. Funzione fondamentale: trasforma la nostra lista italiana in un Set inglese per la grafica
  Set<String> _getMuscoliPerPackage() {
    Set<String> muscoliInglese = {};
    for (String muscoloIT in _muscoliSelezionatiIT) {
      String? nomeInglese = _mappaMuscoli[muscoloIT];
      if (nomeInglese != null) {
        muscoliInglese.add(nomeInglese);
      }
    }
    return muscoliInglese;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Heatmap Muscolare')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Modello 2D",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // 4. IL MODELLO GRAFICO DEL PACCHETTO
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: BodyChart(
                  selectedParts:
                      _getMuscoliPerPackage(), // Passiamo le traduzioni in inglese
                  selectedColor:
                      Colors.blueAccent, // Colore principale (uguale per tutti)
                  unselectedColor: Colors.grey.shade300, // Colore di base
                  viewType: BodyViewType.both, // Mostra sia fronte che retro!
                  width: 250, // Grandezza del disegno
                ),
              ),
            ),
          ),

          const Divider(thickness: 2),

          // 5. LEGENDA E BOTTONE
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Legenda (Seleziona i muscoli allenati):",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  // Creiamo un pulsante per ogni voce nel nostro dizionario italiano
                  children: _mappaMuscoli.keys.map((muscolo) {
                    final isSelezionato = _muscoliSelezionatiIT.contains(
                      muscolo,
                    );
                    return FilterChip(
                      label: Text(muscolo),
                      selected: isSelezionato,
                      selectedColor: Colors.blueAccent.withOpacity(0.4),
                      checkmarkColor: Colors.black,
                      onSelected: (bool selected) {
                        _toggleMuscolo(muscolo);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _salvaAllenamento,
                    icon: const Icon(Icons.fitness_center),
                    label: const Text("Registra Allenamento Manuale"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
