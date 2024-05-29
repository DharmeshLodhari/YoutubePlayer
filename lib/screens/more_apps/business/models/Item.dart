class InvoiceItem {
  int? amount;
  int? id;
  String? name;
  int? quantity;
  String? currency;

  InvoiceItem(
      {this.amount,
      this.currency = "NGN",
      this.id,
      this.name,
      this.quantity = 1});

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      amount: json['amount'],
      currency: json['currency'],
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['amount'] = amount;
    data['currency'] = currency;
    data['id'] = id;
    data['name'] = name;
    data['quantity'] = quantity;
    return data;
  }
}
