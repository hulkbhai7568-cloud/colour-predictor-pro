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
      number.clear();
    });
  }

  int count(String c) =>
      results.where((r) => r['colour'] == c).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'COLOUR PREDICTOR PRO',
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'ADD RESULT',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: period,
            decoration: const InputDecoration(
              labelText: 'Period ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: number,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Number (0-9)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: colour,
            decoration: const InputDecoration(
              labelText: 'Colour',
              border: OutlineInputBorder(),
            ),
            items: ['Green', 'Red', 'Violet'].map((c) {
              return DropdownMenuItem(
                value: c,
                child: Text(c),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) setState(() => colour = v);
            },
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: addResult,
            child: const Text('ADD RESULT'),
          ),
          const SizedBox(height: 25),
          const Text(
            'COLOUR STATISTICS',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text('🟢 Green: ${count('Green')}'),
          Text('🔴 Red: ${count('Red')}'),
          Text('🟣 Violet: ${count('Violet')}'),
          Text('Total Results: ${results.length}'),
          const SizedBox(height: 25),
          const Text(
            'RESULT HISTORY',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          ...results.map((r) => Card(
                color: const Color(0xFF191919),
                child: ListTile(
                  title: Text('Period: ${r['period']}'),
                  subtitle: Text(
                    'Number: ${r['number']}  |  ${r['colour']}',
                  ),
                ),
              )),
          const SizedBox(height: 15),
          const Text(
            'Note: Statistics are based on entered history. '
            'They cannot guarantee future results.',
            style: TextStyle(color: Colors.orangeAccent),
          ),
        ],
      ),
    );
  }
}
