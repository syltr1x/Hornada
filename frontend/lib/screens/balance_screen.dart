import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/balance.dart';
import 'package:http/http.dart' as http;

import '../widgets/spending_card.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => BalanceScreenState();
  
}

class BalanceScreenState extends State<BalanceScreen> {
  

  late Future<List<Balance>> _futureOrders;
  
  final List<String> types = [
    "Caja",
    "Gastos",
    "Servicios",
    "Sueldos"
  ];
  String? selectedType;

  final Map<String, double> totals = {
    "Caja": 0,
    "Gastos": 0,
    "Servicios": 0,
    "Sueldos": 0,
  };

  @override
  void initState() {
    super.initState();
    _futureOrders = getOrders();
  }

  void refreshBalance() {
    setState(() {
      _futureOrders = getOrders();
    });
  }
  Future<void> deleteOrder(int id) async {
    final response = await http.delete(
      Uri.parse("https://api.lahornada.org/spending/$id"),
    );

    if (response.statusCode == 204) {
      setState(() {
        _futureOrders = getOrders();
      });
    }
  }
  Future<void> completeOrder(int id) async {
    final response = await http.put(
      Uri.parse("https://api.lahornada.org/pedidos/$id/complete"),
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
  Future<List<Balance>> getOrders() async {
    final response = await http.get(
      Uri.parse("https://api.lahornada.org/balance"),
    );

    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);

      return jsonData
          .map((e) => Balance.fromJson(e))
          .toList();
    }

    throw Exception("Error al obtener pedidos");
  }

 @override
Widget build(BuildContext context) {
  return FutureBuilder<List<Balance>>(
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

  final totals = {
    "Caja": 0.0,
    "Gastos": 0.0,
    "Servicios": 0.0,
    "Sueldos": 0.0,
  };

  for (final spending in orders) {
    totals[spending.type] =
        (totals[spending.type] ?? 0) +
        spending.total.abs().toDouble();
  }

  final totalGeneral = totals.values.fold(0.0, (a, b) => a + b);

  final entries = totals.entries
      .where((e) => e.value > 0)
      .toList();

  final visibleOrders = selectedType == null
      ? orders
      : orders.where((o) => o.type == selectedType).toList();

  const colors = {
    "Caja": Colors.green,
    "Gastos": Colors.red,
    "Servicios": Colors.orange,
    "Sueldos": Colors.blue,
  };

      return Column(
        children: [
          const SizedBox(height: 64),

          const Text(
            "Balance",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (response?.touchedSection == null) return;

                  final tipo = entries[response!.touchedSection!.touchedSectionIndex].key;

                  setState(() {
                    if (selectedType == tipo) {
                      selectedType = null; // segundo toque: deselecciona
                    } else {
                      selectedType = tipo; // primer toque: selecciona
                    }
                  });
                },
              ),
                sections: entries.map((e) {
                  return PieChartSectionData(
                    value: e.value,
                    title: "${e.key}\n${(e.value / totalGeneral * 100).toStringAsFixed(1)}%",
                    color: colors[e.key],
                    radius: selectedType == e.key ? 80 : 70,
                  );
                }).toList(),
              )
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: visibleOrders.length,
              itemBuilder: (context, index) {
                final order = visibleOrders[index];

                return OrderCard(
                  balance: order,
                  onDelete: () async {
                    final confirmar = await confirmarEliminar(context);
                    if (!confirmar) return;

                    await deleteOrder(order.id);
                  },
                  onReady: () async {
                    await completeOrder(order.id);
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );
}
}