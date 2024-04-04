import 'Item.dart';

class InvoiceModel {
  int? amount;
  String? createdAt;
  String? currency;
  String? dueDate;
  String? fromCustomer;
  String? fromCustomerDisplayName;
  String? toCustomerDisplayName;
  String? fromCustomerAvatar;
  int? id;
  String? invoiceDate;
  List<InvoiceItem>? items;
  String? status;
  String? toCustomer;
  String? toCustomerAvatar;

  InvoiceModel(
      {this.amount,
      this.createdAt,
      this.currency,
      this.dueDate,
      this.fromCustomer,
      this.fromCustomerDisplayName,
      this.toCustomerDisplayName,
      this.fromCustomerAvatar,
      this.id,
      this.invoiceDate,
      this.items,
      this.status,
      this.toCustomer,
      this.toCustomerAvatar});

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      amount: json['amount'],
      createdAt: json['created_at'],
      currency: json['currency'],
      dueDate: json['due_date'],
      fromCustomer: json['from_customer'],
      fromCustomerDisplayName: json['from_customer_display_name'],
      toCustomerDisplayName: json['to_customer_display_name'],
      fromCustomerAvatar: json['from_customer_avatar'],
      id: json['id'],
      invoiceDate: json['invoice_date'],
      items: json['items'] != null
          ? (json['items'] as List).map((i) => InvoiceItem.fromJson(i)).toList()
          : null,
      status: json['status'],
      toCustomer: json['to_customer'],
      toCustomerAvatar: json['to_customer_avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['amount'] = this.amount;
    data['created_at'] = this.createdAt;
    data['currency'] = this.currency;
    data['due_date'] = this.dueDate;
    data['from_customer'] = this.fromCustomer;
    data['from_customer_avatar'] = this.fromCustomerAvatar;
    data['id'] = this.id;
    data['invoice_date'] = this.invoiceDate;
    data['status'] = this.status;
    data['to_customer'] = this.toCustomer;
    data['to_customer_avatar'] = this.toCustomerAvatar;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
