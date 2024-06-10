import 'package:Slydo/screens/more_apps/hotels/models/PartialHotelRoomItem.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'models/CityData.dart';
import 'models/HotelRoomItem.dart';

// ignore: must_be_immutable
class HotelTile extends StatelessWidget {
  String? imageUrl;
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
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.fill,
                    height: 86,
                    width: 68,
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: SizedBox(
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
  final HotelRoomItem? hotelRoom;

  const HotelTileWithHeart({super.key, this.hotelRoom});
  @override
  _HotelTileWithHeartState createState() => _HotelTileWithHeartState();
}

class _HotelTileWithHeartState extends State<HotelTileWithHeart> {
  int _current = 0;

  bool isChange = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
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
                            items: widget.hotelRoom!.images!
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
                                ((5 * widget.hotelRoom!.images!.length) + 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: widget.hotelRoom!.images!.map((url) {
                                final int index =
                                    widget.hotelRoom!.images!.indexOf(url);
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
                                  widget.hotelRoom!.name!,
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
                                          widget.hotelRoom!.price!,
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
                                  "${widget.hotelRoom!.address1}, ${widget.hotelRoom!.address2}",
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
                                      widget.hotelRoom!.rating!,
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
  final HotelRoomItem? hotelRoom;

  const HotelRoomImagesTile({super.key, this.hotelRoom});
  @override
  _HotelRoomImagesTileState createState() => _HotelRoomImagesTileState();
}

class _HotelRoomImagesTileState extends State<HotelRoomImagesTile> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                        items: widget.hotelRoom!.images!
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
                            ((5 * widget.hotelRoom!.images!.length) + 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: widget.hotelRoom!.images!.map((url) {
                            final int index =
                                widget.hotelRoom!.images!.indexOf(url);
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
                              widget.hotelRoom!.name!,
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
                                      widget.hotelRoom!.price!,
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
                              "${widget.hotelRoom!.address1}, ${widget.hotelRoom!.address2}",
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
                                  widget.hotelRoom!.rating!,
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

class PartialHotelRoomItemTile extends StatelessWidget {
  final PartialHotelRoomItem? hotelRoom;

  PartialHotelRoomItemTile({this.hotelRoom});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/hotel-detail");
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          width: 180,
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
                    imageUrl: hotelRoom!.image!,
                    height: 150,
                    width: 150,
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
                                hotelRoom!.price!,
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
                        Text(
                          "/ month ",
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
                    Text(
                      hotelRoom!.shortDescription!,
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

  CityItemCard({this.city});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/hotel-detail");
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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
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
    );
  }
}

class PartnerTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
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
    );
  }
}
