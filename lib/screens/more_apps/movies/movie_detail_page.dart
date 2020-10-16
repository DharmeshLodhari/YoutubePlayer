import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MovieDetailPage extends StatefulWidget {
  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      'https://cdn.jsdelivr.net/gh/BlackStriker99/cdnfiles/dawn-of-thunder.mp4',
    );

    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _controller.pause();
        _controller.dispose();
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
      title: Text(
        "DAWN OF THUNDER",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
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
    return Container(
      child: movieDetail(),
    );
  }

  Widget movieDetail() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            child: AspectRatio(
              aspectRatio: 1.5,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(
                    _controller,
                  ),
                  _controller.value.isPlaying
                      ? Container()
                      : Container(
                    height: double.infinity,
                          child: CachedNetworkImage(
                            fit: BoxFit.fill,
                            imageUrl:
                                "https://c1.iggcdn.com/indiegogo-media-prod-cld/image/upload/c_fill,f_auto,h_630,w_1200/v1506734779/wcsmythcukjuuglotjvb.jpg",
                          ),
                        ),
                  _ControlsOverlay(controller: _controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  height: 24,
                ),
                movieNameAndRating(),
                SizedBox(
                  height: 20,
                ),
                Divider(
                  thickness: 1,
                  color: dividerColor,
                ),
                movieReleaseDetail(),
                SizedBox(
                  height: 16,
                ),
                Divider(
                  thickness: 1,
                  color: dividerColor,
                ),
                SizedBox(
                  height: 12,
                ),
                movieStarringDetail(),
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
                movieDescriptionDetail(),
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

  Widget movieNameAndRating() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "DAWN OF THUNDER",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: blackFont),
            ),
            Row(
              children: [
                Icon(
                  SlydoAppIcon.naira,
                  color: navyBlue,
                  size: 12,
                ),
                Text(
                  "34.00",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: navyBlue),
                )
              ],
            )
          ],
        ),
        SizedBox(
          height: 12,
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
              style: TextStyle(fontSize: 14, color: blackFont),
            )
          ],
        )
      ],
    );
  }

  Widget movieReleaseDetail() {
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
              child: Row(
                children: [
                  RoundedBackgroundIcon(
                    backgroundColor: lightGrey,
                    height: 32,
                    width: 32,
                    icon: Icon(
                      SlydoAppIcon.category,
                      size: 14,
                      color: blackFont,
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    "Category",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: blackFont),
                  )
                ],
              ),
            ),
            Expanded(
              child: Text(
                "Comedy",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: blackFont),
              ),
            )
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
                    width: 32,
                    icon: Icon(
                      SlydoAppIcon.date,
                      size: 14,
                      color: blackFont,
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    "Year",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: blackFont),
                  )
                ],
              ),
            ),
            Expanded(
              child: Text(
                "2020",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: blackFont),
              ),
            )
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
                    width: 32,
                    icon: Icon(
                      Icons.timer,
                      size: 14,
                      color: blackFont,
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    "Time",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: blackFont),
                  )
                ],
              ),
            ),
            Expanded(
              child: Text(
                "1h20m",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: blackFont),
              ),
            )
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
                    width: 32,
                    icon: Icon(
                      SlydoAppIcon.eye,
                      size: 14,
                      color: blackFont,
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    "Viewer rating",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: blackFont),
                  )
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                    decoration: BoxDecoration(
                      color: HexColor("F8F9FA"),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "15+",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: blackFont),
                    ),
                  ),
                  Expanded(child: SizedBox())
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget movieStarringDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Starring",
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: blackFont),
        ),
        SizedBox(
          height: 12,
        ),
        Text(
          "Callan McAuliffe, Lorraine Nicholson, Daniel Eric Gold, Allyson Pratt ...",
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w400, color: blackFont),
        ),
      ],
    );
  }

  Widget movieDescriptionDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: blackFont),
        ),
        SizedBox(
          height: 12,
        ),
        Text(
          "Excepteur sint occaecat cupidatat non proident,sunt in culpa qui officia deserunt mollit anim id est laborum. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pa.Excepteur sint occaecat cupidatat non proident,sunt in culpa qui officia deserunt mollit anim id est laborum. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pa.",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: darkGrey,
          ),
        ),
      ],
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
      onTap: () async {},
    );
  }

  Widget _buildBuyButtonWidget() {
    return Expanded(
      child: CurvedButton(
        backgroundColor: navyBlue,
        textColor: Colors.white,
        text: "BUY NOW",
        onPressed: () {},
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key key, this.controller}) : super(key: key);

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              List popUpMenuItemList = [];
              _examplePlaybackRates.forEach((speed) {
                popUpMenuItemList
                    .add(PopupMenuItem(value: speed, child: Text('${speed}x')));
              });
              return popUpMenuItemList;
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
