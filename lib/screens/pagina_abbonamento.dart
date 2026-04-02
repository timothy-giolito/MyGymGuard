import 'package:flutter/material.dart';

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
