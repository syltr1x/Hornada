import 'package:flutter/material.dart';

class OrderDetail {
  final TextEditingController quantController;
  final TextEditingController flavourController;

  OrderDetail({
    String quant = "",
    String flavour = "",
  })  : quantController = TextEditingController(text: quant),
        flavourController = TextEditingController(text: flavour);

  Map<String, dynamic> toJson() => {
        "quant": int.parse(quantController.text),
        "flavour": flavourController.text,
      };

  void dispose() {
    quantController.dispose();
    flavourController.dispose();
  }
}