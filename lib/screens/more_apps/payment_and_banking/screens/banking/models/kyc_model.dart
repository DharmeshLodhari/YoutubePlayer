class KycModel {
  String? bvnResult;
  String? documentResult;
  String? verificationNote;

  KycModel({
    required this.bvnResult,
    required this.documentResult,
    required this.verificationNote,
  });

  factory KycModel.fromJson(Map<String, dynamic> json) {
    print('KYCMODEL JSON ----> $json');
    return KycModel(
      bvnResult: json['bvn_number_result'],
      documentResult: json['document_result'],
      verificationNote: json['verification_note'],
    );
  }
}
