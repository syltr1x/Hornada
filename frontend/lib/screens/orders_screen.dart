import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/order.dart';
import '../widgets/order_card.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => OrdersScreenState();
}

class OrdersScreenState extends State<OrdersScreen> {

  late Future<List<Order>> _futureOrders;

  @override
  void initState() {
    super.initState();
    _futureOrders = getOrders();
  }

  void refreshOrders() {
    setState(() {
      _futureOrders = getOrders();
    });
  }
  Future<void> deleteOrder(int id) async {
    final response = await http.delete(
      Uri.parse("http://192.168.0.6:3000/pedidos/$id"),
    );

    if (response.statusCode == 204) {
      setState(() {
        _futureOrders = getOrders();
      });
    }
  }
  Future<void> completeOrder(int id) async {
    final response = await http.put(
      Uri.parse("http://192.168.0.6:3000/pedidos/$id/complete"),
    );

    if (response.statusCode == 204) {
      setState(() {
        _futureOrders = getOrders();
      });
    }
  }
  Future<bool> confirmarEliminar(BuildContext context) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar"),
        content: const Text(
          "¿Estás seguro de que querés eliminar este registro?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    return resultado ?? false;
  }
  Future<List<Order>> getOrders() async {
    final response = await http.get(
      Uri.parse("http://192.168.0.6:3000/pedidos"),
    );

    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);

      return jsonData
          .map((e) => Order.fromJson(e))
          .toList();
    }

    throw Exception("Error al obtener pedidos");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 64),
        const Text(
          "Pedidos",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 1),

        Expanded(
          child: FutureBuilder<List<Order>>(
            future: _futureOrders,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }

              final orders = snapshot.data!;

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return OrderCard(
                    order: orders[index],
                    showReady: true,
                    onDelete: () async {
                      final confirmar = await confirmarEliminar(context);
                      if (!confirmar) return;
                      await deleteOrder(orders[index].id);
                    },
                    onReady: () async {
                      await completeOrder(orders[index].id);
                    },
                    onPay: (_, _) async {},
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}