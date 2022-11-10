import 'dart:async';
import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/moments/widgets/attachment_widget.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../locale/app_localization.dart';
import '../../../locator.dart';
import '../../../routes/route_constants.dart';
import '../../../utils/enums.dart';
import '../../../utils/navigation_util.dart';
import '../../../utils/slydo_app_icon_icons.dart';
import '../../../utils/util.dart';
import '../../../widget/LoadingIndicator.dart';
import '../../../widget/customized_textform_field.dart';
import '../../../widget/dialog.dart';
import '../../../widget/read_more_widget.dart';
import '../../../widget/rounded_background_icon.dart';
import '../../more_apps/messaging/chat/models/ChatConversation.dart';
import '../../more_apps/messaging/chat/share_in_chat/ShareInChat.dart';
import '../../more_apps/shopping/models/store.dart';
import '../../post_detail_page.dart';
import '../models/comment_model.dart';
import '../models/moments_model.dart';
import '../moments_bloc.dart';
import '../widgets/custom_moment_detail_button.dart';
import 'create_moment_screen.dart';
import 'moments_service.dart';

late CachedVideoPlayerController _controller;


class MomentsDetailsScreen extends StatefulWidget {
  String? nextPageUrl;

  /* 'indexOfMoment'
  * This is the index of the moment that was clicked from 'moments_screen'.
  * When the user comes to this page, the moment that will be shown at first is the
  * moment the user clicked (through this index).*/
  int indexOfMoment;
  final List<String> listOfConnectionNames;
  List<List<MomentsModel>>? momentsModelList;

  MomentsDetailsScreen({
    Key? key,
    this.nextPageUrl,
    this.listOfConnectionNames = const [],
    required this.indexOfMoment,
    this.momentsModelList,
  }) : super(key: key);

  @override
  _MomentsDetailsScreenState createState() => _MomentsDetailsScreenState();
}

class _MomentsDetailsScreenState extends State<MomentsDetailsScreen> {
  bool loadingMoments = false;

  /* This variable is to show a loading indicator when the user has gotten to the end
  *  of the list and there are more moments to load through widget.nextPageUrl*/
  bool nextPageUrlLoading = false;

  /*This holds the number of previous and next moments to load when the user
  * comes to this page*/
  int numberOfMomentsToLoad = 2;
  int currentVerticalPageIndex = 0;
  late PageController _verticalScrollPageViewCtrl;
  late VideoPlayerManager videoPlayerManager;
  int? horizoallyPageIndex;

  @override
  void initState() {
    videoPlayerManager = VideoPlayerManager();
    super.initState();

    // If moment list is null, initialize it to an empty list.
    if (widget.momentsModelList == null) {
      widget.momentsModelList = [];
    }
    _verticalScrollPageViewCtrl =
        PageController(initialPage: getInitialPageIndex());
    if (widget.listOfConnectionNames.isNotEmpty) {
      getListOfMomentsModelList();
    }
  }

  // To get the initial page that the pageview will show when the user gets this screen and
  // the previous and next two moments(if there is) have been loaded.
  int getInitialPageIndex() {
    if (widget.momentsModelList != null &&
        widget.momentsModelList!.isNotEmpty) {
      return widget.indexOfMoment;
    } else {
      if (widget.indexOfMoment > 2) {
        return 2;
      } else {
        return widget.indexOfMoment;
      }
    }
  }

  // To know where to start looping from while trying to get the moment with owner's name.
  // Ideally we should get the previous two and the next two moments of what the user clicked on from the previous page.
  int getLoopStartingPoint({
    required List<String> mList,
    // If we are loading the nextPageUrl, we do not neec to load the previous moments only the next ones;
    bool loadingNextPageUrl = false,
  }) {
    if (!loadingNextPageUrl) {
      if (mList.indices
          .contains(widget.indexOfMoment - numberOfMomentsToLoad)) {
        return widget.indexOfMoment - numberOfMomentsToLoad;
      } else if (mList.indices.contains(widget.indexOfMoment - 1)) {
        return widget.indexOfMoment - 1;
      } else {
        return widget.indexOfMoment;
      }
    } else {
      return widget.indexOfMoment;
    }
  }

  int getLoopEndingPoint({required List<String> mList}) {
    // To check if the list 'mList' contains a particular index.
    if (mList.indices.contains(widget.indexOfMoment + numberOfMomentsToLoad)) {
      return widget.indexOfMoment + numberOfMomentsToLoad;
    } else if (mList.indices.contains(widget.indexOfMoment + 1)) {
      return widget.indexOfMoment + 1;
    } else {
      return widget.indexOfMoment;
    }
  }

  Future<List<String>?> getNextPageListOfConnectionNames(
      {required String nextPageUrl}) async {
    Map<String, dynamic>? result = await MomentsService().getContactMoments(
      next: widget.nextPageUrl,
    );

    if (result == null) {
      return null;
    }
    widget.nextPageUrl = result['next'];
    var resultList = result['results'] as List<MomentsModel>;

    return resultList.map((e) => e.owner!).toList();
  }

  void getListOfMomentsModelList({bool loadingNextPageUrl = false}) async {
    showLoadingIndicator(loadingNextPageUrl: loadingNextPageUrl, show: true);

    try {
      int startIndex = getLoopStartingPoint(
          mList: widget.listOfConnectionNames,
          loadingNextPageUrl: loadingNextPageUrl);

      int endIndex = getLoopEndingPoint(mList: widget.listOfConnectionNames);

      for (int i = startIndex; i <= endIndex; i++) {
        List<MomentsModel> momentsModelList = await MomentsService()
            .getMomentsWithOwnerName(
                ownerName: widget.listOfConnectionNames[i]);
        widget.momentsModelList!.add(momentsModelList);
      }

      showLoadingIndicator(loadingNextPageUrl: loadingNextPageUrl, show: false);
    } catch (e) {
      showLoadingIndicator(loadingNextPageUrl: loadingNextPageUrl, show: false);

      NavigationUtil.pop(context);
      showToast(message: 'Could not load your moments, try again.');
    }
  }

  showLoadingIndicator({required bool loadingNextPageUrl, required bool show}) {
    if (loadingNextPageUrl) {
      setState(() {
        nextPageUrlLoading = show;
      });
    } else {
      setState(() {
        loadingMoments = show;
      });
    }
  }

  void getNextOrPreviousListOfMomentsWithConnectionNames(
      {required int verticalScrollIndex, required bool getNextList}) async {
    // The 'index' is the index of the moment in the vertical scroll pageview

    int count = getNextList ? 1 : 4;

    do {
      int nextIndex = widget.listOfConnectionNames.indexOf(widget
              .momentsModelList![verticalScrollIndex][0]
              .owner!) + // We can use position 0 here so we can just get the owner's name(we can also use 1 or 2 or whatever cos it is still that  particular user's moment)
          count;
      int previousIndex = widget.listOfConnectionNames.indexOf(
              widget.momentsModelList![verticalScrollIndex][0].owner!) -
          count;

      // Whether previous or next index depending on if the user has gotten to the top or end of the vertical list respectively.
      int indexToWorkWith = getNextList ? nextIndex : previousIndex;

      if (widget.listOfConnectionNames.indices.contains(indexToWorkWith)) {
        try {
          List<MomentsModel> momentsModelList = await MomentsService()
              .getMomentsWithOwnerName(
                  ownerName: widget.listOfConnectionNames[indexToWorkWith]);
          if (getNextList) {
            widget.momentsModelList!.add(momentsModelList);
          } else {
            widget.momentsModelList!.insert(0, momentsModelList);
          }

          setState(() {});
        } catch (e) {
          debugPrint('ERROR FETCHING MOMENT WITH OWNER NAME :: $e');

          NavigationUtil.pop(context);
          showToast(message: 'Could not load your moments, try again.');
        }
      }
      if (getNextList) {
        count++;
      } else {
        count--;
      }
    } while (getNextList ? count <= 4 : count >= 0);
  }

  @override
  Widget build(BuildContext context) {
    if (loadingMoments) {
      return Scaffold(
        body: Center(
          child: CircularLoadingIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Align(
        alignment: Alignment.topLeft,
        // This allows us to scroll vertically to move to the next or previous user's moments.
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                itemCount: widget.momentsModelList!.length,
                controller: _verticalScrollPageViewCtrl,
                scrollDirection: Axis.vertical,
                onPageChanged: (verticalScrollIndex) async {
                  // To check if the pageview has gotten to the top of the list.

                  currentVerticalPageIndex -= 1;

                  if (verticalScrollIndex == 0) {
                    if (widget
                            .momentsModelList![verticalScrollIndex][0].owner !=
                        widget.listOfConnectionNames[0]) {
                      getNextOrPreviousListOfMomentsWithConnectionNames(
                          verticalScrollIndex: verticalScrollIndex,
                          getNextList: false);
                    }
                  }

                  // To check if the pageview has gotten to the end of the list.
                  else if (verticalScrollIndex + 1 ==
                      widget.momentsModelList!.length) {
                    // This is to check if the owner of the last moment that's showing is the same as the last name
                    // in widget.listOfConnectionNames (this helps us to know whether to load the next moments using the
                    // names that are left in widget.listOfConnectionNames or using the url(endpoint) in widget.nextPageUrl).
                    if (widget
                            .momentsModelList![verticalScrollIndex][0].owner !=
                        widget.listOfConnectionNames.last) {
                      getNextOrPreviousListOfMomentsWithConnectionNames(
                          verticalScrollIndex: verticalScrollIndex,
                          getNextList: true);
                    } else {
                      if (widget.nextPageUrl != null) {
                        List<String>? newListOfConnectionNames =
                            await getNextPageListOfConnectionNames(
                                nextPageUrl: widget.nextPageUrl!);

                        widget.indexOfMoment =
                            widget.listOfConnectionNames.length;

                        widget.listOfConnectionNames
                            .addAll(newListOfConnectionNames!);

                        getListOfMomentsModelList(loadingNextPageUrl: true);
                      }
                    }
                  }
                  videoPlayerManager.togglePlay(index: verticalScrollIndex, url: widget.momentsModelList![verticalScrollIndex][horizoallyPageIndex!].media);
                },
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Stack(
                      children: [
                        MediaRendererPageView(
                          momentsModelList: widget.momentsModelList![index],
                          onPageChanged: (pageViewIndex) {
                            setState(() {
                              horizoallyPageIndex = pageViewIndex;
                            });
                            videoPlayerManager.togglePlay(index: pageViewIndex, url: widget.momentsModelList![index][pageViewIndex].media);
                          },
                          videoPlayerManager: videoPlayerManager,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 34.0),
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
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        NavigationUtil.push(context,
                                            screen: CreateMediaMomentScreen());
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
            Visibility(
              visible: nextPageUrlLoading,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: CircularLoadingIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MediaRendererPageView extends StatefulWidget {
  final ValueChanged<int> onPageChanged;
  final List<MomentsModel> momentsModelList;
  final VideoPlayerManager videoPlayerManager;
  const MediaRendererPageView(
      {Key? key, required this.onPageChanged, required this.momentsModelList, required this.videoPlayerManager})
      : super(key: key);

  @override
  _MediaRendererPageViewState createState() => _MediaRendererPageViewState();
}

class _MediaRendererPageViewState extends State<MediaRendererPageView> {
  bool isLiked = false;
  PageController? _pageCtrl;
  Product? product;
  late UserBloc? userBloc;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      Provider.of<MomentsBloc>(context, listen: false).numberOfComments =
          widget.momentsModelList.map((e) => e.numberOfComments!).toList();

      debugPrint(
          'NUMBER OF COMMENTS ${Provider.of<MomentsBloc>(context, listen: false).numberOfComments}');
    });
  }

  @override
  Widget build(BuildContext context) {
    //PageView to scroll horizontally to view a single user's list of moments.
    return PageView.builder(
      controller: _pageCtrl,
      onPageChanged: widget.onPageChanged,
      scrollDirection: Axis.horizontal,
      itemCount: widget.momentsModelList.length,
      itemBuilder: (context, index) {
        // var _index = 1;

        return Stack(
          fit: StackFit.expand,
          children: [
            RenderMedia(momentsModel: widget.momentsModelList[index]),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: MomentDetailDashes(
                    currentPageViewIndex: index,
                    lengthOfMoment: widget.momentsModelList.length),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              child: InkWell(
                onTap: () {
                  _pageCtrl!.previousPage(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeIn);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: InkWell(
                onTap: () {
                  _pageCtrl!.nextPage(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeIn);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                ),
              ),
            ),
            Positioned.directional(
              textDirection: Directionality.of(context),
              end: 15.0,
              bottom: MediaQuery.of(context).size.height * 0.04,
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 16),
                      isMyMoment(index)
                          ? CustomMomentDetailButton(
                              iconEnabled: true,
                              iconData: Icons.more_horiz_outlined,
                              text: '',
                              onPressed: () {
                                androidBottomSheet(
                                  context: context,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      momentVisibilityOption(
                                          widget.momentsModelList[index]),
                                      momentPermanentOption(
                                          widget.momentsModelList[index]),
                                      momentCommentingOption(
                                          widget.momentsModelList[index]),
                                      momentLikeOption(
                                          widget.momentsModelList[index]),
                                      bottomSheetItem(
                                          title: 'Share in chat',
                                          iconData: Icons.send_outlined,
                                          onTap: () async {
                                            await sendMomentToUserInChat(
                                                momentsModel: widget
                                                    .momentsModelList[index]);
                                          }),
                                      bottomSheetItem(
                                        title: 'Delete',
                                        iconData: Icons.delete,
                                        onTap: () {
                                          Navigator.pop(context);

                                          showDialogBox(
                                            context: context,
                                            actionOneTextColor: white,
                                            actionOneBgColor: mateRed,
                                            actionTwoTextColor: blackFont,
                                            actionTwoBgColor: greyBorderColor,
                                            title: AppLocalization.of(context)!
                                                .delete,
                                            actionTwoText:
                                                AppLocalization.of(context)!
                                                    .cancel,
                                            actionOneText:
                                                AppLocalization.of(context)!
                                                    .delete,
                                            description:
                                                'Are you sure you want to delete this moment?',
                                            roundedBackgroundIcon:
                                                RoundedBackgroundIcon(
                                              enableMargin: false,
                                              width: 90,
                                              height: 90,
                                              image: Image.asset(
                                                  'assets/images/delete_dialog_icon.png'),
                                            ),
                                            leftButtonOnPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (dialogLoadingContext) =>
                                                          LoadingIndicator());
                                              MomentsService()
                                                  .deleteMoment(widget
                                                      .momentsModelList[index]
                                                      .id!)
                                                  .then(
                                                (value) {
                                                  Navigator.pop(
                                                      context); // Dismiss loading indicator
                                                  Navigator.pop(context);
                                                  showToast(
                                                      message:
                                                          'Moment deleted');
                                                },
                                              ).catchError((e) {
                                                Navigator.pop(context);
                                                showToast(
                                                    message: e.toString());
                                              });
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : SizedBox.shrink(),
                      _buildShareMomentOption(index),
                      CustomMomentDetailButton(
                        iconEnabled: likeEnabled(index),
                        iconData: Icons.thumb_up,
                        text: likeEnabled(index)
                            ? int.parse(widget.momentsModelList[index].likes
                                        .toString()) <
                                    1
                                ? ''
                                : getFormattedViewCount(
                                    noOfViews:
                                        widget.momentsModelList[index].likes!,
                                    addViewText: false)
                            : '',
                        onPressed: likeEnabled(index)
                            ? () {
                                MomentsService()
                                    .likeMoment(
                                        widget.momentsModelList[index].id!)
                                    .then((value) {
                                  widget.momentsModelList[index] = value;
                                  if (mounted) setState(() {});
                                });
                              }
                            : null,
                      ),
                      CustomMomentDetailButton(
                        iconEnabled: likeEnabled(index),
                        iconData: Icons.thumb_down,
                        text: likeEnabled(index)
                            ? int.parse(widget.momentsModelList[index].dislikes
                                        .toString()) <
                                    1
                                ? ''
                                : getFormattedViewCount(
                                    noOfViews: widget
                                        .momentsModelList[index].dislikes!,
                                    addViewText: false,
                                  )
                            : '',
                        onPressed: likeEnabled(index)
                            ? () {
                                MomentsService()
                                    .dislikeMoment(
                                        widget.momentsModelList[index].id!)
                                    .then((value) {
                                  widget.momentsModelList[index] = value;
                                  if (mounted) setState(() {});
                                });
                              }
                            : null,
                      ),
                      CustomMomentDetailButton(
                        iconEnabled: commentingEnabled(index),
                        iconData: Icons.messenger,
                        text: commentingEnabled(index)
                            ? getCommentCount(index)
                            : '',
                        onPressed: commentingEnabled(index)
                            ? () {
                                commentSheet(
                                  context,
                                  widget.momentsModelList[index].id!,
                                  index: index,
                                );
                              }
                            : null,
                      ),
                      CustomMomentDetailButton(
                        iconEnabled: true,
                        iconData: Icons.visibility_rounded,
                        text: getFormattedViewCount(
                          noOfViews: widget.momentsModelList[index].views,
                          addViewText: false,
                        ),
                        onPressed: null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 12.0,
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
                            Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
                                arguments: widget.momentsModelList[index].avatar);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: getCircularUserAvatar(
                              widget.momentsModelList[index].avatar!,
                              width: 35,
                              height: 35,
                            ),
                          ),
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
                                    context,
                                    Routes.USER_PROFILE,
                                    arguments: {
                                      "searchedUserName":
                                          widget.momentsModelList[index].owner,
                                    },
                                  );
                                },
                                child: Text(
                                  messageDecoderWithEmoji(
                                      '${widget.momentsModelList[index].ownerName!}')!,
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
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                                  SizedBox(width: 4),
                                  getPrivateOrPublicIcon(index),
                                ],
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
                                  widget.momentsModelList[index].text)!,
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
                    ),
                    SizedBox(
                      width: 300,
                      child: getTags(index),
                    ),
                    SizedBox(height: 9),
                    Row(
                      children: [
                        getPayMeBtn(index),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: getWhichAttachmentWidgetToShow(
                            widget.momentsModelList[index].attachment!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShareMomentOption(int index) {
    if (isMyMoment(index)) {
      return SizedBox.shrink();
    }

    return CustomMomentDetailButton(
        iconEnabled: true,
        iconData: Icons.share,
        text: "",
        onPressed: () async {
          await sendMomentToUserInChat(
              momentsModel: widget.momentsModelList[index]);
        });
  }

  Future<void> sendMomentToUserInChat(
      {required MomentsModel momentsModel}) async {
    List<ChatConversation?> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    debugPrint("Selected users = ${listOfRecipient.length}");

    listOfRecipient.forEach((recipient) {
      addMomentPostToChat(
          recipientUser: recipient!, momentsModel: momentsModel);
    });
  }

  Future<void> addMomentPostToChat({
    required ChatConversation recipientUser,
    required MomentsModel momentsModel,
    String? url,
  }) async {
    UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);

    Map<String, dynamic> metaData = {
      "id": momentsModel.id,
      "title": messageDecoderWithEmoji(momentsModel.text),
      "author_avatar": momentsModel.avatar,
      "author_username": messageDecoderWithEmoji(momentsModel.ownerName),
    };

    switch (momentsModel.mediaType) {
      case "image":
        metaData.addAll({"image": momentsModel.media});
        break;
      case "video":
        metaData.addAll({"image": momentsModel.mediaPoster});
        break;
    }

    Map<String, dynamic> data = {
      "meta_data": jsonEncode(metaData),
      "check_id": Uuid().v4(),
      "conversation_id": recipientUser.conversationId,
      "author": userBloc.user.userName,
      "message": 'moment',
      "kind": "moment",
      "created_at": DateTime.now().toUtc().toString(),
      "type": "chatroom_message",
    };
    await sendDataToSocket(data);
    showToast(message: 'Moment Shared');
  }

  Widget momentVisibilityOption(MomentsModel momentModel) {
    String title = "Make ";
    bool isPublic = false;
    IconData icon;
    if (momentModel.isPublic ?? false) {
      title += "Private";
      icon = Icons.shield;
      isPublic = false;
    } else {
      title += "Public";
      icon = Icons.public;
      isPublic = true;
    }

    return bottomSheetItem(
      title: title,
      iconData: icon,
      onTap: () {
        Navigator.pop(context);
        MomentsService().updateMoment(
            momentId: momentModel.id!, data: {"is_public": isPublic}).then(
          (value) {
            momentModel = value;
            if (mounted) setState(() {});
            Navigator.pop(context); // Dismiss loading indicator
            showToast(message: 'Moment updated !!');
          },
        ).catchError((e) {
          Navigator.pop(context);
          showToast(message: e.toString());
        });
      },
    );
  }

  Widget momentPermanentOption(MomentsModel momentModel) {
    bool isPermanent = false;
    String title;
    debugPrint("MOMENT MODEL IS PERMANENT:- ${momentModel.isPermanent}");
    debugPrint("MOMENT IS PERMANENT:- ${momentModel.isPermanent}");
    if (momentModel.isPermanent ?? false) {
      isPermanent = momentModel.isPermanent!;
    }

    if (isPermanent) {
      title = "For Moment Alone";
    } else {
      title = "Make Permanent";
    }

    return bottomSheetItem(
      title: title,
      iconData: CupertinoIcons.infinite,
      onTap: () {
        Navigator.pop(context);
        MomentsService().updateMoment(
            momentId: momentModel.id!,
            data: {"is_permanent": !isPermanent}).then(
          (value) {
            momentModel = value;
            if (mounted) setState(() {});
            Navigator.pop(context); // Dismiss loading indicator
            showToast(message: 'Moment updated !!');
          },
        ).catchError((e) {
          Navigator.pop(context);
          showToast(message: e.toString());
        });
      },
    );
  }

  Widget momentCommentingOption(MomentsModel momentModel) {
    bool isCommentingEnable = false;
    String title;
    if (momentModel.enableCommenting ?? false) {
      isCommentingEnable = momentModel.enableCommenting!;
    }

    IconData icon;
    if (isCommentingEnable) {
      title = "Turn off Commenting";
      icon = Icons.comments_disabled;
    } else {
      title = "Turn on Commenting";
      icon = Icons.comment;
    }

    return bottomSheetItem(
      title: title,
      iconData: icon,
      onTap: () {
        Navigator.pop(context);
        MomentsService().updateMoment(
            momentId: momentModel.id!,
            data: {"enable_commenting": !isCommentingEnable}).then(
          (value) {
            momentModel = value;
            if (mounted) setState(() {});
            Navigator.pop(context); // Dismiss loading indicator
            showToast(message: 'Moment updated !!');
          },
        ).catchError((e) {
          Navigator.pop(context);
          showToast(message: e.toString());
        });
      },
    );
  }

  Widget momentLikeOption(MomentsModel momentModel) {
    bool isLikeEnabled = false;
    String title;
    if (momentModel.enableLikes ?? false) {
      isLikeEnabled = momentModel.enableLikes!;
    }

    IconData icon;
    if (isLikeEnabled) {
      title = "Disable Likes";
      icon = Icons.thumb_up_alt;
    } else {
      title = "Enable Likes";
      icon = Icons.thumb_up_alt;
    }

    return bottomSheetItem(
      title: title,
      iconData: icon,
      onTap: () {
        Navigator.pop(context);

        MomentsService().updateMoment(
            momentId: momentModel.id!,
            data: {"enable_like": !isLikeEnabled}).then(
          (value) {
            momentModel = value;
            if (mounted) setState(() {});
            Navigator.pop(context); // Dismiss loading indicator
            showToast(message: 'Moment updated !!');
          },
        ).catchError((e) {
          Navigator.pop(context);
          showToast(message: e.toString());
        });
      },
    );
  }

  String getCommentCount(int index) {
    String commentCount = '';

    try {
      MomentsBloc momentsBloc = Provider.of<MomentsBloc>(context);
      if (momentsBloc.numberOfComments[index] >= 1) {
        commentCount = getFormattedViewCount(
          noOfViews: momentsBloc.numberOfComments[index],
          addViewText: false,
        );
      }
      // if (momentsBloc.numberOfComments.length <= index + 1) {
      //   if (momentsBloc.numberOfComments[index] >= 1) {
      //     commentCount = getFormattedViewCount(
      //       noOfViews: momentsBloc.numberOfComments[index],
      //       addViewText: false,
      //     );
      //   }
      // }
    } catch (error) {
      commentCount = '';
    }

    return commentCount;
  }

  Widget getPrivateOrPublicIcon(int index) {
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: widget.momentsModelList[index].isPublic == true
          ? Icon(
              Icons.public_outlined,
              color: Colors.white,
              size: 16,
            )
          : Icon(
              Icons.security_outlined,
              color: Colors.white,
              size: 16,
            ),
    );
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

  Widget getWhichAttachmentWidgetToShow(Map<String, dynamic> attachment) {
    if (attachment.containsKey('url')) {
      return attachmentWidget(
        onTap: () {
          _launchUrl(attachment['url'].toString().split('-')[0]);
        },
        iconData: Icons.link,
        title: attachment['url'].toString().split('-')[1],
      );
    }

    if (attachment.containsKey('product')) {
      return attachmentWidget(
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.PRODUCT,
              // arguments: {"productId": 'ce8d6464-8c7f-47db-a381-a163a258713a'},
              arguments: {"productId": attachment['product']},
            );
          },
          iconData: Icons.shopping_cart_rounded,
          title: 'Product');
    }

    if (attachment.containsKey('service')) {
      return attachmentWidget(
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.SERVICE_DETAIL,
              // arguments: {"serviceId": '08083ad8-04d9-4878-8b18-e820f7c680af'},
              arguments: {"serviceId": attachment['service']},
            );
          },
          iconData: Icons.handyman_rounded,
          title: 'Service');
    }

    if (attachment.containsKey('blog')) {
      return attachmentWidget(
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
        iconData: Icons.receipt_long_rounded,
        title: 'Blog',
      );
    } else {
      return Container();
    }
  }

  void _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) throw 'Could not launch $url';
  }

  bool isMyMoment(int index) {
    return getLoggedInUserName(context) == widget.momentsModelList[index].owner;
  }

  bool likeEnabled(int index) {
    return widget.momentsModelList[index].enableLikes != null &&
        widget.momentsModelList[index].enableLikes!;
  }

  bool commentingEnabled(int index) {
    return widget.momentsModelList[index].enableCommenting != null &&
        widget.momentsModelList[index].enableCommenting!;
  }

  Widget getPayMeBtn(int index) {
    return widget.momentsModelList[index].payMe!
        ? InkWell(
            onTap: getLoggedInUserName(context) !=
                    widget.momentsModelList[index].owner
                ? () async {
                    if (getIt<AppConfigurationBloc>()
                            .appConfigurationModel
                            ?.enablePayment ==
                        true) {
                      Navigator.of(context).pushNamed(
                        Routes.SEND_PAYMENT,
                        arguments: <String, dynamic>{
                          'recipient': widget.momentsModelList[index].owner,
                          'isFromProfile': false,
                          'isFromChat': false,
                          'defaultReferenceText':
                              'Payment from  "${truncateString(
                            str: widget.momentsModelList[index].text!,
                            lengthToTruncateAt: 8,
                          )}\" moment'
                        },
                      );
                    } else {
                      showToast(message: 'Payment not available at the moment');
                    }
                  }
                : () {
                    showToast(message: 'You cannot pay yourself');
                  },
            child: PhysicalModel(
              color: Colors.transparent,
              elevation: 20,
              shadowColor: Colors.black.withOpacity(0.7),
              child: Container(
                margin: EdgeInsets.only(right: 12),
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: HexColor(widget
                                .momentsModelList[index].payMeButtonColor !=
                            null
                        ? '#${widget.momentsModelList[index].payMeButtonColor}'
                        : '#3F61DB'),
                    borderRadius: BorderRadius.circular(6)),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/slydo_icon_white.png',
                      width: 30,
                      height: 20,
                      color: widget.momentsModelList[index].payMeButtonColor
                                  ?.toLowerCase() ==
                              '#ffffff'
                          ? navyBlue
                          : Colors.white,
                    ),
                    Text(
                      messageDecoderWithEmoji(
                          widget.momentsModelList[index].payMeLabel ??
                              'Pay Me')!,
                      style: TextStyle(
                        color: widget.momentsModelList[index].payMeButtonColor
                                    ?.toLowerCase() ==
                                '#ffffff'
                            ? navyBlue
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        : SizedBox.shrink();
  }
}

GlobalKey videoPlayerKey = GlobalKey();

class RenderMedia extends StatefulWidget {
  final MomentsModel momentsModel;
  const RenderMedia({Key? key, required this.momentsModel}) : super(key: key);

  @override
  _RenderMediaState createState() => _RenderMediaState();
}

class _RenderMediaState extends State<RenderMedia> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      MomentsService().updateMomentView(widget.momentsModel.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('GLAD IMAGE MEDIATYPE -> ${widget.momentsModel.id}');
    debugPrint('GLAD IMAGE -> ${widget.momentsModel.media!}');
    if (widget.momentsModel.gif != null) {
      return CachedNetworkImage(
        imageUrl: widget.momentsModel.gif!,
        fit: BoxFit.fitWidth,
        memCacheHeight: (MediaQuery.of(context).size.height * 0.8).toInt(),
      );
    }

    if (widget.momentsModel.mediaType == "image") {
      return PhotoView(
        //To be able to zoom the image.
        imageProvider: NetworkImage(widget.momentsModel.media!),
      );

      return CachedNetworkImage(
        imageUrl: widget.momentsModel.media!,
        fit: BoxFit.fitWidth,
        memCacheHeight: (MediaQuery.of(context).size.height * 0.8).toInt(),
        placeholder: (context, _) {
          return Container(color: Colors.grey);
        },
      );
    } else if (widget.momentsModel.mediaType == "video") {
      return VideoDisplay(
          key: videoPlayerKey, momentsModel: widget.momentsModel);
    } else {
      return Container(
        decoration: BoxDecoration(
          color: Color(0XFFdcdcdc).withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
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
  bool showMediaIcon = false;
  late VideoPlayerManager videoPlayerManager;

  @override
  void initState() {
    debugPrint('VIDEO MEDIA --> ${widget.momentsModel.media!}');
    videoPlayerManager = VideoPlayerManager();
    videoPlayerManager.init(widget.momentsModel.media!);
    // _controller = CachedVideoPlayerController.network(
    //   widget.momentsModel.media!,
    // )..initialize().then((value) {
    //     _controller.play();
    //     initialized = true;
    //     _controller.setLooping(true);
    //     setState(() {});
    //   }).catchError((e) {
    //     Navigator.pop(context);
    //     showToast(message: 'Unable to display moment');
    //   });
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    await videoPlayerManager.dispose();
    // await _controller.pause();
    // await _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return FittedBox(
        fit: BoxFit.fitWidth,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: InkWell(
              onTap: () {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                  showMediaIconFor2Seconds();
                } else {
                  _controller.play();
                  showMediaIconFor2Seconds();
                }
              },
              child: Stack(
                children: [
                  CachedVideoPlayer(_controller),
                  Align(
                    alignment: Alignment.center,
                    child: Visibility(
                      visible: showMediaIcon,
                      child: RoundedBackgroundIcon(
                        width: 60,
                        height: 80,
                        borderRadius: 50,
                        icon: Icon(
                          !_controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                        backgroundColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                    fit: BoxFit.fitWidth,
                    memCacheHeight:
                        (MediaQuery.of(context).size.height * 0.8).toInt(),
                    placeholder: (context, _) {
                      return Container(color: Colors.grey);
                    },
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Color(0XFFdcdcdc).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
            Center(child: CircularLoadingIndicator()),
          ],
        ),
      ),
    );
  }

  showMediaIconFor2Seconds() {
    setState(() => showMediaIcon = true);
    Future.delayed(Duration(seconds: 2), () {
      if (mounted)
        setState(() {
          showMediaIcon = false;
        });
    });
  }
}

class VideoPlayerManager {

  late CachedVideoPlayerController _controller;
  int? activeIndex;

  init(String url) async {
    _controller = CachedVideoPlayerController.network(
      url,
    )..initialize()..setLooping(true).then((value) async {
      await play();
    }).catchError((e) {
      showToast(message: 'Unable to display moment');
    });
  }

  play() async {
    await _controller.play();
  }

  togglePlay({int? index, String? url}) async {
    if (index == activeIndex) {
      await play();
    } else if (index != activeIndex) {
      activeIndex = index;
      await pause();
      await init(url!);
    }
  }

  pause() async {
    await _controller.pause();
  }

  dispose() async {
    await pause();
    await _controller.dispose();
  }

}

void commentSheet(BuildContext context, String momentID,
    {required int index}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const OutlineInputBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        borderSide: BorderSide.none),
    builder: (context) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: CommentListWidget(momentID: momentID, index: index),
    ),
  );
}

class CommentListWidget extends StatefulWidget {
  final int
      index; // This is the index of the moment in the (horizontal) moment list.
  final String momentID;
  const CommentListWidget(
      {Key? key, required this.index, required this.momentID})
      : super(key: key);

  @override
  _CommentListWidgetState createState() => _CommentListWidgetState();
}

class _CommentListWidgetState extends State<CommentListWidget> {
  String? nextUrl;
  bool addingComment = false;
  BasePaginationModel<List<CommentModel>>? basePaginationModel;
  List<CommentModel> comments = [];
  List<CommentModel> tempComments = [];

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
      tempComments.addAll(value.result);

      tempComments.forEach((element) {
        if (!(comments.contains(element))) {
          comments.add(element);
        }
      });

      basePaginationModel = value;
      nextUrl = basePaginationModel!.next;
      print("INDEX:- ${widget.index}");
      Provider.of<MomentsBloc>(context, listen: false)
          .numberOfComments[widget.index] = basePaginationModel!.count;

      Provider.of<MomentsBloc>(context, listen: false).numberOfComments =
          Provider.of<MomentsBloc>(context, listen: false).numberOfComments;

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
                        maxLength: 250,
                      ),
                    ),
                    SizedBox(width: 5),
                    InkWell(
                      onTap: addingComment
                          ? null
                          : () {
                              setState(() => addingComment = true);
                              MomentsService().addCommentToMoment(
                                  momentID: widget.momentID,
                                  data: {
                                    'comment': commentCtrl.text,
                                    'author_username':
                                        getLoggedInUserName(context),
                                  }).then((value) {
                                commentCtrl.clear();
                                comments.clear();
                                nextUrl = null;
                                getListOfComments();
                                setState(() => addingComment = false);
                              }).catchError((e) {
                                showToast(message: 'Something went wrong');
                              });
                            },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Icon(
                          SlydoAppIcon.send_message_2,
                          color: addingComment ? greyBorderColor : navyBlue,
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
                  return buildLoadingIndicator(isLoading: isCommentsLoading);
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
                              str: messageDecoderWithEmoji(
                                  commentModel.authorUsername!)!,
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

//The dashes at the top of the moment's page (similar to Whatsapp's)
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
        ),
      );

      widgets.add(widget);
    }
    return widgets;
  }
}

String getGetMomentDetailDateTime(String dateTime) {
  return toTimeAgoLabel(dateTime: DateTime.parse(dateTime));
}

extension ListExtensions on List {
  Range get indices => Range.fromLength(this.length);
}

class Range extends Iterable<int> {
  const Range(this.start, this.end) : assert(start <= end);
  const Range.fromLength(int length) : this(0, length - 1);

  final int start;
  final int end;

  int get length => end - start + 1;

  @override
  Iterator<int> get iterator =>
      Iterable.generate(length, (i) => start + i).iterator;

  @override
  bool contains(Object? index) {
    if (index == null || index is! int) return false;
    return index >= start && index <= end;
  }

  @override
  String toString() => '[$start, $end]';
}
