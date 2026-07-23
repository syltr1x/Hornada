import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SpendingNewScreen extends StatefulWidget {
  const SpendingNewScreen({super.key});

  @override
  State<SpendingNewScreen> createState() => SpendingNewScreenState();
  
}

class SpendingNewScreenState extends State<SpendingNewScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _sending = false;
  final List<String> types = [
    "Caja",
    "Gastos",
    "Servicios",
    "Sueldos"
  ];
  String? selectedMethod;
  final List<String> methods = [
    "Efectivo",
    "Transferencia"
  ];
  String? selectedType;

  DateTime? _dateSelected;
  final TextEditingController _hourController = TextEditingController();

  final _personController = TextEditingController();
  final _quantController = TextEditingController();
  final _reasonController = TextEditingController();
  final _totalController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();

  }
  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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

    final deliveryDate = DateTime(
      _dateSelected!.year,
      _dateSelected!.month,
      _dateSelected!.day,
      int.parse(partsHour[0]),
      int.parse(partsHour[1]),
    );
    final timestamp = deliveryDate.millisecondsSinceEpoch ~/ 1000;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _sending = true;
    });

    final response = await http.post(
      Uri.parse("http://192.168.0.6:3000/balance"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "date": timestamp,
        "person": _personController.text,
        "quant": int.parse(_quantController.text),
        "reason": _reasonController.text,
        "type": selectedType,
        "total": int.parse(_totalController.text),
        "method": selectedMethod,
        "desc": _descController.text,
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
    _personController.dispose();
    _quantController.dispose();
    _reasonController.dispose();
    _totalController.dispose();
    _descController.dispose();


    super.dispose();
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo movimiento"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _personController,
                          decoration: const InputDecoration(
                            labelText: "Persona",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedType,
                          decoration: const InputDecoration(
                            labelText: "Tipo",
                            border: OutlineInputBorder(),
                          ),
                          items: types.map((sabor) {
                            return DropdownMenuItem(
                              value: sabor,
                              child: Text(sabor),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedType = value;
                            });
                          },
                        )
                      ),
                    ],
                  ),const SizedBox(height: 16),
                  Row(
                    children: [
                        Expanded(
                          child:TextFormField(
                            keyboardType: TextInputType.numberWithOptions(),
                            controller: _quantController,
                            decoration: const InputDecoration(
                              labelText: "Cantidad",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      Expanded(
                          child:TextFormField(
                            controller: _reasonController,
                            decoration: const InputDecoration(
                              labelText: "Motivo",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                        Expanded(
                          child: TextFormField(
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
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedMethod,
                          decoration: const InputDecoration(
                            labelText: "Metodo",
                            border: OutlineInputBorder(),
                          ),
                          items: methods.map((sabor) {
                            return DropdownMenuItem(
                              value: sabor,
                              child: Text(sabor),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedMethod = value;
                            });
                          },
                          ),
                        )
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                          controller: _descController,
                          decoration: const InputDecoration(
                            labelText: "Descripcion",
                            border: OutlineInputBorder(),
                          ),
                        ),
                  const SizedBox(height: 16),

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