import 'dart:developer';

import 'package:Slydo/constant.dart';
import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/screens/moments/screens/create_moment_screen.dart';
import 'package:Slydo/screens/moments/screens/moment_detail/custom_story_view.dart';
import 'package:Slydo/screens/moments/screens/moment_detail/moment_detail_page.dart';
import 'package:Slydo/screens/moments/screens/moment_detail/story_moment.dart';
import 'package:Slydo/screens/moments/screens/moments_service.dart';
import 'package:Slydo/screens/moments/utils.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:story_view/controller/story_controller.dart';

import '../../../data/state_notifier.dart';
import '../../../locale/app_localization.dart';
import '../../../locator.dart';
import '../../../services/app_config_bloc.dart';
import '../../../utils/slydo_app_icon_icons.dart';
import '../../../utils/util.dart';
import '../../more_apps/user_profile/models/user.dart';
import 'moment_search_screen.dart';

class MomentsScreen extends StatefulWidget {
  const MomentsScreen({Key? key});

  @override
  State<MomentsScreen> createState() => _MomentsScreenState();
}

const String comingSoonLottie = 'assets/lottie/coming_soon_lottie.json';

class _MomentsScreenState extends State<MomentsScreen> {
  bool storageIsNull = false;
  late UserBloc userBloc;
  bool isFirstTimeContact = true;
  bool isFirstTimeExplore = true;
  bool hasAdverts = false;
  bool hasContactMoments = true;
  bool hasExploreMoments = true;
  String? nextContactMoments = "";
  String? nextExploreMoments = "";
  int? countContactMoments = 0;
  int? countExploreMoments = 0;
  bool myMomentsLoading = false;

  String? previousContactMoments = "";
  String? previousExploreMoments = "";
  bool isContactMomentsLoading = false;
  bool isExploreMomentsLoading = false;
  List<ExploreMomentsModel> exploreMomentsList = [];
  List<MomentsModel> contactMomentsList = [];
  final ScrollController _myConnectionsScrollController = ScrollController();
  final ScrollController _exploreScrollController = ScrollController();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  bool showExploreMomentsPaginationLoading = false;
  AppConfigurationModel? appConfigurationModel;

  @override
  void initState() {
    super.initState();
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;
    if (appConfigurationModel?.enableMoment == true) {
      getConnectionMoments();
      getExploreMoments();
    }

    _myConnectionsScrollController.addListener(() {
      if (_myConnectionsScrollController.position.pixels ==
              _myConnectionsScrollController.position.maxScrollExtent &&
          _myConnectionsScrollController.position.pixels != 0) {
        getConnectionMoments();
      }
    });
    _exploreScrollController.addListener(() {
      if (_exploreScrollController.position.pixels ==
              _exploreScrollController.position.maxScrollExtent &&
          _exploreScrollController.position.pixels != 0) {
        getExploreMoments();
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _exploreScrollController.dispose();
    _myConnectionsScrollController.dispose();
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

  _refreshPage() {
    nextContactMoments = "";
    nextExploreMoments = "";
    countContactMoments = 0;
    countExploreMoments = 0;
    previousContactMoments = "";
    previousExploreMoments = "";
    isContactMomentsLoading = false;
    isExploreMomentsLoading = false;
    isFirstTimeContact = true;
    isFirstTimeExplore = true;
    exploreMomentsList = [];
    contactMomentsList = [];
    if (mounted) setState(() {});
    getConnectionMoments();
    getExploreMoments();
  }

  Future<void> getConnectionMoments() async {
    if (!isContactMomentsLoading) {
      if (nextContactMoments != null && !isContactMomentsLoading) {
        if (mounted) {
          setState(() {
            isContactMomentsLoading = true;
          });
        }
        final Map<String, dynamic>? result =
            await MomentsService().getContactMoments(
          next: nextContactMoments,
          previous: previousContactMoments,
        );
        if (result == null) {
          isContactMomentsLoading = false;
          return;
        }
        nextContactMoments = result['next'];
        countContactMoments = result['count'];
        previousContactMoments = result['previous'];
        final tempList = result['results'];

        isContactMomentsLoading = false;
        contactMomentsList.addAll(tempList);

        if (mounted) setState(() {});

        if (isFirstTimeContact &&
            nextContactMoments != null &&
            nextContactMoments != "") {
          isFirstTimeContact = false;
          getConnectionMoments();
        }
      }
    }
  }

  Future<void> getExploreMoments() async {
    if (!isExploreMomentsLoading) {
      if (nextExploreMoments != null && !isExploreMomentsLoading) {
        if (mounted) {
          setState(() {
            isExploreMomentsLoading = true;
          });
        }
        final Map<String, dynamic>? result =
            await MomentsService().getExploreMoments(
          nextExploreMoments,
          previousExploreMoments,
        );
        if (result == null) {
          isExploreMomentsLoading = false;
          return;
        }
        nextExploreMoments = result['next'];
        countExploreMoments = result['count'];
        previousExploreMoments = result['previous'];
        final tempList = result['results'];

        isExploreMomentsLoading = false;

        if (tempList != null && tempList is List && tempList.isNotEmpty) {
          for (ExploreMomentsModel e in tempList) {
            if (exploreMomentsList.isNotEmpty) {
              bool isUniqueUser = true;
              for (ExploreMomentsModel exploreMomentsModel
                  in exploreMomentsList) {
                if (e.owner == exploreMomentsModel.owner) {
                  isUniqueUser = false;
                  break;
                }
              }

              if (isUniqueUser) {
                exploreMomentsList.add(e);
              }
            } else {
              exploreMomentsList.add(e);
            }
          }
        }

        // for (int i = 0; i < exploreMomentsList.length; i++) {
        //   for (int j = 0; j <= exploreMomentsList[i].moments!.length; j++) {
        //     setState(() {
        //       listOfMoments?.add(exploreMomentsList[i].moments![j]);
        //     });
        //   }
        //   debugPrint('beeetttttt....${exploreMomentsList[i].moments!.length}');
        //   debugPrint('list of momentssss....${listOfMoments!.length}');
        // }
        if (mounted) setState(() {});

        debugPrint(
            ' MOMENT LOADING --> ${!isContactMomentsLoading && !isExploreMomentsLoading}');

        debugPrint(
            ' MOMENT EMPTY ${contactMomentsList.isEmpty && exploreMomentsList.isEmpty}');

        if (isFirstTimeExplore &&
            nextExploreMoments != null &&
            nextExploreMoments != "") {
          isFirstTimeExplore = false;
          getExploreMoments();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: scaffoldBody(),
    );
  }

  Widget comingSoonWidget() {
    return Center(
      child: Lottie.asset(comingSoonLottie),
    );
  }

  AppBar appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 16,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, "back pressed");
        },
      ),
      title: Text(
        AppLocalization.of(context)!.moments,
        style: TextStyle(
          color: blackFont,
          fontSize: 20,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            SlydoAppIcon.search,
            color: darkGrey,
            size: 14,
          ),
          onPressed: () {
            NavigationUtil.push(context, screen: const MomentSearchScreen());
          },
        ),
        addMomentsBtn(),
        const SizedBox(width: 10),
        myMomentsBtn(),
        const SizedBox(width: 14),
      ],
    );
  }

  Widget addMomentsBtn() {
    final PermissionType? hasPermission =
        userBloc.user.hasWritePermission(ProtectionPermission.moment);
    return InkWell(
      onTap: () async {
        if (hasPermission == PermissionType.WRITE) {
          NavigationUtil.push(context, screen: const CreateMediaMomentScreen());
        } else {
          showSnackbar(context,
              message: AppLocalization.of(context)?.doNotPermission ?? "");
        }
      },
      child: Icon(
        Icons.camera_alt_rounded,
        size: 22,
        color: blackFont,
      ),
    );
  }

  Widget myMomentsBtn() {
    return InkWell(
      onTap: myMomentsLoading
          ? null
          : () {
              getCurrentUserMoment();
            },
      child: myMomentsLoading
          ? Center(
              child: SizedBox(
                  width: 30, height: 30, child: CircularLoadingIndicator()),
            )
          : MomentsUtils().getUserProfilePic(
              userBloc.user.avatar!, userBloc.user.fullName!),
    );
  }

  Widget scaffoldBody() {
    if (storageIsNull) {
      return const Center(
        child:
            Text('We experienced a fault. Please restart app to view moments.'),
      );
    }
    if (appConfigurationModel?.enableMoment == false) {
      return comingSoonWidget();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(
          complete: Container(),
          waterDropColor: navyBlue,
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: ListView(
          controller: _exploreScrollController,
          children: [
            contactMomentsListWidget(),
            const SizedBox(height: 16),
            adverts(),
            const SizedBox(height: 16),
            exploreMomentsListWidget(),
            if (isExploreMomentsLoading)
              Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor: greyBorderColor,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisExtent: 300,
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
            Visibility(
              visible: !isContactMomentsLoading &&
                  !isExploreMomentsLoading &&
                  contactMomentsList.isEmpty &&
                  exploreMomentsList.isEmpty,
              child: Center(
                child: Column(
                  children: [
                    Lottie.asset('assets/lottie/no_moment_lottie.json'),
                    const SizedBox(height: 20),
                    const Text(
                        'Create a moment with the camera icon at the top.'),
                    const Text('Pull down to refresh to see latest moments.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget adverts() {
    if (!hasAdverts) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advert',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: blackFont,
            fontSize: 16,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          width: MediaQuery.of(context).size.width,
          child: Card(
            color: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        )
      ],
    );
  }

  Widget contactMomentsListWidget() {
    if (nextContactMoments == '' && isContactMomentsLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.white,
        highlightColor: greyBorderColor,
        child: SizedBox(
          height: 180,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 120,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      if (contactMomentsList.isEmpty) {
        return const SizedBox.shrink();
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: navyBlue,
                  child: const Icon(
                    Icons.group,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "My Friends",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: blackFont,
                    // fontSize: 16,P
                    fontFamily: "Inter",
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                shrinkWrap: true,
                controller: _myConnectionsScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: contactMomentsList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == contactMomentsList.length) {
                    return buildLoadingIndicator(
                        isLoading: isContactMomentsLoading);
                  } else {
                    return ContactMomentsCard(
                      index: index,
                      nextPageUrl: nextContactMoments,
                      userMomentModel: contactMomentsList[index],
                      listOfConnectionsNames:
                          contactMomentsList.map((e) => e.owner!).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        );
      }
    }
  }

  Widget exploreMomentsListWidget() {
    if (exploreMomentsList.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.explore,
              color: navyBlue,
              size: 24,
            ),
            const SizedBox(width: 6),
            Text(
              "Explore",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: blackFont,
                fontSize: 16,
                fontFamily: "Inter",
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (nextExploreMoments == "" && isExploreMomentsLoading)
          const SizedBox.shrink()
        else
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              mainAxisExtent: 300,
              maxCrossAxisExtent: 200,
            ),
            itemCount: exploreMomentsList.length,
            itemBuilder: (context, index) {
              return ExploreMomentsCard(
                index: index,
                exploreMomentsModelList: exploreMomentsList,
              );
            },
          ),
      ],
    );
  }

  void getCurrentUserMoment() {
    myMomentsLoading = true;
    if (mounted) setState(() {});
    MomentsService()
        .getMomentsWithOwnerName(
            ownerName: userBloc.user.userName!, channelUsername: '')
        .then((momentsModelList) {
      myMomentsLoading = false;
      if (mounted) setState(() {});
      if (momentsModelList.isNotEmpty) {
        NavigationUtil.push(
          context,
          screen: MomentsDetailsScreen(
            indexOfMoment: 0,
            // Wrapping it around a List ([]) because the moment detail screen requires a List<List<MomentModel>>
            momentsModelList: [momentsModelList],
          ),
        );
      } else {
        showToast(message: 'You do not have any moment.');
      }
    }).catchError((e) {
      myMomentsLoading = false;
      if (mounted) setState(() {});
      showToast(message: 'ERROR -> $e');
    });
  }
}

class ContactMomentsCard extends StatefulWidget {
  final int index;
  final String? nextPageUrl;
  final MomentsModel userMomentModel;
  final List<String> listOfConnectionsNames;

  ContactMomentsCard({
    super.key,
    required this.index,
    required this.nextPageUrl,
    required this.userMomentModel,
    required this.listOfConnectionsNames,
  });

  @override
  State<ContactMomentsCard> createState() => _ContactMomentsCardState();
}

class _ContactMomentsCardState extends State<ContactMomentsCard> {
  int? lengthOfOwnerMoments;
  bool isConnectionsMomentLoading = false;
  final List<List<MomentsModel>> listOfMomentsModelList = [];

  Future getListOfMomentsModelList(String owner) async {
    final List<MomentsModel> momentsModelList = await MomentsService()
        .getMomentsWithOwnerName(ownerName: owner, channelUsername: '');
    listOfMomentsModelList.add(momentsModelList);
  }

  Future getLengthOfOwnerMoments(String owner) async {
    final List<MomentsModel> momentsModelList = await MomentsService()
        .getMomentsWithOwnerName(ownerName: owner, channelUsername: '');
    lengthOfOwnerMoments = momentsModelList.length;
  }

  @override
  void initState() {
    super.initState();
    getLengthOfOwnerMoments(widget.userMomentModel.owner!);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        NavigationUtil.push(
          context,
          screen: MomentsDetailsScreen(
            nextPageUrl: widget.nextPageUrl,
            indexOfMoment: widget.index,
            listOfConnectionNames: widget.listOfConnectionsNames,
          ),
        );
      },
      child: SizedBox(
        width: 120,
        child: Card(
          color: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _getMediaRenderer(
                  momentModel: widget.userMomentModel, context: context),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 2.0, top: 5.0),
                  child: MomentsUtils().getUserProfilePic(
                      widget.userMomentModel.avatar!,
                      widget.userMomentModel.ownerName!),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      userNameWithVerifiedIcon(
                        name: widget.userMomentModel.ownerName!,
                        isVerified: false,
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              blurRadius: 4.0,
                              color: blackFont,
                              offset: const Offset(0.0, 0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        getFormattedViewCount(
                            noOfViews: widget.userMomentModel.views),
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
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: isConnectionsMomentLoading
                    ? CircleAvatar(
                        backgroundColor: greyBorderColor,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              if (widget.userMomentModel.mediaType == 'video')
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: SvgPicture.asset("yarn/cam_vec".toSVG()),
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class ExploreMomentsCard extends StatefulWidget {
  // This index is the position of the 'ExploreMomentsCard' in the list 0f explore moments.
  final int index;
  final Function()? onTap;
  final bool showProfileAvatar;
  final List<ExploreMomentsModel> exploreMomentsModelList;

  ExploreMomentsCard(
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

Widget momentListLengthWidget(int? length, {double? fontSize}) {
  return length == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.3),
            ),
            child: Text(
              '$length',
              style: TextStyle(
                  fontSize: fontSize,
                  fontFamily: "Inter",
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ),
        );
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

String getTime(String dateTime) {
  return DateFormat.jm().format(DateTime.parse(dateTime));
}

Color getProfilePicBorderColor(User user) {
  return blackFont;
  debugPrint('USER TYPE -> ${user.type}');
  return user.type!.toLowerCase() != "user"
      ? user.type!.toLowerCase() != "business"
          ? starYellow
          : naturalGreen
      : navyBlue;
}
