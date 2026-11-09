import 'package:flutter/material.dart';

void main() {
  runApp(const ColourApp());
}

class ColourApp extends StatelessWidget {
  const ColourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'COLOUR PREDICTOR PRO',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF080808),
        colorScheme: const ColorScheme.dark(
          primary: Colors.greenAccent,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final period = TextEditingController();
  final number = TextEditingController();
  final List<Map<String, dynamic>> results = [];

  String colour = 'Green';

  void addResult() {
    if (period.text.isEmpty ||
        number.text.isEmpty ||
        int.tryParse(number.text) == null ||
        int.parse(number.text) < 0 ||
        int.parse(number.text) > 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid Period ID and Number 0-9')),
      );
      return;
    }

    if (results.any((r) => r['period'] == period.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Period ID already exists')),
      );
      return;
    }

    setState(() {
      results.insert(0, {
        'period': period.text,
        'number': int.parse(number.text),
        'colour': colour,
      });
      period.clear();
