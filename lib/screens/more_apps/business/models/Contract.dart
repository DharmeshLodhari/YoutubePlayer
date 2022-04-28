class ContractModel {
  int? amount;
  String? contractee;
  String? contracteeAvatar;
  String? contractor;
  String? contractorAvatar;
  String? createdAt;
  String? currency;
  String? endDate;
  int? id;
  String? note;
  String? paymentDuration;
  String? startDate;
  String? status;
  bool isAccepted;

  ContractModel(
      {this.amount,
      this.contractee,
      this.contracteeAvatar,
      this.contractor,
      this.contractorAvatar,
      this.createdAt,
      this.currency,
      required this.isAccepted,
      this.endDate,
      this.id,
      this.note,
      this.paymentDuration,
      this.startDate,
      this.status});

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      amount: json['amount'],
      contractee: json['contractee'],
      contracteeAvatar: json['contractee_avatar'],
      contractor: json['contractor'],
      contractorAvatar: json['contractor_avatar'],
      createdAt: json['created_at'],
      currency: json['currency'],
      endDate: json['end_date'],
      id: json['id'],
      note: json['note'],
      paymentDuration: json['payment_duration'],
      startDate: json['start_date'],
      status: json['status'],
      isAccepted: json['is_accepted'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['contractee'] = this.contractee;
    data['contractee_avatar'] = this.contracteeAvatar;
    data['contractor'] = this.contractor;
    data['contractor_avatar'] = this.contractorAvatar;
    data['created_at'] = this.createdAt;
    data['currency'] = this.currency;
    data['end_date'] = this.endDate;
    data['id'] = this.id;
    data['note'] = this.note;
    data['payment_duration'] = this.paymentDuration;
    data['start_date'] = this.startDate;
    data['status'] = this.status;
    return data;
  }
}
