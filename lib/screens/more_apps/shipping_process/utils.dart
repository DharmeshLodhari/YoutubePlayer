import 'package:Slydo/screens/more_apps/shipping_process/auth/shipping_process_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';

Future<List<ShippingAddress>> getAddressListing(
    List<String?> addressList) async {
  String? listNext = "";
  String? listPrevious = "";
  List<ShippingAddress> addressListing = [];
  int? listCount = 0;
  Map<String, dynamic> data = {
    "addresses": addressList,
  };

  if (listNext != null) {
    Map<String, dynamic>? result = await ShippingProcessAuthService()
        .getAddressListing(listNext, listPrevious, data);

    listCount = result!['count'];
    listNext = result['next'];
    listPrevious = result['previous'];
    var tempList = result['results'];
    addressListing.addAll(tempList!);
  }
  return addressListing;
}
