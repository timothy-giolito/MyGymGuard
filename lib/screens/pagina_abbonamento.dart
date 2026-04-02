import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/abbonamento_provider.dart';

class PaginaAbbonamento extends StatelessWidget {
  const PaginaAbbonamento({super.key});

  // Funzione che apre il popup per registrare il pagamento
  void _mostraDialogoPagamento(BuildContext context) {
    // Valori iniziali quando apri il popup
    DateTime dataSelezionata = DateTime.now();
    int mesiSelezionati = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Registra Pagamento'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Quando hai pagato l'abbonamento?"),
                const SizedBox(height: 8),
                // Selettore della data
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    DateFormat('dd/MM/yyyy').format(dataSelezionata),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(
                    Icons.calendar_today,
                    color: Colors.deepPurple,
                  ),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: dataSelezionata,
                      firstDate: DateTime(
                        2020,
                      ), // Puoi inserire pagamenti vecchi
                      lastDate: DateTime.now(), // Fino ad oggi
                    );
                    if (picked != null) {
                      setStateDialog(() {
                        dataSelezionata = picked;
                      });
                    }
                  },
                ),
                const Divider(),
                const SizedBox(height: 8),
                // Selettore della durata
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Durata:"),
                    DropdownButton<int>(
                      value: mesiSelezionati,
                      items: [1, 3, 6, 12].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text("$value ${value == 1 ? 'mese' : 'mesi'}"),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setStateDialog(() {
                            mesiSelezionati = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annulla'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Salviamo i dati nel Provider!
                  context.read<AbbonamentoProvider>().registraPagamento(
                    dataSelezionata,
                    mesiSelezionati,
                  );
                  Navigator.pop(context); // Chiude il popup
                },
                child: const Text('Salva'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final abbProvider = context.watch<AbbonamentoProvider>();
    final scadenza = abbProvider.dataScadenza;
    final pagamento = abbProvider.dataPagamento;

    // Definiamo un colore e un messaggio per lo stato attuale
    Color coloreStato = Colors.redAccent;
    String testoStato = "Abbonamento Scaduto";
    IconData iconaStato = Icons.card_membership;

    if (abbProvider.isAttivo) {
      if (abbProvider.possoEntrareOggi) {
        coloreStato = Colors.green;
        testoStato = "Accesso Consentito Oggi";
        iconaStato = Icons.check_circle;
      } else {
        coloreStato = Colors.orange;
        testoStato = "Oggi Non Puoi Accedere\n(Solo Lun-Ven)";
        iconaStato = Icons.lock_clock;
      }
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconaStato, size: 100, color: coloreStato),
            const SizedBox(height: 20),
            Text(
              testoStato,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: coloreStato,
              ),
            ),
            const SizedBox(height: 15),

            // Dettagli delle date
            if (pagamento != null) ...[
              Text(
                "Ultimo pagamento: ${DateFormat('dd/MM/yyyy').format(pagamento)}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 5),
              Text(
                "Scade il: ${DateFormat('dd/MM/yyyy').format(scadenza!)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Giorni utili rimanenti (Lun-Ven): ${abbProvider.giorniRimanenti}",
                style: const TextStyle(fontSize: 16),
              ),
            ] else ...[
              const Text(
                "Nessun pagamento registrato",
                style: TextStyle(fontSize: 18),
              ),
            ],

            const SizedBox(height: 40),

            // Bottone che apre il popup
            ElevatedButton.icon(
              onPressed: () => _mostraDialogoPagamento(context),
              icon: const Icon(Icons.payment),
              label: const Text("Registra Pagamento"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
