import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../providers/recupero_provider.dart';

// Modello dati per la singola scheda
class SchedaAllenamento {
  final String nome;
  final String percorsoFile;
  final bool isImage; // true se è una foto, false se è un PDF
  final List<String>
  muscoliCoinvolti; // Lista dei muscoli che questa scheda allena

  SchedaAllenamento({
    required this.nome,
    required this.percorsoFile,
    required this.isImage,
    required this.muscoliCoinvolti,
  });

  // Converte l'oggetto in una Mappa per salvarlo nel database
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'percorsoFile': percorsoFile,
      'isImage': isImage,
      'muscoliCoinvolti': muscoliCoinvolti,
    };
  }

  // Ricostruisce l'oggetto leggendo la Mappa dal database
  factory SchedaAllenamento.fromMap(Map<dynamic, dynamic> map) {
    return SchedaAllenamento(
      nome: map['nome'],
      percorsoFile: map['percorsoFile'],
      isImage: map['isImage'],
      // Hive salva le liste come dynamic, dobbiamo specificare che sono Stringhe
      muscoliCoinvolti: List<String>.from(map['muscoliCoinvolti'] ?? []),
    );
  }
}

class PaginaSchede extends StatefulWidget {
  const PaginaSchede({super.key});

  @override
  State<PaginaSchede> createState() => _PaginaSchedeState();
}

class _PaginaSchedeState extends State<PaginaSchede> {
  // Rimosso "final" per poter caricare la lista all'avvio
  List<SchedaAllenamento> _mieSchede = [];
  final ImagePicker _picker = ImagePicker();

  // I muscoli disponibili (devono coincidere con i nomi nel tuo RecuperoProvider)
  final List<String> _tuttiIMuscoli = [
    'Pettorali',
    'Dorsali',
    'Quadricipiti',
    'Femorali',
    'Spalle',
    'Bicipiti',
    'Tricipiti',
    'Addominali',
  ];

  // Appena la pagina viene creata, carica le schede salvate
  @override
  void initState() {
    super.initState();
    _caricaSchedeDalDatabase();
  }

  // Metodo per leggere le schede dal database
  void _caricaSchedeDalDatabase() {
    var box = Hive.box('myGymBox');
    List? schedeSalvate = box.get('lista_schede');

    if (schedeSalvate != null) {
      setState(() {
        _mieSchede = schedeSalvate
            .map((mappa) => SchedaAllenamento.fromMap(mappa))
            .toList();
      });
    }
  }

  // Metodo per salvare l'intera lista nel database
  void _salvaSchedeNelDatabase() {
    var box = Hive.box('myGymBox');
    List schedeDaSalvare = _mieSchede.map((scheda) => scheda.toMap()).toList();
    box.put('lista_schede', schedeDaSalvare);
  }

  void _aggiungiScheda(
    String nome,
    String path,
    bool isImage,
    List<String> muscoli,
  ) {
    setState(() {
      _mieSchede.add(
        SchedaAllenamento(
          nome: nome,
          percorsoFile: path,
          isImage: isImage,
          muscoliCoinvolti: muscoli,
        ),
      );
    });
    // Salva nel database ogni volta che aggiungiamo una nuova scheda!
    _salvaSchedeNelDatabase();
  }

  // NUOVO METODO: Gestisce la conferma e l'eliminazione della scheda
  void _confermaCancellazione(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Scheda'),
        content: Text(
          'Sei sicuro di voler eliminare la scheda "${_mieSchede[index].nome}"?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context), // Chiude il pop-up senza fare nulla
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _mieSchede.removeAt(
                  index,
                ); // Rimuove la scheda dalla lista visiva
              });
              _salvaSchedeNelDatabase(); // Aggiorna il database per riflettere la rimozione
              Navigator.pop(context); // Chiude il pop-up

              // Mostra un piccolo avviso in basso per confermare l'azione
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Scheda eliminata')));
            },
            child: const Text(
              'Elimina',
              style: TextStyle(
                color: Colors.red,
              ), // Testo rosso per indicare un'azione distruttiva
            ),
          ),
        ],
      ),
    );
  }

  void _mostraDialogoCaricamento() {
    String nomeInserito = "";
    List<String> muscoliSelezionati = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Nuova Scheda'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: "Nome della scheda (es. Massa A)",
                    ),
                    onChanged: (value) => nomeInserito = value,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Quali muscoli allena?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    children: _tuttiIMuscoli.map((muscolo) {
                      final isSelected = muscoliSelezionati.contains(muscolo);
                      return FilterChip(
                        label: Text(muscolo),
                        selected: isSelected,
                        onSelected: (selected) {
                          setStateDialog(() {
                            if (selected) {
                              muscoliSelezionati.add(muscolo);
                            } else {
                              muscoliSelezionati.remove(muscolo);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Foto'),
                onPressed: () async {
                  if (nomeInserito.isEmpty) return;
                  final XFile? foto = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (foto != null) {
                    _aggiungiScheda(
                      nomeInserito,
                      foto.path,
                      true,
                      muscoliSelezionati,
                    );
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('PDF'),
                onPressed: () async {
                  if (nomeInserito.isEmpty) return;
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                      );
                  if (result != null) {
                    _aggiungiScheda(
                      nomeInserito,
                      result.files.single.path!,
                      false,
                      muscoliSelezionati,
                    );
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _mieSchede.isEmpty
          ? const Center(child: Text('Nessuna scheda salvata. Aggiungine una!'))
          : ListView.builder(
              itemCount: _mieSchede.length,
              itemBuilder: (context, index) {
                final scheda = _mieSchede[index];
                return ListTile(
                  leading: Icon(
                    scheda.isImage ? Icons.image : Icons.picture_as_pdf,
                  ),
                  title: Text(scheda.nome),
                  subtitle: Text(
                    scheda.muscoliCoinvolti.isEmpty
                        ? 'Nessun muscolo taggato'
                        : scheda.muscoliCoinvolti.join(', '),
                    style: const TextStyle(fontSize: 12),
                  ),
                  // MODIFICA: Ora c'è una "Row" per ospitare due pulsanti (Completa e Cancella)
                  trailing: Row(
                    mainAxisSize: MainAxisSize
                        .min, // Importante per non far occupare tutta la larghezza alla Row
                    children: [
                      // Pulsante per completare l'allenamento (Già esistente)
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 30,
                        ),
                        tooltip: "Completa Allenamento",
                        onPressed: () {
                          if (scheda.muscoliCoinvolti.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Nessun muscolo associato a questa scheda!',
                                ),
                              ),
                            );
                            return;
                          }

                          context.read<RecuperoProvider>().allenaMuscoli(
                            scheda.muscoliCoinvolti,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Allenamento completato! Heatmap aggiornata.',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                      // NUOVO PULSANTE: Elimina Scheda
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 30,
                        ),
                        tooltip: "Elimina Scheda",
                        onPressed: () => _confermaCancellazione(index),
                      ),
                    ],
                  ),
                  onTap: () async {
                    final result = await OpenFilex.open(scheda.percorsoFile);

                    if (result.type != ResultType.done && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Impossibile aprire il file: ${result.message}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostraDialogoCaricamento,
        child: const Icon(Icons.add),
      ),
    );
  }
}
