import 'package:flutter/material.dart';

void main() {
  runApp(const SpareinApp());
}

class SpareinApp extends StatelessWidget {
  const SpareinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sparein',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const Scaffold(body: Center(child: Text('Sparein'))),
    );
  }
}
