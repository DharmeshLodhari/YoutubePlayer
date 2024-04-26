class RentDuration {
  bool? atFewDays;
  bool? atFewMonths;
  bool? atFewWeeks;
  bool? atLeastAYear;

  RentDuration(
      {this.atFewDays, this.atFewMonths, this.atFewWeeks, this.atLeastAYear});

  factory RentDuration.fromJson(Map<String, dynamic> json) {
    return RentDuration(
      atFewDays: json['at_few_days'],
      atFewMonths: json['at_few_months'],
      atFewWeeks: json['at_few_weeks'],
      atLeastAYear: json['at_least_a_year'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['at_few_days'] = atFewDays;
    data['at_few_months'] = atFewMonths;
    data['at_few_weeks'] = atFewWeeks;
    data['at_least_a_year'] = atLeastAYear;
    return data;
  }
}
