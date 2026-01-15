import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FridaySonaScreen extends StatefulWidget {
  const FridaySonaScreen({super.key});

  @override
  State<FridaySonaScreen> createState() => _FridaySonaScreenState();
}

class _FridaySonaScreenState extends State<FridaySonaScreen> {
  List<String> content = [];

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    final jsonString =
        await rootBundle.loadString('assets/data/friday_sona.json');

    final Map<String, dynamic> jsonData = json.decode(jsonString);

    setState(() {
      content = List<String>.from(jsonData['friday_sona']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سنن يوم الجمعة'),
        centerTitle: true,
      ),
      body: content.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: content.length,
              itemBuilder: (context, index) {
                final text = content[index];

                // Empty line
                if (text.trim().isEmpty) {
                  return const SizedBox(height: 14);
                }

                // Section title
                final isHeader = text.startsWith('*');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    isHeader ? text.substring(1).trim() : text,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: isHeader ? 18 : 16,
                      fontWeight:
                          isHeader ? FontWeight.bold : FontWeight.normal,
                      height: 1.7,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
