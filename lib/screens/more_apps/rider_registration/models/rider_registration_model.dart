import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

enum RideTypeOptions { car, bicycle, motorcycle }

enum KYCTypes {
  riderPhoto,
  identityCard,
  vehicleInsurance,
  drivingLicense,
  hackneyPermit,
}

extension SlydoExtensions on int {
  double divideByTen() {
    return this / 10;
  }
}

extension ReadableNameKycType on KYCTypes {
  String toName() {
    switch (this) {
      case KYCTypes.riderPhoto:
        return "Rider Photos";
      case KYCTypes.identityCard:
        return "Identity Card";
      case KYCTypes.vehicleInsurance:
        return "Rider Photos";
      case KYCTypes.drivingLicense:
        return "Rider Photos";
      case KYCTypes.hackneyPermit:
        return "Rider Photos";
      default:
        return "Rider Photos";
    }
  }
}

extension ReadableNameRideType on RideTypeOptions {
  String toName() {
    switch (this) {
      case RideTypeOptions.car:
        return "Car";
      case RideTypeOptions.bicycle:
        return "Bicycle";
      case RideTypeOptions.motorcycle:
        return "Motorcycle";
    }
  }
}

extension ReadableNameTransportType on RideTypeOptions {
  String toTypeName() {
    switch (this) {
      case RideTypeOptions.car:
        return "Driving";
      case RideTypeOptions.bicycle:
        return "Two-wheeler";
      case RideTypeOptions.motorcycle:
        return "Two-wheeler";
    }
  }
}

class RiderRegistrationModel {
  RideTypeOptions? rideTypeOptions;
  KYCTypes? kycTypes;
  XFile? riderPhoto;
  XFile? identityCard;
  XFile? vehicleInsurance;
  XFile? drivingLicense;
  XFile? hackneyPermit;

  RiderRegistrationModel({
    this.rideTypeOptions,
    this.kycTypes,
    this.riderPhoto,
    this.identityCard,
    this.vehicleInsurance,
    this.drivingLicense,
    this.hackneyPermit,
  });

  XFile? getCurrentTypePhoto() {
    switch (kycTypes) {
      case KYCTypes.riderPhoto:
        return riderPhoto;
      case KYCTypes.identityCard:
        return identityCard;
      case KYCTypes.vehicleInsurance:
        return vehicleInsurance;
      case KYCTypes.drivingLicense:
        return drivingLicense;
      case KYCTypes.hackneyPermit:
        return hackneyPermit;
      default:
        return null;
    }
  }

  clearAllProof() {
    riderPhoto = null;
    identityCard = null;
    vehicleInsurance = null;
    drivingLicense = null;
    hackneyPermit = null;
  }

  bool isPhotoAdded(KYCTypes type) {
    switch (type) {
      case KYCTypes.riderPhoto:
        return riderPhoto != null ? true : false;
      case KYCTypes.identityCard:
        return identityCard != null ? true : false;
      case KYCTypes.vehicleInsurance:
        return vehicleInsurance != null ? true : false;
      case KYCTypes.drivingLicense:
        return drivingLicense != null ? true : false;
      case KYCTypes.hackneyPermit:
        return hackneyPermit != null ? true : false;
      default:
        return false;
    }
  }

  Future<List<MultipartFile>> getMultipartFiles() async {
    List<http.MultipartFile> files = [];
    http.MultipartFile? selfie;
    http.MultipartFile? governmentId;
    http.MultipartFile? vehicleInsuranceId;
    http.MultipartFile? vehicleLicense;

    if (riderPhoto != null) {
      selfie = await http.MultipartFile.fromPath("selfie", riderPhoto!.path);
    }

    if (identityCard != null) {
      governmentId = await http.MultipartFile.fromPath(
          "government_id", identityCard!.path);
    }

    if (vehicleInsurance != null) {
      vehicleInsuranceId = await http.MultipartFile.fromPath(
          "vehicle_insurance", vehicleInsurance!.path);
    }

    if (drivingLicense != null) {
      vehicleLicense = await http.MultipartFile.fromPath(
          "vehicle_license", drivingLicense!.path);
    }

    if (hackneyPermit != null) {
      vehicleLicense = await http.MultipartFile.fromPath(
          "vehicle_license", hackneyPermit!.path);
    }

    switch (rideTypeOptions) {
      case RideTypeOptions.car:
        files.addAll(
            [selfie!, governmentId!, vehicleInsuranceId!, vehicleLicense!]);
        break;
      case RideTypeOptions.bicycle:
        files.addAll([selfie!, governmentId!, vehicleLicense!]);
        break;
      case RideTypeOptions.motorcycle:
        files.addAll(
            [selfie!, governmentId!, vehicleInsuranceId!, vehicleLicense!]);
        break;
      default:
        return [];
    }
    return files;
  }

  Map<String, String> toRegisterRider() {
    return {
      "government_id_type": "Passport",
      "vehicle_type": rideTypeOptions?.toName() ?? "",
      "transport_type": rideTypeOptions?.toTypeName() ?? "",
    };
  }
}
