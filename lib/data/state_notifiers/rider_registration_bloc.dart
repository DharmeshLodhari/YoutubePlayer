import 'package:Slydo/screens/rider_registration/models/kyc_data_model.dart';
import 'package:Slydo/screens/rider_registration/models/rider_registration_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RiderRegistrationBloc extends ChangeNotifier {
  RiderRegistrationModel? registrationModel = RiderRegistrationModel();
  KYCDataModel? kycDataModel = KYCDataModel();
  XFile? _tempPicture;

  XFile? get tempPicture => _tempPicture;

  set tempPicture(XFile? value) {
    _tempPicture = value;
    notifyListeners();
  }

  void updateKYCDataModel(KYCDataModel data) {
    kycDataModel = data;
    notifyListeners();
  }

  void updateRideType(String rideType) {
    if (rideType == "Car") {
      registrationModel?.rideTypeOptions = RideTypeOptions.car;
    } else if (rideType == "Bicycle") {
      registrationModel?.rideTypeOptions = RideTypeOptions.bicycle;
    } else if (rideType == "Motorcycle") {
      registrationModel?.rideTypeOptions = RideTypeOptions.motorcycle;
    }
    notifyListeners();
  }

  void updateKYCType(KYCTypes type) {
    switch (type) {
      case KYCTypes.riderPhoto:
        registrationModel?.kycTypes = KYCTypes.riderPhoto;
        break;
      case KYCTypes.identityCard:
        registrationModel?.kycTypes = KYCTypes.identityCard;
        break;
      case KYCTypes.vehicleInsurance:
        registrationModel?.kycTypes = KYCTypes.vehicleInsurance;
        break;
      case KYCTypes.drivingLicense:
        registrationModel?.kycTypes = KYCTypes.drivingLicense;
        break;
      case KYCTypes.hackneyPermit:
        registrationModel?.kycTypes = KYCTypes.hackneyPermit;
        break;
      default:
        break;
    }
    notifyListeners();
  }

  bool isPhotoAdded(KYCTypes type) {
    switch (type) {
      case KYCTypes.riderPhoto:
        return registrationModel?.mRiderPhoto != null ||
                kycDataModel?.selfie != null
            ? true
            : false;
      case KYCTypes.identityCard:
        return registrationModel?.mIdentityCard != null ||
                kycDataModel?.governmentId != null
            ? true
            : false;
      case KYCTypes.vehicleInsurance:
        return registrationModel?.mVehicleInsurance != null ||
                kycDataModel?.vehicleInsurance != null
            ? true
            : false;
      case KYCTypes.drivingLicense:
        return registrationModel?.mDrivingLicense != null ||
                kycDataModel?.vehicleLicense != null
            ? true
            : false;
      case KYCTypes.hackneyPermit:
        return registrationModel?.mDrivingLicense != null ||
                kycDataModel?.vehicleLicense != null
            ? true
            : false;
      default:
        return false;
    }
  }

  void setPhotoInRegistrationModel(XFile image, KYCTypes? type) {
    switch (type) {
      case KYCTypes.riderPhoto:
        registrationModel?.mRiderPhoto = image;
        break;
      case KYCTypes.identityCard:
        registrationModel?.mIdentityCard = image;
        break;
      case KYCTypes.vehicleInsurance:
        registrationModel?.mVehicleInsurance = image;
        break;
      case KYCTypes.drivingLicense:
        registrationModel?.mDrivingLicense = image;
        break;
      case KYCTypes.hackneyPermit:
        registrationModel?.mDrivingLicense = image;
        break;
      default:
        break;
    }
    notifyListeners();
  }

  bool checkAllProofAdded(RideTypeOptions? rideType) {
    switch (rideType) {
      case RideTypeOptions.car:
        if (registrationModel?.mRiderPhoto != null &&
            registrationModel?.mIdentityCard != null &&
            registrationModel?.mVehicleInsurance != null &&
            registrationModel?.mDrivingLicense != null) {
          return true;
        }
        return false;
      case RideTypeOptions.bicycle:
        if (registrationModel?.mRiderPhoto != null &&
            registrationModel?.mIdentityCard != null &&
            registrationModel?.mDrivingLicense != null) {
          return true;
        }
        return false;
      case RideTypeOptions.motorcycle:
        if (registrationModel?.mRiderPhoto != null &&
            registrationModel?.mIdentityCard != null &&
            registrationModel?.mVehicleInsurance != null &&
            registrationModel?.mDrivingLicense != null) {
          return true;
        }
        return false;
      default:
        return false;
    }
  }

  String? getUploadKYCTypePhoto() {
    switch (registrationModel?.kycTypes) {
      case KYCTypes.riderPhoto:
        return kycDataModel?.selfie;
      case KYCTypes.identityCard:
        return kycDataModel?.governmentId;
      case KYCTypes.vehicleInsurance:
        return kycDataModel?.vehicleInsurance;
      case KYCTypes.drivingLicense:
        return kycDataModel?.vehicleLicense;
      case KYCTypes.hackneyPermit:
        return kycDataModel?.vehicleLicense;
      default:
        return null;
    }
  }
}
