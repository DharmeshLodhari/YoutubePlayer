import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/service_hub/auth/service_hub_auth.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/applicant_list_model.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/jobs.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../utils/colors.dart';

class ApplicantList extends StatefulWidget {
  const ApplicantList({Key? key, this.job}) : super(key: key);
  final JobModel? job;

  @override
  State<ApplicantList> createState() => _ApplicantListState();
}

class _ApplicantListState extends State<ApplicantList> {
  SlidableController _slideController = SlidableController();
  JobApplicantModel? applicants;

  bool isLoading = false;
  String? listNext = "";
  String? listPrevious = "";
  bool noApplicantInList = false;

  int? listCount = 0;
  int currentIndex = 0;
  late AppLocalization appLocalization;
  List<JobApplicantModel> applicantList = [];

  // late UserBloc userBloc;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void getApplicantList() async {
    if (!isLoading) {
      if (listNext != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        var result = await ServiceHubAuthService().getApplicantListData(
            listNext, listPrevious,
            jobId: widget.job!.id);

        if (result == null) {
          noApplicantInList = true;

          isLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        // listCount = result.count;
        // listNext = result.next;
        // listPrevious = result.previous;
        // var tempList = result;
        if (mounted) {
          setState(() {
            // noJobsInPostedList = false;

            applicantList.addAll(result);
            isLoading = false;
          });
        }
      }
      if (applicantList.isEmpty) {
        if (mounted) {
          setState(() {
            noApplicantInList = true;
          });
        }
      } else if (listNext == null && applicantList.length > 6) {
        // _productScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
        //   content:
        //       Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
        //   duration: Duration(milliseconds: 500),
        // ));
      }
    }
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
    listNext = "";
    listPrevious = "";
    listCount = 0;
    currentIndex = 0;
    isLoading = false;
    applicantList = [];
    getApplicantList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getApplicantList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: appBar(),
      body: SmartRefresher(
        controller: _refreshController,
        header: WaterDropHeader(
          complete: Container(),
          waterDropColor: navyBlue,
        ),
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              getAppicantListView(),
              isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.white,
                      highlightColor: greyBorderColor,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          mainAxisSpacing: 14,
                          mainAxisExtent: 180,
                          crossAxisSpacing: 15,
                          maxCrossAxisExtent: 200,
                        ),
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          return Card(
                            color: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
              Visibility(
                visible: !isLoading && applicantList.isEmpty,
                child: Center(
                  child: Column(
                    children: [
                      Lottie.asset('assets/lottie/no_moment_lottie.json'),
                      const SizedBox(height: 20),
                      const Text('No items at the moment'),
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

  Flexible getAppicantListView() {
    return Flexible(
      fit: FlexFit.loose,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: applicantList.length,
        itemBuilder: (context, index) {
          return _getSlidableWithLists(context, index);
        },
      ),
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
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Applicant",
        style: TextStyle(
          color: blackFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      // actions: [
      //   _filterBtn(),
      //   SizedBox(
      //     width: 12,
      //   )
      // ],
      // bottom: tabBar() as PreferredSizeWidget,
    );
  }

  Future<void> acceptApplicantAlert(int index) async {
    bool? result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: const Color(0xff46ce7c).withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: const Icon(
          Icons.check,
          color: Color(0xff46ce7c),
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: const Color(0xff46ce7c),
      actionOneTextColor: Colors.white,
      actionTwoBgColor: greyBorderColor,
      actionTwoTextColor: blackFont,
      title: "Accept",
      description: "Are you sure want to accept for this User?",
      actionOneText: AppLocalization.of(context)!.accept,
      actionTwoText: AppLocalization.of(context)!.cancel,
    );
    if (result != null && result) {
      bool done = await ServiceHubAuthService()
          .acceptJobApplicant(jobId: widget.job!.id, data: {
        'applicant': applicantList[index].applicantUsername,
      });
      if (done) {
        showSnackbar(context,
            message: "Applicant accepted for Job Successfully",duration: 1000);
        applicantList.clear();
        getApplicantList();
      } else {
        showSnackbar(context,
            message: "Applicant can not be Accepted. Try again later",duration: 1000);
        applicantList.clear();
        getApplicantList();
      }

      setState(() {});
    } else {
      // _showSnackBar(context, AppLocalization.of(context)!.error);
    }
  }

  Future<void> rejectApplicantAlert(int index) async {
    bool? result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: mateRed.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          Icons.close,
          color: mateRed,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: mateRed,
      actionOneTextColor: Colors.white,
      actionTwoBgColor: greyBorderColor,
      actionTwoTextColor: blackFont,
      title: "Reject",
      description: "Are you sure want to Reject for this User?",
      actionOneText: AppLocalization.of(context)!.reject,
      actionTwoText: AppLocalization.of(context)!.cancel,
    );
    if (result != null && result) {
      bool done = await ServiceHubAuthService()
          .rejectJobApplicant(jobId: widget.job!.id, data: {
        'applicant': applicantList[index].applicantUsername,
      });
      if (done) {
        showSnackbar(context,
            message: "Applicant Rejected for Job Successfully");
        applicantList.clear();
        getApplicantList();
      } else {
        showSnackbar(context,
            message: "Applicant can not be Rejected. Please Try again later");
        applicantList.clear();
        getApplicantList();
      }
      setState(() {});
    } else {
      // _showSnackBar(context, AppLocalization.of(context)!.error);
    }
  }

  List<Widget> listActionSlideActions(int index) {
    return [
      SlideActionButton(
        backgroundColor: mateRed,
        icon: SlydoAppIcon.close_2,
        onTap: () {
          rejectApplicantAlert(index);
        },
        title: "Reject",
        slideController: _slideController,
      ),
    ];
  }

  List<Widget> listSecondaryActions(int index) {
    return [
      SlideActionButton(
        backgroundColor: const Color(0xff46ce7c),
        icon: Icons.person_add,
        onTap: () {
          acceptApplicantAlert(index);
        },
        title: AppLocalization.of(context)!.accept,
        slideController: _slideController,
      ),
    ];
  }

  Widget _getSlidableWithLists(BuildContext context, int index) {
    return Slidable(
      // key: Key(user.userName!),
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: const SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      enabled: widget.job!.assignee == null,
      child: VerticalListItem(
        applicant: applicantList[index],
      ),
      actions: listActionSlideActions(index),
      secondaryActions: listSecondaryActions(index),
    );
  }
}

class VerticalListItem extends StatelessWidget {
  VerticalListItem({required this.applicant});

  final JobApplicantModel? applicant;

  double rating = 3;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // ChatUserManager().clearChatUserMessageCount(
        //     conversationId: widget.user.conversationId);

        // await Navigator.pushNamed(context, Routes.CHAT_SCREEN,
        //     arguments: {"searchedUser": widget.user});
        // if (mounted) setState(() {});
      },
      child: Container(
          height: 80,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 24,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(24),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: "${applicant!.applicantAvatar}",
                    fit: BoxFit.fitWidth,
                    width: double.infinity,
                    errorWidget: productAndServiceBigErrorWidget,
                  ),
                ),
              ),
              title: Text(
                "${applicant!.applicantName}",
                style: const TextStyle(
                  color: Color(0xff030e36),
                  fontSize: 14,
                  fontFamily: "Open Sans",
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: getRating(
                numberOfRating: applicant!.ratings,
              ),
              trailing: Text("${applicant!.numberOfJobs} Jobs done"),
            ),
          )
          // UserTileForConnection(user: widget.user),
          ),
    );
  }
}
