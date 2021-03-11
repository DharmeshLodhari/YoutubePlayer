import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';

class SearchItemWithFilterModel {
  CustomerProfile searchedUser;
  String searchedText;
  String category;
  int minAmount;
  int maxAmount;

  SearchItemWithFilterModel(
      {this.category = "All categories",
      this.minAmount,
      this.searchedText,
      this.maxAmount,
      this.searchedUser});
}
