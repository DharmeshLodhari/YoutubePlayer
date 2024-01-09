import 'package:Slydo/screens/more_apps/rider_registration/models/rider_model.dart';

class KYCDataModel {
  int? id;
  RiderModel? rider;
  String? selfie;
  bool? isSelfieVerified;
  String? governmentIdType;
  String? governmentId;
  bool? isGovernmentIdVerified;
  String? vehicleType;
  String? vehicleLicense;
  bool? vehicleLicenseVerified;
  String? vehicleInsurance;
  bool? vehicleInsuranceVerified;
  bool? identityChecked;
  bool? isVerified;
  String? verificationNote;
  DateTime? updatedAt;
  DateTime? createdAt;

  KYCDataModel({
    this.id,
    this.rider,
    this.selfie,
    this.isSelfieVerified,
    this.governmentIdType,
    this.governmentId,
    this.isGovernmentIdVerified,
    this.vehicleType,
    this.vehicleLicense,
    this.vehicleLicenseVerified,
    this.vehicleInsurance,
    this.vehicleInsuranceVerified,
    this.identityChecked,
    this.isVerified,
    this.verificationNote,
    this.updatedAt,
    this.createdAt,
  });

  factory KYCDataModel.fromJson(Map<String, dynamic> json) => KYCDataModel(
        id: json["id"],
        rider:
            json["rider"] == null ? null : RiderModel.fromJson(json["rider"]),
        selfie: json["selfie"],
        isSelfieVerified: json["is_selfie_verified"],
        governmentIdType: json["government_id_type"],
        governmentId: json["government_id"],
        isGovernmentIdVerified: json["is_government_id_verified"],
        vehicleType: json["vehicle_type"],
        vehicleLicense: json["vehicle_license"],
        vehicleLicenseVerified: json["vehicle_license_verified"],
        vehicleInsurance: json["vehicle_insurance"],
        vehicleInsuranceVerified: json["vehicle_insurance_verified"],
        identityChecked: json["identity_checked"],
        isVerified: json["is_verified"],
        verificationNote: json["verification_note"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "rider": rider?.toJson(),
        "selfie": selfie,
        "is_selfie_verified": isSelfieVerified,
        "government_id_type": governmentIdType,
        "government_id": governmentId,
        "is_government_id_verified": isGovernmentIdVerified,
        "vehicle_type": vehicleType,
        "vehicle_license": vehicleLicense,
        "vehicle_license_verified": vehicleLicenseVerified,
        "vehicle_insurance": vehicleInsurance,
        "vehicle_insurance_verified": vehicleInsuranceVerified,
        "identity_checked": identityChecked,
        "is_verified": isVerified,
        "verification_note": verificationNote,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
      };
}
