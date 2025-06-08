import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
          'https://testportal.udd.edu.ph/api/payments?USER_INDEX=${widget.user['USER_INDEX']}',
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
    if (isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (error != null) return Scaffold(body: Center(child: Text(error!)));

    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: ListView.separated(
        padding: const EdgeInsets.all(10),
        itemCount: payments.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final payment = payments[index];
          return ListTile(
            title: Text(
              payment['DESCRIPTION'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "OR: ${payment['OR_NUMBER']} • Date: ${payment['DATE_PAID']}",
            ),
            trailing: Text(
              "₱${payment['AMOUNT'].toString()}",
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }
}
