import 'package:Slydo/screens/more_apps/news/CustomChip.dart';
import 'package:Slydo/screens/more_apps/news/news_tile.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class NewsDetailPage extends StatefulWidget {
  @override
  _NewsDetailPageState createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  VideoPlayerController _mainVideoController;
  VideoPlayerController _subVideoController;

  bool isVideoPlaying = false;

  List<Map<String, String>> relatedPostList = [
    {
      "title":
          "End Sars: How Nigeria's anti-police brutality protests went global",
      "image":
          "https://ichef.bbci.co.uk/news/800/cpsprodpb/14978/production/_114944348_endsarshi063751597.jpg"
    },
    {
      "title":
          "End Sars protests: Osun governor escapes 'assassination attempt'",
      "image":
          "https://ichef.bbci.co.uk/news/800/cpsprodpb/9CEF/production/_114957104_sars.jpg"
    },
    {
      "title": "End Sars: Hated Nigerian police unit's founder 'feels guilty'",
      "image":
          "https://ichef.bbci.co.uk/news/800/cpsprodpb/762D/production/_114935203_sarsfounder-1_moment.jpg"
    },
    {
      "title": "Nigerian army warns 'trouble makers' amid protests",
      "image":
          "https://ichef.bbci.co.uk/live-experience/cps/624/cpsprodpb/vivo/live/images/2020/10/15/18c0f573-6b37-43aa-bfba-6b1f3b5a9a0f.jpg"
    },
  ];

  @override
  void initState() {
    super.initState();
    _mainVideoController = VideoPlayerController.network(
      'https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/a1f539f00f21c4cb3ac1cb76269f6a36ff6922d7/y2mate.com - Nigerians protesting anti-police brutality bring Lagos to standstill_480p.mp4?raw=true',
    );

    _mainVideoController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _mainVideoController.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
    _subVideoController = VideoPlayerController.network(
      'https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/a1f539f00f21c4cb3ac1cb76269f6a36ff6922d7/y2mate.com - Nigerians protesting anti-police brutality bring Lagos to standstill_480p.mp4?raw=true',
    );

    _subVideoController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _subVideoController.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _mainVideoController.dispose();
    _subVideoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: appBar(),
      body: scaffoldBody(),
      floatingActionButton: floatingBtn(),
    );
  }

  Widget floatingBtn() {
    return FloatingActionButton(
      child: Icon(
        isVideoPlaying ? Icons.pause : Icons.play_arrow_rounded,
        size: 30,
      ),
      onPressed: () {
        if (isVideoPlaying) {
          _mainVideoController.pause();
        } else {
          _mainVideoController.play();
        }
        isVideoPlaying = !isVideoPlaying;
        setState(() {});
      },
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

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 6,
          ),
          videoPlayer(),
          SizedBox(
            height: 20,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                newsTitle(),
                SizedBox(
                  height: 20,
                ),
                bloggerDetail(),
                SizedBox(
                  height: 20,
                ),
                newsShortDescription(),
                SizedBox(
                  height: 20,
                ),
                newsSubTitle(),
                SizedBox(
                  height: 20,
                ),
                newsFullDescription(),
                SizedBox(
                  height: 20,
                ),
                subVideoPlayer(),
                SizedBox(
                  height: 20,
                ),
                newsSubTitle(),
                SizedBox(
                  height: 20,
                ),
                newsFullDescription(),
                SizedBox(
                  height: 20,
                ),
                Divider(
                  thickness: 1,
                  color: dividerColor,
                ),
                SizedBox(
                  height: 20,
                ),
                newsChips(),
                SizedBox(
                  height: 50,
                ),
                relatedPostTitle(),
                SizedBox(
                  height: 20,
                ),
                relatedPost(),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget videoPlayer() {
    return Container(
      child: AspectRatio(
        aspectRatio: 1.7,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            VideoPlayer(
              _mainVideoController,
            ),
            _mainVideoController.value.isPlaying
                ? Container()
                : Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      fit: BoxFit.fill,
                      imageUrl:
                          "https://cms.qz.com/wp-content/uploads/2018/06/RTR44FE-e1529169440642.jpg?quality=75&strip=all&w=800&h=600",
                    ),
                  ),
            _ControlsOverlay(controller: _mainVideoController),
            VideoProgressIndicator(_mainVideoController, allowScrubbing: true),
          ],
        ),
      ),
    );
  }

  Widget subVideoPlayer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        child: AspectRatio(
          aspectRatio: 2,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              VideoPlayer(
                _subVideoController,
              ),
              _subVideoController.value.isPlaying
                  ? Container()
                  : Container(
                      height: double.infinity,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl:
                            "https://cms.qz.com/wp-content/uploads/2018/06/RTR44FE-e1529169440642.jpg?quality=75&strip=all&w=800&h=600",
                      ),
                    ),
              _ControlsOverlay(controller: _subVideoController),
              VideoProgressIndicator(_subVideoController, allowScrubbing: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget newsTitle() {
    return Text(
      "End SARS: See how Nigeria anti-police brutality protests go global",
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: blackFont,
      ),
    );
  }

  Widget bloggerDetail() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        height: 32,
        width: 32,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: "https://i.imgur.com/cVDadwb.png",
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "Blogger • ",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: blackFont,
                ),
              ),
              Text(
                "June 01 ",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: darkGrey,
                ),
              ),
            ],
          ),
          CustomChip(
            text: "5 mins read",
          )
        ],
      ),
    );
  }

  Widget newsShortDescription() {
    return Text(
      "Customer Support is undergoing massive, irreversible change right now – find out how to stay ahead of the curve by adopting the Conversational Support Funnel...",
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: blackFont,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget newsSubTitle() {
    return Text(
      "Zero Transaction Fee",
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: blackFont,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget newsFullDescription() {
    return Text(
      '''With a Slydo account, you can receive and make payment across Africa. Its operation is fast, secure and seamless. Your account comes with a unique QR, which you can send to other users to receive money from them. If you want to send money instead, you can scan the QR of the recipient and make an instant transfer.

Safe and Secure Your Slydo account is very safe and secure. You have to set a 6-digit password for access to the app. You also have to set a 4-digit PIN to enable payment from your account. Your account balance is also protected with the same PIN. You have no need to worry about your data security. We encrypt your data at rest and in transit with end to end encryption for your protection''',
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: blackFont,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget newsChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        CustomChip(text: "Slydo"),
        CustomChip(text: "Business"),
        CustomChip(text: "Online store"),
        CustomChip(text: "E-commerce"),
        CustomChip(text: "Cashless"),
        CustomChip(text: "Cashless"),
      ],
    );
  }

  Widget relatedPostTitle() {
    return Text(
      "RELATED POST",
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: blackFont,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget relatedPost() {
    return Column(
        children: relatedPostList
            .map((news) => Container(
                  child: Column(
                    children: [
                      NewsTile(
                        title: news["title"],
                        image: news["image"],
                      ),
                      SizedBox(
                        height: 16,
                      )
                    ],
                  ),
                ))
            .toList());
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
        // Align(
        //   alignment: Alignment.topRight,
        //   child: PopupMenuButton<double>(
        //     initialValue: controller.value.playbackSpeed,
        //     tooltip: 'Playback speed',
        //     onSelected: (speed) {
        //       controller.setPlaybackSpeed(speed);
        //     },
        //     itemBuilder: (context) {
        //       List<PopupMenuEntry<double>> popUpMenuItemList = [];
        //       _examplePlaybackRates.forEach((speed) {
        //         popUpMenuItemList
        //             .add(PopupMenuItem(value: speed, child: Text('${speed}x')));
        //       });
        //       return popUpMenuItemList;
        //     },
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(
        //         // Using less vertical padding as the text is also longer
        //         // horizontally, so it feels like it would need more spacing
        //         // horizontally (matching the aspect ratio of the video).
        //         vertical: 12,
        //         horizontal: 16,
        //       ),
        //       child: Text('${controller.value.playbackSpeed}x'),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
