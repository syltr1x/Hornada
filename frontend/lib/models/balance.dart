class Balance {
  final int id;
  final String person;
  final String reason;
  final int total;
  final String type;
  final String method;

  Balance({
    required this.id,
    required this.person,
    required this.reason,
    required this.total,
    required this.type,
    required this.method,
  });
  
  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      id: json["id"],
      person: json["person"],
      reason: json["reason"],
      total: json["total"],
      type: json["type"],
      method: json["method"],
    );
  }
}


class Spending {
  final int id;
  final int date;
  final String person;
  final int quant;
  final String reason;
  final int total;
  final String method;
  final String type;
  final String desc;

  Spending({
    required this.id,
    required this.date,
    required this.person,
    required this.quant,
    required this.reason,
    required this.total,
    required this.method,
    required this.type,
    required this.desc,
  });
  
  factory Spending.fromJson(Map<String, dynamic> json) {
    return Spending(
      id: json["id"],
      date: json["date"],
      person: json["person"],
      quant: json["quant"],
      reason: json["reason"],
      total: json["total"],
      method: json["method"],
      type: json["type"],
      desc: json["desc"],
    );
  }
}