import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyGymGuardApp());
}

// Questa è la classe principale della tua applicazione
class MyGymGuardApp extends StatelessWidget {
  const MyGymGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Gym Guard',
      // Scegliamo un tema scuro o chiaro. Qui usiamo un blu sportivo!
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      // Impostiamo la pagina iniziale
      home: const MainScreen(),
    );
  }
}

// Questa schermata gestirà la navigazione tra le 3 funzioni principali
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Questa variabile tiene traccia di quale pagina stiamo guardando (0, 1 o 2)
  int _indiceAttuale = 0;

  // Questa è una lista delle nostre 3 pagine (per ora sono solo testi centrati)
  final List<Widget> _pagine = [
    const PaginaAbbonamento(),
    const PaginaTimer(),
    const PaginaSchede(),
  ];

  // Funzione che cambia la pagina quando tocchi un'icona
  void _cambiaPagina(int index) {
    setState(() {
      _indiceAttuale = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gym Guard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // Mostriamo la pagina corrispondente all'indice attuale
      body: _pagine[_indiceAttuale],

      // La barra di navigazione in basso
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAttuale,
        onTap: _cambiaPagina, // Chiama la funzione quando tocchi un'icona
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Abbonamento',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Schede'),
        ],
      ),
    );
  }
}

// --- Qui definiamo le tre schermate "segnaposto" ---

class PaginaAbbonamento extends StatefulWidget {
  const PaginaAbbonamento({super.key});

  @override
  State<PaginaAbbonamento> createState() => _PaginaAbbonamentoState();
}

class _PaginaAbbonamentoState extends State<PaginaAbbonamento> {
  // Queste variabili salvano le date. "DateTime?" col punto interrogativo
  // significa che all'inizio possono essere vuote (null).
  DateTime? _dataPagamento;
  DateTime? _dataScadenza;
  int _giorniRimanenti = 0;

  // Funzione per mostrare il calendario a schermo
  Future<void> _selezionaData(BuildContext context) async {
    final DateTime? dataSelezionata = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Parte da oggi
      firstDate: DateTime(2024), // Non si può andare prima del 2024
      lastDate: DateTime(2030), // Arriva fino al 2030
    );

    // Se l'utente ha scelto una data e ha premuto "OK"
    if (dataSelezionata != null) {
      // setState dice all'app di ricaricare lo schermo con i nuovi dati
      setState(() {
        _dataPagamento = dataSelezionata;
        _calcolaScadenza();
      });
    }
  }

  // Funzione che fa i calcoli matematici
  void _calcolaScadenza() {
    if (_dataPagamento == null) return;

    // 1. Calcola la scadenza aggiungendo 4 settimane (28 giorni solari)
    _dataScadenza = _dataPagamento!.add(const Duration(days: 28));

    // 2. Calcola i giorni utili rimanenti (da oggi alla scadenza)
    DateTime oggi = DateTime.now();
    // Resettiamo l'orario a mezzanotte per non sballare i calcoli
    oggi = DateTime(oggi.year, oggi.month, oggi.day);
    DateTime scadenza = DateTime(
      _dataScadenza!.year,
      _dataScadenza!.month,
      _dataScadenza!.day,
    );

    int giorni = 0;
    DateTime dataCorrente = oggi;

    // Contiamo un giorno alla volta fino alla scadenza
    while (dataCorrente.isBefore(scadenza)) {
      // Se NON è Sabato (6) e NON è Domenica (7), aggiungi un giorno utile
      if (dataCorrente.weekday != DateTime.saturday &&
          dataCorrente.weekday != DateTime.sunday) {
        giorni++;
      }
      // Passa al giorno successivo
      dataCorrente = dataCorrente.add(const Duration(days: 1));
    }

    // Se l'abbonamento è scaduto (giorni negativi), impostiamo a 0
    _giorniRimanenti = giorni < 0 ? 0 : giorni;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Il Tuo Abbonamento',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Testo che mostra la data di pagamento (se presente)
            Text(
              _dataPagamento == null
                  ? 'Nessun pagamento registrato.'
                  : 'Data Pagamento: ${_dataPagamento!.day}/${_dataPagamento!.month}/${_dataPagamento!.year}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Testo che mostra la scadenza (appare solo se è stata scelta una data)
            if (_dataScadenza != null)
              Text(
                'Scadenza: ${_dataScadenza!.day}/${_dataScadenza!.month}/${_dataScadenza!.year}',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),

            const SizedBox(height: 20),

            // Il riquadro che mostra i giorni rimanenti (esclusi i weekend)
            if (_dataScadenza != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Giorni d\'allenamento rimanenti\n(esclusi sab e dom): $_giorniRimanenti',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 40),

            // Il bottone magico per aprire il calendario
            ElevatedButton.icon(
              onPressed: () => _selezionaData(context),
              icon: const Icon(Icons.calendar_month),
              label: const Text('Inserisci data di pagamento'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
