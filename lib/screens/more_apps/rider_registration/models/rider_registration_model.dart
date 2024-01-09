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

// extension ReadableNameKycType on KYCTypes {
//   String toName() {
//     switch (this) {
//       case KYCTypes.riderPhoto:
//         return "Rider Photos";
//       case KYCTypes.identityCard:
//         return "Identity Card";
//       case KYCTypes.vehicleInsurance:
//         return "Rider Photos";
//       case KYCTypes.drivingLicense:
//         return "Rider Photos";
//       case KYCTypes.hackneyPermit:
//         return "Rider Photos";
//       default:
//         return "Rider Photos";
//     }
//   }
// }

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
  XFile? mRiderPhoto;
  XFile? mIdentityCard;
  XFile? mVehicleInsurance;
  XFile? mDrivingLicense;
  // XFile? mHackneyPermit;

  RiderRegistrationModel({
    this.rideTypeOptions,
    this.kycTypes,
    this.mRiderPhoto,
    this.mIdentityCard,
    this.mVehicleInsurance,
    this.mDrivingLicense,
    // this.mHackneyPermit,
  });

  XFile? getCurrentTypePhoto() {
    switch (kycTypes) {
      case KYCTypes.riderPhoto:
        return mRiderPhoto;
      case KYCTypes.identityCard:
        return mIdentityCard;
      case KYCTypes.vehicleInsurance:
        return mVehicleInsurance;
      case KYCTypes.drivingLicense:
        return mDrivingLicense;
      case KYCTypes.hackneyPermit:
        return mDrivingLicense;
      default:
        return null;
    }
  }

  clearAllProof() {
    mRiderPhoto = null;
    mIdentityCard = null;
    mVehicleInsurance = null;
    mDrivingLicense = null;
    // mHackneyPermit = null;
  }

  Future<List<MultipartFile>> getMultipartFiles() async {
    List<http.MultipartFile> files = [];
    http.MultipartFile? selfie;
    http.MultipartFile? governmentId;
    http.MultipartFile? vehicleInsuranceId;
    http.MultipartFile? vehicleLicense;

    if (mRiderPhoto != null) {
      selfie = await http.MultipartFile.fromPath("selfie", mRiderPhoto!.path);
    }

    if (mIdentityCard != null) {
      governmentId = await http.MultipartFile.fromPath(
          "government_id", mIdentityCard!.path);
    }

    if (mVehicleInsurance != null) {
      vehicleInsuranceId = await http.MultipartFile.fromPath(
          "vehicle_insurance", mVehicleInsurance!.path);
    }

    if (mDrivingLicense != null) {
      vehicleLicense = await http.MultipartFile.fromPath(
          "vehicle_license", mDrivingLicense!.path);
    }

    // if (mHackneyPermit != null) {
    //   vehicleLicense = await http.MultipartFile.fromPath(
    //       "vehicle_license", mHackneyPermit!.path);
    // }

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
