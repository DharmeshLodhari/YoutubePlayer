import 'package:Slydo/services/auth.dart';

import 'models/city_data.dart';
import 'models/partial_property_item.dart';
import 'models/property_item.dart';
import 'models/user_detail_item/PropertyDetailItem.dart';

class PropertyAuthService extends AuthService {
  Future<List<String>> getLocation() async {
    final List<String> list = [
      "Lagos",
      "Kano",
      "Ibadan",
      "Benin City",
      "Abuja"
    ];
    return list;
  }

  Future<List<PropertyItem>> getPropertyList() async {
    final propertyItem = List.generate(
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
    await Future.delayed(const Duration(seconds: 1));
    return propertyItem;
  }

  Future<List<PartialPropertyItem>> getPartialPropertyList() async {
    final List<String> propertyImages = [
      "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/c6495b0b5b6307d708279b6cc055caaec073c590/ezgif-4-2a367168ec0f.gif",
      "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/c6495b0b5b6307d708279b6cc055caaec073c590/ezgif-4-844078c9fe52.gif",
      "https://media.istockphoto.com/photos/3d-rendering-modern-luxury-bedroom-suite-and-bathroom-picture-id928431714?k=6&m=928431714&s=612x612&w=0&h=IBnf0aE9zEmsaJ3nLep6UmK4u-KYQPdEQa6LY30Ivn4=",
      "https://gritdaily.com/wp-content/uploads/2019/07/http-cdn.cnn_.com-cnnnext-dam-assets-190711000204-haneda-excel-hotel-tokyu-03.jpg",
      "https://blisssaigon.com/wp-content/uploads/2019/10/iwood-R5v8Xtc0ecg-unsplash-1.jpg"
    ];

    final List<PartialPropertyItem> propertyItem = propertyImages
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
    await Future.delayed(const Duration(seconds: 1));
    return propertyItem;
  }

  Future<List<CityData>> getCityList() async {
    final List<String> city = [
      "Lagos",
      "Kano",
      "Ibadan",
      "Benin City",
      "Abuja"
    ];

    final List<CityData> cityItem = city
        .map(
          (name) => CityData.fromJson({
            "name": name,
            "image":
                "https://a.travel-assets.com/findyours-php/viewfinder/images/res70/20000/20665-London.jpg",
          }),
        )
        .toList();
    await Future.delayed(const Duration(seconds: 1));
    return cityItem;
  }

  Future<PropertyDetailItem> getProperty() async {
    final dummyData = {
      "name": "Lake side cottage",
      "short_detail": "3 beds • 2 bath • 1 livingroom",
      "owner_name": "Bond street dojo",
      "owner_user_name": "brijesh.sakariya",
      "owner_avatar":
          "https://d2qp0siotla746.cloudfront.net/img/use-cases/profile-picture/template_3.jpg",
      "about":
          "Excepteur sint occaecat cupidatat non proident,sunt in culpa qui officia deserunt mollit anim id est laborum. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pa.Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pa.",
      "location": [
        {"latitude": "6.5244° N", "longitude": "3.3792° E"}
      ],
      "reviews": [
        {
          "name": "Jamé Smith",
          "star": 4,
          "user_avatar":
              "https://d2qp0siotla746.cloudfront.net/img/use-cases/profile-picture/template_3.jpg",
          "detail":
              "Very knowledgeable about all the history, really friendly, always smile, and always up for a chat.",
          "date": "20 Aug"
        },
        {
          "name": "Jamé Smith",
          "star": 4,
          "user_avatar":
              "https://d2qp0siotla746.cloudfront.net/img/use-cases/profile-picture/template_3.jpg",
          "detail":
              "Very knowledgeable about all the history, really friendly, always smile, and always up for a chat.",
          "date": "20 Aug"
        },
        {
          "name": "Jamé Smith",
          "star": 4,
          "user_avatar":
              "https://d2qp0siotla746.cloudfront.net/img/use-cases/profile-picture/template_3.jpg",
          "detail":
              "Very knowledgeable about all the history, really friendly, always smile, and always up for a chat.",
          "date": "20 Aug"
        },
        {
          "name": "Jamé Smith",
          "star": 4,
          "user_avatar":
              "https://d2qp0siotla746.cloudfront.net/img/use-cases/profile-picture/template_3.jpg",
          "detail":
              "Very knowledgeable about all the history, really friendly, always smile, and always up for a chat.",
          "date": "20 Aug"
        },
      ],
      "partners": [
        {
          "name": "Bond street dojo",
          "user_avatar":
              "https://d2qp0siotla746.cloudfront.net/img/use-cases/profile-picture/template_3.jpg",
          "star": "7.8",
          "user_tag": "Renter Friendly"
        },
        {
          "name": "Bond street dojo",
          "user_avatar":
              "https://d2qp0siotla746.cloudfront.net/img/use-cases/profile-picture/template_3.jpg",
          "star": "7.8",
          "user_tag": "Renter Friendly"
        }
      ],
      "similar_properties": [
        {
          "name": "Lake side cottage",
          "image":
              "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/c6495b0b5b6307d708279b6cc055caaec073c590/ezgif-4-2a367168ec0f.gif",
          "short_description": "3 beds in London",
          "price": "1600.00",
          "currency": "NGN"
        },
        {
          "name": "Lake side cottage",
          "image":
              "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/c6495b0b5b6307d708279b6cc055caaec073c590/ezgif-4-844078c9fe52.gif",
          "short_description": "3 beds in London",
          "price": "1600.00",
          "currency": "NGN"
        },
        {
          "name": "Lake side cottage",
          "image":
              "https://media.istockphoto.com/photos/3d-rendering-modern-luxury-bedroom-suite-and-bathroom-picture-id928431714?k=6&m=928431714&s=612x612&w=0&h=IBnf0aE9zEmsaJ3nLep6UmK4u-KYQPdEQa6LY30Ivn4=",
          "short_description": "3 beds in London",
          "price": "1600.00",
          "currency": "NGN"
        },
        {
          "name": "Lake side cottage",
          "image":
              "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/c6495b0b5b6307d708279b6cc055caaec073c590/ezgif-4-844078c9fe52.gif",
          "short_description": "3 beds in London",
          "price": "1600.00",
          "currency": "NGN"
        },
        {
          "name": "Lake side cottage",
          "image":
              "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/c6495b0b5b6307d708279b6cc055caaec073c590/ezgif-4-2a367168ec0f.gif",
          "short_description": "3 beds in London",
          "price": "1600.00",
          "currency": "NGN"
        }
      ],
      "images": [
        "https://www.gannett-cdn.com/-mm-/05b227ad5b8ad4e9dcb53af4f31d7fbdb7fa901b/c=0-64-2119-1259/local/-/media/USATODAY/USATODAY/2014/08/13/1407953244000-177513283.jpg",
        "https://www.thebalancesmb.com/thmb/R5CjZrWUBXBTVj48-MBx3PFIh5U=/3000x2000/filters:fill(auto,1)/hotel_room-627892060-5a7a30d1642dca00370179e6.jpg",
        "https://media.istockphoto.com/photos/3d-rendering-modern-luxury-bedroom-suite-and-bathroom-picture-id928431714?k=6&m=928431714&s=612x612&w=0&h=IBnf0aE9zEmsaJ3nLep6UmK4u-KYQPdEQa6LY30Ivn4=",
        "https://gritdaily.com/wp-content/uploads/2019/07/http-cdn.cnn_.com-cnnnext-dam-assets-190711000204-haneda-excel-hotel-tokyu-03.jpg",
        "https://blisssaigon.com/wp-content/uploads/2019/10/iwood-R5v8Xtc0ecg-unsplash-1.jpg"
      ],
      "video":
          "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/f8001e9a7d13cfa1db96d85e7467c1a87ba73f0b/y2mate.com - Cinematic Real Estate Video in 4K_480p.mp4"
    };

    final PropertyDetailItem property = PropertyDetailItem.fromJson(dummyData);
    await Future.delayed(const Duration(seconds: 1));
    return property;
  }

  Future<void> addToWishList() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return;
  }
}
