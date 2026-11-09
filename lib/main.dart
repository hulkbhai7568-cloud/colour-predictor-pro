import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Colour Trading Analyzer',
      theme: ThemeData.dark(),
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
  static const String apiUrl =
      'https://draw.ar-lottery01.com/WinGo/WinGo_30S/GetHistoryIssuePage.json';

  List<dynamic> results = [];
  String error = '';
  bool loading = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => fetchData(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    if (loading) return;
    setState(() => loading = true);

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode != 200) {
        throw Exception('Server error');
      }

      final decoded = jsonDecode(response.body);
      dynamic data = decoded['data'];

      if (data is Map) {
        data = data['list'] ?? data['records'] ?? data['data'];
      }

      if (data is! List) {
        throw Exception('Unexpected API response');
      }

      if (!mounted) return;
      setState(() {
        results = data;
        error = '';
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Data load nahi hua. Internet/API check karo.';
        loading = false;
      });
    }
  }

  int getNumber(dynamic item) {
    return int.tryParse('${item['number'] ?? 0}') ?? 0;
  }

  String getColour(dynamic item) {
    final value = '${item['color'] ?? ''}';
    if (value.isNotEmpty && value != 'null') return value;

    final n = getNumber(item);
    if (n == 0) return 'Red + Violet';
    if (n == 5) return 'Green + Violet';
    return n.isOdd ? 'Green' : 'Red';
  }

  int countColour(String colour) {
    return results.where((item) {
      return getColour(item).toLowerCase().contains(
        colour.toLowerCase(),
      );
    }).length;
  }

  int countSize(String size) {
    return results.where((item) {
      final n = getNumber(item);
      return (n >= 5 ? 'Big' : 'Small') == size;
    }).length;
  }

  Widget stat(String label, int count) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(
          '$count',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latest = results.isEmpty ? null : results.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('COLOUR TRADING ANALYZER'),
        actions: [
          IconButton(
            onPressed: fetchData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            const Text(
              'LATEST RESULT',
              style: TextStyle(fontSize: 20),
            ),
            Card(
              child: ListTile(
                title: Text(
                  latest == null
                      ? 'Loading...'
                      : 'Number: ${getNumber(latest)}',
                ),
                subtitle: Text(
                  latest == null
                      ? ''
                      : 'Period: ${latest['issueNumber']}\n'
                        'Colour: ${getColour(latest)}\n'
                        'Size: ${getNumber(latest) >= 5 ? 'Big' : 'Small'}',
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'COLOUR ANALYSIS',
              style: TextStyle(fontSize: 20),
            ),
            stat('Red', countColour('Red')),
            stat('Green', countColour('Green')),
            stat('Violet', countColour('Violet')),
            const SizedBox(height: 15),
            const Text(
              'BIG / SMALL ANALYSIS',
              style: TextStyle(fontSize: 20),
            ),
            stat('Big (5-9)', countSize('Big')),
            stat('Small (0-4)', countSize('Small')),
            const SizedBox(height: 15),
            const Text(
              'RECENT HISTORY',
              style: TextStyle(fontSize: 20),
            ),
            ...results.take(30).map((item) {
              final n = getNumber(item);
              return Card(
                child: ListTile(
                  title: Text('Period: ${item['issueNumber']}'),
                  subtitle: Text(getColour(item)),
                  trailing: Text(
                    '$n | ${n >= 5 ? 'Big' : 'Small'}',
                  ),
                ),
              );
            }),
            if (loading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Historical analysis only. Past results do not guarantee future outcomes.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
