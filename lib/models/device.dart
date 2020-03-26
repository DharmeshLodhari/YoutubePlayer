class Device {
  String firebaseToken;
  String type; // Android OR IOS
  String mode;
  String deviceId;
  String deviceName;

  Device(
      {this.firebaseToken,
      this.type,
      this.mode,
      this.deviceId,
      this.deviceName});
}
