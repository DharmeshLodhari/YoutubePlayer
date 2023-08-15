import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/screens/moments/screens/create_moment_screen.dart';
import 'package:Slydo/screens/moments/screens/moment_detail/moment_detail_page.dart';
import 'package:Slydo/screens/moments/screens/moments_service.dart';
import 'package:Slydo/screens/moments/utils.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/state_notifier.dart';
import '../../../locale/app_localization.dart';
import '../../../locator.dart';
import '../../../services/app_config_bloc.dart';
import '../../../utils/slydo_app_icon_icons.dart';
import '../../../utils/util.dart';
import '../../more_apps/user_profile/models/user.dart';
import 'moment_search_screen.dart';

class MomentsScreen extends StatefulWidget {
  const MomentsScreen({Key? key}) : super(key: key);

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
  ScrollController _myConnectionsScrollController = ScrollController();
  ScrollController _exploreScrollController = ScrollController();

  RefreshController _refreshController =
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
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        _refreshPage();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
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

  getConnectionMoments() async {
    if (!isContactMomentsLoading) {
      if (nextContactMoments != null && !isContactMomentsLoading) {
        if (mounted) {
          setState(() {
            isContactMomentsLoading = true;
          });
        }
        Map<String, dynamic>? result = await MomentsService().getContactMoments(
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
        var tempList = result['results'];

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

  getExploreMoments() async {
    if (!isExploreMomentsLoading) {
      if (nextExploreMoments != null && !isExploreMomentsLoading) {
        if (mounted) {
          setState(() {
            isExploreMomentsLoading = true;
          });
        }
        Map<String, dynamic>? result = await MomentsService().getExploreMoments(
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
        var tempList = result['results'];

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

        debugPrint('EXPLORE MOM :: $exploreMomentsList');

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
      title: Text(
        AppLocalization.of(context)!.moments,
        style: TextStyle(
          color: blackFont,
          fontSize: 20,
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
            NavigationUtil.push(context, screen: MomentSearchScreen());
          },
        ),
        addMomentsBtn(),
        SizedBox(width: 10),
        myMomentsBtn(),
        SizedBox(width: 14),
      ],
    );
  }

  Widget addMomentsBtn() {
    return InkWell(
      onTap: () async {
        NavigationUtil.push(context, screen: CreateMediaMomentScreen());
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
      return Center(
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
            SizedBox(height: 16),
            adverts(),
            SizedBox(height: 16),
            exploreMomentsListWidget(),
            isExploreMomentsLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: greyBorderColor,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
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
                : SizedBox.shrink(),
            Visibility(
              visible: !isContactMomentsLoading &&
                  !isExploreMomentsLoading &&
                  contactMomentsList.isEmpty &&
                  exploreMomentsList.isEmpty,
              child: Center(
                child: Column(
                  children: [
                    Lottie.asset('assets/lottie/no_moment_lottie.json'),
                    SizedBox(height: 20),
                    Text('Create a moment with the camera icon at the top.'),
                    Text('Pull down to refresh to see latest moments.'),
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
      return SizedBox.shrink();
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
          ),
        ),
        SizedBox(height: 12),
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
            physics: NeverScrollableScrollPhysics(),
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
    }

    if (contactMomentsList.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: navyBlue,
              child: Icon(
                Icons.group,
                color: Colors.white,
                size: 14,
              ),
            ),
            SizedBox(width: 6),
            Text(
              "My Friends",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: blackFont,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            shrinkWrap: true,
            controller: _myConnectionsScrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(vertical: 4),
            itemCount: contactMomentsList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == contactMomentsList.length) {
                return buildIndicator(isLoading: isContactMomentsLoading);
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

  Widget exploreMomentsListWidget() {
    if (exploreMomentsList.isEmpty) {
      return SizedBox.shrink();
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
            SizedBox(width: 6),
            Text(
              "Explore",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: blackFont,
                fontSize: 16,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        nextExploreMoments == "" && isExploreMomentsLoading
            ? SizedBox.shrink()
            : GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
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

  Widget buildIndicator({required bool isLoading}) {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: CircularLoadingIndicator(),
        ),
      ),
    );
  }

  void getCurrentUserMoment() {
    myMomentsLoading = true;
    if (mounted) setState(() {});
    MomentsService()
        .getMomentsWithOwnerName(ownerName: userBloc.user.userName!)
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
    Key? key,
    required this.index,
    required this.nextPageUrl,
    required this.userMomentModel,
    required this.listOfConnectionsNames,
  }) : super(key: key);

  @override
  State<ContactMomentsCard> createState() => _ContactMomentsCardState();
}

class _ContactMomentsCardState extends State<ContactMomentsCard> {
  int? lengthOfOwnerMoments;
  bool isConnectionsMomentLoading = false;
  final List<List<MomentsModel>> listOfMomentsModelList = [];

  Future getListOfMomentsModelList(String owner) async {
    List<MomentsModel> momentsModelList =
        await MomentsService().getMomentsWithOwnerName(ownerName: owner);
    listOfMomentsModelList.add(momentsModelList);
  }

  Future getLengthOfOwnerMoments(String owner) async {
    List<MomentsModel> momentsModelList =
        await MomentsService().getMomentsWithOwnerName(ownerName: owner);
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
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              blurRadius: 4.0,
                              color: blackFont,
                              offset: Offset(0.0, 0),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        getFormattedViewCount(
                            noOfViews: widget.userMomentModel.views),
                        style: TextStyle(
                          fontSize: 12,
                          shadows: [
                            Shadow(
                              blurRadius: 4.0,
                              color: blackFont,
                              offset: Offset(0.0, 0),
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
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : SizedBox.shrink(),
              ),
              widget.userMomentModel.mediaType == 'video'
                  ? Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: SvgPicture.asset("yarn/cam_vec".toSVG()),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class ExploreMomentsCard extends StatelessWidget {
  // This index is the position of the 'ExploreMomentsCard' in the list 0f explore moments.
  final int index;
  final Function()? onTap;
  final bool showProfileAvatar;
  final List<ExploreMomentsModel> exploreMomentsModelList;
  const ExploreMomentsCard(
      {Key? key,
      this.onTap,
      this.showProfileAvatar =
          true, // We do not show profile avatar on profile page moment's tab.
      required this.index,
      required this.exploreMomentsModelList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          NavigationUtil.push(
            context,
            screen: MomentsDetailsScreen(
              indexOfMoment: index,
              momentsModelList:
                  exploreMomentsModelList.map((e) => e.moments!).toList(),
            ),
          );
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
              momentModel: exploreMomentsModelList[index].moments!.first,
              context: context,
            ),
            showProfileAvatar
                ? Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 10),
                      child: MomentsUtils().getUserProfilePic(
                          exploreMomentsModelList[index].avatar!,
                          exploreMomentsModelList[index].ownerName!),
                    ),
                  )
                : SizedBox.shrink(),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    userNameWithVerifiedIcon(
                      name: exploreMomentsModelList[index].ownerName ?? '',
                      isVerified: false,
                      textStyle: TextStyle(
                        fontSize: 12,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: blackFont,
                            offset: Offset(0.0, 0),
                          ),
                        ],
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      getFormattedViewCount(
                          noOfViews:
                              exploreMomentsModelList[index].moments![0].views),
                      style: TextStyle(
                        fontSize: 12,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: blackFont,
                            offset: Offset(0.0, 0),
                          ),
                        ],
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            exploreMomentsModelList[index].moments!.first.mediaType == 'video'
                ? Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 12.0),
                      child: SvgPicture.asset("yarn/cam_vec".toSVG()),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

Widget momentListLengthWidget(int? length, {double? fontSize}) {
  return length == null
      ? SizedBox.shrink()
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
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ),
        );
}

Widget _getMediaRenderer(
    {required MomentsModel momentModel, required BuildContext context}) {
  debugPrint('POSTER --> ${momentModel.ownerName}');
  debugPrint('POSTER --> ${momentModel.mediaPoster}');
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
          color: Color(0XFFdcdcdc).withOpacity(0.5),
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
