import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';

class SearchItemWithFilterModel {
  String? searchedText;
  String category;
  int? minAmount;
  int? maxAmount;
  String?
      userName; //This is passed in the case that searchedUser is null (e.g when we are searching the super store).
  CustomerProfile? searchedUser;

  SearchItemWithFilterModel(
      {this.category = "All categories",
      this.minAmount,
      this.searchedText,
      this.maxAmount,
      this.userName,
      this.searchedUser});
}

class SearchItemWithFilterModelForSuperStore {
  String? searchedText;
  List<String> categories;
  int? minPrice;
  int? maxPrice;
  List<String> state;
  List<String> lga;
  String? rating;
  String? sortBy;

  SearchItemWithFilterModelForSuperStore({
    this.sortBy,
    this.categories = const [],
    this.minPrice,
    required this.searchedText,
    this.state = const [],
    this.lga = const [],
    this.maxPrice,
    this.rating,
  });
}

