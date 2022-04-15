// {
// "id": "3182c6bf-cc4c-428c-8cc7-a7869653e3be",
// "status": "Successful",
// "customer_username": "tosinmomodu",
// "created_at": "2022-04-14T17:38:20.951735Z",
// "product": {
// "name": "Prepaid",
// "amount": 100000,
// "currency": "NGN",
// "id": "feded17b-db7e-425d-b2bd-2798fb9d7467",
// "provider": {
// "name": "Eko Electricity Distribution Company Plc",
// "avatar":
// "https://slydo-assets.s3.amazonaws.com/media/provider_avatars/ea494008-6209-4f87-98b1-4397c90cf8b6.jpg",
// "id": "afc2f974-2a60-4706-8106-46bdf5cb59ee"
// }
// },
// }

class UtilityHistoryModel {
  String transactionId;
  String status;
  String customerUsername;
  String createdAt;
  int amount;
  String currency;
  String providerName;
  String providerId;
  String providerAvatar;
  String productName;

  UtilityHistoryModel({
    required this.productName,
    required this.currency,
    required this.transactionId,
    required this.status,
    required this.customerUsername,
    required this.createdAt,
    required this.amount,
    required this.providerAvatar,
    required this.providerId,
    required this.providerName,
  });

  factory UtilityHistoryModel.fromJson(Map<String, dynamic> json) {
    return UtilityHistoryModel(
      currency: json['product']['currency'],
      status: json['status'],
      customerUsername: json['customer_username'],
      createdAt: json['created_at'],
      transactionId: json['id'],
      amount: json['product']['amount'],
      providerId: json['product']['provider']['id'],
      providerName: json['product']['provider']['name'],
      providerAvatar: json['product']['provider']['avatar'],
      productName: json['product']['provider']['name'],
    );
  }
}
