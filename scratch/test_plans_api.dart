import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

void main() async {
  final url = Uri.parse('https://exact-gwenette-fitglow-38dc47eb.koyeb.app/payments/plans');
  final response = await http.get(url);
  File('scratch/plans_debug.txt').writeAsStringSync("Status: ${response.statusCode}\nBody: ${response.body}");
}
