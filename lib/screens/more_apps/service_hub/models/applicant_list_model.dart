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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['number_of_jobs'] = this.numberOfJobs;
    data['applicant_username'] = this.applicantUsername;
    data['applicant_name'] = this.applicantName;
    data['applicant_avatar'] = this.applicantAvatar;
    data['ratings'] = this.ratings;
    return data;
  }
}
