import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/balance.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() =>
      _OrderDetailScreenState();
}

class _OrderDetailScreenState
    extends State<OrderDetailScreen> {

  late Future<Spending> _futureOrder;

  @override
  void initState() {
    super.initState();
    _futureOrder = getOrder();
  }

  Future<Spending> getOrder() async {
    final response = await http.get(
      Uri.parse(
        "http://192.168.0.6:3000/spending/${widget.orderId}",
      ),
    );

    if (response.statusCode != 200) {
      throw Exception("No se pudo cargar el pedido");
    }

    return Spending.fromJson(
      jsonDecode(response.body),
    );
  }
  String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      timestamp * 1000,
    );

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Movimiento ${widget.orderId}"),
      ),
      body: FutureBuilder<Spending>(
        future: _futureOrder,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final order = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  order.person,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),
                const Divider(height: 32),
                Text("Fecha: ${formatDate(order.date)}"),
                Text("Tipo: ${order.type}"),
                const Divider(height: 32),
                Text("Total: \$${order.total/1000}00"),
                Text("Metodo: ${order.method}"),
                const Divider(height: 32),
                Text("Cantidad: ${order.quant}"),
                Text("Motivo: ${order.reason}"),
                Text("Descripcion: ${order.desc}"),
                const Divider(height: 32),
                const SizedBox(height: 256),

              ],
            ),
          );
        },
      ),
    );
  }
}