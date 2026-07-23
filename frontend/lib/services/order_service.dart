import 'dart:convert';

import 'package:frontend/models/order.dart';
import 'package:http/http.dart' as http;


class OrderService {
  static const String baseUrl = "http://192.168.0.6:3000";


  static Future<List<Paid>> getOrders() async {
    final response = await http.get(
      Uri.parse("$baseUrl/completed"),
    );


    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((e) => Paid.fromJson(e))
          .toList();
    }

    throw Exception(
      "Error al obtener pedidos (${response.statusCode})",
    );
  }


  static Future<void> deleteOrder(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/pedidos/$id"),
    );


    if (response.statusCode != 204) {
      throw Exception(
        "Error eliminando pedido",
      );
    }
  }


  static Future<void> completeOrder(int id) async {
    final response = await http.put(
      Uri.parse("$baseUrl/pedidos/$id/complete"),
    );


    if (response.statusCode != 204) {
      throw Exception(
        "Error completando pedido",
      );
    }
  }


  static Future<void> payOrder(
    int id,
    String method,
  ) async {

    final response = await http.put(
      Uri.parse(
        "$baseUrl/pedidos/$id/pay?method=$method",
      ),
    );


    if (response.statusCode != 204) {
      throw Exception(
        "Error pagando pedido",
      );
    }
  }
}