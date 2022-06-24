import 'dart:io';
import 'dart:math';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/moments/create_moment_screen.dart';
import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/screens/moments/moments_service.dart';
import 'package:Slydo/screens/moments/moment_detail_page.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../constant.dart';
import '../../data/state_notifier.dart';
import '../../locale/app_localization.dart';
import '../../main.dart';
import '../../utils/slydo_app_icon_icons.dart';
import '../../utils/util.dart';
import '../../utils/video_player_controller/chewie_player.dart';

class MomentsScreen extends StatefulWidget {
  const MomentsScreen({Key? key}) : super(key: key);

  @override
  State<MomentsScreen> createState() => _MomentsScreenState();
}

const String comingSoonLottie = 'assets/lottie/coming_soon_lottie.json';

class _MomentsScreenState extends State<MomentsScreen> {
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
  String? previousContactMoments = "";
  String? previousExploreMoments = "";
  bool isContactMomentsLoading = false;
  bool isExploreMomentsLoading = false;
  List<ExploreMomentsModel> exploreMomentsList = [];
  List<MomentsModel> contactMomentsList = [];
  ScrollController _myConnectionsScrollController = ScrollController();
  ScrollController _exploreScrollController = ScrollController();

  AppConfigurationModel? appConfigurationModel;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    getConnectionMoments();
    getExploreMoments();
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
    String? str = await storage.read(key: appConfigurationKey);
    appConfigurationModel = AppConfigurationModel.deserialize(str!);
    debugPrint('APP CONFIGURATION MOD -> $appConfigurationModel');
    if (mounted) setState(() {});
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
          nextContactMoments,
          previousContactMoments,
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
            await NavigationUtil.push(context, screen: AddVideo());

        if (momentCreated == true) {
          _refreshPage();
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.grey,
        ),
        child: const Icon(
          Icons.camera_alt_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget myMomentsBtn() {
    return InkWell(
      onTap: () {
        getCurrentUserMoment();
      },
      child: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(
          userBloc.user.avatar!,
        ),
      ),
    );
  }

  Widget scaffoldBody() {
    if (appConfigurationModel == null) {
      return Center(child: CircularLoadingIndicator());
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
          children: [
            CustomizedTextFormField(
              hintText: 'Search',
              suffixIcon: IconButton(
                icon: Icon(
                  SlydoAppIcon.search,
                  color: darkGrey,
                  size: 14,
                ),
                onPressed: () {},
              ),
            ),
            SizedBox(height: 16),
            contactMomentsListWidget(),
            SizedBox(height: 16),
            adverts(),
            SizedBox(height: 16),
            exploreMomentsListWidget(),
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
                  color: Colors.red,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "My Connections",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: blackFont,
            fontSize: 16,
          ),
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
    if (nextExploreMoments == "" && isExploreMomentsLoading) {
      return Shimmer.fromColors(
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
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Explore",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: blackFont,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisExtent: 300,
          ),
          itemCount: exploreMomentsList.length + 1,
          itemBuilder: (context, index) {
            if (index == exploreMomentsList.length) {
              return buildIndicator(isLoading: isExploreMomentsLoading);
            } else {
              return ExploreMomentsCard(
                index: index,
                exploreMomentsModelList: exploreMomentsList,
              );
            }
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
    MomentsService()
        .getMomentsWithOwnerName(owner: userBloc.user.userName!)
        .then((momentsModelList) {
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
      showToast(message: 'ERROR -> $e');
    });
  }
}

class ContactMomentsCard extends StatelessWidget {
  final int index;
  final MomentsModel userMomentModel;
  final List<String> listOfConnectionsNames;

  ContactMomentsCard({
    Key? key,
    required this.index,
    required this.userMomentModel,
    required this.listOfConnectionsNames,
  }) : super(key: key);

  final List<List<MomentsModel>> listOfMomentsModelList = [];

  Future getListOfMomentsModelList(String owner) async {
    List<MomentsModel> momentsModelList =
        await MomentsService().getMomentsWithOwnerName(owner: owner);
    listOfMomentsModelList.add(momentsModelList);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        for (int i = 0; i < listOfConnectionsNames.length; i++) {
          await getListOfMomentsModelList(listOfConnectionsNames[i]);

          if (listOfConnectionsNames[i] == listOfConnectionsNames.last) {
            NavigationUtil.push(
              context,
              screen: MomentsDetailsScreen(
                indexOfMoment: index,
                momentsModelList: listOfMomentsModelList,
              ),
            );
          }
        }
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
              _getMediaRenderer(momentModel: userMomentModel),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: userMomentModel.avatar!,
                          ),
                        ),
                      ),
                      Text(
                        truncateString(
                          str: userMomentModel.ownerName!,
                          lengthToTruncateAt: 10,
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 3),
                      Text(
                        getTime(userMomentModel.createdAt!),
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
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
                momentModel: exploreMomentsModelList[index].moments!.first),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: exploreMomentsModelList[index].avatar!,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      truncateString(
                        str: exploreMomentsModelList[index].ownerName!,
                        lengthToTruncateAt: 20,
                      ),
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          backgroundColor: blackFont.withOpacity(0.15)),
                    ),
                    SizedBox(height: 3),
                    Text(
                      getTime(exploreMomentsModelList[index]
                          .moments!
                          .first
                          .createdAt!),
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          backgroundColor: blackFont.withOpacity(0.15)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _getMediaRenderer({required MomentsModel momentModel}) {
  if (momentModel.mediaPoster != null) {
    debugPrint('POSTER :: ${momentModel.mediaPoster}');
  }
  if (momentModel.gif != null) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: momentModel.gif!,
        fit: BoxFit.cover,
      ),
    );
  }
  if (momentModel.mediaType == "image") {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: momentModel.media!,
        fit: BoxFit.cover,
      ),
    );
  }
  if (momentModel.mediaType == "video") {
    // return Container();

    if (momentModel.mediaPoster != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: momentModel.mediaPoster!,
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
