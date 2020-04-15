class SearchedUser {
  String name;
  String userName;
  String email;
  String website;

  SearchedUser({this.name, this.userName, this.email, this.website});

  factory SearchedUser.fromJson(Map<String, dynamic> parsedJson) {
    return SearchedUser(
      userName: parsedJson['username'],
      email: parsedJson['email'],
      website: parsedJson['website'],
      name: parsedJson['name'],
    );
  }
}
