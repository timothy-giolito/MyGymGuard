import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

// 1. IMPORTA IL PROVIDER
import '../providers/recupero_provider.dart';

// Modello dati per la singola scheda
class SchedaAllenamento {
  final String nome;
  final String percorsoFile;
  final bool isImage; // true se è una foto, false se è un PDF
  final List<String>
  muscoliCoinvolti; // 2. NUOVO: Lista dei muscoli che questa scheda allena

  SchedaAllenamento({
    required this.nome,
    required this.percorsoFile,
    required this.isImage,
    required this.muscoliCoinvolti,
  });
}

class PaginaSchede extends StatefulWidget {
  const PaginaSchede({super.key});

  @override
  State<PaginaSchede> createState() => _PaginaSchedeState();
}

class _PaginaSchedeState extends State<PaginaSchede> {
  final List<SchedaAllenamento> _mieSchede = [];
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
  }

  void _mostraDialogoCaricamento() {
    String nomeInserito = "";
    List<String> muscoliSelezionati =
        []; // Tiene traccia dei muscoli scelti nel dialog

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        // StatefulBuilder serve per far funzionare le checkbox nel popup
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
                  // 3. SELEZIONE MUSCOLI: Creiamo dei "chip" cliccabili
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
                  // Mostriamo i muscoli taggati come sottotitolo
                  subtitle: Text(
                    scheda.muscoliCoinvolti.isEmpty
                        ? 'Nessun muscolo taggato'
                        : scheda.muscoliCoinvolti.join(', '),
                    style: const TextStyle(fontSize: 12),
                  ),
                  // 4. BOTTONE COMPLETA ALLENAMENTO
                  trailing: IconButton(
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

                      // CHIAMATA AL PROVIDER!
                      // Questo aggiornerà automaticamente la Heatmap
                      context.read<RecuperoProvider>().allenaMuscoli(
                        scheda.muscoliCoinvolti,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Allenamento completato! Heatmap aggiornata.',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    // Qui in futuro aggiungeremo la funzione per APRIRE e vedere il file
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Apertura di: ${scheda.nome}')),
                    );
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
