import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'providers/recupero_provider.dart';
import 'screens/main_screen.dart';
import 'providers/abbonamento_provider.dart';
import 'providers/timer_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('myGymBox');

  runApp(
    // Usiamo MultiProvider per gestire più "cervelli" nell'app
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RecuperoProvider()),
        ChangeNotifierProvider(create: (context) => AbbonamentoProvider()),
        ChangeNotifierProvider(create: (context) => TimerProvider()),
      ],
      child: const MyGymGuardApp(),
    ),
  );
}

class MyGymGuardApp extends StatelessWidget {
  const MyGymGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Gym Guard',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('it', 'IT')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
