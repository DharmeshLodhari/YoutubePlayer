class InvoiceItem {
  String name;
  int price;
  int qty;

  InvoiceItem({this.name = "", this.price = 0, this.qty = 1});

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      name: json['name'],
      price: json['price'],
      qty: json['qty'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['price'] = this.price;
    data['qty'] = this.qty;
    return data;
  }
}
