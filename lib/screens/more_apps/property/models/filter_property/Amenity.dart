class Amenity {
  bool? ac;
  bool? any;
  bool? dishwasher;
  bool? doorman;
  bool? gatedEntry;
  bool? gym;
  bool? heating;
  bool? laundry;
  bool? parking;
  bool? pool;

  Amenity(
      {this.ac,
      this.any,
      this.dishwasher,
      this.doorman,
      this.gatedEntry,
      this.gym,
      this.heating,
      this.laundry,
      this.parking,
      this.pool});

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      ac: json['ac'],
      any: json['any'],
      dishwasher: json['dishwasher'],
      doorman: json['doorman'],
      gatedEntry: json['gated_entry'],
      gym: json['gym'],
      heating: json['heating'],
      laundry: json['laundry'],
      parking: json['parking'],
      pool: json['pool'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ac'] = ac;
    data['any'] = any;
    data['dishwasher'] = dishwasher;
    data['doorman'] = doorman;
    data['gated_entry'] = gatedEntry;
    data['gym'] = gym;
    data['heating'] = heating;
    data['laundry'] = laundry;
    data['parking'] = parking;
    data['pool'] = pool;
    return data;
  }
}
