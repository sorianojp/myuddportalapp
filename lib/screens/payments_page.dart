import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class PaymentsPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const PaymentsPage({super.key, required this.user});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  List<Map<String, dynamic>> payments = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://portal.udd.edu.ph/api/payments?USER_INDEX=${widget.user['USER_INDEX']}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          payments = List<Map<String, dynamic>>.from(data['payments']);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load payments';
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

    return RefreshIndicator(
      onRefresh: fetchPayments,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: payments.map((payment) {
            return Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(
                  payment['DESCRIPTION'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${payment['OR_NUMBER']}'),
                    Text(
                      DateFormat(
                        "MMMM d, y",
                      ).format(DateTime.parse(payment['DATE_PAID'])),
                    ),
                  ],
                ),
                trailing: Text(
                  "₱${double.tryParse(payment['AMOUNT'].toString())?.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF05056A),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
