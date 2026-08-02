import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/order_detail.dart';
import '../widgets/order_detail_row.dart';

class OrderNewScreen extends StatefulWidget {
  const OrderNewScreen({super.key});

  @override
  State<OrderNewScreen> createState() => _OrderNewScreenState();
  
}

class _OrderNewScreenState extends State<OrderNewScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _totalController = TextEditingController();

  bool _sending = false;

  DateTime? _dateSelected;
  final TextEditingController _hourController = TextEditingController();

  final List<String> flavours = [
    "Carne",
    "Jamón y Queso",
  ];

  final List<OrderDetail> details = [];

  @override
  void initState() {
    super.initState();

    details.add(OrderDetail());
  }
  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (date != null) {
      setState(() {
        _dateSelected = date;
      });
    }
  }

  Future<void> saveOrder() async {
    final partsHour = _hourController.text.split(":");
    if (partsHour[0].length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Porfavor ingresa una hora valida. Ej: 21:00."),
        ),
      );
      return;
    } else if (partsHour.length == 1) {
      partsHour.add("00");
    }

    final deliveryDate = DateTime(
      _dateSelected!.year,
      _dateSelected!.month,
      _dateSelected!.day,
      int.parse(partsHour[0]),
      int.parse(partsHour[1]),
    );
    final timestamp = deliveryDate.millisecondsSinceEpoch ~/ 1000;
    if (!_formKey.currentState!.validate()) return;

    if (details.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debe agregar al menos un ítem."),
        ),
      );
      return;
    }

    setState(() {
      _sending = true;
    });

    final response = await http.post(
      Uri.parse("https://api.lahornada.org/pedidos"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": _nameController.text,
        "address": _addressController.text,
        "details": details.map((e) => e.toJson()).toList(),
        "date": timestamp,
        "total": int.parse(_totalController.text),
        "complete": false,
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
          content: Text(
            "Error al guardar (${response.statusCode})",
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _totalController.dispose();


    for (final detail in details) {
      detail.dispose();
    }

    super.dispose();
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo pedido"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Nombre",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Ingrese un nombre";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: "Dirección",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Ingrese una dirección";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: selectDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Fecha",
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _dateSelected == null
                                  ? "DD/MM"
                                  : "${_dateSelected!.day.toString().padLeft(2, '0')}/"
                                    "${_dateSelected!.month.toString().padLeft(2, '0')}",
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: TextFormField(
                          controller: _hourController,
                          keyboardType: TextInputType.datetime,
                          decoration: const InputDecoration(
                            labelText: "Hora",
                            hintText: "HH:MM",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _totalController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Total",
                      border: OutlineInputBorder(),
                      prefixText: "\$ ",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Ingrese el total";
                      }

                      if (double.tryParse(value.replaceAll(",", ".")) == null) {
                        return "Ingrese un número válido";
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Text(
                        "Detalle del pedido",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            details.add(OrderDetail());
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Agregar"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: details.length,
                    itemBuilder: (context, index) {
                      return OrderDetailRow(
                        detail: details[index],
                        sabores: flavours,
                        onDelete: () {
                          setState(() {
                            details[index].dispose();
                            details.removeAt(index);
                          });
                        },
                      );
                    },
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _sending ? null : saveOrder,
                      child: _sending
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            )
                          : const Text("Guardar"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}