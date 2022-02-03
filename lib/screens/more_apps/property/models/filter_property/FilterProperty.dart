import 'Amenity.dart';
import 'Bathroom.dart';
import 'Bedroom.dart';
import 'PetPolicy.dart';
import 'PropertyType.dart';
import 'RentDuration.dart';

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['check_in_date'] = this.checkInDate;
    data['check_out_date'] = this.checkOutDate;
    data['is_for_buy'] = this.isForBuy;
    data['is_furnished'] = this.isFurnished;
    data['is_roommates_needed'] = this.isRoommatesNeeded;
    data['max_price'] = this.maxPrice;
    data['min_price'] = this.minPrice;
    data['no_of_guest'] = this.noOfGuest;
    if (this.amenity != null) {
      data['amenity'] = this.amenity!.toJson();
    }
    if (this.bathroom != null) {
      data['bathroom'] = this.bathroom!.toJson();
    }
    if (this.bedroom != null) {
      data['bedroom'] = this.bedroom!.toJson();
    }
    if (this.petPolicy != null) {
      data['pet_policy'] = this.petPolicy!.toJson();
    }
    if (this.propertyType != null) {
      data['property_type'] = this.propertyType!.toJson();
    }
    if (this.rentDuration != null) {
      data['rent_duration'] = this.rentDuration!.toJson();
    }
    return data;
  }
}
