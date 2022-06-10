import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/moments/moments_model.dart';
import 'package:Slydo/screens/moments/moments_service.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../constant.dart';
import '../../locale/app_localization.dart';
import '../../main.dart';
import '../../utils/slydo_app_icon_icons.dart';
import '../../utils/util.dart';
import 'moments_view.dart';

class MomentsScreen extends StatefulWidget {
  const MomentsScreen({Key? key}) : super(key: key);

  @override
  State<MomentsScreen> createState() => _MomentsScreenState();
}

const String comingSoonLottie = 'assets/lottie/coming_soon_lottie.json';

class _MomentsScreenState extends State<MomentsScreen> {
  bool isFirstTimeContact = true;
  bool isFirstTimeExplore = true;
  bool hasAdverts = false;
  List exploreMomentList = [];
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
  List<MomentsModel> exploreMomentsList = [];
  List<UserMomentsModel> contactMomentsList = [];
  ScrollController _myConnectionsScrollController = ScrollController();
  ScrollController _exploreScrollController = ScrollController();

  AppConfigurationModel? appConfigurationModel;

  @override
  void initState() {
    super.initState();
    getContactMoments();
    getExploreMoments();
    getAppConfigurationModelFromLocalStorage();

    _myConnectionsScrollController.addListener(() {
      if (_myConnectionsScrollController.position.pixels ==
              _myConnectionsScrollController.position.maxScrollExtent &&
          _myConnectionsScrollController.position.pixels != 0) {
        getContactMoments();
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
    _exploreScrollController.dispose();
    _myConnectionsScrollController.dispose();
    super.dispose();
  }

  getAppConfigurationModelFromLocalStorage() async {
    String? str = await storage.read(key: appConfigurationKey);
    appConfigurationModel = AppConfigurationModel.deserialize(str!);
  }

  getContactMoments() async {
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
          getContactMoments();
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
        AppLocalization.of(context)!.moment,
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
      onTap: () {},
      child: Container(
        width: 32,
        margin: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.6),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          Icons.add,
          color: blackFont,
        ),
      ),
    );
  }

  Widget myMomentsBtn() {
    return InkWell(
      onTap: () {},
      child: Container(
        width: 30,
        height: 30,
        child: Icon(
          Icons.person,
          color: blackFont,
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
    if (isContactMomentsLoading) {
      return Center(child: CircularLoadingIndicator());
    }

    if (contactMomentsList.isEmpty) {
      return SizedBox.shrink();
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
          height: 140,
          child: ListView.builder(
            controller: _myConnectionsScrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(vertical: 4),
            itemCount: contactMomentsList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == contactMomentsList.length) {
                return buildIndicator(isLoading: isContactMomentsLoading);
              } else {
                return ContactMomentsCard(
                  userMomentsModel: contactMomentsList[index],
                );
              }
            },
          ),
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

  Widget exploreMomentsListWidget() {
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
        SizedBox(
          height: 140,
          child: ListView.builder(
            controller: _exploreScrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(vertical: 4),
            itemCount: exploreMomentsList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == exploreMomentsList.length) {
                return buildIndicator(isLoading: isExploreMomentsLoading);
              } else {
                return ExploreMomentsCard(
                  momentsModel: exploreMomentsList[index],
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class ContactMomentsCard extends StatelessWidget {
  final UserMomentsModel userMomentsModel;

  const ContactMomentsCard({Key? key, required this.userMomentsModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        var data = {
          'momentUrl': AppConfig.baseUrl +
              '/api/v1/social/moments/user/${userMomentsModel.owner}/'
        };

        NavigationUtil.push(
          context,
          screen: MomentsView(),
        );
      },
      child: SizedBox(
        width: 140,
        child: Card(
          color: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: userMomentsModel.avatar!,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              truncateString(
                                str: userMomentsModel.ownerName!,
                                lengthToTruncateAt: 14,
                              ),
                              style: TextStyle(color: blackFont),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3),
                      Text(
                        getTime(userMomentsModel.createdAt!),
                        style: TextStyle(color: blackFont),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ExploreMomentsCard extends StatelessWidget {
  final MomentsModel momentsModel;
  const ExploreMomentsCard({Key? key, required this.momentsModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        NavigationUtil.push(context, screen: MomentsView());
      },
      child: SizedBox(
        width: 100,
        child: Stack(
          children: [
            getMediaRenderer(momentsModel: momentsModel),
          ],
        ),
      ),
    );
  }

  Widget getMediaRenderer({required MomentsModel momentsModel}) {
    print('TYPE:: ${momentsModel.mediaType}');
    if (momentsModel.mediaType == "image") {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: momentsModel.media!,
            height: 100,
          ),
        ),
      );
    } else if (momentsModel.mediaType == "video") {
      return Text('VIDEO');
    } else {
      return Text(momentsModel.mediaType!);
    }
  }
}

String getTime(String dateTime) {
  return DateFormat.jm().format(DateTime.parse(dateTime));
}
