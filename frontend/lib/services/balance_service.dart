import 'dart:convert';
import 'package:frontend/models/order.dart';
import 'package:http/http.dart' as http;

import 'order_service.dart';

class BalanceService {

  static const String baseUrl = "http://192.168.0.6:3000";
  static Future<void> sendPaidOrdersToBalance(
      List<Paid> orders,
  ) async {
    final paidOrders = orders.where(
      (o) => o.paid,
    );
    final efectivo = paidOrders.where(
      (o) => o.method == "Efectivo",
    );
    final transferencia = paidOrders.where(
      (o) => o.method == "Transferencia",
    );
    final totalEfectivo =
        efectivo.fold<int>(
          0,
          (sum, order) =>
              sum + order.total,
        );
    final totalTransferencia =
        transferencia.fold<int>(
          0,
          (sum, order) =>
              sum + order.total,
        );
    if (totalEfectivo > 0) {
      await postBalance(
        method: "Efectivo",
        total: totalEfectivo,
      );
    }
    if (totalTransferencia > 0) {
      await postBalance(
        method: "Transferencia",
        total: totalTransferencia,
      );
    }
    for (final order in orders) {
      await OrderService.deleteOrder(order.id);
    }
  }

  static Future<void> postBalance({
    required String method,
    required int total,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/balance"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "date":
            DateTime.now()
            .millisecondsSinceEpoch ~/ 1000,
        "person": "Sistema",
        "quant": 1,
        "reason": "Pedidos cobrados",
        "type": "Caja",
        "total": total,
        "method": method,
        "desc": "Ingreso por pedidos",
      }),
    );
    if (response.statusCode != 201) {
      throw Exception(
        "Error creando balance",
      );
    }
  }
}