import 'dart:math';

import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'models/CityData.dart';
import 'models/PartialPropertyItem.dart';
import 'models/PropertyItem.dart';

// ignore: must_be_immutable
class PropertyTileWithHeart extends StatefulWidget {
  String? imageUrl;
  PropertyTileWithHeart({super.key, this.imageUrl});

  @override
  _PropertyTileWithHeartState createState() => _PropertyTileWithHeartState();
}

class _PropertyTileWithHeartState extends State<PropertyTileWithHeart> {
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
        CustomBoxShadow(
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
                              final int index = hotelImgList.indexOf(url);
                              return Container(
                                width: 5.0,
                                height: 5.0,
                                margin: const EdgeInsets.symmetric(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
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
                          const SizedBox(
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
                                  const SizedBox(
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

class PropertyImagesTile extends StatefulWidget {
  final PropertyItem? property;

  const PropertyImagesTile({this.property});

  @override
  _PropertyImagesTileState createState() => _PropertyImagesTileState();
}

class _PropertyImagesTileState extends State<PropertyImagesTile> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
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
                        items: widget.property!.images!
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
                                      .pushNamed("/property-detail");
                                },
                              ),
                            )
                            .toList(),
                      ),
                      Positioned(
                        bottom: 0,
                        left: MediaQuery.of(context).size.width / 2 -
                            ((5 * widget.property!.images!.length) + 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: widget.property!.images!.map((url) {
                            final int index =
                                widget.property!.images!.indexOf(url);
                            return Container(
                              width: 5.0,
                              height: 5.0,
                              margin: const EdgeInsets.symmetric(
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.property!.name!,
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
                                      widget.property!.price!,
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
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.property!.address1! +
                                  ", " +
                                  widget.property!.address2!,
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
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  widget.property!.rating!,
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

class RentPropertyTile extends StatefulWidget {
  final PropertyItem? property;

  const RentPropertyTile({this.property});

  @override
  _RentPropertyTileState createState() => _RentPropertyTileState();
}

class _RentPropertyTileState extends State<RentPropertyTile> {
  int _current = 0;
  late bool isAvailable;
  bool isChange = false;

  @override
  Widget build(BuildContext context) {
    isAvailable = Random().nextBool();
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed("/property-detail");
      },
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 40,
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
                              items: widget.property!.images!
                                  .map(
                                    (e) => CachedNetworkImage(
                                      width: double.infinity,
                                      imageUrl: e,
                                      fit: BoxFit.fill,
                                      filterQuality: FilterQuality.high,
                                    ),
                                  )
                                  .toList(),
                            ),
                            Positioned(
                              bottom: 0,
                              left: MediaQuery.of(context).size.width / 2 -
                                  ((5 * widget.property!.images!.length) + 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: widget.property!.images!.map((url) {
                                  final int index =
                                      widget.property!.images!.indexOf(url);
                                  return Container(
                                    width: 5.0,
                                    height: 5.0,
                                    margin: const EdgeInsets.symmetric(
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
                            ),
                            Positioned(
                              left: 16,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: LinearGradient(
                                      colors: [
                                        navyBlue,
                                        navyBlue,
                                      ],
                                    )),
                                child: Text(
                                  isAvailable ? "Just added" : "Featured",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "₦",
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20,
                                            color: navyBlue,
                                            fontFamily: "Roborto"),
                                      ),
                                      Text(
                                        widget.property!.price!,
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 22,
                                          color: navyBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 30,
                                    width: 30,
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            "https://d2qp0siotla746.cloudfront.net/img/use-cases/profile-picture/template_3.jpg",
                                        fit: BoxFit.fill,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                widget.property!.name!,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: blackFont,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.property!.address1! +
                                        ", " +
                                        widget.property!.address2!,
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
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        widget.property!.rating!,
                                        style: TextStyle(
                                            fontSize: 14, color: blackFont),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Divider(
                                color: dividerColor,
                                height: 0,
                                thickness: 1,
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RoundedBackgroundIcon(
                                        backgroundColor: lightGrey,
                                        borderRadius: 12,
                                        height: 32,
                                        width: 32,
                                        icon: Icon(
                                          SlydoAppIcon.couch,
                                          size: 14,
                                          color: blackFont,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        "2",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: blackFont),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RoundedBackgroundIcon(
                                        backgroundColor: lightGrey,
                                        borderRadius: 12,
                                        height: 32,
                                        width: 32,
                                        icon: Icon(
                                          SlydoAppIcon.bedroom,
                                          size: 14,
                                          color: blackFont,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        "3",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: blackFont),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RoundedBackgroundIcon(
                                        backgroundColor: lightGrey,
                                        borderRadius: 12,
                                        height: 32,
                                        width: 32,
                                        icon: Icon(
                                          SlydoAppIcon.bathroom,
                                          size: 14,
                                          color: blackFont,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        "2",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: blackFont),
                                      )
                                    ],
                                  ),
                                  // Row(
                                  //   mainAxisSize: MainAxisSize.min,
                                  //   children: [
                                  //     RoundedBackgroundIcon(
                                  //       backgroundColor: lightGrey,
                                  //       borderRadius: 12,
                                  //       height: 32,
                                  //       width: 32,
                                  //       icon: Icon(
                                  //         SlydoAppIcon.free_wifi,
                                  //         size: 14,
                                  //         color: blackFont,
                                  //       ),
                                  //     ),
                                  //     SizedBox(
                                  //       width: 8,
                                  //     ),
                                  //     Text(
                                  //       "Free wifi",
                                  //       style: TextStyle(
                                  //           fontSize: 14,
                                  //           fontWeight: FontWeight.w400,
                                  //           color: blackFont),
                                  //     )
                                  //   ],
                                  // ),

                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RoundedBackgroundIcon(
                                        backgroundColor: lightGrey,
                                        borderRadius: 12,
                                        height: 32,
                                        width: 32,
                                        icon: Icon(
                                          SlydoAppIcon.toilet,
                                          size: 14,
                                          color: blackFont,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        "3",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: blackFont),
                                      )
                                    ],
                                  ),
                                  // Row(
                                  //   mainAxisSize: MainAxisSize.min,
                                  //   children: [
                                  //     RoundedBackgroundIcon(
                                  //       backgroundColor: lightGrey,
                                  //       borderRadius: 12,
                                  //       height: 32,
                                  //       width: 32,
                                  //       icon: Icon(
                                  //         SlydoAppIcon.kitchen,
                                  //         size: 14,
                                  //         color: blackFont,
                                  //       ),
                                  //     ),
                                  //     SizedBox(
                                  //       width: 8,
                                  //     ),
                                  //     Text(
                                  //       "Kitchen",
                                  //       style: TextStyle(
                                  //           fontSize: 14,
                                  //           fontWeight: FontWeight.w400,
                                  //           color: blackFont),
                                  //     )
                                  //   ],
                                  // ),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Divider(
                                color: dividerColor,
                                height: 0,
                                thickness: 1,
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RoundedBackgroundIcon(
                                    backgroundColor: lightGrey,
                                    borderRadius: 12,
                                    height: 32,
                                    width: 32,
                                    icon: Icon(
                                      SlydoAppIcon.date,
                                      size: 14,
                                      color: blackFont,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    isAvailable
                                        ? "Available immediately"
                                        : "Available from 28th Dec 2020",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: blackFont),
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
      ),
    );
  }
}

class RentPropertyTileWithoutHeart extends StatefulWidget {
  final PropertyItem? property;

  const RentPropertyTileWithoutHeart({this.property});

  @override
  _RentPropertyTileWithoutHeartState createState() =>
      _RentPropertyTileWithoutHeartState();
}

class _RentPropertyTileWithoutHeartState
    extends State<RentPropertyTileWithoutHeart> {
  int _current = 0;
  late bool isAvailable;
  bool isChange = false;

  @override
  Widget build(BuildContext context) {
    isAvailable = Random().nextBool();
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed("/property-detail");
      },
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 40,
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
                              items: widget.property!.images!
                                  .map(
                                    (e) => CachedNetworkImage(
                                      width: double.infinity,
                                      imageUrl: e,
                                      fit: BoxFit.fill,
                                      filterQuality: FilterQuality.high,
                                    ),
                                  )
                                  .toList(),
                            ),
                            Positioned(
                              bottom: 0,
                              left: MediaQuery.of(context).size.width / 2 -
                                  ((5 * widget.property!.images!.length) + 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: widget.property!.images!.map((url) {
                                  final int index =
                                      widget.property!.images!.indexOf(url);
                                  return Container(
                                    width: 5.0,
                                    height: 5.0,
                                    margin: const EdgeInsets.symmetric(
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
                            ),
                            Positioned(
                              left: 16,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: LinearGradient(
                                      colors: [
                                        navyBlue,
                                        navyBlue,
                                      ],
                                    )),
                                child: Text(
                                  isAvailable ? "Just added" : "Featured",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "₦",
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20,
                                            color: navyBlue,
                                            fontFamily: "Roborto"),
                                      ),
                                      Text(
                                        widget.property!.price!,
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 22,
                                          color: navyBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 30,
                                    width: 30,
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            "https://d2qp0siotla746.cloudfront.net/img/use-cases/profile-picture/template_3.jpg",
                                        fit: BoxFit.fill,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                widget.property!.name!,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: blackFont,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.property!.address1! +
                                        ", " +
                                        widget.property!.address2!,
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
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        widget.property!.rating!,
                                        style: TextStyle(
                                            fontSize: 14, color: blackFont),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Divider(
                                color: dividerColor,
                                height: 0,
                                thickness: 1,
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RoundedBackgroundIcon(
                                        backgroundColor: lightGrey,
                                        borderRadius: 12,
                                        height: 32,
                                        width: 32,
                                        icon: Icon(
                                          SlydoAppIcon.couch,
                                          size: 14,
                                          color: blackFont,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        "2",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: blackFont),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RoundedBackgroundIcon(
                                        backgroundColor: lightGrey,
                                        borderRadius: 12,
                                        height: 32,
                                        width: 32,
                                        icon: Icon(
                                          SlydoAppIcon.bedroom,
                                          size: 14,
                                          color: blackFont,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        "3",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: blackFont),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RoundedBackgroundIcon(
                                        backgroundColor: lightGrey,
                                        borderRadius: 12,
                                        height: 32,
                                        width: 32,
                                        icon: Icon(
                                          SlydoAppIcon.bathroom,
                                          size: 14,
                                          color: blackFont,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        "2",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: blackFont),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RoundedBackgroundIcon(
                                        backgroundColor: lightGrey,
                                        borderRadius: 12,
                                        height: 32,
                                        width: 32,
                                        icon: Icon(
                                          SlydoAppIcon.toilet,
                                          size: 14,
                                          color: blackFont,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        "3",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: blackFont),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Divider(
                                color: dividerColor,
                                height: 0,
                                thickness: 1,
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RoundedBackgroundIcon(
                                    backgroundColor: lightGrey,
                                    borderRadius: 12,
                                    height: 32,
                                    width: 32,
                                    icon: Icon(
                                      SlydoAppIcon.date,
                                      size: 14,
                                      color: blackFont,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    isAvailable
                                        ? "Available immediately"
                                        : "Available from 28th Dec 2020",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: blackFont),
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
            right: 8,
            top: 8,
            child: RoundedBackgroundIcon(
                height: 28,
                width: 28,
                backgroundColor: Colors.white,
                icon: Icon(
                  SlydoAppIcon.edit,
                  color: blackFont,
                  size: 12,
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/edit-property',
                  );
                }),
          )
        ],
      ),
    );
  }
}

class PartialPropertyItemTile extends StatelessWidget {
  final PartialPropertyItem? property;

  const PartialPropertyItemTile({this.property});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/property-detail");
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          width: 160,
          decoration: decorateBox(borderColor: selectedListItemBackgroundBlue),
          child: Container(
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: property!.image!,
                    height: 130,
                    width: 130,
                    fit: BoxFit.fill,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                "From ",
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: blackFont,
                                ),
                              ),
                              Text(
                                "₦",
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: blackFont,
                                    fontFamily: "Roborto"),
                              ),
                              Text(
                                property!.price!,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: blackFont,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      property!.shortDescription!,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: blackFont,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CityItemCard extends StatelessWidget {
  final CityData? city;

  const CityItemCard({super.key, this.city});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/property-detail");
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          width: 160,
          decoration: decorateBox(borderColor: selectedListItemBackgroundBlue),
          child: Container(
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  city!.name!,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: blackFont,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: city!.image!,
                    height: 130,
                    width: 130,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl:
                            "https://d2qp0siotla746.cloudfront.net/img/use-cases/profile-picture/template_3.jpg",
                        fit: BoxFit.fill,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    "Jamé Smith",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: blackFont),
                  )
                ],
              ),
              Text(
                "20 Aug",
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w400, color: darkGrey),
              )
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              Icon(
                SlydoAppIcon.star,
                color: starYellow,
                size: 11,
              ),
              const SizedBox(
                width: 4,
              ),
              Icon(
                SlydoAppIcon.star,
                color: starYellow,
                size: 11,
              ),
              const SizedBox(
                width: 4,
              ),
              Icon(
                SlydoAppIcon.star,
                color: starYellow,
                size: 11,
              ),
              const SizedBox(
                width: 4,
              ),
              Icon(
                SlydoAppIcon.star,
                color: starYellow,
                size: 11,
              ),
              const SizedBox(
                width: 4,
              ),
              Icon(
                SlydoAppIcon.star,
                color: greyBorderColor,
                size: 11,
              ),
              const SizedBox(
                width: 4,
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            "Very knowledgeable about all the history, really friendly, always smile, and always up for a chat.",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w400, color: blackFont),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(
            height: 8,
          ),
          Divider(
            thickness: 1,
            height: 4,
            color: dividerColor,
          ),
        ],
      ),
    );
  }
}

class PartnerTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl:
                    "https://d2qp0siotla746.cloudfront.net/img/use-cases/profile-picture/template_3.jpg",
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Bond street dojo",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: blackFont),
                ),
                const SizedBox(
                  width: 8,
                ),
                Row(
                  children: [
                    Icon(
                      SlydoAppIcon.star,
                      color: starYellow,
                      size: 11,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      "7.8 • Renter Friendly",
                      style: TextStyle(
                          fontSize: 12,
                          color: blackFont,
                          fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Column(
            children: <Widget>[
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: navyBlue,
                size: 16,
              )
            ],
          ),
        ],
      ),
    );
  }
}
