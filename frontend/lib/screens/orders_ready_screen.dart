import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/order.dart';
import '../widgets/order_card.dart';

class CompletedScreen extends StatefulWidget {
  const CompletedScreen({super.key});

  @override
  State<CompletedScreen> createState() => CompletedScreenState();
}

class CompletedScreenState extends State<CompletedScreen> {

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
      Uri.parse("https://api.lahornada.org/pedidos/$id"),
    );

    if (response.statusCode == 204) {
      setState(() {
        _futureOrders = getOrders();
      });
    }
  }
  Future<void> payOrder(int id, String method) async {
    final response = await http.put(
      Uri.parse("https://api.lahornada.org/pedidos/$id/pay?method=$method"),
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
      Uri.parse("https://api.lahornada.org/completed"),
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
          "Completados",
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
               if(!orders[index].paid) { return OrderCard(
                  order: orders[index],
                  showPay: !orders[index].paid,
                  onDelete: ()async {await deleteOrder(orders[index].id);},
                  onPay: payOrder,
                  onReady: () async {},
                );} else {return null;}
                },
              );
            },
          ),
        ),
        const Text(
          "Pagados",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                  if(orders[index].paid) { return OrderCard(
                  order: orders[index],
                  showPay: !orders[index].paid,
                  onDelete: () async {
                    final confirmar = await confirmarEliminar(context);
                    if (!confirmar) return;
                    await deleteOrder(orders[index].id);
                  },
                  onPay: payOrder,
                  onReady: () async {},
                );} else {return null;}
                },
              );
            },
          ),
        ),
      ],
    );
  }
}