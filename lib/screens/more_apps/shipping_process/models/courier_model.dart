import 'package:Slydo/screens/more_apps/shipping_process/models/shipping_option_model.dart';

class CourierModel {
  double? amount;
  Breakdown? breakdown;
  String? carrierLogo;
  String? carrierName;
  String? carrierRateDescription;
  String? carrierReference;
  String? carrierSlug;
  String? currency;
  String? domain;
  double? defaultAmount;
  String? defaultCurrency;
  String? deliveryAddress;
  DateTime? deliveryDate;
  int? deliveryEta;
  String? deliveryTime;
  bool? dropoffAvailable;
  int? insuranceCoverage;
  bool? includesDuties;
  int? insuranceFee;
  bool? includesInsurance;
  Metadata? metadata;
  String? parcel;
  List<dynamic>? parcels;
  String? pickupAddress;
  int? pickupEta;
  String? pickupTime;
  String? rateId;
  String? source;
  bool? used;
  String? user;
  String? id;
  int? v;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? welcomeId;

  CourierModel({
    this.amount,
    this.breakdown,
    this.carrierLogo,
    this.carrierName,
    this.carrierRateDescription,
    this.carrierReference,
    this.carrierSlug,
    this.currency,
    this.domain,
    this.defaultAmount,
    this.defaultCurrency,
    this.deliveryAddress,
    this.deliveryDate,
    this.deliveryEta,
    this.deliveryTime,
    this.dropoffAvailable,
    this.insuranceCoverage,
    this.includesDuties,
    this.insuranceFee,
    this.includesInsurance,
    this.metadata,
    this.parcel,
    this.parcels,
    this.pickupAddress,
    this.pickupEta,
    this.pickupTime,
    this.rateId,
    this.source,
    this.used,
    this.user,
    this.id,
    this.v,
    this.createdAt,
    this.updatedAt,
    this.welcomeId,
  });

  ShippingOptionModel toShippingOptionModel() {
    return ShippingOptionModel(
        // id: id,
        currency: currency,
        price: ((amount ?? 0) * 100).toInt(),
        name: carrierName,
        owner: carrierName,
        rateId: rateId);
  }

  factory CourierModel.fromJson(Map<String, dynamic> json) => CourierModel(
        amount: json["amount"]?.toDouble(),
        breakdown: json["breakdown"] == null
            ? null
            : Breakdown.fromJson(json["breakdown"]),
        carrierLogo: json["carrier_logo"],
        carrierName: json["carrier_name"],
        carrierRateDescription: json["carrier_rate_description"],
        carrierReference: json["carrier_reference"],
        carrierSlug: json["carrier_slug"],
        currency: json["currency"],
        domain: json["domain"],
        defaultAmount: json["default_amount"]?.toDouble(),
        defaultCurrency: json["default_currency"],
        deliveryAddress: json["delivery_address"],
        deliveryDate: json["delivery_date"] == null
            ? null
            : DateTime.parse(json["delivery_date"]),
        deliveryEta: json["delivery_eta"],
        deliveryTime: json["delivery_time"],
        dropoffAvailable: json["dropoff_available"],
        insuranceCoverage: json["insurance_coverage"],
        includesDuties: json["includes_duties"],
        insuranceFee: json["insurance_fee"],
        includesInsurance: json["includes_insurance"],
        metadata: json["metadata"] == null
            ? null
            : Metadata.fromJson(json["metadata"]),
        parcel: json["parcel"],
        parcels: json["parcels"] == null
            ? []
            : List<dynamic>.from(json["parcels"]!.map((x) => x)),
        pickupAddress: json["pickup_address"],
        pickupEta: json["pickup_eta"],
        pickupTime: json["pickup_time"],
        rateId: json["rate_id"],
        source: json["source"],
        used: json["used"],
        user: json["user"],
        id: json["_id"],
        v: json["__v"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        welcomeId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "breakdown": breakdown?.toJson(),
        "carrier_logo": carrierLogo,
        "carrier_name": carrierName,
        "carrier_rate_description": carrierRateDescription,
        "carrier_reference": carrierReference,
        "carrier_slug": carrierSlug,
        "currency": currency,
        "domain": domain,
        "default_amount": defaultAmount,
        "default_currency": defaultCurrency,
        "delivery_address": deliveryAddress,
        "delivery_date": deliveryDate?.toIso8601String(),
        "delivery_eta": deliveryEta,
        "delivery_time": deliveryTime,
        "dropoff_available": dropoffAvailable,
        "insurance_coverage": insuranceCoverage,
        "includes_duties": includesDuties,
        "insurance_fee": insuranceFee,
        "includes_insurance": includesInsurance,
        "metadata": metadata?.toJson(),
        "parcel": parcel,
        "parcels":
            parcels == null ? [] : List<dynamic>.from(parcels!.map((x) => x)),
        "pickup_address": pickupAddress,
        "pickup_eta": pickupEta,
        "pickup_time": pickupTime,
        "rate_id": rateId,
        "source": source,
        "used": used,
        "user": user,
        "_id": id,
        "__v": v,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "id": welcomeId,
      };
}

class Breakdown {
  double? shipmentCost;
  String? shipmentCostCurrency;
  int? addressValidationFee;
  int? labelGenerationFee;
  double? surchargeAmount;
  double? vat;
  double? chargeAmount;
  String? chargeAmountCurrency;
  int? insuranceFee;
  double? markupFee;
  int? customAccountCharge;
  int? emergencyFee;
  double? chargeAmountNgn;

  Breakdown({
    this.shipmentCost,
    this.shipmentCostCurrency,
    this.addressValidationFee,
    this.labelGenerationFee,
    this.surchargeAmount,
    this.vat,
    this.chargeAmount,
    this.chargeAmountCurrency,
    this.insuranceFee,
    this.markupFee,
    this.customAccountCharge,
    this.emergencyFee,
    this.chargeAmountNgn,
  });

  factory Breakdown.fromJson(Map<String, dynamic> json) => Breakdown(
        shipmentCost: json["shipment_cost"]?.toDouble(),
        shipmentCostCurrency: json["shipment_cost_currency"],
        addressValidationFee: json["address_validation_fee"],
        labelGenerationFee: json["label_generation_fee"],
        surchargeAmount: json["surcharge_amount"]?.toDouble(),
        vat: json["vat"]?.toDouble(),
        chargeAmount: json["charge_amount"]?.toDouble(),
        chargeAmountCurrency: json["charge_amount_currency"],
        insuranceFee: json["insurance_fee"],
        markupFee: json["markup_fee"]?.toDouble(),
        customAccountCharge: json["custom_account_charge"],
        emergencyFee: json["emergency_fee"],
        chargeAmountNgn: json["charge_amount_ngn"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "shipment_cost": shipmentCost,
        "shipment_cost_currency": shipmentCostCurrency,
        "address_validation_fee": addressValidationFee,
        "label_generation_fee": labelGenerationFee,
        "surcharge_amount": surchargeAmount,
        "vat": vat,
        "charge_amount": chargeAmount,
        "charge_amount_currency": chargeAmountCurrency,
        "insurance_fee": insuranceFee,
        "markup_fee": markupFee,
        "custom_account_charge": customAccountCharge,
        "emergency_fee": emergencyFee,
        "charge_amount_ngn": chargeAmountNgn,
      };
}

class Metadata {
  DefaultParcel? defaultParcel;
  AddressPayload? addressPayload;
  double? shipmentCost;
  int? score;
  int? avgRating;
  int? insuranceFee;
  String? insuranceCurrency;
  int? insuranceDefaultFee;
  String? insuranceDefaultCurrency;
  int? codProcessingFee;
  String? localProductCode;
  String? productCode;
  bool? isManual;
  dynamic id;
  double? avgActualTurnaroundTime;
  double? avgActualPickupTime;
  bool? recommended;

  Metadata({
    this.defaultParcel,
    this.addressPayload,
    this.shipmentCost,
    this.score,
    this.avgRating,
    this.insuranceFee,
    this.insuranceCurrency,
    this.insuranceDefaultFee,
    this.insuranceDefaultCurrency,
    this.codProcessingFee,
    this.localProductCode,
    this.productCode,
    this.isManual,
    this.id,
    this.avgActualTurnaroundTime,
    this.avgActualPickupTime,
    this.recommended,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        defaultParcel: json["default_parcel"] == null
            ? null
            : DefaultParcel.fromJson(json["default_parcel"]),
        addressPayload: json["address_payload"] == null
            ? null
            : AddressPayload.fromJson(json["address_payload"]),
        shipmentCost: json["shipment_cost"]?.toDouble(),
        score: json["score"],
        avgRating: json["avgRating"],
        insuranceFee: json["insurance_fee"],
        insuranceCurrency: json["insurance_currency"],
        insuranceDefaultFee: json["insurance_default_fee"],
        insuranceDefaultCurrency: json["insurance_default_currency"],
        codProcessingFee: json["cod_processing_fee"],
        localProductCode: json["localProductCode"],
        productCode: json["productCode"],
        isManual: json["is_manual"],
        id: json["_id"],
        avgActualTurnaroundTime: json["avgActualTurnaroundTime"]?.toDouble(),
        avgActualPickupTime: json["avgActualPickupTime"]?.toDouble(),
        recommended: json["recommended"],
      );

  Map<String, dynamic> toJson() => {
        "default_parcel": defaultParcel?.toJson(),
        "address_payload": addressPayload?.toJson(),
        "shipment_cost": shipmentCost,
        "score": score,
        "avgRating": avgRating,
        "insurance_fee": insuranceFee,
        "insurance_currency": insuranceCurrency,
        "insurance_default_fee": insuranceDefaultFee,
        "insurance_default_currency": insuranceDefaultCurrency,
        "cod_processing_fee": codProcessingFee,
        "localProductCode": localProductCode,
        "productCode": productCode,
        "is_manual": isManual,
        "_id": id,
        "avgActualTurnaroundTime": avgActualTurnaroundTime,
        "avgActualPickupTime": avgActualPickupTime,
        "recommended": recommended,
      };
}

class AddressPayload {
  Address? pickupAddress;
  Address? deliveryAddress;

  AddressPayload({
    this.pickupAddress,
    this.deliveryAddress,
  });

  factory AddressPayload.fromJson(Map<String, dynamic> json) => AddressPayload(
        pickupAddress: json["pickup_address"] == null
            ? null
            : Address.fromJson(json["pickup_address"]),
        deliveryAddress: json["delivery_address"] == null
            ? null
            : Address.fromJson(json["delivery_address"]),
      );

  Map<String, dynamic> toJson() => {
        "pickup_address": pickupAddress?.toJson(),
        "delivery_address": deliveryAddress?.toJson(),
      };
}

class Address {
  String? city;
  String? state;
  String? country;
  String? zip;

  Address({
    this.city,
    this.state,
    this.country,
    this.zip,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        city: json["city"],
        state: json["state"],
        country: json["country"],
        zip: json["zip"],
      );

  Map<String, dynamic> toJson() => {
        "city": city,
        "state": state,
        "country": country,
        "zip": zip,
      };
}

class DefaultParcel {
  PackagingDimension? packagingDimension;
  int? parcelTotalWeight;

  DefaultParcel({
    this.packagingDimension,
    this.parcelTotalWeight,
  });

  factory DefaultParcel.fromJson(Map<String, dynamic> json) => DefaultParcel(
        packagingDimension: json["packaging_dimension"] == null
            ? null
            : PackagingDimension.fromJson(json["packaging_dimension"]),
        parcelTotalWeight: json["parcel_total_weight"],
      );

  Map<String, dynamic> toJson() => {
        "packaging_dimension": packagingDimension?.toJson(),
        "parcel_total_weight": parcelTotalWeight,
      };
}

class PackagingDimension {
  int? length;
  int? height;
  int? width;

  PackagingDimension({
    this.length,
    this.height,
    this.width,
  });

  factory PackagingDimension.fromJson(Map<String, dynamic> json) =>
      PackagingDimension(
        length: json["length"],
        height: json["height"],
        width: json["width"],
      );

  Map<String, dynamic> toJson() => {
        "length": length,
        "height": height,
        "width": width,
      };
}
