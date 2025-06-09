import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SchedulePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const SchedulePage({super.key, required this.user});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<Map<String, dynamic>> schedule = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchSchedule();
  }

  Future<void> fetchSchedule() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://testportal.udd.edu.ph/api/schedule?USER_INDEX=${widget.user['USER_INDEX']}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          schedule = List<Map<String, dynamic>>.from(data['schedule']);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load schedule';
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

  String getWeekDayName(String day) {
    switch (day) {
      case '1':
        return 'Monday';
      case '2':
        return 'Tuesday';
      case '3':
        return 'Wednesday';
      case '4':
        return 'Thursday';
      case '5':
        return 'Friday';
      case '6':
        return 'Saturday';
      case '7':
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(error!));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: schedule.map((item) {
          return Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                item['SUB_CODE'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['SUB_NAME'] ?? ''),
                  Text(item['SECTION'] ?? ''),
                  Text(
                    '${getWeekDayName(item['WEEK_DAY'].toString())} • ${item['TIME_FROM']} - ${item['TIME_TO']} • ${item['ROOM_NUMBER']}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
