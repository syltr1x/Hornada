class OrderComplete {
  final int id;
  final String name;
  final String address;
  final int date;
  final int total;
  final String method;
  final List<OrderDetailData> details;
  final bool paid;

  OrderComplete({
    required this.id,
    required this.name,
    required this.address,
    required this.date,
    required this.total,
    required this.method,
    required this.details,
    required this.paid
  });

  factory OrderComplete.fromJson(Map<String, dynamic> json) {
    return OrderComplete(
      id: json["id"],
      name: json["name"],
      address: json["address"],
      date: json["date"],
      total: json["total"],
      method: json["method"],
      details: (json["details"] as List)
          .map((e) => OrderDetailData.fromJson(e))
          .toList(),
      paid: json["paid"],
    );
  }
}

class OrderDetailData {
  final int id;
  final int orderId;
  final int quant;
  final String flavour;

  OrderDetailData({
    required this.id,
    required this.orderId,
    required this.quant,
    required this.flavour,
  });

  factory OrderDetailData.fromJson(Map<String, dynamic> json) {
    return OrderDetailData(
      id: json["id"],
      orderId: json["order_id"],
      quant: json["quant"],
      flavour: json["flavour"],
    );
  }
}