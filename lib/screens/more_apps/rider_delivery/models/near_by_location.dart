class NearByLocation {
  int? orderId;
  bool? atPickupLocation;
  bool? atDeliveryLocation;

  NearByLocation({
    this.orderId,
    this.atPickupLocation,
    this.atDeliveryLocation,
  });

  factory NearByLocation.fromJson(Map<String, dynamic> json) => NearByLocation(
        orderId: json["order_id"],
        atPickupLocation: json["at_pickup_location"],
        atDeliveryLocation: json["at_delivery_location"],
      );

  factory NearByLocation.fromDBJson(Map<String, dynamic> json) =>
      NearByLocation(
        orderId: json["order_id"],
        atPickupLocation: json["at_pickup_location"] == 1 ? true : false,
        atDeliveryLocation: json["at_delivery_location"] == 1 ? true : false,
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "at_pickup_location": atPickupLocation == true ? 1 : 0,
        "at_delivery_location": atDeliveryLocation == true ? 1 : 0,
      };

  // factory NearByLocation.fromDBJson(Map<String, dynamic> json) {
  //   return NearByLocation(
  //     orderId: json['order_id'],
  //     atLocation: json['at_location'] ?? false,
  //   );
  // }
  //
  // Map<String, dynamic> toDBJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['order_id'] = this.orderId;
  //   data['at_location'] = this.atLocation;
  //   return data;
  // }
}
