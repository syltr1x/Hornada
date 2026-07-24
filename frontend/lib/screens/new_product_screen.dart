import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductNewScreen extends StatefulWidget {
  const ProductNewScreen({super.key});

  @override
  State<ProductNewScreen> createState() => _ProductNewScreenState();
}

class _ProductNewScreenState extends State<ProductNewScreen> {
  final _formKey = GlobalKey<FormState>();

  final _quantController = TextEditingController();

  bool _sending = false;

  final List<String> _flavours = [
    "Carne",
    "Jamón y Queso",
  ];

  String? _selectedFlavour;

  Future<void> guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _sending = true;
    });

    final response = await http.post(
      Uri.parse("https://api.lahornada.org/inventory"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "quant": int.parse(_quantController.text),
        "flavour": _selectedFlavour,
      }),
    );

    setState(() {
      _sending = false;
    });

    if (response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${response.statusCode}"),
        ),
      );
    }
  }

  @override
  void dispose() {
    _quantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo producto"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _quantController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Cantidad",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ingrese una cantidad";
                  }

                  final n = int.tryParse(value);

                  if (n == null || n <= 0) {
                    return "Cantidad inválida";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedFlavour,
                decoration: const InputDecoration(
                  labelText: "Sabor",
                  border: OutlineInputBorder(),
                ),
                items: _flavours
                    .map(
                      (flavour) => DropdownMenuItem(
                        value: flavour,
                        child: Text(flavour),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFlavour = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return "Seleccione un sabor";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending ? null : guardarProducto,
                  child: _sending
                      ? const CircularProgressIndicator()
                      : const Text("Guardar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}