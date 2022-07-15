import 'package:Slydo/screens/moments/create_moment_screen.dart';
import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/screens/moments/moment_detail_page.dart';
import 'package:Slydo/screens/moments/moments_service.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../constant.dart';
import '../../data/state_notifier.dart';
import '../../locale/app_localization.dart';
import '../../services/app_config_bloc.dart';
import '../../utils/slydo_app_icon_icons.dart';
import '../../utils/util.dart';
import '../more_apps/user_profile/models/user.dart';
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
    debugPrint('MOMENT INIT STATE');
    getAppConfigurationModelFromLocalStorage();

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

  getAppConfigurationModelFromLocalStorage() async {
    final getStorage = GetStorage(appFeaturesKey);

    var str = await getStorage.read(appFeaturesKey);
    debugPrint('GETTING APP FEATURES STR -> $str');

    if (str == null) {
      await AppFeaturesService().getAppFeatures().then(
        (value) async {
          debugPrint('APP MOMENT FEATURES ::: $value');

          await getStorage.write(
            appFeaturesKey,
            AppConfigurationModel.serialize(value!),
          );

          debugPrint(
              'APP FEATURES VALUE ::: ${getStorage.read(appFeaturesKey)}');
          appConfigurationModel = value;
        },
      );

      if (appConfigurationModel?.enableMoment == true) {
        getConnectionMoments();
        getExploreMoments();
      } else {
        // enableMoment is false, change the view to reflect that.
        setState(() {});
      }
    } else {
      appConfigurationModel = AppConfigurationModel.deserialize(str!);
      getConnectionMoments();
      getExploreMoments();
    }
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
        exploreMomentsList.addAll(tempList);

        debugPrint('EXPLORE MOM :: $exploreMomentsList');

        if (mounted) setState(() {});

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
        var momentCreated =
            await NavigationUtil.push(context, screen: CreateMomentScreen());

        if (momentCreated == true) {
          _refreshPage();
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
          : getCircularUserAvatar(userBloc.user.avatar!),
    );
  }

  Widget scaffoldBody() {
    if (storageIsNull) {
      return Center(
        child:
            Text('We experienced a fault. Please restart app to view moments.'),
      );
    }
    if (appConfigurationModel == null) {
      return Center(child: CircularLoadingIndicator());
    }
    if (appConfigurationModel!.enableMoment == false) {
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
            InkWell(
              onTap: () {
                NavigationUtil.push(context, screen: MomentSearchScreen());
              },
              child: IgnorePointer(
                child: CustomizedTextFormField(
                  hintText: 'Search moment',
                  suffixIcon: IconButton(
                    icon: Icon(
                      SlydoAppIcon.search,
                      color: darkGrey,
                      size: 14,
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
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
                : SizedBox.shrink()
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
            // CircleAvatar(
            //   radius: 15,
            //   backgroundColor: navyBlue,
            //   child: Image.asset(
            //     'assets/images/my_moment_connections_icons.png',
            //     color: Colors.white,
            //     width: 40,
            //   ),
            // ),
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
              "My Connections",
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
        // isExploreMomentsLoading
        //     ? SizedBox.shrink()
        //     : exploreMomentsList.isEmpty
        //         ? Text(
        //             'There are no moments to explore right now.',
        //             style: TextStyle(
        //                 color: blackFont, fontWeight: FontWeight.w700),
        //           )
        //         : SizedBox.shrink(),
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
        .getMomentsWithOwnerName(owner: userBloc.user.userName!)
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
        await MomentsService().getMomentsWithOwnerName(owner: owner);
    listOfMomentsModelList.add(momentsModelList);
  }

  Future getLengthOfOwnerMoments(String owner) async {
    List<MomentsModel> momentsModelList =
        await MomentsService().getMomentsWithOwnerName(owner: owner);
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
      // onTap: isConnectionsMomentLoading
      //     ? null
      //     : () async {
      //         if (mounted) {
      //           setState(() {
      //             isConnectionsMomentLoading = true;
      //           });
      //         }
      //         for (int i = 0; i < widget.listOfConnectionsNames.length; i++) {
      //           await getListOfMomentsModelList(
      //               widget.listOfConnectionsNames[i]);
      //
      //           if (widget.listOfConnectionsNames[i] ==
      //               widget.listOfConnectionsNames.last) {
      //             if (mounted) {
      //               setState(() {
      //                 isConnectionsMomentLoading = false;
      //               });
      //             }
      //             NavigationUtil.push(
      //               context,
      //               screen: MomentsDetailsScreen(
      //                 indexOfMoment: widget.index,
      //                 momentsModelList: listOfMomentsModelList,
      //               ),
      //             );
      //           }
      //         }
      //       },
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
                  padding: const EdgeInsets.only(left: 4.0),
                  child: SizedBox(
                    width: 25,
                    child:
                        getCircularUserAvatar(widget.userMomentModel.avatar!),
                  ),
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
                      Text(
                        truncateString(
                          str: widget.userMomentModel.ownerName!,
                          lengthToTruncateAt: 14,
                        ),
                        style: TextStyle(
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
              // Align(
              //   alignment: Alignment.topRight,
              //   child: momentListLengthWidget(
              //     lengthOfOwnerMoments,
              //     fontSize: 12,
              //   ),
              // ),
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
  final List<ExploreMomentsModel> exploreMomentsModelList;
  const ExploreMomentsCard(
      {Key? key, required this.index, required this.exploreMomentsModelList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        NavigationUtil.push(
          context,
          screen: MomentsDetailsScreen(
            indexOfMoment: index,
            momentsModelList:
                exploreMomentsModelList.map((e) => e.moments!).toList(),
          ),
        );
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
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: SizedBox(
                  width: 25,
                  child: getCircularUserAvatar(
                      exploreMomentsModelList[index].avatar!),
                ),
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
                    Text(
                      truncateString(
                        str: exploreMomentsModelList[index].ownerName!,
                        lengthToTruncateAt: 20,
                      ),
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
            // Align(
            //   alignment: Alignment.topRight,
            //   child: momentListLengthWidget(
            //     exploreMomentsModelList[index].moments!.length,
            //   ),
            // ),
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
  if (momentModel.mediaPoster != null) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: momentModel.mediaPoster!,
        fit: BoxFit.fill,
        memCacheHeight: (MediaQuery.of(context).size.height * 0.8).toInt(),
      ),
    );
  }
  // Image.asset(
  //   'assets/images/moment_placeholder_image.png',
  //   fit: BoxFit.cover,
  // ),
  if (momentModel.mediaType == "image") {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: momentModel.media!,
        fit: BoxFit.cover,
        memCacheHeight: (MediaQuery.of(context).size.height * 0.8).toInt(),
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
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/moment_placeholder_image.png',
          fit: BoxFit.cover,
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
