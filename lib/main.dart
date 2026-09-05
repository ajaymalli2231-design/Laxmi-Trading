import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LaxmiTradingApp());
}

class LaxmiTradingApp extends StatelessWidget {
  const LaxmiTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laxmi Trading',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Laxmi Trading'),
          backgroundColor: const Color(0xFF1F1F1F),
        ),
        body: const Center(
          child: Text(
            'Laxmi Trading App is Ready!',
            style: TextStyle(fontSize: 20, color: Colors.greenAccent),
          ),
        ),
      ),
    );
  }
}
