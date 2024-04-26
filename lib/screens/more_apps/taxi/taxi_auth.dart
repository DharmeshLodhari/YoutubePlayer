import 'dart:convert';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/taxi/model/DirectionsModal.dart';
import 'package:Slydo/screens/more_apps/taxi/model/PlaceModal.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TaxiAuth extends AuthService {
  Future<List> searchPlaces({String? place = ""}) async {
    String url = "https://maps.googleapis.com/maps/api/place/textsearch/json?";

    url = "${url}query=$place";
    url = "$url&key=${AppConfig.googleMapApiKey}";

    url = Uri.encodeFull(url);
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    if (response.statusCode == 200) {
      debugPrint("URL:- $url statusCode:- ${response.statusCode}");

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      final List<PlaceModal> placesModal = [];

      final List places = responseBody['results'];

      places.forEach((element) {
        placesModal.add(PlaceModal.fromJson(element));
      });

      return placesModal;
    } else {
      debugPrint(
          "URL:- $url statusCode:- ${response.statusCode}  body:- ${response.body}");
      return [];
    }
  }

  Future<Directions> getDirections(
      {required LatLng origin, required LatLng destination}) async {
    String url = "https://maps.googleapis.com/maps/api/directions/json?";

    url = "${url}origin=${origin.latitude},${origin.longitude}";
    url = "$url&destination=${destination.latitude},${destination.longitude}";
    url = "$url&key=${AppConfig.googleMapApiKey}";

    url = Uri.encodeFull(url);
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    if (response.statusCode == 200) {
      final Directions directions =
          Directions.fromMap(jsonDecode(response.body));

      return directions;
    } else {
      debugPrint(
          "URL:- $url statusCode:- ${response.statusCode}  body:- ${response.body}");
      return Future.error(
          "URL:- $url statusCode:- ${response.statusCode}  body:- ${response.body}");
    }
  }

  List<PlaceModal> getFakePlaces() {
    final List<PlaceModal> places = [];

    final List<Map<String, dynamic>> fakeJson = [
      {
        "business_status": "OPERATIONAL",
        "formatted_address":
            "Ikeja City Mall, Obafemi Awolowo Way, Ikeja, Nigeria",
        "geometry": {
          "location": {"lat": 6.613793299999999, "lng": 3.357997},
          "viewport": {
            "northeast": {"lat": 6.615326479892722, "lng": 3.358928379892722},
            "southwest": {"lat": 6.612626820107278, "lng": 3.356228720107278}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/shopping-71.png",
        "icon_background_color": "#4B96F3",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/shoppingcart_pinlet",
        "name": "Shoprite Ikeja City Mall",
        "opening_hours": {"open_now": true},
        "photos": [
          {
            "height": 3008,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/117852248501968340109\">Jacobus Krynauw</a>"
            ],
            "photo_reference":
                "Aap_uECXKZB3wnuCBzSyKudWNsl3g8VuTI9BE4AyM7Ekd04gEP9ABbsW6f1pyIaBQxs5riuwf4_3ZCsnW9kMVDP3DhWDsxa1UOerHlyjBHOwqVCikFKrySA_MdllMl93uRmCKBRvQ2o3DEkHHmu_5_x9nvtuCKlYB7WnpC-f5DC9cf7puCd8",
            "width": 5344
          }
        ],
        "place_id": "ChIJJ-Hs58mTOxAR6ax9rB2vnME",
        "plus_code": {
          "compound_code": "J975+G5 Ikeja, Nigeria",
          "global_code": "6FR5J975+G5"
        },
        "price_level": 2,
        "rating": 4.3,
        "reference": "ChIJJ-Hs58mTOxAR6ax9rB2vnME",
        "types": [
          "supermarket",
          "bakery",
          "grocery_or_supermarket",
          "finance",
          "travel_agency",
          "food",
          "point_of_interest",
          "store",
          "establishment"
        ],
        "user_ratings_total": 7735
      },
      {
        "business_status": "OPERATIONAL",
        "formatted_address":
            "Mall, 174 / 194 Obafemi Awolowo Way Lagos Ikeja City, Lagos, Nigeria",
        "geometry": {
          "location": {"lat": 6.6144441, "lng": 3.3580345},
          "viewport": {
            "northeast": {"lat": 6.615889079892721, "lng": 3.359316129892723},
            "southwest": {"lat": 6.613189420107277, "lng": 3.356616470107278}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/movies-71.png",
        "icon_background_color": "#13B5C7",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/movie_pinlet",
        "name": "Silverbird Cinemas - Ikeja",
        "opening_hours": {"open_now": true},
        "photos": [
          {
            "height": 3024,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/113627246833729836485\">Owobo Yomi</a>"
            ],
            "photo_reference":
                "Aap_uEBY25zci1CR-MOsmt_2P-hAkS1pAYj4SLxQOioMUj6sGYKYi3jq82Q7f6s-fDjfBTns2G9W38PpXkH70XsH5hyK9FZ6qGnlv52UytQ1aGQTn0-4ezgcfgkVfK6Pe6hrUucTrxSNpEvkXShNS3lWGk3p43TajhkD3BYVcJ-BJLJCHYBu",
            "width": 4032
          }
        ],
        "place_id": "ChIJKQ9m5SKTOxAR8qUrS5kCovk",
        "plus_code": {
          "compound_code": "J975+Q6 Lagos, Nigeria",
          "global_code": "6FR5J975+Q6"
        },
        "rating": 4.2,
        "reference": "ChIJKQ9m5SKTOxAR8qUrS5kCovk",
        "types": ["movie_theater", "point_of_interest", "establishment"],
        "user_ratings_total": 3887
      },
      {
        "business_status": "OPERATIONAL",
        "formatted_address": "Alausa 100212, Ikeja, Nigeria",
        "geometry": {
          "location": {"lat": 6.6201985, "lng": 3.3610773},
          "viewport": {
            "northeast": {"lat": 6.621542979892722, "lng": 3.362393879892722},
            "southwest": {"lat": 6.618843320107278, "lng": 3.359694220107277}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/generic_business-71.png",
        "icon_background_color": "#7B9EB0",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/generic_pinlet",
        "name": "Jr_Consultant_Scout_Agent",
        "opening_hours": {"open_now": true},
        "photos": [
          {
            "height": 2448,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/103023483285844203360\">Chidi Lugard</a>"
            ],
            "photo_reference":
                "Aap_uEAxdEHZsdiaA-9j2SXR6BRstuQw5pGIZp903JoGIudQfx7KOF7J4RBN2-dsBKHy0HfrvnnoX25vSt8d_X2bQTYV2xs2rSk-REejCgeeQPcjX_uoRxs4x2h3N-vMkjb9BSOx0sXXCd0EnI8JgCUA7jkzCfrncqjIv2k_3E4TsTig85OT",
            "width": 3264
          }
        ],
        "place_id": "ChIJFW6oW7aTOxARrcM2NPtg4Do",
        "plus_code": {
          "compound_code": "J9C6+3C Ikeja, Nigeria",
          "global_code": "6FR5J9C6+3C"
        },
        "rating": 4.4,
        "reference": "ChIJFW6oW7aTOxARrcM2NPtg4Do",
        "types": ["point_of_interest", "establishment"],
        "user_ratings_total": 36118
      },
      {
        "business_status": "OPERATIONAL",
        "formatted_address":
            "Ikeja City Mall, Alausa, Obafemi Awolowo Way, Oregun, Ikeja, Nigeria",
        "geometry": {
          "location": {"lat": 6.6141618, "lng": 3.3580237},
          "viewport": {
            "northeast": {"lat": 6.615696229892721, "lng": 3.359238129892722},
            "southwest": {"lat": 6.612996570107277, "lng": 3.356538470107278}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/shopping-71.png",
        "icon_background_color": "#4B96F3",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/shopping_pinlet",
        "name": "iStore Ikeja Mall",
        "opening_hours": {"open_now": true},
        "photos": [
          {
            "height": 323,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/112900676358763406967\">mofoluwake arogundade</a>"
            ],
            "photo_reference":
                "Aap_uECXYjzW2p9u5LElVMrTWHIGwuZWzZWXPIZNwXGrDPSMbha631eq9Fu_qaxfmi0Xgp3j6VPb-Gngzix6fZ4vxMSCtxggaKSNnYTi-KZ45gfqYIj1dv8m5BGqp-04Feg27TrdMP09U0SsgSRoNvSLqkfU54AAj6o5TZ7NHznFPWaCoh2f",
            "width": 800
          }
        ],
        "place_id": "ChIJt5CiFsqTOxARKnFMOHC6FuE",
        "plus_code": {
          "compound_code": "J975+M6 Ikeja, Nigeria",
          "global_code": "6FR5J975+M6"
        },
        "rating": 4.3,
        "reference": "ChIJt5CiFsqTOxARKnFMOHC6FuE",
        "types": [
          "electronics_store",
          "point_of_interest",
          "store",
          "establishment"
        ],
        "user_ratings_total": 113
      },
      {
        "business_status": "OPERATIONAL",
        "formatted_address":
            "Shop L-49, by entrance 2 Ikeja City Mall, Shoprite, Alausa, Ikeja, Nigeria",
        "geometry": {
          "location": {"lat": 6.614743, "lng": 3.358383},
          "viewport": {
            "northeast": {"lat": 6.616149979892722, "lng": 3.359626029892722},
            "southwest": {"lat": 6.613450320107278, "lng": 3.356926370107277}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/shopping-71.png",
        "icon_background_color": "#4B96F3",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/shopping_pinlet",
        "name": "Audacious Ikeja City Mall",
        "opening_hours": {"open_now": true},
        "photos": [
          {
            "height": 2444,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/106853277615744393403\">A Google User</a>"
            ],
            "photo_reference":
                "Aap_uECDTIqKA_R1Uk7bTiAG_Ct41blERKQxrJcZ-sPJD2dsn6gYm2-0iSX3wdAh_jzGr5Io2hffhMBdEcBWBZk_OHTmal61IU79MnSq0W-I208kHICgjrAlsu2DeGEobsscG8CCW7BtwO3lve80_NkNezFiM0unNxHPPGN-IWxS91hpn2-h",
            "width": 2444
          }
        ],
        "place_id": "ChIJN7dPG8qTOxARESo4vOBah5Y",
        "plus_code": {
          "compound_code": "J975+V9 Ikeja, Nigeria",
          "global_code": "6FR5J975+V9"
        },
        "rating": 5,
        "reference": "ChIJN7dPG8qTOxARESo4vOBah5Y",
        "types": [
          "clothing_store",
          "point_of_interest",
          "store",
          "establishment"
        ],
        "user_ratings_total": 2
      },
      {
        "business_status": "OPERATIONAL",
        "formatted_address": "Ipodo St, Opebi 101233, Ikeja, Nigeria",
        "geometry": {
          "location": {"lat": 6.596006200000001, "lng": 3.342994},
          "viewport": {
            "northeast": {"lat": 6.597347679892722, "lng": 3.344313279892722},
            "southwest": {"lat": 6.594648020107278, "lng": 3.341613620107277}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/shopping-71.png",
        "icon_background_color": "#4B96F3",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/shopping_pinlet",
        "name": "Ikeja",
        "opening_hours": {"open_now": true},
        "place_id": "ChIJK2No5MSTOxAR3g3nZa34k64",
        "plus_code": {
          "compound_code": "H8WV+C5 Ikeja, Nigeria",
          "global_code": "6FR5H8WV+C5"
        },
        "rating": 0,
        "reference": "ChIJK2No5MSTOxAR3g3nZa34k64",
        "types": ["shopping_mall", "point_of_interest", "establishment"],
        "user_ratings_total": 0
      },
      {
        "business_status": "OPERATIONAL",
        "formatted_address":
            "Elephant Bus-stop Along Obafemi Awolowo way, Shop No. L 12 Ikeja City Mall Alausa Ikeja, 100246, Ikeja, Nigeria",
        "geometry": {
          "location": {"lat": 6.614059, "lng": 3.357561},
          "viewport": {
            "northeast": {"lat": 6.615526329892722, "lng": 3.358860829892722},
            "southwest": {"lat": 6.612826670107278, "lng": 3.356161170107278}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/shopping-71.png",
        "icon_background_color": "#4B96F3",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/shopping_pinlet",
        "name": "9mobile Experience Centre Ikeja Mall",
        "opening_hours": {"open_now": true},
        "photos": [
          {
            "height": 3357,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/103954575076717880594\">Olumide Daniel</a>"
            ],
            "photo_reference":
                "Aap_uEB8cJ_ucK8-9qrBEwQE-T8bSCrcQAj0KN5wYrw1kD7N2TYvFH1Gu6nDhXxqj8JSLr104HPP4AstpHx-uCv75j1lAi_vbsJmHbYpMUWxWFVgC-XIWzaqeOnH7PTvFJ72_7vwTOgddp88MxmWkBk5G6FfoiahBnS14NkWf1BLio5LphNO",
            "width": 2080
          }
        ],
        "place_id": "ChIJg6Bl_fOROxARheTMxoa7Meg",
        "plus_code": {
          "compound_code": "J975+J2 Ikeja, Nigeria",
          "global_code": "6FR5J975+J2"
        },
        "rating": 4.1,
        "reference": "ChIJg6Bl_fOROxARheTMxoa7Meg",
        "types": ["point_of_interest", "store", "establishment"],
        "user_ratings_total": 50
      },
      {
        "business_status": "OPERATIONAL",
        "formatted_address":
            "79 Obafemi Awolowo Way, Ikeja 101233, Ikeja, Nigeria",
        "geometry": {
          "location": {"lat": 6.6021566, "lng": 3.3440466},
          "viewport": {
            "northeast": {"lat": 6.603558229892721, "lng": 3.345535079892723},
            "southwest": {"lat": 6.600858570107278, "lng": 3.342835420107278}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/generic_business-71.png",
        "icon_background_color": "#7B9EB0",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/generic_pinlet",
        "name": "Trinity Mall",
        "opening_hours": {"open_now": false},
        "photos": [
          {
            "height": 2988,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/109021919043392669000\">Austin Chikwado Ofor</a>"
            ],
            "photo_reference":
                "Aap_uED5FgivNmLGIC35tLgUF58hzfre6ex9wyk-bXhAcjI_K9N-PXmvuuY2rSZKFw6kA1-2wH84BReucajSmIP_Cg4SjBM2mzlyl3amC2-vlL7yTzQ-kdJuSsT5MopzC9aSqg2mhSliTpt_aMzVAgkQxzC8oKvExAEGZBzZy7Mr2eFLj2uP",
            "width": 2988
          }
        ],
        "place_id": "ChIJs4BkxyiSOxARikgYj0wZdh0",
        "plus_code": {
          "compound_code": "J82V+VJ Ikeja, Nigeria",
          "global_code": "6FR5J82V+VJ"
        },
        "rating": 4,
        "reference": "ChIJs4BkxyiSOxARikgYj0wZdh0",
        "types": ["shopping_mall", "point_of_interest", "establishment"],
        "user_ratings_total": 634
      },
      {
        "business_status": "OPERATIONAL",
        "formatted_address":
            "Ikeja City Mall Obafemi Awolowo Way Ikeja, 100001, Lagos, Nigeria",
        "geometry": {
          "location": {"lat": 6.6143776, "lng": 3.3579681},
          "viewport": {
            "northeast": {"lat": 6.615829079892722, "lng": 3.359245079892723},
            "southwest": {"lat": 6.613129420107278, "lng": 3.356545420107278}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/generic_business-71.png",
        "icon_background_color": "#7B9EB0",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/generic_pinlet",
        "name": "Pizza Hut Ikeja City Mall",
        "opening_hours": {"open_now": true},
        "photos": [
          {
            "height": 1280,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/118052045398727640041\">A Google User</a>"
            ],
            "photo_reference":
                "Aap_uEATBO6itlQGkV2SzZmK3OuOzxuEm_v0ZK2Sjrl6ZFw-Ws6BEBK0bi5i0he3erPZPIpTeMiiqlJfI-RyJ3y6vvSV4Z8sBSUlMjSOkaOlB9EW5kIDEHo0Jrt_XE4_khSFH69bj-E08i2SVfy_7YDLCIuZmrRG60sl7VzupKOpVM2rg5gD",
            "width": 960
          }
        ],
        "place_id": "ChIJV-eX2_GTOxARH7_N6_AGLoU",
        "plus_code": {
          "compound_code": "J975+Q5 Lagos, Nigeria",
          "global_code": "6FR5J975+Q5"
        },
        "rating": 3.7,
        "reference": "ChIJV-eX2_GTOxARH7_N6_AGLoU",
        "types": [
          "meal_delivery",
          "restaurant",
          "food",
          "point_of_interest",
          "establishment"
        ],
        "user_ratings_total": 29
      },
      {
        "business_status": "OPERATIONAL",
        "formatted_address":
            "Ikeja City Mall, Obafemi Awolowo Way, Ikeja, Nigeria",
        "geometry": {
          "location": {"lat": 6.6141874, "lng": 3.3584295},
          "viewport": {
            "northeast": {"lat": 6.615815379892722, "lng": 3.359586829892722},
            "southwest": {"lat": 6.613115720107278, "lng": 3.356887170107277}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/restaurant-71.png",
        "icon_background_color": "#FF9E67",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/restaurant_pinlet",
        "name": "Rhapsody's Ikeja",
        "opening_hours": {"open_now": true},
        "photos": [
          {
            "height": 3096,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/104632654651988290518\">Sanya Oluwadare</a>"
            ],
            "photo_reference":
                "Aap_uEC7DuVpyWcjsBeHscd8fyF59ytrBXdGrcPXMr8klyQArSZ2x-i1OuZSYRmeBxr9cFWssbhTMmrQNlPLTtp6CIVwwZgBftgRPp94UmvH5kxTgaTlzY99lwSTQyFni40qypD8qMCkdAHp2f4ZX9mppNbmzwJaRyfwwaUCIWH3mHikp6lu",
            "width": 4128
          }
        ],
        "place_id": "ChIJARTNa8qTOxARsqfw5unp3QY",
        "plus_code": {
          "compound_code": "J975+M9 Ikeja, Nigeria",
          "global_code": "6FR5J975+M9"
        },
        "price_level": 2,
        "rating": 4.3,
        "reference": "ChIJARTNa8qTOxARsqfw5unp3QY",
        "types": [
          "restaurant",
          "night_club",
          "bar",
          "food",
          "point_of_interest",
          "establishment"
        ],
        "user_ratings_total": 285
      },
      {
        "business_status": "OPERATIONAL",
        "formatted_address":
            "Ikeja shopping mall Alausa Ikeja Lagos Alausa, 100212, Lagos, Nigeria",
        "geometry": {
          "location": {"lat": 6.6208949, "lng": 3.3611486},
          "viewport": {
            "northeast": {"lat": 6.622256079892722, "lng": 3.362497829892722},
            "southwest": {"lat": 6.619556420107278, "lng": 3.359798170107278}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/shopping-71.png",
        "icon_background_color": "#4B96F3",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/shopping_pinlet",
        "name": "Bedmate Furniture Nigeria (Ikeja Shopping Mall)",
        "opening_hours": {"open_now": true},
        "photos": [
          {
            "height": 2957,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/103954575076717880594\">Olumide Daniel</a>"
            ],
            "photo_reference":
                "Aap_uECw3tcBtsTy88luAW7PbmnWVFWP92fZMFBX6Wa0Rr-AqyzvuGJMLqOzoOsAlv72LJS3Vw1lbPQu35EUhrtQ_t8JYBnuNxyeVo6CHbXtzFeufW-L7qaNWiOzrAbHZq2ovcIg9uM0-qVaY7kQ1YtK6MTEYACwaZ3qZpYcD_95geoVbZNn",
            "width": 2080
          }
        ],
        "place_id": "ChIJcdns71_2OxARqC7p7wQSkGQ",
        "plus_code": {
          "compound_code": "J9C6+9F Lagos, Nigeria",
          "global_code": "6FR5J9C6+9F"
        },
        "rating": 4.4,
        "reference": "ChIJcdns71_2OxARqC7p7wQSkGQ",
        "types": [
          "furniture_store",
          "home_goods_store",
          "point_of_interest",
          "store",
          "establishment"
        ],
        "user_ratings_total": 28
      },
      {
        "business_status": "OPERATIONAL",
        "formatted_address":
            "Simbiat Abiola way, Ikeja Ikeja, 100212, Lagos, Nigeria",
        "geometry": {
          "location": {"lat": 6.592124399999999, "lng": 3.3382064},
          "viewport": {
            "northeast": {"lat": 6.593473679892722, "lng": 3.339554629892722},
            "southwest": {"lat": 6.590774020107278, "lng": 3.336854970107277}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/shopping-71.png",
        "icon_background_color": "#4B96F3",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/shopping_pinlet",
        "name": "Yves Rocher Mall, Ikeja",
        "opening_hours": {"open_now": true},
        "photos": [
          {
            "height": 4032,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/104471955450879671282\">Adodo Oluwafemi</a>"
            ],
            "photo_reference":
                "Aap_uEAYQgtpP6CSZ-9BBiblH5f4P6cnyyNuI0xmMWWAYL1uINyC_3UB6CCq20TbEdU3UCC6qBrmi8EloZOEaJOaDh2o5ELEWQBtB7qzpnIpajTdH_Eu4eGc3nIH_RnI5FTF4dxTMTwpPzy3IYIfxlD8cRp7hTXIygedfD9oflDSYOxZ2Y6X",
            "width": 1960
          }
        ],
        "place_id": "ChIJCwWGZXmROxARbR9-zglsoWQ",
        "plus_code": {
          "compound_code": "H8RQ+R7 Lagos, Nigeria",
          "global_code": "6FR5H8RQ+R7"
        },
        "rating": 5,
        "reference": "ChIJCwWGZXmROxARbR9-zglsoWQ",
        "types": ["point_of_interest", "store", "establishment"],
        "user_ratings_total": 1
      },
      {
        "business_status": "OPERATIONAL",
        "formatted_address":
            "Ikeja City Mall, Alausa, Obafemi Awolowo Way, Oregun, Ikeja, Nigeria",
        "geometry": {
          "location": {"lat": 6.6137466, "lng": 3.3576798},
          "viewport": {
            "northeast": {"lat": 6.614939879892722, "lng": 3.358845929892722},
            "southwest": {"lat": 6.612240220107278, "lng": 3.356146270107278}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/shopping-71.png",
        "icon_background_color": "#4B96F3",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/shopping_pinlet",
        "name": "PEP Lagos Ikeja City Mall",
        "opening_hours": {"open_now": true},
        "photos": [
          {
            "height": 720,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/116982467480040305658\">A Google User</a>"
            ],
            "photo_reference":
                "Aap_uEDYS7l_nsY8eguKYlfzC3Bp8yu6PKdPcwlqk72xA71OC8OxcPt-egukkFAvIiDj0QWtW-2Erzc_dfakGzKRQgtgXLHLSM82ZN6tzmYU2R8uV1cRV1LGl49Jc1VJUeLkV-B0gQ4lbE1ZQ2ctgz4UreeBwaMT5yyNeaTfmv0xC6M5HIOC",
            "width": 1280
          }
        ],
        "place_id": "ChIJ6URuQMqTOxARS6xXGFk2A3I",
        "plus_code": {
          "compound_code": "J975+F3 Ikeja, Nigeria",
          "global_code": "6FR5J975+F3"
        },
        "rating": 4.4,
        "reference": "ChIJ6URuQMqTOxARS6xXGFk2A3I",
        "types": [
          "clothing_store",
          "point_of_interest",
          "store",
          "establishment"
        ],
        "user_ratings_total": 11
      },
      {
        "business_status": "OPERATIONAL",
        "formatted_address":
            "Shop 7, Toscanini Plaza, opposite Cornerest Hotel Oriyomi street, Off Toyin Ikeja, Lagos State, India",
        "geometry": {
          "location": {"lat": 25.8931748, "lng": 76.18162570000001},
          "viewport": {
            "northeast": {"lat": 25.89452462989272, "lng": 76.18297552989273},
            "southwest": {"lat": 25.89182497010728, "lng": 76.18027587010728}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/shopping-71.png",
        "icon_background_color": "#4B96F3",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/shopping_pinlet",
        "name": "Micky Skincare Cosmetic Store",
        "opening_hours": {"open_now": false},
        "place_id": "ChIJG8i9K7UxbjkRkwaPLFHmLLo",
        "plus_code": {
          "compound_code": "V5VJ+7M Shop, Rajasthan",
          "global_code": "7JQRV5VJ+7M"
        },
        "rating": 0,
        "reference": "ChIJG8i9K7UxbjkRkwaPLFHmLLo",
        "types": ["shopping_mall", "point_of_interest", "establishment"],
        "user_ratings_total": 0
      },
      {
        "business_status": "OPERATIONAL",
        "formatted_address": "H9G8+M44, Maryland 101233, Lagos, Nigeria",
        "geometry": {
          "location": {"lat": 6.5766426, "lng": 3.3653415},
          "viewport": {
            "northeast": {"lat": 6.578023579892721, "lng": 3.366724879892723},
            "southwest": {"lat": 6.575323920107278, "lng": 3.364025220107278}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/shopping-71.png",
        "icon_background_color": "#4B96F3",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/shoppingcart_pinlet",
        "name": "Maryland mall,Ikeja.",
        "opening_hours": {"open_now": true},
        "place_id": "ChIJu20T9-eTOxARjRUyvKP5MGQ",
        "rating": 5,
        "reference": "ChIJu20T9-eTOxARjRUyvKP5MGQ",
        "types": [
          "grocery_or_supermarket",
          "food",
          "point_of_interest",
          "store",
          "establishment"
        ],
        "user_ratings_total": 1
      },
      {
        "business_status": "OPERATIONAL",
        "formatted_address":
            "Phase 1, Computer Village, Francis Oremeji St, Ikeja, Nigeria",
        "geometry": {
          "location": {"lat": 6.593545, "lng": 3.3407327},
          "viewport": {
            "northeast": {"lat": 6.595063479892722, "lng": 3.342052229892722},
            "southwest": {"lat": 6.592363820107278, "lng": 3.339352570107277}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/shopping-71.png",
        "icon_background_color": "#4B96F3",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/shopping_pinlet",
        "name": "Powa Shopping Complex Ikeja",
        "opening_hours": {"open_now": true},
        "photos": [
          {
            "height": 1920,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/108343903407683651870\">Nkenna Aneke</a>"
            ],
            "photo_reference":
                "Aap_uEAY43OAg_7plGPRugLCtnD91PFSmzeu_Nb6ofN-Ao5uEUDZXxDWJ-gZXGgeX_2v3IqcBiq4dTw8SeOvE-JyM8QkLCYC3vLF82f0Bv2pAU0ayhebRUoY1-bgthMab5t9yfJDFyrgGkTGUl8C2P931ByLtFYAktstd2dEZ1l1t-jUWw2P",
            "width": 2560
          }
        ],
        "place_id": "ChIJ7V4gRyeSOxARUTeU3tJo5W8",
        "plus_code": {
          "compound_code": "H8VR+C7 Ikeja, Nigeria",
          "global_code": "6FR5H8VR+C7"
        },
        "rating": 3.8,
        "reference": "ChIJ7V4gRyeSOxARUTeU3tJo5W8",
        "types": ["shopping_mall", "point_of_interest", "establishment"],
        "user_ratings_total": 486
      },
      {
        "business_status": "OPERATIONAL",
        "formatted_address": "H8VW+627, Ikeja GRA 101233, Ikeja, Nigeria",
        "geometry": {
          "location": {"lat": 6.593045099999999, "lng": 3.3450352},
          "viewport": {
            "northeast": {"lat": 6.594372229892723, "lng": 3.346371679892723},
            "southwest": {"lat": 6.591672570107279, "lng": 3.343672020107278}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/shopping-71.png",
        "icon_background_color": "#4B96F3",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/shopping_pinlet",
        "name": "Ikeja Plaza",
        "place_id": "ChIJw3bcjs2TOxARM7q5pwnKPzw",
        "rating": 5,
        "reference": "ChIJw3bcjs2TOxARM7q5pwnKPzw",
        "types": ["shopping_mall", "point_of_interest", "establishment"],
        "user_ratings_total": 2
      },
      {
        "business_status": "OPERATIONAL",
        "formatted_address": "12 Old Medical Rd, Oregun 101233, Ikeja, Nigeria",
        "geometry": {
          "location": {"lat": 6.613737599999999, "lng": 3.3581864},
          "viewport": {
            "northeast": {"lat": 6.615437329892722, "lng": 3.359257079892722},
            "southwest": {"lat": 6.612737670107278, "lng": 3.356557420107278}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/shopping-71.png",
        "icon_background_color": "#4B96F3",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/shopping_pinlet",
        "name": "Mtn Centre Ikeja City Mall",
        "opening_hours": {"open_now": true},
        "photos": [
          {
            "height": 4864,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/100451381589327162063\">Monisola Adejo</a>"
            ],
            "photo_reference":
                "Aap_uEBrDUlgSac7vk0XpEldlBUcCakYbF1IhvAvOVtUsmOzvk0h4fLG82LVNHlzhkdZLxKs0FV-1xJ2MOPePnZvb5DXXTEyswBm38vgei9oi1CQ0eINaa8wWaVXT8LO_m9WU9bbxamlS_-vXvk80X15qYwjMSJt3yVoucXMTC4_bsQ8_fuY",
            "width": 2736
          }
        ],
        "place_id": "ChIJ1RrHbMqTOxARD8-fY2VuQy0",
        "plus_code": {
          "compound_code": "J975+F7 Ikeja, Nigeria",
          "global_code": "6FR5J975+F7"
        },
        "rating": 3.7,
        "reference": "ChIJ1RrHbMqTOxARD8-fY2VuQy0",
        "types": [
          "electronics_store",
          "point_of_interest",
          "store",
          "establishment"
        ],
        "user_ratings_total": 23
      },
      {
        "business_status": "OPERATIONAL",
        "formatted_address":
            "9 Obafemi Awolowo Way, Oregun 101233, Ikeja, Nigeria",
        "geometry": {
          "location": {"lat": 6.614338399999999, "lng": 3.3578021},
          "viewport": {
            "northeast": {"lat": 6.615762729892722, "lng": 3.359097279892722},
            "southwest": {"lat": 6.613063070107279, "lng": 3.356397620107277}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/restaurant-71.png",
        "icon_background_color": "#FF9E67",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/restaurant_pinlet",
        "name": "Ocean Basket - Ikeja City Mall",
        "opening_hours": {"open_now": true},
        "photos": [
          {
            "height": 3024,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/116984051580048762221\">Oluwatimilehin Makinde</a>"
            ],
            "photo_reference":
                "Aap_uECrqCPdSoKwL2Y-BK-UuPgvGkjeSqn0pGzkESyC-jY_UwmlyXlHmhhw8ALscIxEnsRVRwTzJZgL_CZrGVU2mNCr0GqIeoP13j2NTiUg5Bk_UvgJ3GWelPmmKspKGsXbufmp8BLKY9S5DChbMmI_1lUkUyvr6avbbozwdjm6_QkgN3SJ",
            "width": 4032
          }
        ],
        "place_id": "ChIJMfvZF8qTOxARVNCi2ObEcpg",
        "plus_code": {
          "compound_code": "J975+P4 Ikeja, Nigeria",
          "global_code": "6FR5J975+P4"
        },
        "rating": 4.4,
        "reference": "ChIJMfvZF8qTOxARVNCi2ObEcpg",
        "types": ["restaurant", "food", "point_of_interest", "establishment"],
        "user_ratings_total": 355
      },
      {
        "business_status": "OPERATIONAL",
        "formatted_address":
            "53 Isaac John St, Ikeja GRA 101233, Ikeja, Nigeria",
        "geometry": {
          "location": {"lat": 6.585820999999999, "lng": 3.3562743},
          "viewport": {
            "northeast": {"lat": 6.586570099999999, "lng": 3.357995929892722},
            "southwest": {"lat": 6.583573700000001, "lng": 3.355296270107277}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/shopping-71.png",
        "icon_background_color": "#4B96F3",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/shopping_pinlet",
        "name": "Adebola Shopping Mall",
        "opening_hours": {"open_now": true},
        "photos": [
          {
            "height": 1456,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/101800762095337102788\">Seyi Abdullahi</a>"
            ],
            "photo_reference":
                "Aap_uEBiGOnRFDWyrirh01KJUyq4ZBYz1XSYwStIz3IjFMTD59gkk6tqQdkGmISCV6koByErVsWfpbqZPPK1NwfcBgHajPtQ8iU8DEiFVagbVcHkeTiX65oOBrJr_hj2PWU4wEDoXFEognhAypXFEV5RChW4YyDVeDC_oavn4z6pVlX3UupO",
            "width": 2592
          }
        ],
        "place_id": "ChIJQXFKABWSOxAR6ErxG4wAvaA",
        "plus_code": {
          "compound_code": "H9P4+8G Ikeja, Nigeria",
          "global_code": "6FR5H9P4+8G"
        },
        "rating": 4,
        "reference": "ChIJQXFKABWSOxAR6ErxG4wAvaA",
        "types": ["shopping_mall", "point_of_interest", "establishment"],
        "user_ratings_total": 500
      }
    ];

    fakeJson.forEach((element) {
      places.add(PlaceModal.fromJson(element));
    });

    return places;
  }
}
