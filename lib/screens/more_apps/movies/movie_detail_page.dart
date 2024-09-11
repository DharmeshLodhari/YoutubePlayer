import 'package:Slydo/screens/more_apps/movies/models/movie_detail_item.dart';
import 'package:Slydo/screens/more_apps/movies/movie_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/utils/video_player_controller/chewie_player.dart';
import 'package:Slydo/utils/video_player_controller/chewie_progress_colors.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class MovieDetailPage extends StatefulWidget {
  const MovieDetailPage({super.key});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late VideoPlayerController _videoController;
  late ChewieController _chewieController;

  bool isLoading = false;
  MovieDetailItem movieDetailItem = MovieDetailItem();

  @override
  void initState() {
    getMovieItem();
    super.initState();
  }

  void getMovieItem() async {
    isLoading = true;
    if (mounted) setState(() {});

    movieDetailItem = await MovieAuthService().getMovie();
    _videoController = VideoPlayerController.network(
      movieDetailItem.video!,
    );

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
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

    isLoading = false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController.dispose();

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
    return WillPopScope(
      onWillPop: () {
        _videoController.pause();
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: lightGrey,
        appBar: appBar() as PreferredSizeWidget?,
        body: isLoading
            ? Center(
                child: CircularLoadingIndicator(),
              )
            : scaffoldBody(),
        floatingActionButton: floatingActionBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
        movieDetailItem.name!,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        shareBtn(),
        const SizedBox(
          width: 8,
        ),
        addToCartBtn(),
        // ignore: prefer_const_constructors
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Chewie(
            controller: _chewieController,
            posterUrl: movieDetailItem.poster,
            titleName: movieDetailItem.name,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(
                  height: 24,
                ),
                movieNameAndRating(),
                const SizedBox(
                  height: 20,
                ),
                Divider(
                  thickness: 1,
                  color: dividerColor,
                ),
                movieReleaseDetail(),
                const SizedBox(
                  height: 16,
                ),
                Divider(
                  thickness: 1,
                  color: dividerColor,
                ),
                const SizedBox(
                  height: 12,
                ),
                movieStarringDetail(),
                const SizedBox(
                  height: 12,
                ),
                Divider(
                  thickness: 1,
                  color: dividerColor,
                ),
                const SizedBox(
                  height: 12,
                ),
                movieDescriptionDetail(),
                const SizedBox(
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
              movieDetailItem.name!,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: blackFont),
            ),
            Row(
              children: [
                getUserCurrencySymbol(context),
                Text(
                  movieDetailItem.price!,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: navyBlue),
                )
              ],
            )
          ],
        ),
        const SizedBox(
          height: 12,
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
              movieDetailItem.rating!,
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
        const SizedBox(
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
                  const SizedBox(
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
                movieDetailItem.category!,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: blackFont),
              ),
            )
          ],
        ),
        const SizedBox(
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
                  const SizedBox(
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
                movieDetailItem.year!,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: blackFont),
              ),
            )
          ],
        ),
        const SizedBox(
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
                  const SizedBox(
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
                movieDetailItem.time!,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: blackFont),
              ),
            )
          ],
        ),
        const SizedBox(
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
                  const SizedBox(
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
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                    decoration: BoxDecoration(
                      color: HexColor("F8F9FA"),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      movieDetailItem.viewingRating!,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: blackFont),
                    ),
                  ),
                  const Expanded(child: SizedBox())
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
        const SizedBox(
          height: 12,
        ),
        Text(
          movieDetailItem.starring!,
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
        const SizedBox(
          height: 12,
        ),
        Text(
          movieDetailItem.description!,
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

  Widget floatingActionBar() {
    return Card(
      elevation: 50,
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
        child: Row(
          children: <Widget>[
            addToCartWidget(),
            const SizedBox(
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
