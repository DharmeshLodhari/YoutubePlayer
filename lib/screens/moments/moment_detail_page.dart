import 'package:Slydo/screens/moments/widgets/rotated_image.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_video_player/cached_video_player.dart';

import '../../utils/navigation_util.dart';
import '../../utils/util.dart';
import 'create_moment_screen.dart';
import 'models/moments_model.dart';
import 'moments_service.dart';
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
                            backgroundColor: navyBlue,
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // CircleAvatar(
                        //   child: Text(
                        //     '$currentSingleMomentListPosition',
                        //     style: TextStyle(color: Colors.white),
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  NavigationUtil.push(context,
                                      screen: AddVideo());
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: navyBlue,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                  ),
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
                bottom: 100.0,
                child: Column(
                  children: <Widget>[
                    CustomButton(
                      SvgPicture.asset('assets/images/three_dot.svg'),
                      '',
                    ),
                    CustomButton(
                      Icon(Icons.thumb_up, color: Colors.white),
                      int.parse(widget.momentsModelList[index].likes
                                  .toString()) <
                              1
                          ? ''
                          : widget.momentsModelList[index].likes.toString(),
                      onPressed: () {
                        MomentsService()
                            .likeMoment(widget.momentsModelList[index].id!)
                            .then((value) {
                          widget.momentsModelList[index] = value;
                          if (mounted) setState(() {});
                        });
                      },
                    ),
                    CustomButton(
                      isLiked
                          ? Icon(Icons.thumb_down, color: Colors.white)
                          : Icon(Icons.thumb_down, color: Colors.white),
                      int.parse(widget.momentsModelList[index].dislikes
                                  .toString()) <
                              1
                          ? ''
                          : widget.momentsModelList[index].dislikes.toString(),
                      onPressed: () {
                        MomentsService()
                            .dislikeMoment(widget.momentsModelList[index].id!)
                            .then((value) {
                          widget.momentsModelList[index] = value;
                          if (mounted) setState(() {});
                        });
                      },
                    ),
                    CustomButton(
                      Icon(Icons.messenger, color: Colors.white),
                      '',
                      onPressed: () {
                        commentSheet(context);
                      },
                    ),
                    CustomButton(
                      SvgPicture.asset('assets/images/share_icon.svg'),
                      '',
                      onPressed: () {
                        commentSheet(context);
                      },
                    ),
                    Row(
                      children: [
                        Container(
                          width: 70,
                          margin: EdgeInsets.only(right: 10),
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.link),
                              SizedBox(width: 5),
                              Text(
                                'Link',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 5),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned.directional(
                textDirection: Directionality.of(context),
                start: 12.0,
                bottom: 72.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${getDateTime(widget.momentsModelList[index].createdAt!)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            offset: Offset(0.0, 0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getCircularUserAvatar(
                            widget.momentsModelList[index].avatar!),
                        SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${widget.momentsModelList[index].ownerName!}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: blackFont,
                                  offset: Offset(0.0, 0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    SizedBox(
                      width: 340,
                      child: Text(
                        '${widget.momentsModelList[index].text!}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: blackFont,
                              offset: Offset(0.0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Wrap(
                      children: getTags(index),
                    ),
                  ],
                ),
              ),
              // Positioned.directional(
              //   textDirection: Directionality.of(context),
              //   start: 12.0,
              //   bottom: 72.0,
              //   child: RichText(
              //     text: TextSpan(
              //       children: [
              //         TextSpan(
              //           text:
              //               '${getDateTime(widget.momentsModelList[index].createdAt!)}\n',
              //           style: TextStyle(
              //             fontWeight: FontWeight.bold,
              //             shadows: [
              //               Shadow(
              //                 blurRadius: 10.0,
              //                 offset: Offset(0.0, 0),
              //               ),
              //             ],
              //           ),
              //         ),
              //         WidgetSpan(
              //           child: Padding(
              //             padding: const EdgeInsets.only(top: 18.0),
              //             child: getCircularUserAvatar(
              //                 widget.momentsModelList[index].avatar!),
              //           ),
              //         ),
              //         TextSpan(
              //           text:
              //               '${widget.momentsModelList[index].ownerName!}\n\n',
              //           style: TextStyle(
              //             fontWeight: FontWeight.bold,
              //             shadows: [
              //               Shadow(
              //                 blurRadius: 10.0,
              //                 color: blackFont,
              //                 offset: Offset(0.0, 0),
              //               ),
              //             ],
              //           ),
              //         ),
              //         // TextSpan(
              //         //   text: '${widget.momentsModelList[index].text!}\n\n',
              //         //   style: TextStyle(
              //         //     fontWeight: FontWeight.bold,
              //         //     shadows: [
              //         //       Shadow(
              //         //         blurRadius: 10.0,
              //         //         color: blackFont,
              //         //         offset: Offset(0.0, 0),
              //         //       ),
              //         //     ],
              //         //   ),
              //         //   children: getTags(index),
              //         // ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

  // void likeUnlikePost() async {
  //   await MomentsService().likeMoment().then((value) {
  //     widget.post = value;
  //     if (mounted) setState(() {});
  //   }).catchError((error) {
  //     debugPrint("Error:- $error");
  //     showToast(message: "$error");
  //   });
  //   // await UserReviewAuth()
  //   //     .unlikeUserReview(widget.review!)
  //   //     .then((value) {})
  //   //     .catchError((error) {
  //   //   debugPrint("Error:- $error");
  //   //   showToast(message: "$error");
  //   // });
  // }

  List<Widget> getTags(int index) {
    List<String> formattedTagList = [];

    if (widget.momentsModelList[index].tags != null) {
      widget.momentsModelList[index].tags!.join(', ');

      widget.momentsModelList[index].tags!.forEach((tag) {
        formattedTagList.add('#$tag ');
      });

      return formattedTagList
          .map(
            (e) => Text(
              e,
              style: TextStyle(color: Colors.white70),
            ),
          )
          .toList();
    } else {
      return [];
    }
  }

  String getDateTime(String dateTime) {
    return DateFormat.yMd().add_jm().format(DateTime.parse(dateTime));
  }
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
        fit: BoxFit.fill,
        placeholder: (context, _) {
          return Container(color: Colors.grey);
        },
      );
    } else if (widget.momentsModel.mediaType == "video") {
      return VideoDisplay(momentsModel: widget.momentsModel);
    } else {
      return Image.asset('assets/images/app_logo.png');
    }
  }
}

class VideoDisplay extends StatefulWidget {
  final MomentsModel momentsModel;
  const VideoDisplay({Key? key, required this.momentsModel}) : super(key: key);

  @override
  _VideoDisplayState createState() => _VideoDisplayState();
}

class _VideoDisplayState extends State<VideoDisplay> {
  bool initialized = false;
  late CachedVideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        CachedVideoPlayerController.network(widget.momentsModel.media!)
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
    return widget.momentsModel.mediaPoster != null
        ? Container(
            color: greyBorderColor,
            child: Center(
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.momentsModel.mediaPoster!,
                    fit: BoxFit.cover,
                    placeholder: (context, _) {
                      return Container(color: Colors.grey);
                    },
                  ),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          )
        : Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/moment_placeholder_image.png',
                fit: BoxFit.cover,
              ),
              Center(child: CircularProgressIndicator()),
            ],
          );
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

class MomentDetailDashes extends StatefulWidget {
  final int lengthOfMoment;

  const MomentDetailDashes({Key? key, required this.lengthOfMoment})
      : super(key: key);

  @override
  _MomentDetailDashesState createState() => _MomentDetailDashesState();
}

class _MomentDetailDashesState extends State<MomentDetailDashes> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: dashes(widget.lengthOfMoment),
      ),
    );
  }

  List<Widget> dashes(int lengthOfMoment) {
    List<Widget> widgets = [];
    Widget widget = Expanded(
      child: Container(
        height: 10,
        color: Colors.white,
      ),
    );
    for (int i = 0; i < lengthOfMoment; i++) {
      widgets.add(widget);
    }
    return widgets;
  }
}
