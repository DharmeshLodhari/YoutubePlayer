import 'dart:async';

import 'package:animated_fractionally_sized_box/animated_fractionally_sized_box.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/state_notifier.dart';
import '../../locale/app_localization.dart';
import '../../routes/route_constants.dart';
import '../../utils/enums.dart';
import '../../utils/navigation_util.dart';
import '../../utils/slydo_app_icon_icons.dart';
import '../../utils/util.dart';
import '../../widget/LoadingIndicator.dart';
import '../../widget/customized_textform_field.dart';
import '../../widget/dialog.dart';
import '../../widget/read_more_widget.dart';
import '../../widget/rounded_background_icon.dart';
import '../more_apps/user_profile/user_auth.dart';
import '../post_detail_page.dart';
import 'create_moment_screen.dart';
import 'models/comment_model.dart';
import 'models/moments_model.dart';
import 'moments_service.dart';
import 'widgets/custom_button.dart';

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
    debugPrint('ID --> ${widget.momentsModelList[widget.indexOfMoment]}');
  }

  getMomentsModelListLength() {
    currentSingleMomentListPosition =
        widget.momentsModelList[widget.indexOfMoment].length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
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
                                .momentsModelList[_verticalScrollIndex].length -
                            pageViewIndex;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0),
                    child: Row(
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
                                      screen: CreateMomentScreen());
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
                  ),
                ],
              ),
            );
          },
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

  // _pageCtrl!.nextPage(
  // duration: Duration(milliseconds: 800),
  // curve: Curves.decelerate);
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageCtrl,
      onPageChanged: widget.onPageChanged,
      scrollDirection: Axis.horizontal,
      itemCount: widget.momentsModelList.length,
      itemBuilder: (context, index) {
        debugPrint('ID ---> ${widget.momentsModelList[index].attachment}');
        debugPrint(
            'ENABLE LIKE ---> ${widget.momentsModelList[index].enableLikes}');
        return Stack(
          fit: StackFit.expand,
          children: [
            RenderMedia(momentsModel: widget.momentsModelList[index]),
            Align(
              alignment: Alignment.topCenter,
              child: MomentDetailDashes(
                  currentPageViewIndex: index,
                  lengthOfMoment: widget.momentsModelList.length),
            ),
            Positioned.directional(
              textDirection: Directionality.of(context),
              end: -10.0,
              top: MediaQuery.of(context).size.height * 0.3,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Column(
                  children: <Widget>[
                    isMyMoment(index)
                        ? CustomButton(
                            Icon(
                              Icons.delete,
                              color: mateRed,
                              size: 28,
                            ),
                            '',
                            onPressed: () {
                              showDialogBox(
                                context: context,
                                actionOneTextColor: white,
                                actionOneBgColor: mateRed,
                                actionTwoTextColor: blackFont,
                                actionTwoBgColor: greyBorderColor,
                                title: AppLocalization.of(context)!.delete,
                                actionTwoText:
                                    AppLocalization.of(context)!.cancel,
                                actionOneText:
                                    AppLocalization.of(context)!.delete,
                                description:
                                    'Are you sure you want to delete this moment?',
                                roundedBackgroundIcon: RoundedBackgroundIcon(
                                  enableMargin: false,
                                  width: 90,
                                  height: 90,
                                  image: Image.asset(
                                      'assets/images/delete_dialog_icon.png'),
                                ),
                                leftButtonOnPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (dialogLoadingContext) =>
                                          LoadingIndicator());
                                  MomentsService()
                                      .deleteMoment(
                                          widget.momentsModelList[index].id!)
                                      .then(
                                    (value) {
                                      Navigator.pop(
                                          context); // Dismiss loading indicator
                                      Navigator.pop(context);
                                    },
                                  ).catchError((e) {
                                    Navigator.pop(context);
                                    showToast(message: e.toString());
                                  });
                                },
                              );
                            },
                          )
                        : SizedBox.shrink(),

                    widget.momentsModelList[index].enableLikes != null &&
                            widget.momentsModelList[index].enableLikes!
                        ? CustomButton(
                            Icon(Icons.thumb_up, color: Colors.white),
                            int.parse(widget.momentsModelList[index].likes
                                        .toString()) <
                                    1
                                ? ''
                                : widget.momentsModelList[index].likes
                                    .toString(),
                            onPressed: () {
                              MomentsService()
                                  .likeMoment(
                                      widget.momentsModelList[index].id!)
                                  .then((value) {
                                widget.momentsModelList[index] = value;
                                if (mounted) setState(() {});
                              });
                            },
                          )
                        : SizedBox.shrink(),
                    widget.momentsModelList[index].enableLikes != null &&
                            widget.momentsModelList[index].enableLikes!
                        ? CustomButton(
                            Icon(Icons.thumb_down, color: Colors.white),
                            int.parse(widget.momentsModelList[index].dislikes
                                        .toString()) <
                                    1
                                ? ''
                                : widget.momentsModelList[index].dislikes
                                    .toString(),
                            onPressed: () {
                              MomentsService()
                                  .dislikeMoment(
                                      widget.momentsModelList[index].id!)
                                  .then((value) {
                                widget.momentsModelList[index] = value;
                                if (mounted) setState(() {});
                              });
                            },
                          )
                        : SizedBox.shrink(),
                    widget.momentsModelList[index].enableCommenting != null &&
                            widget.momentsModelList[index].enableCommenting!
                        ? CustomButton(
                            Icon(Icons.messenger, color: Colors.white),
                            widget.momentsModelList[index].numberOfComments! < 1
                                ? ''
                                : widget
                                    .momentsModelList[index].numberOfComments!
                                    .toString(),
                            onPressed: () {
                              commentSheet(
                                context,
                                widget.momentsModelList[index].id!,
                              );
                            },
                          )
                        : SizedBox.shrink(),

                    // ATTACHMENT WIDGET
                    // Row(
                    //   children: [
                    //     getAttachmentWidget(
                    //         widget.momentsModelList[index].attachment!),
                    //     SizedBox(width: 5),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
            Positioned.directional(
              textDirection: Directionality.of(context),
              start: 12.0,
              bottom: 20.0,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, Routes.USER_PROFILE,
                                arguments: {
                                  "searchedUserName":
                                      widget.momentsModelList[index].owner,
                                });
                          },
                          child: getCircularUserAvatar(
                              widget.momentsModelList[index].avatar!),
                        ),
                        SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, Routes.USER_PROFILE,
                                      arguments: {
                                        "searchedUserName": widget
                                            .momentsModelList[index].owner,
                                      });
                                },
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
                              Text(
                                '${getGetMomentDetailDateTime(widget.momentsModelList[index].createdAt!)}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w400,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0,
                                      offset: Offset(0.0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: widget.momentsModelList[index].text != null
                          ? ReadMoreText(
                              messageDecoderWithEmoji(
                                  widget.momentsModelList[index].text!)!,
                              trimLines: 2,
                              colorClickableText: Colors.pink,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: 'more',
                              trimExpandedText: 'less',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: blackFont,
                                    offset: Offset(0.0, 0),
                                  ),
                                ],
                              ),
                              moreStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                              ),
                              lessStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          : SizedBox.shrink(),
                      // Text(
                      //   // messageDecoderWithEmoji(
                      //   //     widget.momentsModelList[index].text!)!,
                      //   'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam a erat ex. Mauris mattis....',
                      //   maxLines: 8,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: TextStyle(
                      //     fontSize: 18,
                      //     color: Colors.white,
                      //     fontWeight: FontWeight.w600,
                      //     shadows: [
                      //       Shadow(
                      //         blurRadius: 10.0,
                      //         color: blackFont,
                      //         offset: Offset(0.0, 0),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ),
                    SizedBox(
                      width: 300,
                      child: getTags(index),
                    ),
                    SizedBox(height: 9),
                    getPayMeBtn(index),
                  ],
                ),
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
        );
      },
    );
  }

  //
  MomentState getMomentState({required int pageViewIndex}) {
    if (widget.momentsModelList
            .indexOf(widget.momentsModelList[pageViewIndex]) ==
        pageViewIndex) {
      return MomentState.ACTIVE;
    } else {
      return MomentState.INACTIVE;
    }
  }

  Widget getTags(int index) {
    List<String> formattedTagList = [];

    if (widget.momentsModelList[index].tags != null) {
      widget.momentsModelList[index].tags!.join(', ');

      widget.momentsModelList[index].tags!.forEach((tag) {
        formattedTagList.add('#$tag ');
      });

      return ReadMoreText(
        formattedTagList.join(' '),
        trimLines: 2,
        colorClickableText: Colors.pink,
        trimMode: TrimMode.Line,
        trimCollapsedText: 'more',
        trimExpandedText: 'less',
        style: TextStyle(color: Colors.white70),
        moreStyle: TextStyle(
          fontSize: 14,
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
        lessStyle: TextStyle(
          fontSize: 14,
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      return Container();
    }
  }

  Widget getAttachmentWidget(Map<String, dynamic> attachment) {
    if (attachment.containsKey('url')) {
      return InkWell(
        onTap: () {
          _launchUrl(attachment['url']);
        },
        child: Container(
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
      );
    }
    if (attachment.containsKey('product')) {
      return InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.PRODUCT,
            // arguments: {"productId": 'ce8d6464-8c7f-47db-a381-a163a258713a'},
            arguments: {"productId": attachment['product']},
          );
        },
        child: Container(
          width: 80,
          margin: EdgeInsets.only(right: 10),
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'BUY NOW',
            textAlign: TextAlign.center,
            style: TextStyle(color: navyBlue),
          ),
        ),
      );
    }
    if (attachment.containsKey('service')) {
      return InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.SERVICE_DETAIL,
            // arguments: {"serviceId": '08083ad8-04d9-4878-8b18-e820f7c680af'},
            arguments: {"serviceId": attachment['service']},
          );
        },
        child: Container(
          width: 70,
          margin: EdgeInsets.only(right: 10),
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'PAY NOW',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blue),
          ),
        ),
      );
    }
    if (attachment.containsKey('blog')) {
      return InkWell(
        onTap: () {
          NavigationUtil.push(
            context,
            screen: PostDetailPage(
              // postId: '303d5c1b-5539-4b63-a448-c0d3e9687d61',
              postId: attachment['blog'],
              postType: PostType.blog,
            ),
          );
        },
        child: Container(
          width: 70,
          margin: EdgeInsets.only(right: 10),
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Read',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blue),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) throw 'Could not launch $url';
  }

  bool isMyMoment(int index) {
    return getUserName(context) == widget.momentsModelList[index].owner;
  }

  Widget getPayMeBtn(int index) {
    return getUserName(context) != widget.momentsModelList[index].owner
        ? widget.momentsModelList[index].payMe!
            ? PhysicalModel(
                color: Colors.transparent,
                elevation: 20,
                shadowColor: Colors.black.withOpacity(0.7),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                      color: navyBlue, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/slydo_icon_white.png',
                        width: 30,
                        height: 30,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      InkWell(
                        onTap: () async {
                          var customerProfileBloc =
                              Provider.of<CustomerProfileBloc>(context,
                                  listen: false);
                          customerProfileBloc.customer = await UserAuth()
                              .fetchCustomerProfile(
                                  widget.momentsModelList[index].owner);

                          await Navigator.of(context).pushNamed(
                            Routes.SEND_PAYMENT,
                            arguments: <String, dynamic>{
                              'isFromProfile': false,
                              'isFromChat': false,
                            },
                          );
                        },
                        child: Text(
                          'Pay me',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            : SizedBox.shrink()
        : SizedBox.shrink();
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
        // memCacheWidth: 75,
        // memCacheHeight: 75,
        memCacheHeight: (MediaQuery.of(context).size.height * 0.3).toInt(),
      );
    }
    if (widget.momentsModel.mediaType == "image") {
      return CachedNetworkImage(
        imageUrl: widget.momentsModel.media!,
        fit: BoxFit.fill,
        // memCacheWidth: 75,
        // memCacheHeight: 75,
        memCacheHeight: (MediaQuery.of(context).size.height * 0.3).toInt(),
        placeholder: (context, _) {
          return Container(color: Colors.grey);
        },
      );
    } else if (widget.momentsModel.mediaType == "video") {
      return VideoDisplay(momentsModel: widget.momentsModel);
    } else {
      return Image.asset(
        'assets/images/moment_placeholder_image.png',
      );
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
    _controller =
        CachedVideoPlayerController.network(widget.momentsModel.media!)
          ..initialize().then((value) {
            _controller.play();
            initialized = true;
            _controller.setLooping(true);
            setState(() {});
          });
    super.initState();
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
      child: Center(
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.momentsModel.mediaPoster != null
                ? CachedNetworkImage(
                    imageUrl: widget.momentsModel.mediaPoster!,
                    fit: BoxFit.cover,
                    memCacheHeight:
                        (MediaQuery.of(context).size.height * 0.3).toInt(),
                    placeholder: (context, _) {
                      return Container(color: Colors.grey);
                    },
                  )
                : Image.asset(
                    'assets/images/moment_placeholder_image.png',
                  ),
            Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

void commentSheet(BuildContext context, String momentID) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const OutlineInputBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        borderSide: BorderSide.none),
    builder: (context) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: CommentListWidget(momentID: momentID),
    ),
  );
}

class CommentListWidget extends StatefulWidget {
  final String momentID;
  const CommentListWidget({Key? key, required this.momentID}) : super(key: key);

  @override
  _CommentListWidgetState createState() => _CommentListWidgetState();
}

class _CommentListWidgetState extends State<CommentListWidget> {
  String? nextUrl;
  BasePaginationModel<List<CommentModel>>? basePaginationModel;
  List<CommentModel> comments = [];
  bool isCommentsLoading = false;
  TextEditingController commentCtrl = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getListOfComments();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getListOfComments();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getListOfComments() {
    if (mounted) {
      setState(() {
        isCommentsLoading = true;
      });
    }

    MomentsService()
        .getMomentComments(nextUrl: nextUrl, momentID: widget.momentID)
        .then((value) {
      basePaginationModel = value;
      nextUrl = basePaginationModel!.next;

      comments.addAll(basePaginationModel!.result);
      if (mounted) {
        setState(() {
          isCommentsLoading = false;
        });
      }
    }).catchError((e) {
      basePaginationModel = BasePaginationModel(
        count: 0,
        next: '',
        result: [],
        previous: '',
      );
      if (mounted) {
        setState(() {
          isCommentsLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomSheet: isCommentsLoading
          ? SizedBox.shrink()
          : Container(
              height: 100,
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomizedTextFormField(
                        controller: commentCtrl,
                        hintText: 'Comment...',
                      ),
                    ),
                    SizedBox(width: 5),
                    InkWell(
                      onTap: () {
                        MomentsService().addCommentToMoment(
                            momentID: widget.momentID,
                            data: {
                              'comment': commentCtrl.text,
                              'author_username': getUserName(context),
                            }).then((value) {
                          commentCtrl.clear();
                          comments.clear();
                          getListOfComments();
                        }).catchError((e) {
                          showToast(message: 'Something went wrong');
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Icon(
                          SlydoAppIcon.send_message_2,
                          color: navyBlue,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          isCommentsLoading
              ? SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Text(
                        "Comments",
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        '${basePaginationModel!.count}',
                        style: TextStyle(
                          color: Color(0xff75818F),
                        ),
                      ),
                    ],
                  ),
                ),
          Expanded(
            flex: 6,
            child: ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: comments.length + 1,
              itemBuilder: (context, index) {
                if (index == comments.length) {
                  return buildIndicator(isLoading: isCommentsLoading);
                } else {
                  return singleCommentWidget(comments[index]);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget singleCommentWidget(CommentModel commentModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Divider(
          color: Color(0xffEBEDFC),
          thickness: 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getCircularUserAvatar(commentModel.authorAvatar!),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          truncateString(
                              lengthToTruncateAt: 13,
                              str: commentModel.authorUsername!,
                              showEllipsis: false),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(' • '),
                        Text(
                          getGetMomentDetailDateTime(commentModel.createdAt!),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      messageDecoderWithEmoji(commentModel.comment!)!,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void showCommentTextFieldBottomSheet() {
    showBottomSheet(
        context: context,
        constraints: BoxConstraints.loose(Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.45)),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 16.0, bottom: 10),
            child: Container(
              color: Colors.red,
              child: Row(
                children: [
                  Expanded(
                    child: CustomizedTextFormField(
                      autoFocus: true,
                      hintText: 'Comment...',
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // MomentsService().addCommentToMoment(
                      //     momentID: widget.momentID,
                      //     data: {
                      //       'comment': commentCtrl.text,
                      //       'author_username': getUserName(context),
                      //     }).then((value) {
                      //   commentCtrl.clear();
                      //
                      //   getListOfComments();
                      // }).catchError((e) {
                      //   showToast(message: 'Something went wrong');
                      // });
                    },
                    child: Icon(
                      SlydoAppIcon.send_message_2,
                      color: navyBlue,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class MomentDetailDashes extends StatefulWidget {
  final int currentPageViewIndex;
  final int lengthOfMoment;

  const MomentDetailDashes(
      {Key? key,
      required this.currentPageViewIndex,
      required this.lengthOfMoment})
      : super(key: key);

  @override
  _MomentDetailDashesState createState() => _MomentDetailDashesState();
}

class _MomentDetailDashesState extends State<MomentDetailDashes> {
  Timer? timer;
  double widthFactor = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (widthFactor.toInt() >= 1) {
        timer.cancel();
      }
      widthFactor += 0.1;

      if (mounted) setState(() {});
      debugPrint('WIDTH FACTOR -> ${widthFactor.toInt()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: dashes(widget.lengthOfMoment, widget.currentPageViewIndex),
      ),
    );
  }

  List<Widget> dashes(int lengthOfMoment, int currentIndex) {
    debugPrint('DASHES ---> ');
    List<Widget> widgets = [];
    for (int i = 0; i < lengthOfMoment; i++) {
      Widget widget = Expanded(
        child: Container(
          height: 4,
          margin: EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: Offset(0, 0),
              ),
            ],
            color: currentIndex >= i
                ? Colors.white
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          // child: currentWidget(momentState),
        ),
      );

      widgets.add(widget);
    }
    return widgets;
  }

  Widget currentWidget(MomentState momentState) {
    switch (momentState) {
      case MomentState.ACTIVE:
        {
          return AnimatedFractionallySizedBox(
            duration: Duration(seconds: 1),
            alignment: Alignment.centerLeft,
            widthFactor: widthFactor,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      case MomentState.INACTIVE:
        {
          return SizedBox.shrink();
        }
      case MomentState.COMPLETED:
        {
          return Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }
    }
  }
}

enum MomentState { ACTIVE, INACTIVE, COMPLETED }
String getGetMomentDetailDateTime(String dateTime) {
  return toTimeAgoLabel(dateTime: DateTime.parse(dateTime));
  return DateFormat.yMd().add_jm().format(DateTime.parse(dateTime));
}
