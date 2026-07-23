import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/order_full.dart';

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

  late Future<OrderComplete> _futureOrder;

  @override
  void initState() {
    super.initState();
    _futureOrder = getOrder();
  }

  Future<OrderComplete> getOrder() async {
    final response = await http.get(
      Uri.parse(
        "http://192.168.0.6:3000/pedidos/${widget.orderId}",
      ),
    );

    if (response.statusCode != 200) {
      throw Exception("No se pudo cargar el pedido");
    }

    return OrderComplete.fromJson(
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
        title: Text("Pedido ${widget.orderId}"),
      ),
      body: FutureBuilder<OrderComplete>(
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
                  order.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text("Direccion: ${order.address}"),
                Text("Fecha: ${formatDate(order.date)}"),
                if(order.paid) 
                  Row(
                    children: [
                      Text("Pagado mediante: ${order.method}")
                    ],
                  ),

                const Divider(height: 32),

                const Text(
                  "Detalle",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: ListView.builder(
                    itemCount: order.details.length,
                    itemBuilder: (context, index) {
                      final d = order.details[index];

                      return ListTile(
                        leading: Text(
                          d.quant.toString(),
                        ),
                        title: Text(d.flavour),
                      );
                    },
                  ),
                ),
                Text("Total: \$${order.total/1000}00"),
                const SizedBox(height: 256),

              ],
            ),
          );
        },
      ),
    );
  }
}