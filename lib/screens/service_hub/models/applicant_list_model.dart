class JobApplicantModel {
  int? numberOfJobs;
  String? applicantUsername;
  String? applicantName;
  String? applicantAvatar;
  int? ratings;

  JobApplicantModel(
      {this.numberOfJobs,
      this.applicantUsername,
      this.applicantName,
      this.applicantAvatar,
      this.ratings});

  JobApplicantModel.fromJson(Map<String, dynamic> json) {
    numberOfJobs = json['number_of_jobs'];
    applicantUsername = json['applicant_username'];
    applicantName = json['applicant_name'];
    applicantAvatar = json['applicant_avatar'];
    ratings = json['ratings'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['number_of_jobs'] = numberOfJobs;
    data['applicant_username'] = applicantUsername;
    data['applicant_name'] = applicantName;
    data['applicant_avatar'] = applicantAvatar;
    data['ratings'] = ratings;
    return data;
  }
}
