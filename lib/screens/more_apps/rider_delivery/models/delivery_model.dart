import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:intl/intl.dart';

class DeliveryModel {
  String? id;
  dynamic deliveryDistance;
  dynamic pickupDistance;
  String? merchantAvatar;
  String? merchantFullName;
  String? merchant;
  String? dispatcherAvatar;
  String? dispatcherFullName;
  String? dispatcher;
  ShippingAddress? pickupAddress;
  ShippingAddress? deliveryAddress;
  RiderLocation? location;
  List<dynamic>? route;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? status;
  String? type;
  String? dispatchId;
  DateTime? expectedPickupTime;
  DateTime? expectedDeliveryTime;
  DateTime? actualPickupTime;
  DateTime? actualDeliveryTime;
  int? tip;
  int? riderPayment;
  String? currency;
  String? acceptedBy;
  String? customer;
  bool? isInProgress;
  bool? hasEnded;
  int? totalWeight;
  int? totalNoOfItems;
  String? deliveryEvidence;
  int? orderId;
  int? distanceTravel;
  String? dispatcherNumber;
  // bool? isShowDetails;
  // bool? isDeliveryAccepted;
  // bool? isDeliveryStarted;
  // bool? isDeliveryEnded;
  // bool? isDeliveryCancel;
  // bool? isChecked;

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
    this.route,
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
    this.riderPayment,
    this.currency,
    this.acceptedBy,
    this.customer,
    this.isInProgress,
    this.hasEnded,
    this.totalWeight,
    this.totalNoOfItems,
    this.deliveryEvidence,
    this.orderId,
    this.distanceTravel,
    this.dispatcherNumber,
    // this.isShowDetails = true,
    // this.isDeliveryAccepted = false,
    // this.isDeliveryStarted = false,
    // this.isDeliveryEnded = false,
    // this.isDeliveryCancel = false,
    // this.isChecked = false,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) => DeliveryModel(
        id: json["id"],
        deliveryDistance: json["delivery_distance"],
        pickupDistance: json["pickup_distance"],
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
        location: json["location"] == null
            ? null
            : RiderLocation.fromJson(json["location"]),
        route: json["route"] == null
            ? []
            : List<dynamic>.from(json["route"]!.map((x) => x)),
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
        expectedDeliveryTime: json["expected_delivery_time"] == null
            ? null
            : DateTime.parse(json["expected_delivery_time"]),
        actualPickupTime: json["actual_pickup_time"] == null
            ? null
            : DateTime.parse(json["actual_pickup_time"]),
        actualDeliveryTime: json["actual_delivery_time"] == null
            ? null
            : DateTime.parse(json["actual_delivery_time"]),
        tip: json["tip"],
        riderPayment: json["rider_payment"],
        currency: json["currency"],
        acceptedBy: json["accepted_by"],
        customer: json["customer"],
        isInProgress: json["is_in_progress"],
        hasEnded: json["has_ended"],
        totalWeight: json["total_weight"],
        totalNoOfItems: json["total_no_of_items"],
        deliveryEvidence: json["delivery_evidence"],
        orderId: json["order_id"],
        distanceTravel: json["distance_travel"],
        dispatcherNumber: json["dispatcher_number"],
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
        "location": location?.toJson(),
        "route": route == null ? [] : List<dynamic>.from(route!.map((x) => x)),
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
        "rider_payment": riderPayment,
        "currency": currency,
        "route": route,
        "accepted_by": acceptedBy,
        "customer": customer,
        "is_in_progress": isInProgress,
        "has_ended": hasEnded,
        "total_weight": totalWeight,
        "delivery_evidence": deliveryEvidence,
        "total_no_of_items": totalNoOfItems,
        "delivery_evidence": deliveryEvidence,
        "order_id": orderId,
        "distance_travel": distanceTravel,
        "dispatcher_number": dispatcherNumber,
      };

  bool isOfferAccepted(String? userName) {
    if (acceptedBy != null) {
      if (acceptedBy == userName) {
        return true;
      }
    }
    return false;
  }

  bool isAfterOfferAccepted(String? userName) {
    if (isOfferAccepted(userName) == true &&
        isInProgress == false &&
        hasEnded == false) {
      return true;
    }
    return false;
  }

  bool isOfferStarted(String? userName) {
    if (isOfferAccepted(userName) == true && isInProgress == true) {
      return true;
    }
    return false;
  }

  bool isOfferEnded(String? userName) {
    if (isOfferAccepted(userName) == true && hasEnded == true) {
      return true;
    }
    return false;
  }

  String convertDateFormat(String time) {
    if (time != null && time != "null") {
      DateTime pickupTime = DateTime.parse(time);
      // Format into AM/PM time
      return DateFormat('h:mm a').format(pickupTime.toLocal());
    }
    return "";
  }
}

class RiderLocation {
  double? longitude;
  double? latitude;
  double? heading;

  RiderLocation({
    this.longitude,
    this.latitude,
    this.heading,
  });

  factory RiderLocation.fromJson(Map<String, dynamic> json) => RiderLocation(
        longitude: json["longitude"]?.toDouble(),
        latitude: json["latitude"]?.toDouble(),
        heading: json["heading"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "longitude": longitude,
        "latitude": latitude,
        "heading": heading,
      };
}
