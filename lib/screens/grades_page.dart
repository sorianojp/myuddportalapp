import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GradesPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const GradesPage({super.key, required this.user});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  Map<String, List<dynamic>> groupedGrades = {};
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchGrades();
  }

  Future<void> fetchGrades() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://testportal.udd.edu.ph/api/grades?USER_INDEX=${widget.user['USER_INDEX']}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          groupedGrades = Map<String, List<dynamic>>.from(data['grades']);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load grades';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(error!));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedGrades.entries.map((entry) {
          final term = entry.key;
          final grades = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                term,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF05056A),
                ),
              ),
              const SizedBox(height: 10),
              ...grades.map((g) {
                final gradeValue = g['GRADE'] != null
                    ? double.tryParse(
                            g['GRADE'].toString(),
                          )?.toStringAsFixed(0) ??
                          '–'
                    : '–';
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      '${g['SUB_CODE']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${g['SUB_NAME']}'),
                        Text(
                          '${g['ENCODED_BY']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${g['GRADE_NAME']}'),
                      ],
                    ),
                    trailing: Text(
                      gradeValue,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF05056A),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }
}
