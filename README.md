# 🏋️‍♂️ MyGymGuard

MyGymGuard è un'applicazione mobile sviluppata in Flutter pensata per supportarti nella tua routine di allenamento in palestra. Gestisce i tempi di recupero, tiene traccia dei giorni rimanenti del tuo abbonamento e archivia le tue schede di allenamento in modo semplice e intuitivo.

---

## ✨ Funzionalità Principali

L'applicazione è divisa in tre sezioni principali, accessibili tramite una comoda barra di navigazione inferiore:

### 1. 📅 Gestione Abbonamento
Mai più dubbi sulla scadenza del tuo abbonamento!
* **Inserimento data:** Permette di selezionare la data di pagamento tramite un calendario integrato.
* **Calcolo intelligente:** Calcola automaticamente la data di scadenza esatta (aggiungendo 4 settimane / 28 giorni).
* **Giorni di allenamento:** Mostra un conto alla rovescia dei giorni "utili" di allenamento rimanenti, escludendo automaticamente i sabati e le domeniche.

### 2. ⏱️ Timer di Recupero
Ottimizza i tuoi tempi di riposo tra una serie e l'altra.
* **Pulsanti rapidi:** Imposta istantaneamente il timer sui tempi di recupero più comuni (1 minuto, 1.5 minuti, 2 minuti).
* **Controlli completi:** Avvia, metti in pausa o resetta il conto alla rovescia in qualsiasi momento.
* **Avviso fine recupero:** Un comodo pop-up visivo ti avvisa quando il tempo è scaduto, ricordandoti di tornare a spingere! Una volta chiuso l'avviso, il timer si resetta automaticamente.

### 3. 📁 Archivio Schede di Allenamento
Porta sempre con te i tuoi programmi di allenamento, senza bisogno di carta.
* **Gestione documenti:** Permette di caricare e salvare le proprie schede di allenamento direttamente nell'app.
* **Supporto multi-formato:** Puoi scattare una foto alla tua scheda cartacea (usando la fotocamera) oppure caricare un file PDF dalla memoria del telefono.
* **Nomi personalizzati:** Assegna un nome specifico a ogni scheda (es. "Massa A", "Forza B") per trovarla facilmente in una lista ordinata.

---

## 🛠️ Tecnologie Utilizzate

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Design:** Material Design 3
* **Librerie esterne (Pacchetti):**
  * `image_picker`: Per l'acquisizione di foto tramite la fotocamera del dispositivo.
  * `file_picker`: Per la selezione e il caricamento di file PDF.

---

## 🚀 Come avviare il progetto

Se desideri scaricare il codice e far girare l'app sul tuo computer o telefono:

1. Assicurati di aver installato **Flutter** e **Dart** sul tuo computer.
2. Clona questo repository o scarica i file.
3. Apri il terminale nella cartella principale del progetto (`my_gym_guard`).
4. Scarica le dipendenze necessarie eseguendo il comando:
   ```bash
   flutter pub get
5. Collega il tuo smartphone (con Debug USB attivo) oppure, avvia un emulatore
6. Lancia l'applicazione con il comando:
   ```bash
   flutter run
---

Progetto sviluppato come assistente per l'allenamento personale e in fase di sviluppo.
