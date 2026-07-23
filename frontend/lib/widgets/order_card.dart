import 'package:flutter/material.dart';

import '../models/order.dart';
import '../screens/detail_order_screen.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onDelete;
  final VoidCallback onReady;
  final Future<void> Function(int id, String method) onPay;
  final bool showReady;
  final bool showPay;
  final List<String> methods = const [
  "Efectivo",
  "Transferencia",
  "Mercado Pago",
];
  

  const OrderCard({
    super.key,
    required this.order,
    required this.onDelete,
    required this.onReady,
    required this.onPay,
    this.showReady = false,
    this.showPay = false,
  });

  @override
  Widget build(BuildContext context) {
    String selectedMethod = methods.first;
    return Card(
      child: ListTile(
        title: Text(order.name),
        subtitle: Text(order.address),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(
                  orderId: order.id,
              ),
            ),
          );
        },

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showReady) IconButton(
              icon: const Icon(Icons.check),
              onPressed: onReady,
            ),
            if (showPay) IconButton(
              icon: const Icon(Icons.attach_money),
              onPressed: () {
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
                            "Metodo",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          initialValue: selectedMethod,
                          decoration: const InputDecoration(
                            labelText: "Método de pago",
                            border: OutlineInputBorder(),
                          ),
                          items: methods
                              .map((m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(m),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              selectedMethod = value;
                            }
                          },
                        ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                await onPay(order.id, selectedMethod);

                                if (bottomContext.mounted) {
                                  Navigator.pop(bottomContext);
                                }
                              },
                              child: const Text("Pagar"),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}