import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

// Modello dati per la singola scheda
class SchedaAllenamento {
  final String nome;
  final String percorsoFile;
  final bool isImage; // true se è una foto, false se è un PDF

  SchedaAllenamento({
    required this.nome,
    required this.percorsoFile,
    required this.isImage,
  });
}

class PaginaSchede extends StatefulWidget {
  const PaginaSchede({super.key});

  @override
  State<PaginaSchede> createState() => _PaginaSchedeState();
}

class _PaginaSchedeState extends State<PaginaSchede> {
  // La nostra lista (archivio) di schede salvate
  final List<SchedaAllenamento> _mieSchede = [];
  final ImagePicker _picker = ImagePicker();

  // Funzione per aggiungere una nuova scheda alla lista
  void _aggiungiScheda(String nome, String path, bool isImage) {
    setState(() {
      _mieSchede.add(
        SchedaAllenamento(nome: nome, percorsoFile: path, isImage: isImage),
      );
    });
  }

  // Finestra di dialogo per chiedere il nome e il tipo di file
  void _mostraDialogoCaricamento() {
    String nomeInserito = "";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuova Scheda'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: "Nome della scheda (es. Massa A)",
          ),
          onChanged: (value) => nomeInserito = value,
        ),
        actions: [
          // Opzione Foto
          TextButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Foto'),
            onPressed: () async {
              if (nomeInserito.isEmpty) return;
              final XFile? foto = await _picker.pickImage(
                source: ImageSource.camera,
              );
              if (foto != null) {
                _aggiungiScheda(nomeInserito, foto.path, true);
                Navigator.pop(context);
              }
            },
          ),
          // Opzione PDF
          TextButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('PDF'),
            onPressed: () async {
              if (nomeInserito.isEmpty) return;
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf'],
              );
              if (result != null) {
                _aggiungiScheda(nomeInserito, result.files.single.path!, false);
                Navigator.pop(context);
              }
            },
          ),
        ],
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
                    scheda.percorsoFile.split('/').last,
                  ), // Mostra il nome del file
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
