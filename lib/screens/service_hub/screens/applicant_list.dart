import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/service_hub/auth/service_hub_auth.dart';
import 'package:Slydo/screens/service_hub/models/applicant_list_model.dart';
import 'package:Slydo/screens/service_hub/models/jobs.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../routes/route_constants.dart';

class ApplicantList extends StatefulWidget {
  const ApplicantList({super.key, this.job});
  final JobModel? job;

  @override
  State<ApplicantList> createState() => _ApplicantListState();
}

class _ApplicantListState extends State<ApplicantList>
    with SingleTickerProviderStateMixin {
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
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void getApplicantList() async {
    if (!isLoading) {
      if (listNext != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        final result = await ServiceHubAuthService().getApplicantListData(
            listNext, listPrevious,
            jobId: widget.job!.id);

        // debugPrint("message::$result");

        if (result == null) {
          noApplicantInList = true;

          isLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }
        if (mounted) {
          setState(() {
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
        // _productScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        //   content:
        //       Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
        //   duration: Duration(milliseconds: 500),
        // ));
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
      body: SlidableAutoCloseBehavior(
        closeWhenOpened: true,
        child: SmartRefresher(
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
                if (isLoading)
                  Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: greyBorderColor,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
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
                else
                  const SizedBox.shrink(),
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
      ),
    );
  }

  Flexible getAppicantListView() {
    return Flexible(
      fit: FlexFit.loose,
      child: ListView.builder(
        padding: const EdgeInsets.all(4),
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
      surfaceTintColor: Colors.transparent,
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
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> acceptApplicantAlert(int index) async {
    final bool? result = await showDialogBox(
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
      description: "Are you sure you want to accept this applicant?",
      actionOneText: AppLocalization.of(context)!.accept,
      actionTwoText: AppLocalization.of(context)!.cancel,
    );
    if (result != null && result) {
      final bool done = await ServiceHubAuthService()
          .acceptJobApplicant(jobId: widget.job!.id, data: {
        'applicant': applicantList[index].applicantUsername,
      });
      if (done) {
        showSnackbar(context,
            message: "Applicant accepted for Job Successfully", duration: 1000);
        applicantList.clear();
        getApplicantList();
      } else {
        showSnackbar(context,
            message: "Applicant can not be Accepted. Try again later",
            duration: 1000);
        applicantList.clear();
        getApplicantList();
      }

      setState(() {});
    } else {
      // _showSnackBar(context, AppLocalization.of(context)!.error);
    }
  }

  Future<void> rejectApplicantAlert(int index) async {
    final bool? result = await showDialogBox(
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
      description: "Are you sure you want to reject this applicant?",
      actionOneText: AppLocalization.of(context)!.reject,
      actionTwoText: AppLocalization.of(context)!.cancel,
    );
    if (result != null && result) {
      final bool done = await ServiceHubAuthService()
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
        borderRadius: BorderRadius.circular(5),
        padding: EdgeInsets.zero,
        backgroundColor: mateRed,
        icon: SlydoAppIcon.close_2,
        onPressed: (con) {
          rejectApplicantAlert(index);
        },
        label: "Reject",
      ),
    ];
  }

  List<Widget> listSecondaryActions(int index) {
    return [
      SlideActionButton(
        borderRadius: BorderRadius.circular(5),
        padding: EdgeInsets.zero,
        backgroundColor: const Color(0xff46ce7c),
        icon: Icons.person_add,
        onPressed: (con) {
          acceptApplicantAlert(index);
        },
        label: AppLocalization.of(context)!.accept,
      ),
    ];
  }

  Widget _getSlidableWithLists(BuildContext context, int index) {
    return Slidable(
      enabled: widget.job!.assignee == null,
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: listActionSlideActions(index),
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: listSecondaryActions(index),
      ),
      child: VerticalListItem(
        applicant: applicantList[index],
      ),
    );
  }
}

class VerticalListItem extends StatelessWidget {
  const VerticalListItem({super.key, required this.applicant});

  final JobApplicantModel? applicant;

  final double rating = 3;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.pushNamed(context, Routes.USER_PROFILE,
            arguments: {"searchedUserName": applicant?.applicantUsername});
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
                  fontFamily: "Inter",
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
