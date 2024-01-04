enum RideTypeOptions { car, bicycle, motorcycle }

enum KYCTypes { riderPhoto, identityCard, vehicleInsurance, hackneyPermit }

class RiderRegistrationModel {
  RideTypeOptions? rideTypeOptions;
  KYCTypes? kycTypes;

  RiderRegistrationModel({
    this.rideTypeOptions,
    this.kycTypes,
  });
}
