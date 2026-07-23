import 'package:flutter/material.dart';

import '../models/order.dart';

class ProductCard extends StatelessWidget {
  final Inventory product;
  final Future<void> Function(int id, int cantidad) onEdit;
  final bool showEdit;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    this.showEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: Center(
                child: Text(
                  product.quant.toString(),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const VerticalDivider(),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                product.flavour,
                style: const TextStyle(
                  fontSize: 22,
                ),
              ),
            ),
            if (showEdit)
              IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                final controller = TextEditingController(
                  text: product.quant.toString(),
                );

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (bottomContext) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom:
                            MediaQuery.of(bottomContext).viewInsets.bottom + 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            product.flavour,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Cantidad",
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                final cantidad =
                                    int.tryParse(controller.text);

                                if (cantidad == null) return;

                                await onEdit(product.id, cantidad);

                                if (bottomContext.mounted) {
                                  Navigator.pop(bottomContext);
                                }
                              },
                              child: const Text("Guardar"),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}