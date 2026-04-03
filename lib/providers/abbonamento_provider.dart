import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Definiamo i due tipi di abbonamento possibili
enum TipoAbbonamento { feriale, completo }

class AbbonamentoProvider extends ChangeNotifier {
  DateTime? _dataPagamento;
  int _durataMesi = 1;
  // Impostiamo di default l'abbonamento feriale
  TipoAbbonamento _tipoAbbonamento = TipoAbbonamento.feriale;

  DateTime? get dataPagamento => _dataPagamento;
  int get durataMesi => _durataMesi;
  TipoAbbonamento get tipoAbbonamento => _tipoAbbonamento;

  DateTime? get dataScadenza {
    if (_dataPagamento == null) return null;
    return DateTime(
      _dataPagamento!.year,
      _dataPagamento!.month + _durataMesi,
      _dataPagamento!.day,
    );
  }

  // Modificato per calcolare i giorni in base al tipo di abbonamento
  int get giorniRimanenti {
    if (dataScadenza == null) return 0;

    final ora = DateTime.now();
    // Se è già scaduto, i giorni sono 0
    if (dataScadenza!.isBefore(ora)) return 0;

    int giorniUtili = 0;
    DateTime giornoCorrente = ora;

    // Cicla giorno per giorno fino alla scadenza
    while (giornoCorrente.isBefore(dataScadenza!)) {
      if (_tipoAbbonamento == TipoAbbonamento.completo) {
        // Se è completo, contiamo tutti i giorni
        giorniUtili++;
      } else {
        // Se è feriale, contiamo solo dal Lunedì (1) al Venerdì (5)
        if (giornoCorrente.weekday >= 1 && giornoCorrente.weekday <= 5) {
          giorniUtili++;
        }
      }
      giornoCorrente = giornoCorrente.add(const Duration(days: 1));
    }

    return giorniUtili;
  }

  // Verifica se l'abbonamento non è scaduto (indipendentemente dai giorni della settimana)
  bool get isAttivo {
    if (dataScadenza == null) return false;
    return dataScadenza!.isAfter(DateTime.now());
  }

  // Modificato: Verifica se oggi l'utente può entrare in base al tipo di abbonamento
  bool get possoEntrareOggi {
    if (!isAttivo) return false;

    // Se ha l'abbonamento completo, può sempre entrare
    if (_tipoAbbonamento == TipoAbbonamento.completo) return true;

    // Se ha l'abbonamento feriale, controlliamo che sia tra Lunedì e Venerdì
    final giornoDellaSettimana = DateTime.now().weekday;
    return giornoDellaSettimana >= 1 && giornoDellaSettimana <= 5;
  }

  AbbonamentoProvider() {
    _caricaDati();
  }

  void _caricaDati() {
    var box = Hive.box('myGymBox');
    String? dataString = box.get('data_pagamento');
    int? mesi = box.get('durata_mesi');
    int? tipoIndex = box.get('tipo_abbonamento'); // Recuperiamo il tipo salvato

    if (dataString != null) {
      _dataPagamento = DateTime.parse(dataString);
    }
    if (mesi != null) {
      _durataMesi = mesi;
    }
    if (tipoIndex != null) {
      // Convertiamo l'indice salvato nell'enum corrispondente
      _tipoAbbonamento = TipoAbbonamento.values[tipoIndex];
    }
    notifyListeners();
  }

  // Modificato: ora accetta anche il tipo di abbonamento
  void registraPagamento(DateTime data, int mesi, TipoAbbonamento tipo) {
    _dataPagamento = data;
    _durataMesi = mesi;
    _tipoAbbonamento = tipo;

    var box = Hive.box('myGymBox');
    box.put('data_pagamento', data.toIso8601String());
    box.put('durata_mesi', mesi);
    box.put(
      'tipo_abbonamento',
      tipo.index,
    ); // Salviamo l'indice dell'enum (0 o 1)

    notifyListeners();
  }
}
