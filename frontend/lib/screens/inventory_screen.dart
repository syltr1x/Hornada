import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/order.dart';

import '../widgets/product_card.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => InventoryScreenState();
}

class InventoryScreenState extends State<InventoryScreen> {

  late Future<List<Inventory>> _futureProducts;
  late Future<List<Inventory>> _futureDifference;

  @override
  void initState() {
    super.initState();
    _futureProducts = getProducts();
    _futureDifference = getDifference();
  }
  void refreshInventory() {
    setState(() {
    _futureProducts = getProducts();
    _futureDifference = getDifference();
    });
  }
  Future<void> editProduct(int id, int cantidad) async {
    final response = await http.put(
      Uri.parse("http://192.168.0.6:3000/inventory/$id"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "quant": cantidad,
      }),
    );

    if (response.statusCode == 204) {
      setState(() {
        _futureProducts = getProducts();
        _futureDifference = getDifference();
      });
    }
  }
  Future<List<Inventory>> getProducts() async {
    final response = await http.get(
      Uri.parse("http://192.168.0.6:3000/inventory"),
    );

    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);

      return jsonData
          .map((e) => Inventory.fromJson(e))
          .toList();
    }

    throw Exception("Error al obtener pedidos");
  }
  Future<List<Inventory>> getDifference() async {
    final response = await http.get(
      Uri.parse("http://192.168.0.6:3000/inventory/dif"),
    );

    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);

      return jsonData
          .map((e) => Inventory.fromJson(e))
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
          "Inventario",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Inventory>>(
            future: _futureProducts,
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

              final products = snapshot.data!;

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: products[index],
                    onEdit: editProduct,
                  );
                },
              );
            },
          ),
        ),
        const Text(
          "Diferencia",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Inventory>>(
            future: _futureDifference,
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

              final difference = snapshot.data!;

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: difference.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: difference[index],
                    onEdit: editProduct,
                    showEdit: false
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