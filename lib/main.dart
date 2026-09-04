import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LaxmiTradingAppInitializer());
}

class LaxmiTradingAppInitializer extends StatelessWidget {
  const LaxmiTradingAppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laxmi Trading',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Firebase Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return const LaxmiTradingApp();
          }
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: Center(
              child: CircularProgressIndicator(color: Colors.amber),
            ),
          );
        },
      ),
    );
  }
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
      home: const Scaffold(
        body: Center(
          child: Text('Laxmi Trading Home Screen', style: TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ),
    );
  }
}
