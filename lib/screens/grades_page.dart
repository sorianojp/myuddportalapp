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
    if (isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (error != null) return Scaffold(body: Center(child: Text(error!)));

    return Scaffold(
      appBar: AppBar(title: Text('Grades')),
      body: ListView(
        children: groupedGrades.entries.map((entry) {
          final term = entry.key;
          final grades = entry.value;

          return ExpansionTile(
            title: Text(
              term,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: grades.map<Widget>((g) {
              return ListTile(
                title: Text(
                  '${g['SUB_CODE']} - ${g['SUB_NAME']} (${g['GRADE_NAME']})',
                ),
                subtitle: Text(
                  'Grade: ${g['GRADE']} | Units: ${g['CREDIT_EARNED']} | ${g['REMARK']}',
                ),
                trailing: Text(g['ENCODED_BY'] ?? ''),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
