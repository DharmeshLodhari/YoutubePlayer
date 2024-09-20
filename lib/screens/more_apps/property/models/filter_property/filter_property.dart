import 'amenity_model.dart';
import 'bathroom_model.dart';
import 'bedroom_model.dart';
import 'pet_policy.dart';
import 'property_type.dart';
import 'rent_duration.dart';

class FilterProperty {
  Amenity? amenity;
  Bathroom? bathroom;
  Bedroom? bedroom;
  String? checkInDate;
  String? checkOutDate;
  bool? isForBuy;
  bool? isFurnished;
  bool? isRoommatesNeeded;
  int? maxPrice;
  int? minPrice;
  int? noOfGuest;
  PetPolicy? petPolicy;
  PropertyType? propertyType;
  RentDuration? rentDuration;

  FilterProperty(
      {this.amenity,
      this.bathroom,
      this.bedroom,
      this.checkInDate,
      this.checkOutDate,
      this.isForBuy,
      this.isFurnished,
      this.isRoommatesNeeded,
      this.maxPrice,
      this.minPrice,
      this.noOfGuest,
      this.petPolicy,
      this.propertyType,
      this.rentDuration});

  factory FilterProperty.fromJson(Map<String, dynamic> json) {
    return FilterProperty(
      amenity:
          json['amenity'] != null ? Amenity.fromJson(json['amenity']) : null,
      bathroom:
          json['bathroom'] != null ? Bathroom.fromJson(json['bathroom']) : null,
      bedroom:
          json['bedroom'] != null ? Bedroom.fromJson(json['bedroom']) : null,
      checkInDate: json['check_in_date'],
      checkOutDate: json['check_out_date'],
      isForBuy: json['is_for_buy'],
      isFurnished: json['is_furnished'],
      isRoommatesNeeded: json['is_roommates_needed'],
      maxPrice: json['max_price'],
      minPrice: json['min_price'],
      noOfGuest: json['no_of_guest'],
      petPolicy: json['pet_policy'] != null
          ? PetPolicy.fromJson(json['pet_policy'])
          : null,
      propertyType: json['property_type'] != null
          ? PropertyType.fromJson(json['property_type'])
          : null,
      rentDuration: json['rent_duration'] != null
          ? RentDuration.fromJson(json['rent_duration'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['check_in_date'] = checkInDate;
    data['check_out_date'] = checkOutDate;
    data['is_for_buy'] = isForBuy;
    data['is_furnished'] = isFurnished;
    data['is_roommates_needed'] = isRoommatesNeeded;
    data['max_price'] = maxPrice;
    data['min_price'] = minPrice;
    data['no_of_guest'] = noOfGuest;
    if (amenity != null) {
      data['amenity'] = amenity!.toJson();
    }
    if (bathroom != null) {
      data['bathroom'] = bathroom!.toJson();
    }
    if (bedroom != null) {
      data['bedroom'] = bedroom!.toJson();
    }
    if (petPolicy != null) {
      data['pet_policy'] = petPolicy!.toJson();
    }
    if (propertyType != null) {
      data['property_type'] = propertyType!.toJson();
    }
    if (rentDuration != null) {
      data['rent_duration'] = rentDuration!.toJson();
    }
    return data;
  }
}
