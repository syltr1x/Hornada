import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../models/order_detail.dart';

class OrderDetailRow extends StatelessWidget {
  final OrderDetail detail;
  final List<String> sabores;
  final VoidCallback onDelete;

  const OrderDetailRow({
    super.key,
    required this.detail,
    required this.sabores,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: TextFormField(
              controller: detail.quantController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Cant.",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Obligatorio";
                }

                final n = int.tryParse(value);

                if (n == null || n <= 0) {
                  return "Inválida";
                }

                return null;
              },
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: TypeAheadField<String>(
              controller: detail.flavourController,

              suggestionsCallback: (search) {
                return sabores
                    .where(
                        (s) => s.toLowerCase().contains(
                            search.toLowerCase(),
                            ),
                    )
                    .toList();
                },

              itemBuilder: (context, sabor) {
                return ListTile(
                  title: Text(sabor),
                );
              },

              onSelected: (sabor) {
                detail.flavourController.text = sabor;
              },

              builder: (
                context,
                controller,
                focusNode,
              ) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: "Sabor",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Seleccione un sabor";
                    }

                    return null;
                  },
                );
              },
            ),
          ),

          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}