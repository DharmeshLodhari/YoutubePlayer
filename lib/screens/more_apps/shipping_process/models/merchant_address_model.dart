class MerchantAddressModel {
  String? addressId;
  String? merchant;

  MerchantAddressModel({
    this.addressId,
    this.merchant,
  });

  factory MerchantAddressModel.fromJson(Map<String, dynamic> json) =>
      MerchantAddressModel(
        addressId: json["address_id"],
        merchant: json["merchant"],
      );

  Map<String, dynamic> toJson() => {
        "address_id": addressId,
        "merchant": merchant,
      };
}
