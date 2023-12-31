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
  Address? pickupAddress;
  Address? deliveryAddress;
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
  Job? job;
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
    this.job,
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
            : Address.fromJson(json["pickup_address"]),
        deliveryAddress: json["delivery_address"] == null
            ? null
            : Address.fromJson(json["delivery_address"]),
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
        job: json["job"] == null ? null : Job.fromJson(json["job"]),
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
        "job": job?.toJson(),
        "total_weight": totalWeight,
        "total_no_of_items": totalNoOfItems,
      };
}

class Address {
  String? id;
  String? addressLine1;
  String? addressLine2;
  String? location;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? city;
  String? state;
  String? country;
  String? email;
  bool? isResidential;
  String? firstName;
  String? lastName;
  String? line1;
  String? line2;
  Metadata? metadata;
  String? name;
  String? phone;
  String? zip;
  String? providerId;
  DateTime? providerCreatedAt;
  DateTime? providerUpdatedAt;
  bool? anonymous;
  bool? isDefault;

  Address({
    this.id,
    this.addressLine1,
    this.addressLine2,
    this.location,
    this.createdAt,
    this.updatedAt,
    this.city,
    this.state,
    this.country,
    this.email,
    this.isResidential,
    this.firstName,
    this.lastName,
    this.line1,
    this.line2,
    this.metadata,
    this.name,
    this.phone,
    this.zip,
    this.providerId,
    this.providerCreatedAt,
    this.providerUpdatedAt,
    this.anonymous,
    this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json["id"],
        addressLine1: json["address_line_1"],
        addressLine2: json["address_line_2"],
        location: json["location"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        city: json["city"],
        state: json["state"],
        country: json["country"],
        email: json["email"],
        isResidential: json["is_residential"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        line1: json["line1"],
        line2: json["line2"],
        metadata: json["metadata"] == null
            ? null
            : Metadata.fromJson(json["metadata"]),
        name: json["name"],
        phone: json["phone"],
        zip: json["zip"],
        providerId: json["provider_id"],
        providerCreatedAt: json["provider_created_at"] == null
            ? null
            : DateTime.parse(json["provider_created_at"]),
        providerUpdatedAt: json["provider_updated_at"] == null
            ? null
            : DateTime.parse(json["provider_updated_at"]),
        anonymous: json["anonymous"],
        isDefault: json["is_default"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "address_line_1": addressLine1,
        "address_line_2": addressLine2,
        "location": location,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "city": city,
        "state": state,
        "country": country,
        "email": email,
        "is_residential": isResidential,
        "first_name": firstName,
        "last_name": lastName,
        "line1": line1,
        "line2": line2,
        "metadata": metadata?.toJson(),
        "name": name,
        "phone": phone,
        "zip": zip,
        "provider_id": providerId,
        "provider_created_at": providerCreatedAt?.toIso8601String(),
        "provider_updated_at": providerUpdatedAt?.toIso8601String(),
        "anonymous": anonymous,
        "is_default": isDefault,
      };
}

class Metadata {
  String? googlePostalCode;

  Metadata({
    this.googlePostalCode,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        googlePostalCode: json["google_postal_code"],
      );

  Map<String, dynamic> toJson() => {
        "google_postal_code": googlePostalCode,
      };
}

class Job {
  String? id;

  Job({
    this.id,
  });

  factory Job.fromJson(Map<String, dynamic> json) => Job(
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
      };
}
