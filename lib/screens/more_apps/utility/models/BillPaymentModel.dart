class BillPaymentModel {
  int amount;
  String productId;
  String customerId;
  String providerId;
  String customerRefNum;

  BillPaymentModel({
    required this.amount,
    required this.productId,
    required this.customerId,
    required this.providerId,
    required this.customerRefNum,
  });

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "product_id": productId,
      "customer_id": customerId,
      "provider_id": providerId,
      "customer_ref_num": customerRefNum,
    };
  }
}
