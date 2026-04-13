import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Creiamo l'istanza del pacchetto
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Funzione per inizializzare le notifiche all'avvio dell'app
  static Future<void> init() async {
    // Usiamo l'icona di default di Android (quella che hai in res/mipmap)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse response) async {},
    );

    // Chiediamo il permesso all'utente (obbligatorio per Android 13+)
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // Funzione per mostrare il timer
  static Future<void> mostraTimer(int secondiRimanenti) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'timer_palestra_channel', // Un ID univoco per il canale
      'Timer Palestra', // Nome visibile nelle impostazioni
      channelDescription: 'Mostra il timer di recupero',
      importance: Importance.max,
      priority: Priority.high,
      ongoing:
          true, // Rende la notifica fissa (non eliminabile con lo swipe) finché non la cancelliamo noi
      usesChronometer: true, // Attiva il timer automatico di Android
      chronometerCountDown: true, // Imposta il timer come conto alla rovescia
      // Diciamo ad Android quando finirà il timer
      when: DateTime.now().millisecondsSinceEpoch + (secondiRimanenti * 1000),
    );

    NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: 0, // ID della notifica
      title: 'Recupero in corso ⏱️',
      body: 'Torna a spingere tra poco!',
      notificationDetails: details,
    );
  }

  // Funzione per togliere la notifica quando il timer scade o viene fermato
  static Future<void> cancellaTimer() async {
    await _notificationsPlugin.cancel(id: 0);
  }
}
 