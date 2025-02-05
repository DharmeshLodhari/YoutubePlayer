import 'dart:developer';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/locator.dart';
import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/screens/moments/moments_auth.dart';
import 'package:Slydo/screens/moments/screens/moment_detail/custom_story_view.dart';
import 'package:Slydo/screens/moments/screens/moment_detail/story_moment.dart';
import 'package:Slydo/screens/moments/utils.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:story_view/controller/story_controller.dart';

class MomentsSocialMedia extends StatefulWidget {
  const MomentsSocialMedia({super.key, this.momentUrl});

  final String? momentUrl;

  @override
  State<MomentsSocialMedia> createState() => _MomentsSocialMediaState();
}

const String comingSoonLottie = 'assets/lottie/coming_soon_lottie.json';

class _MomentsSocialMediaState extends State<MomentsSocialMedia> {
  bool isFirstTime = true;
  String? nextMoments = "";
  int? countMoments = 0;

  String? previousMoments = "";
  bool isMomentsLoading = false;
  bool noList = false;
  List<ExploreMomentsModel> momentsList = [];
  final ScrollController _momentScrollController = ScrollController();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  AppConfigurationModel? appConfigurationModel;

  @override
  void initState() {
    super.initState();
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;
    if (appConfigurationModel?.enableMoment == true) {
      getSocialMoments();
    }

    _momentScrollController.addListener(() {
      if (_momentScrollController.position.pixels ==
              _momentScrollController.position.maxScrollExtent &&
          _momentScrollController.position.pixels != 0) {
        getSocialMoments();
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _momentScrollController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    if (await checkConnection(context)) {
      _refreshPage();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  void _refreshPage() {
    nextMoments = "";
    countMoments = 0;
    previousMoments = "";
    isMomentsLoading = false;
    noList = false;
    isFirstTime = true;
    momentsList = [];
    if (mounted) setState(() {});
    getSocialMoments();
  }

  Future<void> getSocialMoments() async {
    if (!isMomentsLoading) {
      if (nextMoments != null && !isMomentsLoading) {
        if (mounted) {
          setState(() {
            isMomentsLoading = true;
          });
        }
        final Map<String, dynamic>? result =
            await MomentsAuthService().getExploreMoments(
          nextMoments,
          previousMoments,
          momentUrl: widget.momentUrl,
        );
        if (result == null) {
          noList = true;
          isMomentsLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }
        nextMoments = result['next'];
        countMoments = result['count'];
        previousMoments = result['previous'];
        final tempList = result['results'];

        isMomentsLoading = false;
        noList = false;

        if (tempList != null && tempList is List && tempList.isNotEmpty) {
          for (ExploreMomentsModel e in tempList) {
            if (momentsList.isNotEmpty) {
              bool isUniqueUser = true;
              for (ExploreMomentsModel exploreMomentsModel in momentsList) {
                if (e.owner == exploreMomentsModel.owner) {
                  isUniqueUser = false;
                  break;
                }
              }

              if (isUniqueUser) {
                momentsList.add(e);
              }
            } else {
              momentsList.add(e);
            }
          }
        }

        if (mounted) setState(() {});

        if (isFirstTime && nextMoments != null && nextMoments != "") {
          isFirstTime = false;
          getSocialMoments();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      body: scaffoldBody(),
    );
  }

  Widget comingSoonWidget() {
    return Center(
      child: Lottie.asset(comingSoonLottie),
    );
  }

  Widget scaffoldBody() {
    if (appConfigurationModel?.enableMoment == false) {
      return comingSoonWidget();
    }

    return Column(
      children: [
        Expanded(
          child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: !isMomentsLoading && noList
                ? NoItemInList(
                    msg: AppLocalization.of(context)!.noResultFound,
                  )
                : ListView(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    controller: _momentScrollController,
                    children: [
                      momentsListWidget(),
                      if (isMomentsLoading)
                        Shimmer.fromColors(
                          baseColor: Colors.white,
                          highlightColor: greyBorderColor,
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              mainAxisExtent: 270,
                            ),
                            itemCount: 2,
                            itemBuilder: (context, index) {
                              return Card(
                                color: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget momentsListWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        if (nextMoments == "" && isMomentsLoading)
          const SizedBox.shrink()
        else
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              mainAxisExtent: 270,
              maxCrossAxisExtent: 200,
            ),
            itemCount: momentsList.length,
            itemBuilder: (context, index) {
              return ExploreMomentsCard(
                index: index,
                exploreMomentsModelList: momentsList,
              );
            },
          ),
      ],
    );
  }
}

class ExploreMomentsCard extends StatefulWidget {
  // This index is the position of the 'ExploreMomentsCard' in the list 0f explore moments.
  final int index;
  final Function()? onTap;
  final bool showProfileAvatar;
  final List<ExploreMomentsModel> exploreMomentsModelList;

  const ExploreMomentsCard(
      {super.key,
      this.onTap,
      this.showProfileAvatar =
          true, // We do not show profile avatar on profile page moment's tab.
      required this.index,
      required this.exploreMomentsModelList});

  @override
  State<ExploreMomentsCard> createState() => _ExploreMomentsCardState();
}

class _ExploreMomentsCardState extends State<ExploreMomentsCard> {
  final storyController = StoryController();

  List<Shiddo> storyItems = [];

  ExploreMomentsModel? exploreMoment;
  MomentsModel? sigleMoment;

  @override
  void initState() {
    widget.exploreMomentsModelList[widget.index].moments!.map((e) {
      sigleMoment = e;
      if (e.mediaType == 'image') {
        storyItems.add(Shiddo.pageImage(
            url: e.media!,
            controller: storyController,
            duration: const Duration(seconds: 10),
            momentsModel: e));
      }
      if (e.mediaType == 'video') {
        storyItems.add(Shiddo.pageVideo(e.media!,
            controller: storyController,
            duration: Duration(milliseconds: e.duration!),
            momentsModel: e));
      }
      log('message...first${widget.exploreMomentsModelList[widget.index].moments!.length}');
      log('message...second$e');
    }).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          NavigationUtil.push(
            context,
            screen: StoryMomentScreen(
              controller: storyController,
              storyItems: storyItems,
              currentMoment: sigleMoment,
            ),
          );
          ////
          // NavigationUtil.push(
          //   context,
          //   screen: MomentsDetailsScreen(
          //     indexOfMoment: widget.index,
          //     momentsModelList:
          //     widget.exploreMomentsModelList.map((e) => e.moments!).toList(),
          //   ),
          // );
        }
      },
      child: Card(
        color: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _getMediaRenderer(
              momentModel:
                  widget.exploreMomentsModelList[widget.index].moments!.first,
              context: context,
            ),
            if (widget.showProfileAvatar)
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 10),
                  child: MomentsUtils().getUserProfilePic(
                      widget.exploreMomentsModelList[widget.index].avatar!,
                      widget.exploreMomentsModelList[widget.index].ownerName!),
                ),
              )
            else
              const SizedBox.shrink(),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    userNameWithVerifiedIcon(
                      name: widget.exploreMomentsModelList[widget.index]
                              .ownerName ??
                          '',
                      isVerified: false,
                      textStyle: TextStyle(
                        fontSize: 12,
                        fontFamily: "Inter",
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: blackFont,
                            offset: const Offset(0.0, 0),
                          ),
                        ],
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      getFormattedViewCount(
                          noOfViews: widget
                              .exploreMomentsModelList[widget.index]
                              .moments![0]
                              .views),
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: "Inter",
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: blackFont,
                            offset: const Offset(0.0, 0),
                          ),
                        ],
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (widget.exploreMomentsModelList[widget.index].moments!.first
                    .mediaType ==
                'video')
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 12.0),
                  child: SvgPicture.asset("yarn/cam_vec".toSVG()),
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

Widget _getMediaRenderer(
    {required MomentsModel momentModel, required BuildContext context}) {
  if (momentModel.mediaPoster != null) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: momentModel.mediaPoster!,
        fit: BoxFit.fill,
        memCacheHeight: (MediaQuery.of(context).size.height * 0.8).toInt(),
        errorWidget: productAndServiceBigErrorWidget,
      ),
    );
  }

  if (momentModel.mediaType == "image") {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: momentModel.media!,
        fit: BoxFit.cover,
        memCacheHeight: (MediaQuery.of(context).size.height * 0.8).toInt(),
        errorWidget: productAndServiceBigErrorWidget,
      ),
    );
  }

  if (momentModel.mediaType == "video") {
    if (momentModel.mediaPoster == null) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0XFFdcdcdc).withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
      );
    } else {
      return Container();
    }
  } else {
    return Container();
  }
}
