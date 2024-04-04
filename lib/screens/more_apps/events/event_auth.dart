import 'package:Slydo/screens/more_apps/events/models/EventDetailItem.dart';
import 'package:Slydo/screens/more_apps/events/models/EventPoster.dart';
import 'package:Slydo/screens/more_apps/events/models/PartialEventItem.dart';
import 'package:Slydo/services/auth.dart';

import 'models/CityData.dart';

class EventAuthService extends AuthService {
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

  Future<List<EventPoster>> getEventPosterList() async {
    final List<Map<String, String>> eventPoster = [
      {
        "name": "Mongola",
        "image":
            "https://www.telegraph.co.uk/content/dam/Travel/Destinations/Europe/United%20Kingdom/London/london-aerial-thames-guide.jpg"
      },
      {
        "name": "Beach Event",
        "image":
            "https://www.cityam.com/wp-content/uploads/2020/02/London_Tower_Bridge_City.jpg"
      },
      {
        "name": "Mongola",
        "image":
            "https://metab.ern-net.eu/wp-content/uploads/2018/04/London.jpg"
      },
      {
        "name": "Beach Event",
        "image":
            "https://travel.home.sndimg.com/content/dam/images/travel/fullset/2015/05/28/big-ben-london-england.jpg"
      },
      {
        "name": "Mongola",
        "image":
            "https://a.travel-assets.com/findyours-php/viewfinder/images/res70/20000/20665-London.jpg"
      }
    ];

    final eventPosterList = eventPoster
        .map(
          (element) => EventPoster.fromJson(element),
        )
        .toList();
    await Future.delayed(const Duration(seconds: 1));
    return eventPosterList;
  }

  Future<List<PartialEventItem>> getPartialEventList() async {
    final List<PartialEventItem> propertyItem = List.generate(
      8,
      (image) => PartialEventItem.fromJson({
        "name": "5th Borough food festival",
        "image":
            "https://specialedshortbus.com/wp-content/uploads/2020/01/52.jpg",
        "short_description": "Humankind is now facing a global crisis...",
        "title": "Bronx night market",
        "price": "34.00",
        "currency": "NGN",
        "location": "Clave lakes park",
        "date_time": "Thu, Oct 15 • 6:54 AM"
      }),
    );
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
                "https://a.travel-assets.com/findyours-php/viewfinder/images/res70/20000/20665-London.jpg"
          }),
        )
        .toList();
    await Future.delayed(const Duration(seconds: 1));
    return cityItem;
  }

  Future<EventDetailItem> getEventDetailItem() async {
    final dummyData = {
      "name": '“Sundays on the beach" Brunch & beach party',
      "event_time": "Sunday, October 18 • 6:54 PM",
      "owner_name": "Bond street dojo",
      "owner_user_name": "brijesh.sakariya",
      "owner_avatar":
          "https://d2qp0siotla746.cloudfront.net/img/use-cases/profile-picture/template_3.jpg",
      "about":
          "Excepteur sint occaecat cupidatat non proident,sunt in culpa qui officia deserunt mollit anim id est laborum. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pa.Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pa.",
      "location": [
        {
          "name": "Savana beach bar",
          "latitude": "6.5244° N",
          "longitude": "3.3792° E"
        }
      ],
      "price": "34.00",
      "currency": "NGN",
      "similar_event": [
        {
          "name": "5th Borough food festival",
          "image":
              "https://specialedshortbus.com/wp-content/uploads/2020/01/52.jpg",
          "short_description": "Humankind is now facing a global crisis...",
          "title": "Bronx night market",
          "price": "34.00",
          "currency": "NGN",
          "location": "Clave lakes park",
          "date_time": "Thu, Oct 15 • 6:54 AM"
        },
        {
          "name": "5th Borough food festival",
          "image":
              "https://specialedshortbus.com/wp-content/uploads/2020/01/52.jpg",
          "short_description": "Humankind is now facing a global crisis...",
          "title": "Bronx night market",
          "price": "34.00",
          "currency": "NGN",
          "location": "Clave lakes park",
          "date_time": "Thu, Oct 15 • 6:54 AM"
        },
        {
          "name": "5th Borough food festival",
          "image":
              "https://specialedshortbus.com/wp-content/uploads/2020/01/52.jpg",
          "short_description": "Humankind is now facing a global crisis...",
          "title": "Bronx night market",
          "price": "34.00",
          "currency": "NGN",
          "location": "Clave lakes park",
          "date_time": "Thu, Oct 15 • 6:54 AM"
        },
        {
          "name": "5th Borough food festival",
          "image":
              "https://specialedshortbus.com/wp-content/uploads/2020/01/52.jpg",
          "short_description": "Humankind is now facing a global crisis...",
          "title": "Bronx night market",
          "price": "34.00",
          "currency": "NGN",
          "location": "Clave lakes park",
          "date_time": "Thu, Oct 15 • 6:54 AM"
        },
        {
          "name": "5th Borough food festival",
          "image":
              "https://specialedshortbus.com/wp-content/uploads/2020/01/52.jpg",
          "short_description": "Humankind is now facing a global crisis...",
          "title": "Bronx night market",
          "price": "34.00",
          "currency": "NGN",
          "location": "Clave lakes park",
          "date_time": "Thu, Oct 15 • 6:54 AM"
        },
        {
          "name": "5th Borough food festival",
          "image":
              "https://specialedshortbus.com/wp-content/uploads/2020/01/52.jpg",
          "short_description": "Humankind is now facing a global crisis...",
          "title": "Bronx night market",
          "price": "34.00",
          "currency": "NGN",
          "location": "Clave lakes park",
          "date_time": "Thu, Oct 15 • 6:54 AM"
        }
      ],
      "image":
          "https://ichef.bbci.co.uk/news/976/cpsprodpb/D50C/production/_105204545_2men.jpg"
    };

    final EventDetailItem event = EventDetailItem.fromJson(dummyData);
    await Future.delayed(const Duration(seconds: 1));
    return event;
  }

  Future<void> addToWishList() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return;
  }
}
