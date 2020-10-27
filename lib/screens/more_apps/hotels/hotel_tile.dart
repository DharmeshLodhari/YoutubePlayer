import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class HotelTile extends StatelessWidget {
  String imageUrl;
  HotelTile({this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.fill,
                    height: 86,
                    width: 68,
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Container(
                    height: 86,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Thu, Oct 15 • 6:54 AM",
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: mateRed,
                          ),
                        ),
                        flexibleSpace(flex: 2),
                        Text(
                          "5th Borough food festival",
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: blackFont,
                          ),
                        ),
                        flexibleSpace(),
                        Text(
                          "Clove lakes park",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: blackFont,
                          ),
                        ),
                        flexibleSpace(flex: 5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

// ignore: must_be_immutable
class HotelTileWithHeart extends StatefulWidget {
  String imageUrl;
  HotelTileWithHeart({this.imageUrl});

  @override
  _HotelTileWithHeartState createState() => _HotelTileWithHeartState();
}

class _HotelTileWithHeartState extends State<HotelTileWithHeart> {
  List<String> hotelImgList = [
    "https://www.gannett-cdn.com/-mm-/05b227ad5b8ad4e9dcb53af4f31d7fbdb7fa901b/c=0-64-2119-1259/local/-/media/USATODAY/USATODAY/2014/08/13/1407953244000-177513283.jpg",
    "https://www.thebalancesmb.com/thmb/R5CjZrWUBXBTVj48-MBx3PFIh5U=/3000x2000/filters:fill(auto,1)/hotel_room-627892060-5a7a30d1642dca00370179e6.jpg",
    "https://media.istockphoto.com/photos/3d-rendering-modern-luxury-bedroom-suite-and-bathroom-picture-id928431714?k=6&m=928431714&s=612x612&w=0&h=IBnf0aE9zEmsaJ3nLep6UmK4u-KYQPdEQa6LY30Ivn4=",
    "https://gritdaily.com/wp-content/uploads/2019/07/http-cdn.cnn_.com-cnnnext-dam-assets-190711000204-haneda-excel-hotel-tokyu-03.jpg",
    "https://blisssaigon.com/wp-content/uploads/2019/10/iwood-R5v8Xtc0ecg-unsplash-1.jpg"
  ];

  int _current = 0;

  bool isChange = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: CustomBoxShadow(
            child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.zero,
                shadowColor: boxShadowTwo,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                                viewportFraction: 1.0,
                                enlargeCenterPage: true,
                                autoPlay: false,
                                aspectRatio: 2,
                                onPageChanged: (index, _) {
                                  if (mounted) {
                                    setState(() {
                                      _current = index;
                                    });
                                  }
                                }),
                            items: hotelImgList
                                .map(
                                  (image) => InkWell(
                                    child: CachedNetworkImage(
                                      width: double.infinity,
                                      imageUrl: image,
                                      fit: BoxFit.fill,
                                    ),
                                    onTap: () {
                                      Navigator.of(context)
                                          .pushNamed("/hotel-detail");
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                          Positioned(
                            bottom: 0,
                            left: MediaQuery.of(context).size.width / 2 -
                                ((5 * hotelImgList.length) + 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: hotelImgList.map((url) {
                                int index = hotelImgList.indexOf(url);
                                return Container(
                                  width: 5.0,
                                  height: 5.0,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 2.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _current == index
                                        ? Colors.white
                                        : Colors.white30,
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        ],
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "House 1 for rent",
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: blackFont,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "₦",
                                          softWrap: false,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: navyBlue,
                                              fontFamily: "Roborto"),
                                        ),
                                        Text(
                                          "34.00",
                                          softWrap: false,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: navyBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "/ month",
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: darkGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Old Ken road, London SE15",
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: darkGrey,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      SlydoAppIcon.star,
                                      color: starYellow,
                                      size: 11,
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      "7.8",
                                      style: TextStyle(
                                          fontSize: 14, color: blackFont),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )),
          ),
        ),
        Positioned(
          right: 10,
          child: IconButton(
            icon: Icon(
              isChange ? SlydoAppIcon.heart_empty : SlydoAppIcon.heart_1,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              isChange = !isChange;
              setState(() {});
            },
          ),
        )
      ],
    );
  }
}

class HotelRoomImagesTile extends StatefulWidget {
  @override
  _HotelRoomImagesTileState createState() => _HotelRoomImagesTileState();
}

class _HotelRoomImagesTileState extends State<HotelRoomImagesTile> {
  List<String> hotelImgList = [
    "https://www.gannett-cdn.com/-mm-/05b227ad5b8ad4e9dcb53af4f31d7fbdb7fa901b/c=0-64-2119-1259/local/-/media/USATODAY/USATODAY/2014/08/13/1407953244000-177513283.jpg",
    "https://www.thebalancesmb.com/thmb/R5CjZrWUBXBTVj48-MBx3PFIh5U=/3000x2000/filters:fill(auto,1)/hotel_room-627892060-5a7a30d1642dca00370179e6.jpg",
    "https://media.istockphoto.com/photos/3d-rendering-modern-luxury-bedroom-suite-and-bathroom-picture-id928431714?k=6&m=928431714&s=612x612&w=0&h=IBnf0aE9zEmsaJ3nLep6UmK4u-KYQPdEQa6LY30Ivn4=",
    "https://gritdaily.com/wp-content/uploads/2019/07/http-cdn.cnn_.com-cnnnext-dam-assets-190711000204-haneda-excel-hotel-tokyu-03.jpg",
    "https://blisssaigon.com/wp-content/uploads/2019/10/iwood-R5v8Xtc0ecg-unsplash-1.jpg"
  ];

  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomBoxShadow(
        child: Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.zero,
            shadowColor: boxShadowTwo,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(
                children: <Widget>[
                  Stack(
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                            viewportFraction: 1.0,
                            enlargeCenterPage: true,
                            autoPlay: false,
                            aspectRatio: 2,
                            onPageChanged: (index, _) {
                              if (mounted) {
                                setState(() {
                                  _current = index;
                                });
                              }
                            }),
                        items: hotelImgList
                            .map(
                              (e) => InkWell(
                                child: CachedNetworkImage(
                                  width: double.infinity,
                                  imageUrl: e,
                                  fit: BoxFit.fill,
                                  filterQuality: FilterQuality.high,
                                ),
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed("/hotel-detail");
                                },
                              ),
                            )
                            .toList(),
                      ),
                      Positioned(
                        bottom: 0,
                        left: MediaQuery.of(context).size.width / 2 -
                            ((5 * hotelImgList.length) + 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: hotelImgList.map((url) {
                            int index = hotelImgList.indexOf(url);
                            return Container(
                              width: 5.0,
                              height: 5.0,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _current == index
                                    ? Colors.white
                                    : Colors.white30,
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "House 1 for rent",
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: blackFont,
                              ),
                            ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "₦",
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: navyBlue,
                                          fontFamily: "Roborto"),
                                    ),
                                    Text(
                                      "34.00",
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: navyBlue,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "/ month",
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: darkGrey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Old Ken road, London SE15",
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: darkGrey,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  SlydoAppIcon.star,
                                  color: starYellow,
                                  size: 11,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  "7.8",
                                  style:
                                      TextStyle(fontSize: 14, color: blackFont),
                                )
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
