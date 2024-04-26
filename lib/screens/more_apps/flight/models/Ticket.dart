class Ticket {
  String? from;
  String? fromTime;
  String? gate;
  String? journeyTime;
  String? qrCode;
  String? seat;
  String? to;
  String? toTime;

  Ticket(
      {this.from = "",
      this.fromTime = "",
      this.gate = "",
      this.journeyTime = "",
      this.qrCode = "",
      this.seat = "",
      this.to = "",
      this.toTime = ""});

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      from: json['from'],
      fromTime: json['from_time'],
      gate: json['gate'],
      journeyTime: json['journey_time'],
      qrCode: json['qr_code'],
      seat: json['seat'],
      to: json['to'],
      toTime: json['to_time'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['from'] = from;
    data['from_time'] = fromTime;
    data['gate'] = gate;
    data['journey_time'] = journeyTime;
    data['qr_code'] = qrCode;
    data['seat'] = seat;
    data['to'] = to;
    data['to_time'] = toTime;
    return data;
  }
}
