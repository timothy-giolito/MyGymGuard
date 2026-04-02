import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AbbonamentoProvider extends ChangeNotifier {
  DateTime? _dataPagamento;
  int _durataMesi = 1;

  DateTime? get dataPagamento => _dataPagamento;
  int get durataMesi => _durataMesi;

  DateTime? get dataScadenza {
    if (_dataPagamento == null) return null;
    return DateTime(
      _dataPagamento!.year,
      _dataPagamento!.month + _durataMesi,
      _dataPagamento!.day,
    );
  }

  // NUOVO: Calcola SOLO i giorni feriali (Lunedì - Venerdì)
  int get giorniRimanenti {
    if (dataScadenza == null) return 0;

    final ora = DateTime.now();
    // Se è già scaduto, i giorni sono 0
    if (dataScadenza!.isBefore(ora)) return 0;

    int giorniUtili = 0;
    DateTime giornoCorrente = ora;

    // Cicla giorno per giorno fino alla scadenza
    while (giornoCorrente.isBefore(dataScadenza!)) {
      // 1 = Lunedì, 5 = Venerdì, 6 = Sabato, 7 = Domenica
      if (giornoCorrente.weekday >= 1 && giornoCorrente.weekday <= 5) {
        giorniUtili++;
      }
      giornoCorrente = giornoCorrente.add(const Duration(days: 1));
    }

    return giorniUtili;
  }

  // Verifica se l'abbonamento non è scaduto
  bool get isAttivo {
    if (dataScadenza == null) return false;
    return dataScadenza!.isAfter(DateTime.now());
  }

  // NUOVO: Verifica se l'abbonamento è attivo E oggi è tra Lunedì e Venerdì
  bool get possoEntrareOggi {
    if (!isAttivo) return false;
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

    if (dataString != null) {
      _dataPagamento = DateTime.parse(dataString);
    }
    if (mesi != null) {
      _durataMesi = mesi;
    }
    notifyListeners();
  }

  void registraPagamento(DateTime data, int mesi) {
    _dataPagamento = data;
    _durataMesi = mesi;

    var box = Hive.box('myGymBox');
    box.put('data_pagamento', data.toIso8601String());
    box.put('durata_mesi', mesi);

    notifyListeners();
  }
}
