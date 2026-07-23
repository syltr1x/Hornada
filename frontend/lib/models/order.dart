class Order {
  final int id;
  final String name;
  final String address;
  final bool completed;
  final bool paid;

  Order({
    required this.id,
    required this.name,
    required this.address,
    required this.completed,
    required this.paid,
  });
  
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json["id"],
      name: json["name"],
      address: json["address"],
      completed: json["completed"],
      paid: json["paid"],
    );
  }
}
class Inventory {
  final int id;
  final int quant;
  final String flavour;

  Inventory({
    required this.id,
    required this.quant,
    required this.flavour
  });
  
  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json["id"],
      quant: json["quant"],
      flavour: json["flavour"],
    );
  }
}

class Paid {
  final int id;
  final String name;
  final int total;
  final String method;
  final bool completed;
  final bool paid;

  Paid({
    required this.id,
    required this.name,
    required this.total,
    required this.method,
    required this.completed,
    required this.paid,
  });

  factory Paid.fromJson(Map<String, dynamic> json) {
    return Paid(
      id: json["id"],
      name: json["name"],
      total: json["total"],
      method: json["method"],
      completed: json["completed"],
      paid: json["paid"],
    );
  }
}