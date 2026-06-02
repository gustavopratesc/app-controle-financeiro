import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// Esse FutureProvider faz a requisição e gerencia os estados de carregamento automaticamente
final cotacaoDolarProvider = FutureProvider<String>((ref) async {
  // Fazemos um GET na API pública
  final url = Uri.parse('https://economia.awesomeapi.com.br/last/USD-BRL');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // Pegamos o valor de compra (bid) do Dólar
    final valorDolar = double.parse(data['USDBRL']['bid']);
    return 'Dólar hoje: R\$ ${valorDolar.toStringAsFixed(2)}';
  } else {
    throw Exception('Falha ao carregar cotação');
  }
});