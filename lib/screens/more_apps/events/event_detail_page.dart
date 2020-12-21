import 'package:Slydo/screens/more_apps/events/event_auth.dart';
import 'package:Slydo/screens/more_apps/events/event_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/events/event_tile.dart';
import 'package:Slydo/screens/more_apps/events/models/EventDetailItem.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventDetailPage extends StatefulWidget {
  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  EventDashboardBloc _eventDashboardBloc;

  List<String> availableDates = ["18", "25", "01", "08", "15"];
  int selectedDate = 0;

  bool isWishList = false;

  EventDetailItem event = EventDetailItem();
  bool isLoading = false;
  bool isVideo = false;

  @override
  void initState() {
    getResult();
    super.initState();
  }

  void getResult() async {
    isLoading = true;
    if (mounted) setState(() {});

    event = await EventAuthService().getEventDetailItem();

    isLoading = false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _eventDashboardBloc = Provider.of<EventDashboardBloc>(context);
    return WillPopScope(
      onWillPop: () {
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar(),
        body: scaffoldBody(),
        floatingActionButton: floatingActionBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        shareBtn(),
        SizedBox(
          width: 8,
        ),
        addToCartBtn(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget shareBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.share,
        size: 16,
        color: blackFont,
      ),
      onTap: () {},
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget addToCartBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.cart,
        size: 16,
        color: blackFont,
      ),
      onTap: () {},
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget scaffoldBody() {
    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                eventPoster(),
                Column(
                  children: [
                    SizedBox(
                      height: 24,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: eventNameAndHostInformation(),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed("/event-ticket-detail");
                        },
                        child: Image.asset("assets/images/TICKET.png")),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Divider(
                            thickness: 1,
                            height: 0,
                            color: dividerColor,
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          eventTimeAndPlaceDetail(),
                          SizedBox(
                            height: 16,
                          ),
                          Divider(
                            thickness: 1,
                            color: dividerColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                dateAndTime(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Divider(
                        thickness: 1,
                        color: dividerColor,
                        height: 16,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      aboutEvent(),
                      SizedBox(
                        height: 12,
                      ),
                      Divider(
                        thickness: 1,
                        color: dividerColor,
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      eventLocation(),
                      SizedBox(
                        height: 40,
                      ),
                      moreLikeThis(),
                      SizedBox(
                        height: 80,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget eventPoster() {
    return Container(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            CachedNetworkImage(
              width: double.infinity,
              height: double.infinity,
              imageUrl: event.image,
              fit: BoxFit.fill,
            ),
            Positioned(
              right: 12,
              top: 12,
              child: InkWell(
                child: Icon(
                  isWishList ? SlydoAppIcon.heart_1 : SlydoAppIcon.heart_empty,
                  color: Colors.white,
                  size: 22,
                ),
                onTap: () {
                  isWishList = !isWishList;
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget eventNameAndHostInformation() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                event.name,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: blackFont),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 12,
        ),
        Row(
          children: [
            Container(
              height: 32,
              width: 32,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: event.ownerAvatar,
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Text(
              event.ownerName,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: blackFont),
            )
          ],
        )
      ],
    );
  }

  Widget eventTimeAndPlaceDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Information",
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: blackFont),
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            RoundedBackgroundIcon(
                              backgroundColor: lightGrey,
                              height: 32,
                              width: 32,
                              borderRadius: 12,
                              icon: Icon(
                                SlydoAppIcon.date,
                                size: 14,
                                color: blackFont,
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Text(
                                event.eventTime,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: blackFont),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            RoundedBackgroundIcon(
                              backgroundColor: lightGrey,
                              height: 32,
                              borderRadius: 12,
                              width: 32,
                              icon: Icon(
                                SlydoAppIcon.location,
                                size: 14,
                                color: blackFont,
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Text(
                                event.location.first.name,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: blackFont),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            RoundedBackgroundIcon(
                              backgroundColor: lightGrey,
                              borderRadius: 12,
                              height: 32,
                              width: 32,
                              icon: Icon(
                                SlydoAppIcon.price_tag,
                                size: 14,
                                color: blackFont,
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Row(
                              children: [
                                Icon(
                                  SlydoAppIcon.naira,
                                  color: navyBlue,
                                  size: 10,
                                ),
                                Text(
                                  event.price,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: navyBlue),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
            RoundedBackgroundIcon(
              backgroundColor: navyBlue.withOpacity(0.1),
              borderRadius: 12,
              height: 32,
              width: 32,
              icon: Icon(
                SlydoAppIcon.location_circle,
                size: 14,
                color: navyBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget dateAndTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            "Date & time",
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: blackFont),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: List.generate(availableDates.length, (index) {
                return Container(
                    padding: EdgeInsets.only(left: 16),
                    child: dateAndTimeTile(
                        availableDates[index], selectedDate == index, index));
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget dateAndTimeTile(String date, bool isSelected, index) {
    return InkWell(
      onTap: () {
        selectedDate = index;
        setState(() {});
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: boxShadowTwo,
              offset: Offset(0.0, 0.0),
              blurRadius: 20.0,
            ),
          ],
          color: isSelected ? navyBlue : Colors.white,
          borderRadius: BorderRadius.all(
            const Radius.circular(10.0),
          ),
          border: new Border.all(
              color: isSelected ? navyBlue : lightGrey,
              width: 1.0,
              style: BorderStyle.solid),
        ),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Column(
          children: [
            Text(
              "Oct $date",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : blackFont),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              "Sun • 6:54 PM",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isSelected ? Colors.white : darkGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget aboutEvent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About",
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: blackFont),
        ),
        SizedBox(
          height: 12,
        ),
        Text(
          event.about,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: darkGrey,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget eventLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Location",
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: blackFont),
            ),
            Text(
              "Direction",
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w400, color: navyBlue),
            ),
          ],
        ),
        SizedBox(
          height: 12,
        ),
        Container(
          height: 180,
          width: 335,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: CachedNetworkImage(
            imageUrl:
                "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/e97dfc8dfdfa529c0da2248948fff5caba872d65/location.png",
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }

  Widget moreLikeThis() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "More like this",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: blackFont,
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Column(
            children: event.similarEvent
                .map((element) => Container(
                      margin: EdgeInsets.only(bottom: 12),
                      child: EventTileWithHeart(partialEvent: element),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget floatingActionBar() {
    return Card(
      elevation: 50,
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
        child: Row(
          children: <Widget>[
            addToCartWidget(),
            SizedBox(
              width: 8,
            ),
            _buildBuyButtonWidget(),
          ],
        ),
      ),
    );
  }

  Widget addToCartWidget() {
    return RoundedBackgroundIcon(
      borderRadius: 16,
      height: 44,
      width: 44,
      icon: Icon(
        SlydoAppIcon.add_cart,
        color: navyBlue,
        size: 22,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () async {
        Navigator.of(context).pushNamed("/mix-cart-item");
      },
    );
  }

  Widget _buildBuyButtonWidget() {
    return Expanded(
      child: CurvedButton(
        backgroundColor: navyBlue,
        textColor: Colors.white,
        text: "BUY NOW",
        onPressed: () {
          Navigator.of(context).pushNamed(
            '/send-payment',
            arguments: {
              'isFromProfile': false,
            },
          );
        },
      ),
    );
  }
}
