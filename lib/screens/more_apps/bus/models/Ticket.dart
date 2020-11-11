class Ticket {
  String from;
  String fromTime;
  String gate;
  String journeyTime;
  String qrCode;
  String seat;
  String to;
  String toTime;

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from;
    data['from_time'] = this.fromTime;
    data['gate'] = this.gate;
    data['journey_time'] = this.journeyTime;
    data['qr_code'] = this.qrCode;
    data['seat'] = this.seat;
    data['to'] = this.to;
    data['to_time'] = this.toTime;
    return data;
  }
}
