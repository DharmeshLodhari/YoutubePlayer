class ContractModel {
  int? amount;
  String? contract;
  String? contractAvatar;
  String? contractor;
  String? contractorDisplayName;
  String? contractDisplayName;
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
      this.contract,
      this.contractorDisplayName,
      this.contractDisplayName,
      this.contractAvatar,
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
      contract: json['contractee'],
      contractDisplayName: json['contractee_display_name'],
      contractorDisplayName: json['contractor_display_name'],
      contractAvatar: json['contractee_avatar'],
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    data['contractee'] = contract;
    data['contractee_avatar'] = contractAvatar;
    data['contractor'] = contractor;
    data['contractor_avatar'] = contractorAvatar;
    data['created_at'] = createdAt;
    data['currency'] = currency;
    data['end_date'] = endDate;
    data['id'] = id;
    data['note'] = note;
    data['payment_duration'] = paymentDuration;
    data['start_date'] = startDate;
    data['status'] = status;
    return data;
  }
}
