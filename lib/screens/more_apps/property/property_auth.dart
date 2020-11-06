import 'package:Slydo/screens/more_apps/property/modals/PartialPropertyItem.dart';
import 'package:Slydo/screens/more_apps/property/modals/PropertyItem.dart';
import 'package:Slydo/services/auth.dart';

import 'modals/CityData.dart';

class PropertyAuthService extends AuthService {
  Future<List<String>> getLocation() async {
    List<String> list = ["Lagos", "Kano", "Ibadan", "Benin City", "Abuja"];
    return list;
  }

  Future<List<PropertyItem>> getPropertyList() async {
    var propertyItem = List.generate(
      10,
      (index) => PropertyItem.fromJson({
        "name": "Lake side cottage",
        "images": [
          "https://www.gannett-cdn.com/-mm-/05b227ad5b8ad4e9dcb53af4f31d7fbdb7fa901b/c=0-64-2119-1259/local/-/media/USATODAY/USATODAY/2014/08/13/1407953244000-177513283.jpg",
          "https://www.thebalancesmb.com/thmb/R5CjZrWUBXBTVj48-MBx3PFIh5U=/3000x2000/filters:fill(auto,1)/hotel_room-627892060-5a7a30d1642dca00370179e6.jpg",
          "https://media.istockphoto.com/photos/3d-rendering-modern-luxury-bedroom-suite-and-bathroom-picture-id928431714?k=6&m=928431714&s=612x612&w=0&h=IBnf0aE9zEmsaJ3nLep6UmK4u-KYQPdEQa6LY30Ivn4=",
          "https://gritdaily.com/wp-content/uploads/2019/07/http-cdn.cnn_.com-cnnnext-dam-assets-190711000204-haneda-excel-hotel-tokyu-03.jpg",
          "https://blisssaigon.com/wp-content/uploads/2019/10/iwood-R5v8Xtc0ecg-unsplash-1.jpg"
        ],
        "address1": "Old Ken road",
        "address2": "London SE15",
        "price": "34000.00",
        "currency": "NGN",
        "rating": "7.8"
      }),
    );
    await Future.delayed(Duration(seconds: 3));
    return propertyItem;
  }

  Future<List<PartialPropertyItem>> getPartialPropertyList() async {
    List<String> propertyImages = [
      "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/c6495b0b5b6307d708279b6cc055caaec073c590/ezgif-4-2a367168ec0f.gif",
      "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/c6495b0b5b6307d708279b6cc055caaec073c590/ezgif-4-844078c9fe52.gif",
      "https://media.istockphoto.com/photos/3d-rendering-modern-luxury-bedroom-suite-and-bathroom-picture-id928431714?k=6&m=928431714&s=612x612&w=0&h=IBnf0aE9zEmsaJ3nLep6UmK4u-KYQPdEQa6LY30Ivn4=",
      "https://gritdaily.com/wp-content/uploads/2019/07/http-cdn.cnn_.com-cnnnext-dam-assets-190711000204-haneda-excel-hotel-tokyu-03.jpg",
      "https://blisssaigon.com/wp-content/uploads/2019/10/iwood-R5v8Xtc0ecg-unsplash-1.jpg"
    ];

    List<PartialPropertyItem> propertyItem = propertyImages
        .map(
          (image) => PartialPropertyItem.fromJson({
            "name": "Lake side cottage",
            "image": image,
            "short_description": "3 beds in London",
            "price": "2500.00",
            "currency": "NGN"
          }),
        )
        .toList();
    await Future.delayed(Duration(seconds: 2));
    return propertyItem;
  }

  Future<List<CityData>> getCityList() async {
    List<String> city = ["Lagos", "Kano", "Ibadan", "Benin City", "Abuja"];

    List<CityData> cityItem = city
        .map(
          (name) => CityData.fromJson({
            "name": name,
            "image":
                "https://a.travel-assets.com/findyours-php/viewfinder/images/res70/20000/20665-London.jpg",
          }),
        )
        .toList();
    await Future.delayed(Duration(seconds: 2));
    return cityItem;
  }
}
