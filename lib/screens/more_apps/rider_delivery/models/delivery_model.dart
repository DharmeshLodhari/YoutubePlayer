import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';

class DeliveryModel {
  String? id;
  double? deliveryDistance;
  double? pickupDistance;
  String? merchantAvatar;
  String? merchantFullName;
  String? merchant;
  String? dispatcherAvatar;
  dynamic dispatcherFullName;
  dynamic dispatcher;
  ShippingAddress? pickupAddress;
  ShippingAddress? deliveryAddress;
  dynamic location;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? status;
  String? type;
  String? dispatchId;
  DateTime? expectedPickupTime;
  dynamic expectedDeliveryTime;
  dynamic actualPickupTime;
  dynamic actualDeliveryTime;
  int? tip;
  String? currency;
  dynamic route;
  dynamic acceptedBy;
  String? customer;
  bool? isInProgress;
  bool? hasEnded;
  int? totalWeight;
  int? totalNoOfItems;

  DeliveryModel({
    this.id,
    this.deliveryDistance,
    this.pickupDistance,
    this.merchantAvatar,
    this.merchantFullName,
    this.merchant,
    this.dispatcherAvatar,
    this.dispatcherFullName,
    this.dispatcher,
    this.pickupAddress,
    this.deliveryAddress,
    this.location,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.type,
    this.dispatchId,
    this.expectedPickupTime,
    this.expectedDeliveryTime,
    this.actualPickupTime,
    this.actualDeliveryTime,
    this.tip,
    this.currency,
    this.route,
    this.acceptedBy,
    this.customer,
    this.isInProgress,
    this.hasEnded,
    this.totalWeight,
    this.totalNoOfItems,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) => DeliveryModel(
        id: json["id"],
        deliveryDistance: json["delivery_distance"],
        pickupDistance: json["pickup_distance"]?.toDouble(),
        merchantAvatar: json["merchant_avatar"],
        merchantFullName: json["merchant_full_name"],
        merchant: json["merchant"],
        dispatcherAvatar: json["dispatcher_avatar"],
        dispatcherFullName: json["dispatcher_full_name"],
        dispatcher: json["dispatcher"],
        pickupAddress: json["pickup_address"] == null
            ? null
            : ShippingAddress.fromJson(json["pickup_address"]),
        deliveryAddress: json["delivery_address"] == null
            ? null
            : ShippingAddress.fromJson(json["delivery_address"]),
        location: json["location"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        status: json["status"],
        type: json["type"],
        dispatchId: json["dispatch_id"],
        expectedPickupTime: json["expected_pickup_time"] == null
            ? null
            : DateTime.parse(json["expected_pickup_time"]),
        expectedDeliveryTime: json["expected_delivery_time"],
        actualPickupTime: json["actual_pickup_time"],
        actualDeliveryTime: json["actual_delivery_time"],
        tip: json["tip"],
        currency: json["currency"],
        route: json["route"],
        acceptedBy: json["accepted_by"],
        customer: json["customer"],
        isInProgress: json["is_in_progress"],
        hasEnded: json["has_ended"],
        totalWeight: json["total_weight"],
        totalNoOfItems: json["total_no_of_items"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "delivery_distance": deliveryDistance,
        "pickup_distance": pickupDistance,
        "merchant_avatar": merchantAvatar,
        "merchant_full_name": merchantFullName,
        "merchant": merchant,
        "dispatcher_avatar": dispatcherAvatar,
        "dispatcher_full_name": dispatcherFullName,
        "dispatcher": dispatcher,
        "pickup_address": pickupAddress?.toJson(),
        "delivery_address": deliveryAddress?.toJson(),
        "location": location,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "status": status,
        "type": type,
        "dispatch_id": dispatchId,
        "expected_pickup_time": expectedPickupTime?.toIso8601String(),
        "expected_delivery_time": expectedDeliveryTime,
        "actual_pickup_time": actualPickupTime,
        "actual_delivery_time": actualDeliveryTime,
        "tip": tip,
        "currency": currency,
        "route": route,
        "accepted_by": acceptedBy,
        "customer": customer,
        "is_in_progress": isInProgress,
        "has_ended": hasEnded,
        "total_weight": totalWeight,
        "total_no_of_items": totalNoOfItems,
      };
}
