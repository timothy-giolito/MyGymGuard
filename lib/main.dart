import 'package:flutter/material.dart';

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

class PaginaTimer extends StatelessWidget {
  const PaginaTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Qui metteremo il timer di recupero!'));
  }
}

class PaginaSchede extends StatelessWidget {
  const PaginaSchede({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Qui gestiremo le schede di allenamento!'));
  }
}
