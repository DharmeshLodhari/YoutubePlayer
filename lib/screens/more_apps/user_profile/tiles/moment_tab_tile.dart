import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/screens/moments/screens/moment_detail/moment_detail_page.dart';
import 'package:Slydo/screens/moments/screens/moments_screen.dart';
import 'package:Slydo/screens/moments/screens/moments_service.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class MomentsTab extends StatefulWidget {
  CustomerProfile? searchedUser;
  String? channelUsername;
  MomentsTab({super.key, required this.searchedUser, this.channelUsername});

  @override
  State<MomentsTab> createState() => _MomentsTabState();
}

class _MomentsTabState extends State<MomentsTab> {
  bool isFirstTime = true;
  String? myMomentsNext = "";
  int? myMomentsCount = 0;
  bool isMyMomentsLoading = false;
  List<MomentsModel> myMomentsList = [];
  final ScrollController _myMomentsScrollController = ScrollController();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();

    getSearchedUserMoments();
  }

  void getSearchedUserMoments() async {
    if (!isMyMomentsLoading) {
      if (myMomentsNext != null && !isMyMomentsLoading) {
        if (mounted) {
          setState(() {
            isMyMomentsLoading = true;
          });
        }

        if (widget.searchedUser != null) {
          await MomentsService()
              .getMomentsWithOwnerName(
                  ownerName: widget.searchedUser!.userName!,
                  channelUsername: widget.channelUsername ?? '')
              .then(
            (myMomentsModelList) {
              isMyMomentsLoading = false;
              myMomentsList.addAll(myMomentsModelList);

              if (mounted) setState(() {});

              if (isFirstTime && myMomentsNext != null && myMomentsNext != "") {
                isFirstTime = false;
                getSearchedUserMoments();
              }
            },
          ).catchError(
            (error) {
              isMyMomentsLoading = false;

              if (mounted) setState(() {});
              debugPrint('ERROR GETTING MY MOMENTS -> $error');
            },
          );
        }
      }
    }
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
    isFirstTime = true;
    myMomentsNext = "";
    myMomentsCount = 0;
    isMyMomentsLoading = false;
    myMomentsList = [];
    if (mounted) setState(() {});
    getSearchedUserMoments();
  }

  @override
  Widget build(BuildContext context) {
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
        child: myMomentsList.isEmpty
            ? NoItemInList(
                msg: AppLocalization.of(context)!.noMoments,
              )
            : ListView(
                controller: _myMomentsScrollController,
                children: [
                  const SizedBox(height: 16),
                  if (isMyMomentsLoading)
                    Shimmer.fromColors(
                      baseColor: Colors.white,
                      highlightColor: greyBorderColor,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
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
                  myMomentsListWidget(),
                ],
              ),
      ),
    );
  }

  bool momentClicked = false;

  Widget myMomentsListWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (myMomentsNext == "" && isMyMomentsLoading)
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
            itemCount: myMomentsList.length,
            itemBuilder: (context, index) {
              return ExploreMomentsCard(
                index: index,
                showProfileAvatar: false,
                onTap: () {
                  if (momentClicked == true) return;
                  momentClicked = true;
                  if (mounted) setState(() {});
                  MomentsService()
                      .getSingleMoment(momentId: myMomentsList[index].id!)
                      .then((momentsModelList) {
                    momentClicked = false;
                    if (mounted) setState(() {});

                    NavigationUtil.push(
                      context,
                      screen: MomentsDetailsScreen(
                        indexOfMoment: 0,
                        // Wrapping it around a List ([]) because the moment detail screen requires a List<List<MomentModel>>
                        momentsModelList: [momentsModelList],
                      ),
                    );
                  }).catchError((e) {
                    momentClicked = false;
                    if (mounted) setState(() {});

                    showToast(message: 'ERROR -> $e');
                  });
                },
                exploreMomentsModelList: myMomentsList
                    .map(
                      (e) => ExploreMomentsModel(
                        owner: e.owner,
                        avatar: e.avatar,
                        moments: [myMomentsList[index]],
                        // ownerName: e.ownerName,
                      ),
                    )
                    .toList(),
              );
            },
          ),
      ],
    );
  }
}
