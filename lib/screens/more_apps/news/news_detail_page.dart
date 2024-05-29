import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/news/CustomChip.dart';
import 'package:Slydo/screens/more_apps/news/models/news_detail_item.dart';
import 'package:Slydo/screens/more_apps/news/news_tile.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/utils/video_player_controller/chewie_player.dart';
import 'package:Slydo/utils/video_player_controller/chewie_progress_colors.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:video_player/video_player.dart';

import 'news_auth.dart';

class NewsDetailPage extends StatefulWidget {
  @override
  _NewsDetailPageState createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  late VideoPlayerController _mainVideoController;
  late VideoPlayerController _subVideoController;

  late ChewieController _chewieMainController;
  late ChewieController _chewieSubController;

  bool isVideoPlaying = false;

  NewsDetailItem newsDetailItem = NewsDetailItem();
  bool isLoading = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    getResult();
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        getResult();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  void getResult() async {
    isLoading = true;
    if (mounted) {
      setState(() {});
    }

    newsDetailItem = await NewsAuthService().getNewsDetail();

    isLoading = false;
    if (mounted) {
      setState(() {});
    }

    _mainVideoController = VideoPlayerController.network(
      newsDetailItem.video!,
    );

    _chewieMainController = ChewieController(
      videoPlayerController: _mainVideoController,
      aspectRatio: 16 / 9,
      allowedScreenSleep: false,
      allowFullScreen: true,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      systemOverlaysAfterFullScreen: SystemUiOverlay.values,
      // showControls: false,
      materialProgressColors: ChewieProgressColors(
        playedColor: navyBlue,
        handleColor: Colors.white,
        backgroundColor: dividerColor,
        bufferedColor: Colors.white30,
      ),
      autoInitialize: true,
    );

    _subVideoController = VideoPlayerController.network(
      newsDetailItem.video!,
    );

    _chewieSubController = ChewieController(
      videoPlayerController: _subVideoController,
      aspectRatio: 16 / 9,
      allowedScreenSleep: false,
      allowFullScreen: true,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      systemOverlaysAfterFullScreen: SystemUiOverlay.values,
      // showControls: false,
      materialProgressColors: ChewieProgressColors(
        playedColor: navyBlue,
        handleColor: Colors.white,
        backgroundColor: dividerColor,
        bufferedColor: Colors.white30,
      ),
      autoInitialize: true,
    );
  }

  @override
  void dispose() {
    _mainVideoController.dispose();
    _subVideoController.dispose();

    _chewieMainController.dispose();
    _chewieSubController.dispose();

    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: appBar() as PreferredSizeWidget?,
      body: scaffoldBody(),
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
        const SizedBox(
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
    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 6,
                  ),
                  videoPlayer(),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        newsTitle(),
                        const SizedBox(
                          height: 20,
                        ),
                        bloggerDetail(),
                        const SizedBox(
                          height: 20,
                        ),
                        newsShortDescription(),
                        const SizedBox(
                          height: 20,
                        ),
                        newsSubTitle(),
                        const SizedBox(
                          height: 20,
                        ),
                        newsFullDescription(),
                        const SizedBox(
                          height: 20,
                        ),
                        subVideoPlayer(),
                        const SizedBox(
                          height: 20,
                        ),
                        newsSubTitle(),
                        const SizedBox(
                          height: 20,
                        ),
                        newsFullDescription(),
                        const SizedBox(
                          height: 20,
                        ),
                        Divider(
                          thickness: 1,
                          color: dividerColor,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        newsChips(),
                        const SizedBox(
                          height: 50,
                        ),
                        relatedPostTitle(),
                        const SizedBox(
                          height: 20,
                        ),
                        relatedPost(),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }

  Widget videoPlayer() {
    return Chewie(
      controller: _chewieMainController,
      posterUrl: newsDetailItem.poster,
      titleName: newsDetailItem.title,
    );
  }

  Widget subVideoPlayer() {
    return Chewie(
      controller: _chewieSubController,
      titleName: newsDetailItem.title,
      posterUrl: newsDetailItem.poster,
    );
  }

  Widget newsTitle() {
    return Text(
      newsDetailItem.title!,
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
            imageUrl: newsDetailItem.authorAvatar!,
            errorWidget: imageErrorWidget,
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "${newsDetailItem.author} • ",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: blackFont,
                ),
              ),
              Text(
                "${newsDetailItem.uploadTime} ",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: darkGrey,
                ),
              ),
            ],
          ),
          CustomChip(
            text: "${newsDetailItem.readTime} read",
          )
        ],
      ),
    );
  }

  Widget newsShortDescription() {
    return Text(
      newsDetailItem.shortDescription!,
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
      newsDetailItem.subHeader!,
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
      newsDetailItem.description!,
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
        children:
            newsDetailItem.tags!.map((e) => CustomChip(text: e)).toList());
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
        children: newsDetailItem.newsListItems!
            .map((news) => Container(
                  child: Column(
                    children: [
                      NewsTile(
                        newsListItem: news,
                      ),
                      const SizedBox(
                        height: 16,
                      )
                    ],
                  ),
                ))
            .toList());
  }
}
