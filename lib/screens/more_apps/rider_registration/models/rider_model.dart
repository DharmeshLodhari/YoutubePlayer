/// id : "659b3ee2-ccc7-402a-bea6-d146d2cade07"
/// username : "blackstriker"
/// is_active : true
/// status : "Pending"
/// transport_type : "Walking"
/// current_location : null
/// updated_at : "2023-12-22T19:36:31.813372Z"
/// created_at : "2023-12-22T19:16:38.940767Z"
library;

class RiderModel {
  String? id;
  String? username;
  bool? isActive;
  String? status;
  String? transportType;
  dynamic currentLocation;
  String? updatedAt;
  String? createdAt;

  RiderModel({
    this.id,
    this.username,
    this.isActive,
    this.status,
    this.transportType,
    this.currentLocation,
    this.updatedAt,
    this.createdAt,
  });

  RiderModel.fromJson(dynamic json) {
    id = json['id'];
    username = json['username'];
    isActive = json['is_active'];
    status = json['status'];
    transportType = json['transport_type'];
    currentLocation = json['current_location'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
  }

  RiderModel copyWith({
    String? id,
    String? username,
    bool? isActive,
    String? status,
    String? transportType,
    dynamic currentLocation,
    String? updatedAt,
    String? createdAt,
  }) =>
      RiderModel(
        id: id ?? this.id,
        username: username ?? this.username,
        isActive: isActive ?? this.isActive,
        status: status ?? this.status,
        transportType: transportType ?? this.transportType,
        currentLocation: currentLocation ?? this.currentLocation,
        updatedAt: updatedAt ?? this.updatedAt,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['username'] = username;
    map['is_active'] = isActive;
    map['status'] = status;
    map['transport_type'] = transportType;
    map['current_location'] = currentLocation;
    map['updated_at'] = updatedAt;
    map['created_at'] = createdAt;
    return map;
  }

  bool isStatusApproved() {
    if (status == "Pending") {
      return false;
    }
    return true;
  }
}
