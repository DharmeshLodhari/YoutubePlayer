import 'package:Slydo/screens/moments/widgets/rotated_image.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_video_player/cached_video_player.dart';

import 'models/moments_model.dart';
import 'widgets/custom_button.dart';

List<String> videos2 = [
  'assets/videos/4.mp4',
  'assets/videos/5.mp4',
  'assets/videos/6.mp4',
];

List<String> imagesInDisc2 = [
  'assets/user/user4.png',
  'assets/user/user3.png',
  'assets/user/user1.png',
];

class MomentsDetailsScreen extends StatefulWidget {
  /*'indexOfMoment'
  * This is the index of the moment that was clicked from 'moments_screen'.
  * When the user comes to this page, the moment that will be shown at first is the
  * moment the user clicked (through this index).*/
  final int indexOfMoment;
  final List<List<MomentsModel>> momentsModelList;

  const MomentsDetailsScreen({
    Key? key,
    required this.indexOfMoment,
    required this.momentsModelList,
  }) : super(key: key);

  @override
  _MomentsDetailsScreenState createState() => _MomentsDetailsScreenState();
}

class _MomentsDetailsScreenState extends State<MomentsDetailsScreen> {
  /*This maintains the position of the moment in the vertical scroll direction.*/
  late int _verticalScrollIndex;
  /*This variable is used to display how many more moments the user
  is left to see (minus 1) for a single moment*/
  int currentSingleMomentListPosition = 0;
  late PageController _verticalScrollPageViewCtrl;

  @override
  void initState() {
    super.initState();
    _verticalScrollIndex = widget.indexOfMoment;
    _verticalScrollPageViewCtrl =
        PageController(initialPage: widget.indexOfMoment);
    getMomentsModelListLength();
  }

  getMomentsModelListLength() {
    currentSingleMomentListPosition =
        widget.momentsModelList[widget.indexOfMoment].length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topLeft,
          child: PageView.builder(
            // This allows us to scroll vertically to move to the next user's moments.
            itemCount: widget.momentsModelList.length,
            controller: _verticalScrollPageViewCtrl,
            scrollDirection: Axis.vertical,
            onPageChanged: (verticalScrollIndex) {
              _verticalScrollIndex = verticalScrollIndex;
              setState(() {
                currentSingleMomentListPosition =
                    widget.momentsModelList[verticalScrollIndex].length;
              });
            },
            itemBuilder: (context, index) {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    MediaRendererPageView(
                      momentsModelList: widget.momentsModelList[index],
                      onPageChanged: (pageViewIndex) {
                        setState(() {
                          currentSingleMomentListPosition = widget
                                  .momentsModelList[_verticalScrollIndex]
                                  .length -
                              pageViewIndex;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        CircleAvatar(
                          child: Text(
                            '$currentSingleMomentListPosition',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class MediaRendererPageView extends StatefulWidget {
  final Function(int index) onPageChanged;
  final List<MomentsModel> momentsModelList;
  const MediaRendererPageView(
      {Key? key, required this.onPageChanged, required this.momentsModelList})
      : super(key: key);

  @override
  _MediaRendererPageViewState createState() => _MediaRendererPageViewState();
}

class _MediaRendererPageViewState extends State<MediaRendererPageView> {
  bool isLiked = false;
  PageController? _pageCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageCtrl,
      onPageChanged: widget.onPageChanged,
      scrollDirection: Axis.horizontal,
      itemCount: widget.momentsModelList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _pageCtrl!.nextPage(
                duration: Duration(milliseconds: 800),
                curve: Curves.decelerate);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              RenderMedia(momentsModel: widget.momentsModelList[index]),
              Positioned.directional(
                textDirection: Directionality.of(context),
                end: -10.0,
                bottom: 80.0,
                child: Column(
                  children: <Widget>[
                    CustomButton(
                      SvgPicture.asset('assets/images/three_dot.svg'),
                      '',
                    ),
                    CustomButton(
                      isLiked
                          ? Icon(Icons.thumb_down, color: Colors.white)
                          : Icon(Icons.thumb_down, color: Colors.white),
                      '1.2k',
                      onPressed: () {
                        setState(() {
                          isLiked = !isLiked;
                        });
                      },
                    ),
                    CustomButton(
                      Icon(Icons.thumb_up, color: Colors.white),
                      '1.2k',
                    ),
                    CustomButton(
                      Icon(Icons.messenger, color: Colors.white),
                      '287',
                      onPressed: () {
                        commentSheet(context);
                      },
                    ),
                    CustomButton(
                      SvgPicture.asset('assets/images/share_icon.svg'),
                      '287',
                      onPressed: () {
                        commentSheet(context);
                      },
                    ),
                    // Padding(
                    //   padding: EdgeInsets.symmetric(vertical: 8.0),
                    //   child:
                    //       RotatedImage(widget.momentsModelList[index].avatar!),
                    // ),
                  ],
                ),
              ),
              Positioned.directional(
                textDirection: Directionality.of(context),
                start: 12.0,
                bottom: 72.0,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${getDateTime(widget.momentsModelList[index].createdAt!)}\n',
                        style: TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                      TextSpan(
                        text:
                            '${widget.momentsModelList[index].ownerName!}\n\n',
                      ),
                      TextSpan(
                        text: widget.momentsModelList[index].text!,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String getDateTime(String dateTime) {
    // 18/08/2020 • 6:54 AM

    return DateFormat.yMd().add_jm().format(DateTime.parse(dateTime));
  }
}

class Comment {
  final String image;
  final String name;
  final String comment;
  final String time;

  Comment(
      {required this.image,
      required this.name,
      required this.comment,
      required this.time});
}

void commentSheet(BuildContext context) async {
  List<Comment> comments = [
    Comment(
      image: 'assets/user/user1.png',
      name: 'Emery Dias',
      comment: "Great food! I have a great meal.Nice package",
      time: ' 4' "asdasd",
    ),
    Comment(
      image: 'assets/user/user2.png',
      name: 'Emery Dias',
      comment: "Great food! I have a great meal.Nice package",
      time: ' 1' "dfgdfgdfg",
    ),
    Comment(
      image: 'assets/user/user3.png',
      name: 'Emery Dias',
      comment: "Great food! I have a great meal.Nice package",
      time: ' 4' "asdasdasdasd",
    ),
    Comment(
      image: 'assets/user/user4.png',
      name: 'Emery Dias',
      comment: "Great food! I have a great meal.Nice package",
      time: ' 2' "asdasdasdasd",
    ),
    Comment(
      image: 'assets/user/user1.png',
      name: 'Emery Dias',
      comment: "Great food! I have a great meal.Nice package",
      time: ' 5' "asd",
    ),
    Comment(
      image: 'assets/user/user2.png',
      name: 'Emery Dias',
      comment: "Great food! I have a great meal.Nice package",
      time: ' 15' "asd",
    ),
    Comment(
      image: 'assets/user/user3.png',
      name: 'Emery Dias',
      comment: "Great food! I have a great meal.Nice package",
      time: ' 1' "asdasdasdasd",
    ),
    Comment(
      image: 'assets/user/user4.png',
      name: 'Emery Dias',
      comment: "Great food! I have a great meal.Nice package",
      time: ' 2' "asdasdasdasd",
    ),
  ];

  await showModalBottomSheet(
    enableDrag: false,
    isScrollControlled: true,
    // backgroundColor: backgroundColor,
    shape: const OutlineInputBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        borderSide: BorderSide.none),
    context: context,
    builder: (context) => SizedBox(
      height: MediaQuery.of(context).size.height / 1.5,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Text(
                      "Comments",
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      "409",
                      style: TextStyle(
                        color: Color(0xff75818F),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 60.0),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[
                        const Divider(
                          color: Color(0xffEBEDFC),
                          thickness: 1,
                        ),
                        ListTile(
                          leading: Image.asset(
                            comments[index].image,
                            scale: 2.3,
                          ),
                          title: Text(comments[index].name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              )),
                          trailing: Text(
                            "Jul 07, 2021",
                            style: TextStyle(),
                          ),
                        ),
                        ListTile(
                          leading: const Text(""),
                          title: Text(
                            comments[index].comment,
                            style: TextStyle(),
                          ),
                          subtitle: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, right: 10),
                                child: Row(
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.thumb_up_alt_outlined),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text("12")
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, right: 10),
                                child: Row(
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.thumb_down_alt_outlined),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text("12")
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, right: 10),
                                child: Row(
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.mode_comment_outlined,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text("12")
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        ],
      ),
    ),
  );
}

class RenderMedia extends StatefulWidget {
  final MomentsModel momentsModel;
  const RenderMedia({Key? key, required this.momentsModel}) : super(key: key);

  @override
  _RenderMediaState createState() => _RenderMediaState();
}

class _RenderMediaState extends State<RenderMedia> {
  @override
  Widget build(BuildContext context) {
    if (widget.momentsModel.gif != null) {
      return CachedNetworkImage(
        imageUrl: widget.momentsModel.gif!,
        fit: BoxFit.cover,
      );
    }
    if (widget.momentsModel.mediaType == "image") {
      return CachedNetworkImage(
        imageUrl: widget.momentsModel.media!,
        fit: BoxFit.cover,
        placeholder: (context, _) {
          return Container(color: Colors.grey);
        },
      );
    } else if (widget.momentsModel.mediaType == "video") {
      return VideoDisplay(videoUrl: widget.momentsModel.media!);
    } else {
      return Image.asset('assets/images/app_logo.png');
    }
  }
}

class VideoDisplay extends StatefulWidget {
  final String videoUrl;
  const VideoDisplay({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoDisplayState createState() => _VideoDisplayState();
}

class _VideoDisplayState extends State<VideoDisplay> {
  bool initialized = false;
  late CachedVideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CachedVideoPlayerController.network(widget.videoUrl)
      ..initialize().then((value) {
        _controller.play();
        setState(() {
          initialized = true;
          _controller.setLooping(true);
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedVideoPlayer(
          _controller,
        ),
      );
    }
    return Container(
      color: greyBorderColor,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class FollowingTabPage extends StatelessWidget {
  final List<String> videos;
  final List<String> images;
  final bool isFollowing;

  final int variable;

  const FollowingTabPage(this.videos, this.images, this.isFollowing,
      {Key? key, required this.variable})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FollowingTabBody(videos, images, isFollowing, variable);
  }
}

class FollowingTabBody extends StatefulWidget {
  final List<String> videos;
  final List<String> images;

  final bool isFollowing;
  final int variable;

  const FollowingTabBody(
      this.videos, this.images, this.isFollowing, this.variable,
      {Key? key})
      : super(key: key);

  @override
  _FollowingTabBodyState createState() => _FollowingTabBodyState();
}

class _FollowingTabBodyState extends State<FollowingTabBody> {
  late PageController _pageController;
  int current = 0;
  bool isOnPageTurning = false;

  void scrollListener() {
    if (isOnPageTurning &&
        _pageController.page == _pageController.page!.roundToDouble()) {
      setState(() {
        current = _pageController.page!.toInt();
        isOnPageTurning = false;
      });
    } else if (!isOnPageTurning &&
        current.toDouble() != _pageController.page &&
        (current.toDouble() - _pageController.page!).abs() > 0.1) {
      setState(() {
        isOnPageTurning = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      physics: const BouncingScrollPhysics(),
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, position) {
        return VideoPage(
          widget.videos[position],
          widget.images[position],
          pageIndex: position,
          currentPageIndex: current,
          isPaused: isOnPageTurning,
          isFollowing: widget.isFollowing,
        );
      },
      itemCount: widget.videos.length,
    );
  }
}

// Their design
class VideoPage extends StatefulWidget {
  final String video;
  final String image;
  final int pageIndex;
  final int currentPageIndex;
  final bool isPaused;
  final bool isFollowing;

  const VideoPage(this.video, this.image,
      {Key? key,
      required this.pageIndex,
      required this.currentPageIndex,
      required this.isPaused,
      required this.isFollowing})
      : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _controller;
  bool initialized = false;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.video)
      ..initialize().then((value) {
        setState(() {
          _controller.setLooping(true);
          initialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pageIndex == widget.currentPageIndex &&
        !widget.isPaused &&
        initialized) {
      _controller.play();
    } else {
      _controller.pause();
    }

    return GestureDetector(
      onTap: () {
        _controller.value.isPlaying ? _controller.pause() : _controller.play();
      },
      child: _controller.value.isInitialized
          ? VideoPlayer(_controller)
          : const SizedBox.shrink(),
    );

    if (widget.pageIndex == 2) _controller.pause();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            },
            child: _controller.value.isInitialized
                ? VideoPlayer(_controller)
                : const SizedBox.shrink(),
          ),
          Positioned.directional(
            textDirection: Directionality.of(context),
            end: -10.0,
            bottom: 80.0,
            child: Column(
              children: <Widget>[
                CustomButton(
                  SvgPicture.asset(
                    'assets/images/apk_icon.svg',
                  ),
                  '',
                ),
                CustomButton(
                  isLiked
                      ? SvgPicture.asset(
                          'assets/images/apk_icon.svg',
                          color: Colors.blue,
                        )
                      : SvgPicture.asset(
                          'assets/images/apk_icon.svg',
                        ),
                  '1.2k',
                  onPressed: () {
                    setState(() {
                      isLiked = !isLiked;
                    });
                  },
                ),
                CustomButton(
                  Image.asset('assets/images/app_logo.png'),
                  '1.2k',
                ),
                CustomButton(
                  Image.asset('assets/images/app_logo.png'),
                  '287',
                  onPressed: () {
                    // commentSheet(context);
                  },
                ),
                CustomButton(
                  Image.asset('assets/images/app_logo.png'),
                  '287',
                  onPressed: () {
                    // commentSheet(context);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: RotatedImage(widget.image),
                ),
              ],
            ),
          ),
          Positioned.directional(
            textDirection: Directionality.of(context),
            start: 12.0,
            bottom: 72.0,
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: '18/08/2020 • 6:54 AM\n',
                    style: TextStyle(
                      color: Colors.white54,
                    ),
                  ),
                  TextSpan(
                    text: "sdfsdf",
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
