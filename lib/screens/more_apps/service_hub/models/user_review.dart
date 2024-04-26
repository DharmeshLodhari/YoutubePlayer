class UserReviewModel {
  String? jobContractor;
  String? jobOwner;
  int? score;
  String? review;
  String? job;
  String? jobOwnerName;
  String? jobContractorName;
  String? ownerAvatar;
  String? contractorAvatar;

  UserReviewModel(
      {this.jobContractor,
      this.jobOwner,
      this.score,
      this.review,
      this.job,
      this.jobOwnerName,
      this.jobContractorName,
      this.ownerAvatar,
      this.contractorAvatar});

  UserReviewModel.fromJson(Map<String, dynamic> json) {
    jobContractor = json['job_contractor'];
    jobOwner = json['job_owner'];
    score = json['score'];
    review = json['review'];
    job = json['job'];
    jobOwnerName = json['job_owner_name'];
    jobContractorName = json['job_contractor_name'];
    ownerAvatar = json['owner_avatar'];
    contractorAvatar = json['contractor_avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['job_contractor'] = jobContractor;
    data['job_owner'] = jobOwner;
    data['score'] = score;
    data['review'] = review;
    data['job'] = job;
    data['job_owner_name'] = jobOwnerName;
    data['job_contractor_name'] = jobContractorName;
    data['owner_avatar'] = ownerAvatar;
    data['contractor_avatar'] = contractorAvatar;
    return data;
  }

  factory UserReviewModel.fromMap(Map<String, dynamic> json) {
    return UserReviewModel(
        jobContractor: json['job_contractor'] as String,
        jobOwner: json['job_owner'] as String,
        score: json['score'] as int,
        review: json['review'] as String,
        job: json['job'] as String,
        jobOwnerName: json['job_owner_name'] as String,
        jobContractorName: json['job_contractor_name'] as String,
        ownerAvatar: json['owner_avatar'] as String,
        contractorAvatar: json['contractor_avatar'] as String);
  }
}
